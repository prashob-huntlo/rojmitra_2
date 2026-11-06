import { Schema, model } from 'mongoose';

const companySchema = new Schema(
  {
    name: { type: String, required: true },
    nameNormalized: { type: String, required: true, unique: true },
    status: { type: String, enum: ['pending', 'accepted', 'rejected'], default: 'pending' },
    suggestedBy: [{ type: Schema.Types.ObjectId, ref: 'SourcingPartner' }],
    reviewedBy: { type: Schema.Types.ObjectId, ref: 'Admin' },
    reviewedAt: Date,
    mergedInto: { type: Schema.Types.ObjectId, ref: 'Company' },
  },
  { timestamps: true },
);

export const Company = model('Company', companySchema);
