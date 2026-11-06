import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { SourcingPartner } from '../models';
import { asyncHandler, AppError } from '../middleware/asyncHandler';
import { partnerMeJson, requireAuth, toAuthPartner } from '../middleware/auth';
import { createOtp, verifyOtp } from '../services/otp';
import { env } from '../config/env';
import { isOurObjectKey } from '../services/gcs';

export const authRouter = Router();

const ROLES = ['csc', 'cmc', 'anganwadi', 'gov_ngo'] as const;

type AddressInput = {
  line: string;
  villageOrTown: string;
  district: string;
  state: string;
  pincode: string;
};

function parseAddress(raw: unknown, field: string): AddressInput {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) {
    throw new AppError(400, `${field} is required`, 'validation_error', { [field]: 'missing_field' });
  }
  const o = raw as Record<string, unknown>;
  const line = typeof o.line === 'string' ? o.line.trim() : '';
  const villageOrTown = typeof o.villageOrTown === 'string' ? o.villageOrTown.trim() : '';
  const district = typeof o.district === 'string' ? o.district.trim() : '';
  const state = typeof o.state === 'string' ? o.state.trim() : '';
  const pincode = typeof o.pincode === 'string' ? o.pincode.trim() : '';
  if (!line) {
    throw new AppError(400, `${field}.line is required`, 'validation_error', { [`${field}.line`]: 'missing_field' });
  }
  if (!villageOrTown) {
    throw new AppError(400, `${field}.villageOrTown is required`, 'validation_error', {
      [`${field}.villageOrTown`]: 'missing_field',
    });
  }
  if (!district) {
    throw new AppError(400, `${field}.district is required`, 'validation_error', {
      [`${field}.district`]: 'missing_field',
    });
  }
  if (!state) {
    throw new AppError(400, `${field}.state is required`, 'validation_error', { [`${field}.state`]: 'missing_field' });
  }
  if (!/^\d{6}$/.test(pincode)) {
    throw new AppError(400, `${field}.pincode must be 6 digits`, 'validation_error', {
      [`${field}.pincode`]: 'invalid_pincode',
    });
  }
  return { line, villageOrTown, district, state, pincode };
}

/** Accept full permanentAddress, or legacy flat state/district/pincode. */
function resolveSignupAddresses(body: Record<string, unknown>): {
  permanentAddress: AddressInput;
  presentAddress: AddressInput;
  presentSameAsPermanent: boolean;
} {
  const same = Boolean(body.presentSameAsPermanent ?? true);
  let permanent: AddressInput;
  if (body.permanentAddress != null) {
    permanent = parseAddress(body.permanentAddress, 'permanentAddress');
  } else {
    // Legacy signup fields → thin permanent address.
    const state = typeof body.state === 'string' ? body.state.trim() : '';
    const district = typeof body.district === 'string' ? body.district.trim() : '';
    const pincode = typeof body.pincode === 'string' ? body.pincode.trim() : '';
    const line = typeof body.subDistrict === 'string' && body.subDistrict.trim()
      ? body.subDistrict.trim()
      : '—';
    if (!state || !district || !/^\d{6}$/.test(pincode)) {
      throw new AppError(400, 'permanentAddress is required', 'validation_error', {
        permanentAddress: 'missing_field',
      });
    }
    permanent = {
      line,
      villageOrTown: '—',
      district,
      state,
      pincode,
    };
  }
  const present = same
    ? permanent
    : parseAddress(body.presentAddress, 'presentAddress');
  return {
    permanentAddress: permanent,
    presentAddress: present,
    presentSameAsPermanent: same,
  };
}

function partnerAuthResponse(partner: { id: string; role: string; fullName: string; status: string }) {
  const token = jwt.sign(
    { sub: partner.id, role: partner.role },
    env.jwtSecret,
    { expiresIn: '7d' },
  );
  return {
    token,
    partner: {
      id: partner.id,
      role: partner.role,
      fullName: partner.fullName,
      status: partner.status,
    },
  };
}

