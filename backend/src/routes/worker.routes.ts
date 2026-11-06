import crypto from 'crypto';
import { Router } from 'express';
import { Types } from 'mongoose';
import { Worker, WorkerAvailabilityLog, Skill, Company, Job } from '../models';
import { asyncHandler, AppError } from '../middleware/asyncHandler';
import { requireAuth, requireAccepted } from '../middleware/auth';
import { skillDisplayName } from '../services/catalog';
import { catalogView } from '../models/i18n';
import { parseLang } from '../config/languages';
import { isLevel } from '../config/levels';
import { env } from '../config/env';
import { isOurObjectKey } from '../services/gcs';

export const workerRouter = Router();

workerRouter.use(requireAuth, requireAccepted);

function assertDocumentObjectKeys(documents: unknown) {
  if (documents == null) return;
  if (typeof documents !== 'object' || Array.isArray(documents)) {
    throw new AppError(400, 'documents must be an object', 'validation_error', {
      documents: 'invalid_type',
    });
  }
  for (const [field, value] of Object.entries(documents as Record<string, unknown>)) {
    if (value == null || value === '') continue;
    if (typeof value !== 'string' || !isOurObjectKey(value)) {
      throw new AppError(
        400,
        `${field} must be a GCS object key from /api/uploads/signed-url`,
        'validation_error',
        { [field]: 'invalid_object_key' },
      );
    }
  }
}

function normalizeIdNumber(idNumber: string): string {
  return idNumber.trim().replace(/[\s-]/g, '').toLowerCase();
}

function assertIdNumber(idType: string, idNumber: string) {
  const raw = idNumber.trim().replace(/[\s-]/g, '');
  if (idType === 'aadhaar') {
    if (!/^\d{12}$/.test(raw)) {
      throw new AppError(400, 'Aadhaar must be 12 digits', 'validation_error', {
        idNumber: 'invalid_aadhaar',
      });
    }
    return;
  }
  if (idType === 'pan') {
    if (!/^[A-Z]{5}[0-9]{4}[A-Z]$/i.test(raw)) {
      throw new AppError(400, 'PAN must be like ABCDE1234F', 'validation_error', {
        idNumber: 'invalid_pan',
      });
    }
  }
}

function hashIdentity(idNumber: string): string {
  return crypto
    .createHmac('sha256', env.identityHashSecret)
    .update(normalizeIdNumber(idNumber))
    .digest('hex');
}

function maskIdentity(idNumber: string): string {
  const n = normalizeIdNumber(idNumber);
  const last4 = n.slice(-4);
  return `${'X'.repeat(Math.max(0, n.length - 4))}${last4}`;
}

function isObjectId(v: unknown): v is string {
  return typeof v === 'string' && Types.ObjectId.isValid(v);
}

function stripIdentityHash(doc: InstanceType<typeof Worker> | Record<string, unknown>) {
  const o =
    typeof (doc as any).toObject === 'function'
      ? (doc as any).toObject({ virtuals: true })
      : { ...doc };
  delete o.identityHash;
  delete o.__v;
  return o;
}

function refName(doc: any, lang?: string): { id: string; name: string } | null {
  if (!doc || !doc._id) return null;
  const id = doc.id ?? String(doc._id);
  if (doc.name != null && typeof doc.name === 'string' && !doc.names) {
    return { id, name: doc.name };
  }
  if (doc.names) {
    const view = catalogView(doc, parseLang(lang));
    return { id, name: String(view.name ?? skillDisplayName(doc, lang)) };
  }
  return { id, name: skillDisplayName(doc, lang) };
}

function formatWorker(doc: InstanceType<typeof Worker>, lang?: string) {
  const o = stripIdentityHash(doc);
  if (o.jobId && typeof o.jobId === 'object' && o.jobId._id) {
    o.jobId = refName(o.jobId, lang);
    // Back-compat for clients still reading primaryTrade as the trade label.
    o.primaryTrade = o.jobId;
  }
  if (Array.isArray(o.skillIds)) {
    o.skillIds = o.skillIds
      .map((s: any) => (s && s._id ? refName(s, lang) : null))
      .filter(Boolean);
  }
  if (Array.isArray(o.workExperiences)) {
    o.workExperiences = o.workExperiences.map((ex: any) => {
      const row = { ...ex };
      if (row.companyId && row.companyId._id) row.companyId = refName(row.companyId, lang);
      if (row.skillId && row.skillId._id) row.skillId = refName(row.skillId, lang);
      return row;
    });
  }
  return o;
}

