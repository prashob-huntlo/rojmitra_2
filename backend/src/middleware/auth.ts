import { RequestHandler } from 'express';
import jwt from 'jsonwebtoken';
import { SourcingPartner } from '../models';
import { env } from '../config/env';
import { AppError } from './asyncHandler';

export type PartnerAddress = {
  line?: string;
  villageOrTown?: string;
  district?: string;
  state?: string;
  pincode?: string;
};

export type AuthPartner = {
  id: string;
  role: string;
  fullName: string;
  phoneNumber: string;
  email?: string;
  status: string;
  avatarUrl?: string;
  permanentAddress?: PartnerAddress;
  presentAddress?: PartnerAddress;
  presentSameAsPermanent?: boolean;
  state?: string;
  district?: string;
  pincode?: string;
  rejectionReason?: string;
  profile?: Record<string, unknown>;
};

declare global {
  namespace Express {
    interface Request {
      partner?: AuthPartner;
    }
  }
}

function addressFrom(doc: any): PartnerAddress | undefined {
  if (!doc || typeof doc !== 'object') return undefined;
  return {
    line: doc.line ?? undefined,
    villageOrTown: doc.villageOrTown ?? undefined,
    district: doc.district ?? undefined,
    state: doc.state ?? undefined,
    pincode: doc.pincode ?? undefined,
  };
}

export function toAuthPartner(partner: InstanceType<typeof SourcingPartner>): AuthPartner {
  return {
    id: partner.id,
    role: partner.role,
    fullName: partner.fullName,
    phoneNumber: partner.phoneNumber,
    email: partner.email ?? undefined,
    status: partner.status,
    avatarUrl: partner.avatarUrl ?? undefined,
    permanentAddress: addressFrom(partner.permanentAddress),
    presentAddress: addressFrom(partner.presentAddress),
    presentSameAsPermanent: Boolean(partner.presentSameAsPermanent),
    state: partner.state ?? undefined,
    district: partner.district ?? undefined,
    pincode: partner.pincode ?? undefined,
    rejectionReason: partner.rejectionReason ?? undefined,
    profile: partner.profile && typeof partner.profile === 'object'
      ? (partner.profile as Record<string, unknown>)
      : undefined,
  };
}

export function partnerMeJson(p: AuthPartner) {
  return {
    id: p.id,
    role: p.role,
    fullName: p.fullName,
    phoneNumber: p.phoneNumber,
    email: p.email ?? null,
    status: p.status,
    avatarUrl: p.avatarUrl ?? null,
    permanentAddress: p.permanentAddress ?? null,
    presentAddress: p.presentSameAsPermanent
      ? (p.permanentAddress ?? null)
      : (p.presentAddress ?? null),
    presentSameAsPermanent: Boolean(p.presentSameAsPermanent),
    state: p.state ?? p.permanentAddress?.state ?? '',
    district: p.district ?? p.permanentAddress?.district ?? '',
    pincode: p.pincode ?? p.permanentAddress?.pincode ?? '',
    rejectionReason: p.rejectionReason,
    profile: p.profile ?? {},
  };
}

export const requireAuth: RequestHandler = async (req, _res, next) => {
  try {
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ')) {
      throw new AppError(401, 'Unauthorized', 'unauthorized');
    }

    const token = header.slice(7);
    const payload = jwt.verify(token, env.jwtSecret) as { sub?: string; role?: string };
    if (!payload.sub) throw new AppError(401, 'Unauthorized', 'unauthorized');

    const partner = await SourcingPartner.findById(payload.sub);
    if (!partner) throw new AppError(401, 'Unauthorized', 'unauthorized');

    req.partner = toAuthPartner(partner);
    next();
  } catch (err: any) {
    if (err instanceof AppError) return next(err);
    next(new AppError(401, 'Unauthorized', 'unauthorized'));
  }
};

export const requireAccepted: RequestHandler = (req, _res, next) => {
  if (req.partner?.status !== 'accepted') {
    next(new AppError(403, 'Partner account is not accepted', 'not_accepted'));
    return;
  }
  next();
};
