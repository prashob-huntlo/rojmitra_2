import { Schema, model } from 'mongoose';

/** Privacy / terms content editable later from admin. */
const legalDocumentSchema = new Schema(
  {
    /** `privacy` | `terms` */
    slug: { type: String, required: true, trim: true, lowercase: true },
    lang: { type: String, required: true, trim: true, lowercase: true, default: 'en' },
    title: { type: String, required: true, trim: true },
    /** Plain text; paragraphs separated by blank lines. */
    format: { type: String, enum: ['plain'], default: 'plain' },
    body: { type: String, required: true },
  },
  { timestamps: true },
);

legalDocumentSchema.index({ slug: 1, lang: 1 }, { unique: true });

export const LegalDocument = model('LegalDocument', legalDocumentSchema, 'legal_documents');