const PROFILE_REQUIRED: Record<(typeof ROLES)[number], string[]> = {
  csc: ['vleId', 'kioskName'],
  cmc: ['agencyOrPartnerName', 'supervisorName', 'supervisorPhone'],
  anganwadi: ['awcCode', 'centerName'],
  gov_ngo: ['organizationName', 'designation'],
};

function isTenDigitPhone(phone: unknown): phone is string {
  return typeof phone === 'string' && /^[6-9]\d{9}$/.test(phone);
}

function normalizeOptionalEmail(email: unknown): string | undefined {
  if (typeof email !== 'string') return undefined;
  const trimmed = email.trim().toLowerCase();
  if (!trimmed) return undefined;
  if (!trimmed.includes('@') || !trimmed.includes('.')) {
    throw new AppError(400, 'email is invalid', 'validation_error', { email: 'invalid_email' });
  }
  return trimmed;
}

function assertRoleProfile(
  role: (typeof ROLES)[number],
  profile: Record<string, unknown>,
  ownPhone: string,
): void {
  for (const key of PROFILE_REQUIRED[role]) {
    const val = profile[key];
    if (typeof val !== 'string' || !val.trim()) {
      throw new AppError(400, `profile.${key} is required`, 'validation_error', {
        [`profile.${key}`]: 'missing_field',
      });
    }
  }

  if (role === 'cmc') {
    const supervisorPhone = String(profile.supervisorPhone ?? '').trim();
    if (!isTenDigitPhone(supervisorPhone)) {
      throw new AppError(400, 'profile.supervisorPhone must be a valid 10-digit mobile', 'validation_error', {
        'profile.supervisorPhone': 'invalid_phone',
      });
    }
    if (supervisorPhone === ownPhone) {
      throw new AppError(
        400,
        'Supervisor phone must be different from your mobile number',
        'validation_error',
        { 'profile.supervisorPhone': 'same_as_own_phone' },
      );
    }
    profile.supervisorPhone = supervisorPhone;
    if (typeof profile.mobilizerId === 'string') {
      profile.mobilizerId = profile.mobilizerId.trim();
    }
  }
}

authRouter.post(
  '/signup',
  asyncHandler(async (req, res) => {
    const body = (req.body ?? {}) as Record<string, unknown>;
    const { role: rawRole, fullName, phoneNumber, email, profile } = body;

    if (typeof rawRole !== 'string' || !ROLES.includes(rawRole as (typeof ROLES)[number])) {
      throw new AppError(400, 'Invalid role', 'validation_error', { role: 'invalid_role' });
    }
    const role = rawRole as (typeof ROLES)[number];
    if (typeof fullName !== 'string' || !fullName.trim()) {
      throw new AppError(400, 'fullName is required', 'validation_error', { fullName: 'missing_field' });
    }
    if (!isTenDigitPhone(phoneNumber)) {
      throw new AppError(400, 'phoneNumber must be a valid 10-digit mobile', 'validation_error', {
        phoneNumber: 'invalid_phone',
      });
    }
    const emailNorm = normalizeOptionalEmail(email);
    if (!profile || typeof profile !== 'object' || Array.isArray(profile)) {
      throw new AppError(400, 'profile is required', 'validation_error', { profile: 'missing_field' });
    }

    const addresses = resolveSignupAddresses(body);
    const profileObj = { ...(profile as Record<string, unknown>) };
    assertRoleProfile(role, profileObj, phoneNumber);

    const byPhone = await SourcingPartner.findOne({ phoneNumber });
    if (byPhone) {
      throw new AppError(409, 'Phone number already registered', 'duplicate_phone');
    }
    if (emailNorm) {
      const byEmail = await SourcingPartner.findOne({ email: emailNorm });
      if (byEmail) {
        throw new AppError(409, 'Email already registered', 'duplicate_email');
      }
    }

    try {
      await SourcingPartner.create({
        role,
        fullName: fullName.trim(),
        phoneNumber,
        ...(emailNorm ? { email: emailNorm } : {}),
        status: 'pending',
        permanentAddress: addresses.permanentAddress,
        presentAddress: addresses.presentAddress,
        presentSameAsPermanent: addresses.presentSameAsPermanent,
        state: addresses.permanentAddress.state,
        district: addresses.permanentAddress.district,
        pincode: addresses.permanentAddress.pincode,
        profile: profileObj,
      });
    } catch (err: any) {
      if (err?.code === 11000) {
        if (err?.keyPattern?.email) {
          throw new AppError(409, 'Email already registered', 'duplicate_email');
        }
        throw new AppError(409, 'Phone number already registered', 'duplicate_phone');
      }
      throw err;
    }

    await createOtp(phoneNumber, 'signup');
    res.status(201).json({ message: 'Signup successful. Verify the OTP sent to your phone.' });
  }),
);

