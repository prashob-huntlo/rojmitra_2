// Sample partner/company/worker data for local/dev.
// Does NOT wipe the catalog (categories / skills / jobs) — run import:catalog for that.
import bcrypt from 'bcryptjs';
import mongoose, { Types } from 'mongoose';
import { connectToMongoDB, disconnectFromMongoDB } from '../config/db';
import {
  Admin, Company, Job, Worker, WorkerAvailabilityLog, SourcingPartner, PartnerOtp,
} from '../models';
import { normalize } from '../services/catalog';

const id = () => new Types.ObjectId();
const cscId = id(), cmcId = id(), awcId = id(), ngoId = id(), adminId = id();
const acmeId = id(), shaktiId = id(), pendingCompanyId = id();
const hash = (c: string) => c.repeat(64);

/** Dev password for all seeded accepted partners: Password1 */
const DEV_PASSWORD = 'Password1';

async function buildPartners(passwordHash: string) {
  return [
    {
      _id: cscId, role: 'csc', fullName: 'Ramesh Patel', phoneNumber: '9876500001',
      email: 'ramesh.csc@example.com', passwordHash, status: 'accepted', state: 'Gujarat', district: 'Ahmedabad',
      subDistrict: 'Daskroi', pincode: '382430',
      profile: {
        vleId: 'VLE-GJ-1001', kioskName: 'Patel Digital Seva', kioskAddress: 'Main Bazaar, Daskroi',
        certificateDocUrl: 'https://example.com/docs/csc1001.pdf',
        location: { type: 'Point', coordinates: [72.6869, 22.9676] },
      },
    },
    {
      _id: cmcId, role: 'cmc', fullName: 'Sunita Devi', phoneNumber: '9876500002',
      email: 'sunita.cmc@example.com', passwordHash, status: 'accepted', state: 'Bihar', district: 'Patna',
      subDistrict: 'Danapur', pincode: '801503',
      profile: {
        mobilizerId: 'MOB-BR-2002', agencyOrPartnerName: 'Rozgar Seva Trust',
        supervisorName: 'Anil Kumar', supervisorPhone: '9876500099', assignedPanchayat: 'Danapur Khagaul',
      },
    },
    {
      _id: awcId, role: 'anganwadi', fullName: 'Lakshmi Bai', phoneNumber: '9876500003',
      email: 'lakshmi.awc@example.com', passwordHash, status: 'pending', state: 'Maharashtra', district: 'Pune',
      pincode: '412205',
      profile: { awcCode: 'AWC-MH-3003', centerName: 'Shivaji Nagar AWC', sectorCircle: 'Haveli-2', cdpoOfficeName: 'CDPO Haveli' },
    },
    {
      _id: ngoId, role: 'gov_ngo', fullName: 'Dr. Meera Iyer', phoneNumber: '9876500004',
      email: 'meera.ngo@example.com', passwordHash, status: 'accepted', state: 'Karnataka', district: 'Bengaluru Urban',
      pincode: '560001',
      profile: {
        organizationName: 'Skill Bharat Foundation', registrationOrDarpanId: 'KA/2020/0012345',
        designation: 'Program Director', jurisdictionLevel: 'state',
      },
    },
  ];
}

const companies = [
  {
    _id: acmeId, name: 'Acme Builders', nameNormalized: normalize('Acme Builders'),
    status: 'accepted', suggestedBy: [cscId],
  },
  {
    _id: shaktiId, name: 'Shakti Infra', nameNormalized: normalize('Shakti Infra'),
    status: 'accepted', suggestedBy: [cmcId],
  },
  {
    _id: pendingCompanyId, name: 'Local Contractors Co', nameNormalized: normalize('Local Contractors Co'),
    status: 'pending', suggestedBy: [ngoId],
  },
];

const addr = (district: string, state: string, pincode: string) => ({
  line: '12, Gandhi Road', villageOrTown: district, district, state, pincode,
});

async function dropLegacyCollections() {
  const db = mongoose.connection.db;
  if (!db) return;
  for (const name of [
    'lab' + 'orers',
    'lab' + 'oravailabilitylogs',
    'people',
    'person_availability_logs',
  ]) {
    try {
      await db.dropCollection(name);
    } catch (err: any) {
      if (err?.codeName !== 'NamespaceNotFound' && err?.message !== 'ns not found' && !/ns not found/i.test(err?.message ?? '')) {
        if (err?.code !== 26) throw err;
      }
    }
  }
}

