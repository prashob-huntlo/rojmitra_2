import { Schema, model } from 'mongoose';

const otpSchema = new Schema(
  {
    phoneNumber: { type: String, required: true },
    otpHmac: { type: String, required: true },
    purpose: { type: String, required: true },
    attempts: { type: Number, default: 0 },
    maxAttempts: { type: Number, default: 5 },
    expiresAt: { type: Date, required: true },
    isUsed: { type: Boolean, default: false },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

otpSchema.index({ phoneNumber: 1, purpose: 1, isUsed: 1 });
otpSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // Mongo deletes expired OTPs itself

export const PartnerOtp = model('PartnerOtp', otpSchema);