function normalizeOtpPurpose(purpose: unknown): 'signup' | 'login' | 'reset' {
  if (purpose === 'signup') return 'signup';
  if (purpose === 'reset' || purpose === 'forgot_password') return 'reset';
  return 'login';
}

authRouter.post(
  '/request-otp',
  asyncHandler(async (req, res) => {
    const { phoneNumber, purpose } = req.body ?? {};
    const otpPurpose = normalizeOtpPurpose(purpose);
    // Same response whether or not the phone exists (and if createOtp rate-limits).
    if (isTenDigitPhone(phoneNumber)) {
      const partner = await SourcingPartner.findOne({ phoneNumber });
      if (partner) {
        try {
          await createOtp(phoneNumber, otpPurpose);
        } catch {
          /* keep response generic */
        }
      }
    }
    res.json({ message: 'If this number is registered, an OTP has been sent.' });
  }),
);

authRouter.post(
  '/reset-password',
  asyncHandler(async (req, res) => {
    const { phoneNumber, otp, newPassword } = req.body ?? {};
    if (!isTenDigitPhone(phoneNumber)) {
      throw new AppError(400, 'phoneNumber must be 10 digits', 'validation_error', {
        phoneNumber: 'invalid_phone',
      });
    }
    if (typeof otp !== 'string' || !otp.trim()) {
      throw new AppError(400, 'otp is required', 'validation_error', { otp: 'missing_field' });
    }
    if (typeof newPassword !== 'string' || newPassword.length < 8) {
      throw new AppError(400, 'newPassword must be at least 8 characters', 'validation_error', {
        newPassword: 'invalid_password',
      });
    }

    await verifyOtp(phoneNumber, 'reset', otp.trim());

    const partner = await SourcingPartner.findOne({ phoneNumber }).select('+passwordHash');
    // Same generic failure whether phone is unknown (OTP would already fail if no send).
    if (!partner) {
      throw new AppError(400, 'Invalid or expired OTP', 'otp_invalid');
    }

    partner.passwordHash = await bcrypt.hash(newPassword, 10);
    await partner.save();

    res.json({ message: 'Password updated. You can sign in with the new password.' });
  }),
);

authRouter.post(
  '/verify-otp',
  asyncHandler(async (req, res) => {
    const { phoneNumber, otp, purpose } = req.body ?? {};
    if (!isTenDigitPhone(phoneNumber)) {
      throw new AppError(400, 'phoneNumber must be 10 digits', 'validation_error', { phoneNumber: 'invalid_phone' });
    }
    if (typeof otp !== 'string' || !otp.trim()) {
      throw new AppError(400, 'otp is required', 'validation_error', { otp: 'missing_field' });
    }
    if (purpose !== 'signup' && purpose !== 'login') {
      throw new AppError(400, 'purpose must be signup or login', 'validation_error', { purpose: 'missing_field' });
    }

    await verifyOtp(phoneNumber, purpose, otp.trim());

    const partner = await SourcingPartner.findOne({ phoneNumber });
    // Do not reveal whether the phone is registered.
    if (!partner) throw new AppError(400, 'Invalid or expired OTP', 'otp_invalid');

    res.json(partnerAuthResponse(partner));
  }),
);