async function assertSkillIds(ids: string[]) {
  for (const id of ids) {
    if (!isObjectId(id)) {
      throw new AppError(400, `Invalid skill id: ${id}`, 'validation_error', { skillId: 'invalid_id' });
    }
    const skill = await Skill.findById(id);
    if (!skill || skill.status === 'rejected') {
      throw new AppError(400, `Invalid skill id: ${id}`, 'validation_error', { skillId: 'invalid_id' });
    }
  }
}

async function assertCompanyId(id: string) {
  if (!isObjectId(id)) {
    throw new AppError(400, `Invalid company id: ${id}`, 'validation_error', { companyId: 'invalid_id' });
  }
  const company = await Company.findById(id);
  if (!company || company.status === 'rejected') {
    throw new AppError(400, `Invalid company id: ${id}`, 'validation_error', { companyId: 'invalid_id' });
  }
}

async function resolveJobSkillIds(resolvedJobId: unknown): Promise<{ jobId: string; skillIdList: string[] }> {
  if (!isObjectId(resolvedJobId)) {
    throw new AppError(400, 'jobId is required', 'validation_error', { jobId: 'missing_field' });
  }
  const job = await Job.findById(resolvedJobId);
  if (!job || job.status === 'rejected') {
    throw new AppError(400, 'Invalid jobId', 'validation_error', { jobId: 'invalid_id' });
  }
  const skillIdList = (job.skills ?? []).map((s) => String(s));
  await assertSkillIds(skillIdList);
  return { jobId: resolvedJobId, skillIdList };
}

async function normalizeWorkExperiences(
  workExperiences: unknown,
  partner: { id: string; role: string },
) {
  const experiencesIn = Array.isArray(workExperiences) ? workExperiences : [];
  const experiences = [];
  for (const ex of experiencesIn) {
    if (!ex || typeof ex !== 'object') {
      throw new AppError(400, 'Invalid workExperiences entry', 'validation_error', {
        workExperiences: 'missing_field',
      });
    }
    const row = ex as Record<string, unknown>;
    await assertCompanyId(String(row.companyId));
    if (row.skillId != null) {
      if (!isObjectId(row.skillId)) {
        throw new AppError(400, 'Invalid skillId in workExperiences', 'validation_error', {
          skillId: 'invalid_id',
        });
      }
      await assertSkillIds([String(row.skillId)]);
    }
    if (row.level != null && !isLevel(row.level)) {
      throw new AppError(400, 'Invalid level', 'validation_error', { level: 'invalid_value' });
    }
    if (row.yearsOfExperience != null) {
      if (typeof row.yearsOfExperience !== 'number' || row.yearsOfExperience < 0) {
        throw new AppError(400, 'yearsOfExperience must be >= 0', 'validation_error', {
          yearsOfExperience: 'invalid_number',
        });
      }
    }
    experiences.push({
      companyId: row.companyId,
      skillId: row.skillId,
      level: row.level,
      yearsOfExperience: row.yearsOfExperience,
      addedBy: { partnerId: partner.id, role: partner.role },
    });
  }
  return experiences;
}

async function loadOwnedWorker(id: string, partnerId: string, lang?: string) {
  const worker = await Worker.findOne({
    _id: id,
    'registeredBy.partnerId': partnerId,
  })
    .populate('jobId')
    .populate('skillIds')
    .populate('workExperiences.companyId')
    .populate('workExperiences.skillId');
  if (!worker) throw new AppError(404, 'Worker not found', 'not_found');
  return formatWorker(worker, lang);
}

