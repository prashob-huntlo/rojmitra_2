import crypto from 'crypto';
import { Router } from 'express';
import { asyncHandler, AppError } from '../middleware/asyncHandler';
import { requireAuth, requireAccepted } from '../middleware/auth';
import {
  assertAllowedContentType,
  createReadSignedUrl,
  createUploadSignedUrl,
  extensionForContentType,
  isOurObjectKey,
} from '../services/gcs';

export const uploadsRouter = Router();

uploadsRouter.use(requireAuth, requireAccepted);

const KINDS = new Set(['id-front', 'id-back', 'pan', 'photo', 'avatar']);

uploadsRouter.post(
  '/signed-url',
  asyncHandler(async (req, res) => {
    const contentType = assertAllowedContentType(String(req.body?.contentType ?? ''));
    const kind = String(req.body?.kind ?? '').trim();
    if (!KINDS.has(kind)) {
      throw new AppError(
        400,
        'kind must be one of: id-front, id-back, pan, photo, avatar',
        'invalid_kind',
      );
    }

    const partnerId = req.partner!.id;
    const ext = extensionForContentType(contentType);
    const objectKey = `partners/${partnerId}/${kind}/${crypto.randomUUID()}.${ext}`;

    const signed = await createUploadSignedUrl({ objectKey, contentType });
    res.json({
      uploadUrl: signed.uploadUrl,
      objectKey: signed.objectKey,
      bucket: signed.bucket,
      headers: { 'Content-Type': contentType },
    });
  }),
);

uploadsRouter.post(
  '/signed-read',
  asyncHandler(async (req, res) => {
    const objectKey = String(req.body?.objectKey ?? '').trim();
    if (!isOurObjectKey(objectKey)) {
      throw new AppError(400, 'Invalid object key', 'invalid_object_key');
    }
    const signed = await createReadSignedUrl({ objectKey });
    res.json(signed);
  }),
);
