import { Router } from 'express';
import { asyncHandler, AppError } from '../middleware/asyncHandler';
import { requireAuth, requireAccepted } from '../middleware/auth';
import {
  searchSkills,
  searchJobs,
  searchCompanies,
  skillDisplayName,
  jobDisplayName,
  getOrCreateSkill,
  getOrCreateJob,
  getOrCreateCompany,
  jobView,
  levelsForLang,
} from '../services/catalog';
import { parseLang } from '../config/languages';
import { catalogView } from '../models/i18n';

export const catalogRouter = Router();

catalogRouter.get(
  '/skills',
  asyncHandler(async (req, res) => {
    const q = typeof req.query.q === 'string' ? req.query.q : '';
    const lang = parseLang(req.query.lang);
    if (!q.trim()) {
      res.json([]);
      return;
    }
    const skills = await searchSkills(q, 10);
    res.json(skills.map((s) => catalogView(s as any, lang)));
  }),
);

catalogRouter.get(
  '/jobs',
  asyncHandler(async (req, res) => {
    const q = typeof req.query.q === 'string' ? req.query.q : '';
    const lang = parseLang(req.query.lang);
    const limit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));
    const jobs = await searchJobs(q, limit);
    res.json(jobs.map((j) => jobView(j, lang)));
  }),
);

catalogRouter.get(
  '/levels',
  asyncHandler(async (req, res) => {
    res.json(levelsForLang(typeof req.query.lang === 'string' ? req.query.lang : undefined));
  }),
);

catalogRouter.get(
  '/companies',
  asyncHandler(async (req, res) => {
    const q = typeof req.query.q === 'string' ? req.query.q : '';
    if (!q.trim()) {
      res.json([]);
      return;
    }
    const companies = await searchCompanies(q, 10);
    res.json(companies.map((c) => ({ id: c.id, name: c.name })));
  }),
);

catalogRouter.post(
  '/skills',
  requireAuth,
  requireAccepted,
  asyncHandler(async (req, res) => {
    const { name, lang } = req.body ?? {};
    if (typeof name !== 'string' || !name.trim()) {
      throw new AppError(400, 'name is required', 'validation_error', { name: 'missing_field' });
    }
    const skill = await getOrCreateSkill({
      name,
      lang: typeof lang === 'string' ? lang : undefined,
      partnerId: req.partner!.id,
    });
    if (!skill) throw new AppError(422, 'Skill was rejected', 'catalog_item_rejected');
    res.json({
      id: skill.id,
      name: skillDisplayName(skill, typeof lang === 'string' ? lang : undefined),
      status: skill.status,
    });
  }),
);

catalogRouter.post(
  '/jobs',
  requireAuth,
  requireAccepted,
  asyncHandler(async (req, res) => {
    const { name, lang } = req.body ?? {};
    if (typeof name !== 'string' || !name.trim()) {
      throw new AppError(400, 'name is required', 'validation_error', { name: 'missing_field' });
    }
    const job = await getOrCreateJob({
      name,
      lang: typeof lang === 'string' ? lang : undefined,
      partnerId: req.partner!.id,
    });
    if (!job) throw new AppError(422, 'Job was rejected', 'catalog_item_rejected');
    res.json({
      id: job.id,
      name: jobDisplayName(job, typeof lang === 'string' ? lang : undefined),
      status: job.status,
    });
  }),
);

catalogRouter.post(
  '/companies',
  requireAuth,
  requireAccepted,
  asyncHandler(async (req, res) => {
    const { name } = req.body ?? {};
    if (typeof name !== 'string' || !name.trim()) {
      throw new AppError(400, 'name is required', 'validation_error', { name: 'missing_field' });
    }
    const company = await getOrCreateCompany({ name, partnerId: req.partner!.id });
    if (!company) throw new AppError(422, 'Company was rejected', 'catalog_item_rejected');
    res.json({ id: company.id, name: company.name, status: company.status });
  }),
);