workerRouter.post(
  '/',
  asyncHandler(async (req, res) => {
    const body = req.body ?? {};
    const {
      idType, idNumber, panNumber, fullName, dateOfBirth, gender, phoneNumber,
      hasDisability, disabilityDetails,
      permanentAddress, presentSameAsPermanent, presentAddress, documents,
      registrationLocation, dailyWageExpected, jobId, workExperiences,
    } = body;
    // Accept legacy primaryTrade as jobId alias during client migration.
    const resolvedJobId = jobId ?? body.primaryTrade;

    if (typeof fullName !== 'string' || !fullName.trim()) {
      throw new AppError(400, 'fullName is required', 'validation_error', { fullName: 'missing_field' });
    }
    if (typeof idType !== 'string' || !idType.trim()) {
      throw new AppError(400, 'idType is required', 'validation_error', { idType: 'missing_field' });
    }
    if (typeof idNumber !== 'string' || !idNumber.trim()) {
      throw new AppError(400, 'idNumber is required', 'validation_error', { idNumber: 'missing_field' });
    }
    assertIdNumber(idType.trim(), idNumber);

    if (dailyWageExpected != null) {
      if (typeof dailyWageExpected !== 'number' || dailyWageExpected < 0) {
        throw new AppError(400, 'dailyWageExpected must be a number >= 0', 'validation_error', {
          dailyWageExpected: 'invalid_number',
        });
      }
    }

    const { jobId: validatedJobId, skillIdList } = await resolveJobSkillIds(resolvedJobId);
    const experiences = await normalizeWorkExperiences(workExperiences, {
      id: req.partner!.id,
      role: req.partner!.role,
    });

    const identityHash = hashIdentity(idNumber);
    const maskedIdentity = maskIdentity(idNumber);
    assertDocumentObjectKeys(documents);

    let worker;
    try {
      worker = await Worker.create({
        idType: idType.trim(),
        identityHash,
        maskedIdentity,
        panNumber,
        fullName: fullName.trim(),
        dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : undefined,
        gender,
        phoneNumber,
        hasDisability: Boolean(hasDisability),
        disabilityDetails:
          typeof disabilityDetails === 'string' && disabilityDetails.trim()
            ? disabilityDetails.trim()
            : undefined,
        permanentAddress,
        presentSameAsPermanent: presentSameAsPermanent ?? false,
        presentAddress,
        documents,
        registrationLocation,
        dailyWageExpected,
        jobId: validatedJobId,
        skillIds: skillIdList,
        workExperiences: experiences,
        isReadyToWork: false,
        registeredBy: { partnerId: req.partner!.id, role: req.partner!.role },
      });
    } catch (err: any) {
      if (err?.code === 11000) {
        throw new AppError(409, 'Worker already registered', 'duplicate_worker');
      }
      throw err;
    }

    res.status(201).json(stripIdentityHash(worker));
  }),
);

workerRouter.get(
  '/',
  asyncHandler(async (req, res) => {
    const filter: Record<string, unknown> = {
      'registeredBy.partnerId': req.partner!.id,
    };
    if (typeof req.query.state === 'string' && req.query.state) {
      filter['permanentAddress.state'] = req.query.state;
    }
    if (typeof req.query.district === 'string' && req.query.district) {
      filter['permanentAddress.district'] = req.query.district;
    }
    if (req.query.isReadyToWork === 'true') filter.isReadyToWork = true;
    if (req.query.isReadyToWork === 'false') filter.isReadyToWork = false;
    if (req.query.hasDisability === 'true') filter.hasDisability = true;
    if (req.query.hasDisability === 'false') filter.hasDisability = false;
    if (typeof req.query.q === 'string' && req.query.q.trim()) {
      filter.fullName = { $regex: req.query.q.trim(), $options: 'i' };
    }
    if (typeof req.query.skillId === 'string' && req.query.skillId) {
      if (!isObjectId(req.query.skillId)) {
        throw new AppError(400, 'Invalid skillId', 'validation_error', { skillId: 'invalid_id' });
      }
      filter.skillIds = req.query.skillId;
    }
    if (typeof req.query.jobId === 'string' && req.query.jobId) {
      if (!isObjectId(req.query.jobId)) {
        throw new AppError(400, 'Invalid jobId', 'validation_error', { jobId: 'invalid_id' });
      }
      filter.jobId = req.query.jobId;
    }

    const page = Math.max(1, Number(req.query.page) || 1);
    const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));
    const skip = (page - 1) * limit;

    const lang = typeof req.query.lang === 'string' ? req.query.lang : undefined;
    const [rows, total] = await Promise.all([
      Worker.find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('jobId')
        .populate('skillIds')
        .populate('workExperiences.companyId')
        .populate('workExperiences.skillId'),
      Worker.countDocuments(filter),
    ]);

    res.json({
      items: rows.map((r) => formatWorker(r, lang)),
      page,
      limit,
      total,
    });
  }),
);

workerRouter.get(
  '/:id',
  asyncHandler(async (req, res) => {
    if (!isObjectId(req.params.id)) throw new AppError(404, 'Worker not found', 'not_found');
    const lang = typeof req.query.lang === 'string' ? req.query.lang : undefined;

    const worker = await Worker.findOne({
      _id: req.params.id,
      'registeredBy.partnerId': req.partner!.id,
    })
      .populate('jobId')
      .populate('skillIds')
      .populate('workExperiences.companyId')
      .populate('workExperiences.skillId');

    if (!worker) throw new AppError(404, 'Worker not found', 'not_found');
    res.json(formatWorker(worker, lang));
  }),
);

