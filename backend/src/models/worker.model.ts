import { Schema, model } from 'mongoose';
import { LEVEL_KEYS } from '../config/levels';

const address = new Schema(
  { line: String, villageOrTown: String, district: String, state: String, pincode: String },
  { _id: false },
);

const workExperience = new Schema({
  companyId: { type: Schema.Types.ObjectId, ref: 'Company', required: true },
  skillId: { type: Schema.Types.ObjectId, ref: 'Skill' },
  /** Canonical experience key from config/levels.ts */
  level: { type: String, enum: LEVEL_KEYS },
  yearsOfExperience: Number,
  addedBy: {
    partnerId: { type: Schema.Types.ObjectId, ref: 'SourcingPartner' },
    role: String,
  },
});

const workerSchema = new Schema(
  {
    idType: { type: String, required: true },
    identityHash: { type: String, required: true },
    maskedIdentity: { type: String, required: true },
    panNumber: String,

    fullName: { type: String, required: true },
    dateOfBirth: Date,
    gender: String,
    phoneNumber: String,

    /** Person with disability (PwD). Optional details when true. */
    hasDisability: { type: Boolean, default: false },
    disabilityDetails: { type: String, trim: true },

    permanentAddress: address,
    presentAddress: address,
    presentSameAsPermanent: { type: Boolean, default: false },

    isReadyToWork: { type: Boolean, default: false },
    statusUpdatedAt: Date,

    dailyWageExpected: Number,
    /** Job (trade) selected at registration — skills are taken from Job.skills */
    jobId: { type: Schema.Types.ObjectId, ref: 'Job' },
    skillIds: [{ type: Schema.Types.ObjectId, ref: 'Skill' }],

    registeredBy: {
      partnerId: { type: Schema.Types.ObjectId, ref: 'SourcingPartner', required: true },
      role: { type: String, required: true },
    },
    registrationLocation: { type: { type: String, enum: ['Point'] }, coordinates: [Number] },

    documents: {
      primaryIdFrontUrl: String,
      primaryIdBackUrl: String,
      panCardUrl: String,
      photoUrl: String,
    },
    workExperiences: [workExperience],
  },
  { timestamps: true },
);

workerSchema.index({ idType: 1, identityHash: 1 }, { unique: true });
workerSchema.index({ 'permanentAddress.state': 1, 'permanentAddress.district': 1 });
workerSchema.index({ isReadyToWork: 1, skillIds: 1 });
workerSchema.index({ skillIds: 1 });
workerSchema.index({ jobId: 1 });
workerSchema.index({ 'workExperiences.companyId': 1 });
workerSchema.index({ 'registeredBy.partnerId': 1 });

export const Worker = model('Worker', workerSchema, 'workers');
