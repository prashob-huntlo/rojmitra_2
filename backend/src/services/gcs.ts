import { Storage } from '@google-cloud/storage';
import { env } from '../config/env';
import { AppError } from '../middleware/asyncHandler';

const ALLOWED_CONTENT_TYPES = new Set([
  'image/jpeg',
  'image/png',
  'image/webp',
]);

let storage: Storage | null = null;

function requireGcsConfigured(): void {
  if (!env.gcsBucket) {
    throw new AppError(
      503,
      'Image upload is not configured yet (missing GCS_BUCKET)',
      'gcs_not_configured',
    );
  }
}

function getStorage(): Storage {
  requireGcsConfigured();
  if (storage) return storage;

  if (env.gcsClientEmail && env.gcsPrivateKey) {
    storage = new Storage({
      projectId: env.gcsProjectId,
      credentials: {
        client_email: env.gcsClientEmail,
        private_key: env.gcsPrivateKey,
      },
    });
  } else {
    // Uses GOOGLE_APPLICATION_CREDENTIALS (from .env via dotenv) or ADC.
    storage = new Storage(env.gcsProjectId ? { projectId: env.gcsProjectId } : undefined);
  }
  return storage;
}

export function assertAllowedContentType(contentType: string): string {
  const normalized = contentType.trim().toLowerCase();
  if (!ALLOWED_CONTENT_TYPES.has(normalized)) {
    throw new AppError(
      400,
      'Only JPEG, PNG, or WebP images are allowed',
      'invalid_content_type',
    );
  }
  return normalized;
}

export function extensionForContentType(contentType: string): string {
  switch (contentType) {
    case 'image/png':
      return 'png';
    case 'image/webp':
      return 'webp';
    default:
      return 'jpg';
  }
}

export function isOurObjectKey(objectKey: string): boolean {
  if (!objectKey || objectKey.includes('..') || objectKey.startsWith('/')) return false;
  return objectKey.startsWith('partners/');
}

export async function createUploadSignedUrl(input: {
  objectKey: string;
  contentType: string;
  expiresInSeconds?: number;
}): Promise<{ uploadUrl: string; objectKey: string; bucket: string }> {
  requireGcsConfigured();
  const contentType = assertAllowedContentType(input.contentType);
  const bucket = env.gcsBucket!;
  const file = getStorage().bucket(bucket).file(input.objectKey);
  const expires = Date.now() + (input.expiresInSeconds ?? 15 * 60) * 1000;

  const [uploadUrl] = await file.getSignedUrl({
    version: 'v4',
    action: 'write',
    expires,
    contentType,
  });

  return { uploadUrl, objectKey: input.objectKey, bucket };
}

export async function createReadSignedUrl(input: {
  objectKey: string;
  expiresInSeconds?: number;
}): Promise<{ readUrl: string; objectKey: string }> {
  requireGcsConfigured();
  if (!isOurObjectKey(input.objectKey)) {
    throw new AppError(400, 'Invalid object key', 'invalid_object_key');
  }

  const file = getStorage().bucket(env.gcsBucket!).file(input.objectKey);
  const expires = Date.now() + (input.expiresInSeconds ?? 15 * 60) * 1000;
  const [readUrl] = await file.getSignedUrl({
    version: 'v4',
    action: 'read',
    expires,
  });

  return { readUrl, objectKey: input.objectKey };
}