async function main() {
  await connectToMongoDB();
  await dropLegacyCollections();
  await Promise.all([
    Worker.deleteMany({}), WorkerAvailabilityLog.deleteMany({}),
    SourcingPartner.deleteMany({}), PartnerOtp.deleteMany({}),
    Admin.deleteMany({}), Company.deleteMany({}),
  ]);

  const sampleJobs = await Job.find({ status: 'accepted' }).limit(3);
  const job0 = sampleJobs[0];
  const job1 = sampleJobs[1] ?? sampleJobs[0];
  const job2 = sampleJobs[2] ?? sampleJobs[0];

  const workers = [
    {
      _id: id(), idType: 'aadhaar', identityHash: hash('a'), maskedIdentity: 'XXXX-XXXX-1234',
      fullName: 'Mohan Singh', dateOfBirth: new Date('1990-04-12'), gender: 'male', phoneNumber: '9000000001',
      permanentAddress: addr('Ahmedabad', 'Gujarat', '382430'), presentSameAsPermanent: true,
      isReadyToWork: true, statusUpdatedAt: new Date(),
      jobId: job0?._id,
      skillIds: job0?.skills ?? [],
      registeredBy: { partnerId: cscId, role: 'csc' },
      registrationLocation: { type: 'Point', coordinates: [72.6869, 22.9676] },
      documents: { primaryIdFrontUrl: 'https://example.com/m1/front.jpg', primaryIdBackUrl: 'https://example.com/m1/back.jpg', photoUrl: 'https://example.com/m1/photo.jpg' },
    },
    {
      _id: id(), idType: 'aadhaar', identityHash: hash('b'), maskedIdentity: 'XXXX-XXXX-5678',
      panNumber: 'ABCDE1234F', fullName: 'Geeta Kumari', dateOfBirth: new Date('1995-09-30'), gender: 'female',
      phoneNumber: '9000000002',
      permanentAddress: addr('Patna', 'Bihar', '801503'),
      presentAddress: addr('Pune', 'Maharashtra', '411001'), presentSameAsPermanent: false,
      isReadyToWork: false, statusUpdatedAt: new Date(),
      dailyWageExpected: 550,
      jobId: job1?._id,
      skillIds: job1?.skills ?? [],
      registeredBy: { partnerId: cmcId, role: 'cmc' },
      documents: { primaryIdFrontUrl: 'https://example.com/g2/front.jpg', panCardUrl: 'https://example.com/g2/pan.jpg' },
    },
    {
      _id: id(), idType: 'voter_id', identityHash: hash('c'), maskedIdentity: 'XXXXXX7890',
      fullName: 'Suresh Yadav', dateOfBirth: new Date('1987-01-05'), gender: 'male', phoneNumber: '9000000003',
      permanentAddress: addr('Pune', 'Maharashtra', '412205'), presentSameAsPermanent: true,
      isReadyToWork: true, statusUpdatedAt: new Date(),
      dailyWageExpected: 900,
      jobId: job2?._id,
      skillIds: job2?.skills ?? [],
      registeredBy: { partnerId: ngoId, role: 'gov_ngo' },
      workExperiences: job2
        ? [{
            companyId: acmeId,
            skillId: job2.skills?.[0],
            level: 'skilled',
            yearsOfExperience: 12,
            addedBy: { partnerId: ngoId, role: 'gov_ngo' },
          }]
        : [],
    },
  ];

  const passwordHash = await bcrypt.hash(DEV_PASSWORD, 10);

  await Admin.create({
    _id: adminId, name: 'Platform Admin', email: 'admin@example.com',
    passwordHash,
  });
  await SourcingPartner.insertMany(await buildPartners(passwordHash));
  console.log(`Partner password (dev): ${DEV_PASSWORD}`);
  await Company.insertMany(companies);
  await Worker.insertMany(workers);
  await WorkerAvailabilityLog.insertMany([
    { workerId: workers[0]._id, previousStatus: false, newStatus: true, updatedBy: { partnerId: cscId, role: 'csc' } },
    { workerId: workers[1]._id, previousStatus: true, newStatus: false, updatedBy: { partnerId: cmcId, role: 'cmc' } },
    { workerId: workers[2]._id, previousStatus: false, newStatus: true, updatedBy: { partnerId: ngoId, role: 'gov_ngo' } },
  ]);
  await PartnerOtp.create({
    phoneNumber: '9876500003', otpHmac: 'dummy-hmac-not-a-real-otp', purpose: 'signup',
    expiresAt: new Date(Date.now() + 10 * 60 * 1000),
  });

  console.log(
    `Seeded: 1 admin, 4 partners, 3 companies, 3 workers (linked to ${sampleJobs.length} catalog jobs)`,
  );
  if (!sampleJobs.length) {
    console.warn('No accepted jobs found — run npm run import:catalog -- --reset first');
  }
}

main()
  .catch((err) => { console.error(err); process.exitCode = 1; })
  .finally(disconnectFromMongoDB);
