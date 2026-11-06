import { Router } from 'express';
import { asyncHandler, AppError } from '../middleware/asyncHandler';
import { ensureLegalDefaults, getLegalDocument } from '../services/legalDocuments';
import { parseLang } from '../config/languages';

export const legalRouter = Router();

const ALLOWED = new Set(['privacy', 'terms']);

legalRouter.get(
  '/:slug',
  asyncHandler(async (req, res) => {
    const slug = String(req.params.slug ?? '').trim().toLowerCase();
    if (!ALLOWED.has(slug)) {
      throw new AppError(404, 'Legal document not found', 'not_found');
    }

    await ensureLegalDefaults();

    const langParam =
      typeof req.query.lang === 'string' ? req.query.lang : undefined;
    const lang = parseLang(langParam);

    const doc = await getLegalDocument(slug, lang);
    if (!doc) {
      throw new AppError(404, 'Legal document not found', 'not_found');
    }

    res.json({
      slug: doc.slug,
      lang: doc.lang,
      title: doc.title,
      format: doc.format ?? 'plain',
      body: doc.body,
      updatedAt: doc.updatedAt,
    });
  }),
);