workerRouter.patch(
  '/:id',
  asyncHandler(async (req, res) => {
    if (!isObjectId(req.params.id)) throw new AppError(404, 'Worker not found', 'not_found');

    const worker = await Worker.findOne({
      _id: req.params.id,
      'registeredBy.partnerId': req.partner!.id,
    });
    if (!worker) throw new AppError(404, 'Worker not found', 'not_found');

    const body = req.body ?? {};
    const {
      fullName,
      dateOfBirth,
      gender,
      phoneNumber,
      hasDisability,
      disabilityDetails,
      permanentAddress,
      presentSameAsPermanent,
      presentAddress,
      documents,
      registrationLocation,
      dailyWageExpected,
      jobId,
      workExperiences,
    } = body;
    const resolvedJobId = jobId ?? body.primaryTrade;

    // Identity (idType / idNumber) is immutable after registration.
    if (typeof fullName === 'string' && fullName.trim()) {
      worker.fullName = fullName.trim();
    } else if (fullName != null) {
      throw new AppError(400, 'fullName is required', 'validation_error', { fullName: 'missing_field' });
    }

    if (dateOfBirth !== undefined) {
      worker.dateOfBirth = dateOfBirth ? new Date(dateOfBirth) : undefined;
    }
    if (gender !== undefined) worker.gender = gender;
    if (phoneNumber !== undefined) worker.phoneNumber = phoneNumber;
    if (hasDisability !== undefined) {
      worker.hasDisability = Boolean(hasDisability);
      if (!worker.hasDisability) worker.disabilityDetails = undefined;
    }
    if (disabilityDetails !== undefined) {
      worker.disabilityDetails =
        typeof disabilityDetails === 'string' && disabilityDetails.trim()
          ? disabilityDetails.trim()
          : undefined;
    }

    if (permanentAddress !== undefined) worker.permanentAddress = permanentAddress;
    if (presentSameAsPermanent !== undefined) {
      worker.presentSameAsPermanent = Boolean(presentSameAsPermanent);
    }
    if (presentAddress !== undefined) worker.presentAddress = presentAddress;
    if (registrationLocation !== undefined) {
      worker.registrationLocation = registrationLocation;
    }

    if (dailyWageExpected != null) {
      if (typeof dailyWageExpected !== 'number' || dailyWageExpected < 0) {
        throw new AppError(400, 'dailyWageExpected must be a number >= 0', 'validation_error', {
          dailyWageExpected: 'invalid_number',
        });
      }
      worker.dailyWageExpected = dailyWageExpected;
    }

    if (resolvedJobId !== undefined) {
      const { jobId: validatedJobId, skillIdList } = await resolveJobSkillIds(resolvedJobId);
      worker.jobId = validatedJobId as any;
      worker.skillIds = skillIdList as any;
    }

    if (workExperiences !== undefined) {
      worker.workExperiences = (await normalizeWorkExperiences(workExperiences, {
        id: req.partner!.id,
        role: req.partner!.role,
      })) as any;
    }

    if (documents !== undefined) {
      assertDocumentObjectKeys(documents);
      const existingDocs = worker.documents
        ? {
            primaryIdFrontUrl: worker.documents.primaryIdFrontUrl,
            primaryIdBackUrl: worker.documents.primaryIdBackUrl,
            panCardUrl: worker.documents.panCardUrl,
            photoUrl: worker.documents.photoUrl,
          }
        : {};
      worker.documents = {
        ...existingDocs,
        ...(documents as Record<string, unknown>),
      } as typeof worker.documents;
    }

    await worker.save();

    const lang = typeof req.query.lang === 'string' ? req.query.lang : undefined;
    res.json(await loadOwnedWorker(req.params.id, req.partner!.id, lang));
  }),
);

workerRouter.patch(
  '/:id/availability',
  asyncHandler(async (req, res) => {
    if (!isObjectId(req.params.id)) throw new AppError(404, 'Worker not found', 'not_found');
    const { isReadyToWork } = req.body ?? {};
    if (typeof isReadyToWork !== 'boolean') {
      throw new AppError(400, 'isReadyToWork must be a boolean', 'validation_error', {
        isReadyToWork: 'missing_field',
      });
    }

    const worker = await Worker.findOne({
      _id: req.params.id,
      'registeredBy.partnerId': req.partner!.id,
    });
    if (!worker) throw new AppError(404, 'Worker not found', 'not_found');

    if (worker.isReadyToWork === isReadyToWork) {
      res.json(stripIdentityHash(worker));
      return;
    }

    const previousStatus = worker.isReadyToWork;
    worker.isReadyToWork = isReadyToWork;
    worker.statusUpdatedAt = new Date();
    await worker.save();

    await WorkerAvailabilityLog.create({
      workerId: worker._id,
      previousStatus,
      newStatus: isReadyToWork,
      updatedBy: { partnerId: req.partner!.id, role: req.partner!.role },
    });

    res.json(stripIdentityHash(worker));
  }),
);