authRouter.post(
  '/login',
  asyncHandler(async (req, res) => {
    const { phoneNumber, password } = req.body ?? {};
    if (!isTenDigitPhone(phoneNumber)) {
      throw new AppError(400, 'phoneNumber must be 10 digits', 'validation_error', {
        phoneNumber: 'invalid_phone',
      });
    }
    if (typeof password !== 'string' || !password) {
      throw new AppError(400, 'password is required', 'validation_error', { password: 'missing_field' });
    }

    const partner = await SourcingPartner.findOne({ phoneNumber }).select('+passwordHash');
    // Same generic failure whether phone/password is wrong or password is unset.
    if (!partner?.passwordHash) {
      throw new AppError(401, 'Invalid phone number or password', 'invalid_credentials');
    }

    const ok = await bcrypt.compare(password, partner.passwordHash);
    if (!ok) {
      throw new AppError(401, 'Invalid phone number or password', 'invalid_credentials');
    }

    res.json(partnerAuthResponse(partner));
  }),
);

authRouter.get(
  '/me',
  requireAuth,
  asyncHandler(async (req, res) => {
    res.json(partnerMeJson(req.partner!));
  }),
);

/** Update profile fields (name, email, avatar, addresses, role profile). Phone/role are immutable. */
authRouter.patch(
  '/me',
  requireAuth,
  asyncHandler(async (req, res) => {
    const partner = await SourcingPartner.findById(req.partner!.id);
    if (!partner) throw new AppError(401, 'Unauthorized', 'unauthorized');

    const body = (req.body ?? {}) as Record<string, unknown>;
    const {
      fullName,
      email,
      avatarUrl,
      permanentAddress,
      presentAddress,
      presentSameAsPermanent,
      profile,
    } = body;

    if (fullName !== undefined) {
      if (typeof fullName !== 'string' || !fullName.trim()) {
        throw new AppError(400, 'fullName is required', 'validation_error', {
          fullName: 'missing_field',
        });
      }
      partner.fullName = fullName.trim();
    }

    let clearEmail = false;
    if (email !== undefined) {
      const emailNorm = normalizeOptionalEmail(email);
      if (!emailNorm) {
        // Never persist "" / null — sparse unique only skips a missing field.
        clearEmail = true;
        partner.set('email', undefined);
      } else if (emailNorm !== partner.email) {
        const taken = await SourcingPartner.findOne({
          email: emailNorm,
          _id: { $ne: partner._id },
        });
        if (taken) {
          throw new AppError(409, 'Email already registered', 'duplicate_email');
        }
        partner.email = emailNorm;
      }
    }

    if (avatarUrl !== undefined) {
      if (avatarUrl === null || avatarUrl === '') {
        partner.avatarUrl = undefined;
      } else if (typeof avatarUrl === 'string' && isOurObjectKey(avatarUrl)) {
        partner.avatarUrl = avatarUrl;
      } else {
        throw new AppError(
          400,
          'avatarUrl must be a GCS object key from /api/uploads/signed-url',
          'validation_error',
          { avatarUrl: 'invalid_object_key' },
        );
      }
    }

    if (permanentAddress !== undefined) {
      const permanent = parseAddress(permanentAddress, 'permanentAddress');
      partner.permanentAddress = permanent;
      partner.state = permanent.state;
      partner.district = permanent.district;
      partner.pincode = permanent.pincode;
    }

    if (presentSameAsPermanent !== undefined) {
      partner.presentSameAsPermanent = Boolean(presentSameAsPermanent);
    }

    if (partner.presentSameAsPermanent) {
      partner.presentAddress = partner.permanentAddress;
    } else if (presentAddress !== undefined) {
      partner.presentAddress = parseAddress(presentAddress, 'presentAddress');
    }

    if (profile !== undefined) {
      if (!profile || typeof profile !== 'object' || Array.isArray(profile)) {
        throw new AppError(400, 'profile must be an object', 'validation_error', {
          profile: 'invalid_type',
        });
      }
      const role = partner.role as (typeof ROLES)[number];
      const next = {
        ...(partner.profile as Record<string, unknown> | undefined),
        ...(profile as Record<string, unknown>),
      };
      assertRoleProfile(role, next, partner.phoneNumber);
      partner.profile = next;
      partner.markModified('profile');
    }

    await partner.save();
    if (clearEmail) {
      await SourcingPartner.updateOne({ _id: partner._id }, { $unset: { email: 1 } });
      partner.email = undefined;
    }
    res.json(partnerMeJson(toAuthPartner(partner)));
  }),
);
