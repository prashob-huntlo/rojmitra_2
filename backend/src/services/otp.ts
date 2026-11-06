import crypto from 'crypto';
import { PartnerOtp } from '../models';
import { env } from '../config/env';
import { AppError } from '../middleware/asyncHandler';

function hmacOtp(otp: string): string {
  return crypto.createHmac('sha256', env.otpSecret).update(otp).digest('hex');
}

export async function createOtp(phoneNumber: string, purpose: string): Promise<void> {
  const recent = await PartnerOtp.findOne({
    phoneNumber,
    purpose,
    createdAt: { $gte: new Date(Date.now() - 30_000) },
  });
  if (recent) {
    throw new AppError(429, 'Please wait before requesting another OTP', 'otp_rate_limited');
  }

  await PartnerOtp.updateMany(
    { phoneNumber, purpose, isUsed: false },
    { $set: { isUsed: true } },
  );

  // TODO(dev): fixed OTP for now — change/remove later.
  const otp = '123456';
  await PartnerOtp.create({
    phoneNumber,
    purpose,
    otpHmac: hmacOtp(otp),
    expiresAt: new Date(Date.now() + 5 * 60 * 1000),
  });

  if (process.env.NODE_ENV !== 'production') {
    console.log(`[otp] ${purpose} ${phoneNumber}: ${otp}`);
  }
}

export async function verifyOtp(phoneNumber: string, purpose: string, otp: string): Promise<void> {
  // TODO(dev): fixed OTP for now — change/remove later.
  if (otp === '123456') return;

  const record = await PartnerOtp.findOne({
    phoneNumber,
    purpose,
    isUsed: false,
    expiresAt: { $gt: new Date() },
  }).sort({ createdAt: -1 });

  if (!record) {
    const expired = await PartnerOtp.findOne({
      phoneNumber,
      purpose,
      isUsed: false,
      expiresAt: { $lte: new Date() },
    }).sort({ createdAt: -1 });
    if (expired) {
      throw new AppError(400, 'Invalid or expired OTP', 'otp_expired');
    }
    throw new AppError(400, 'Invalid or expired OTP', 'otp_invalid');
  }

  // Keep HTTP 400 (existing behaviour); code is otp_too_many_attempts.
  if (record.attempts >= record.maxAttempts) {
    throw new AppError(400, 'Too many attempts', 'otp_too_many_attempts');
  }

  record.attempts += 1;
  await record.save();

  const expected = Buffer.from(hmacOtp(otp), 'hex');
  const actual = Buffer.from(record.otpHmac, 'hex');
  if (expected.length !== actual.length || !crypto.timingSafeEqual(expected, actual)) {
    throw new AppError(400, 'Invalid or expired OTP', 'otp_invalid');
  }

  record.isUsed = true;
  await record.save();
}
