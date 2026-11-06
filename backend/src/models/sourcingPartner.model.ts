import { Schema, model } from 'mongoose';

// One collection for every partner type. `role` says which type it is and
// `profile` holds that type's own fields (replaces the 4 *_profiles tables):
//   csc:       { vleId, kioskName, kioskAddress, certificateDocUrl, location }
//   cmc:       { mobilizerId, agencyOrPartnerName, supervisorName, supervisorPhone, assignedPanchayat }
//   anganwadi: { awcCode, centerName, sectorCircle, cdpoOfficeName }
//   gov_ngo:   { organizationName, registrationOrDarpanId, designation, jurisdictionLevel }
// Per-role validation belongs in the service layer, once signup is built.

const address = new Schema(
  { line: String, villageOrTown: String, district: String, state: String, pincode: String },
  { _id: false },
);

const partnerSchema = new Schema(
  {
    role: { type: String, required: true, enum: ['csc', 'cmc', 'anganwadi', 'gov_ngo'] },
    fullName: { type: String, required: true },
    phoneNumber: { type: String, required: true, unique: true },
    /** Optional — sparse unique so missing/empty emails don't collide. */
    email: { type: String, unique: true, sparse: true, lowercase: true },
    passwordHash: { type: String, select: false },
    /** Optional profile photo — GCS object key from /api/uploads/signed-url. */
    avatarUrl: String,
    status: { type: String, enum: ['pending', 'accepted', 'rejected'], default: 'pending' },
    reviewedBy: { type: Schema.Types.ObjectId, ref: 'Admin' },
    reviewedAt: Date,
    rejectionReason: String,
    permanentAddress: address,
    presentAddress: address,
    presentSameAsPermanent: { type: Boolean, default: false },
    /** Mirrored from permanentAddress for existing filters/indexes. */
    state: String,
    district: String,
    subDistrict: String,
    pincode: String,
    profile: Schema.Types.Mixed,
  },
  { timestamps: true },
);

partnerSchema.index({ role: 1, state: 1, district: 1 });

export const SourcingPartner = model('SourcingPartner', partnerSchema);
