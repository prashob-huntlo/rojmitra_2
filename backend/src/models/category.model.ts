import { Schema, model, Types } from 'mongoose';
import { LangMap, langFields, i18nPlugin } from './i18n';

// The 80 categories. Admin-managed only, so no status or aliases.
export interface CategoryDoc {
  _id: Types.ObjectId;
  externalId?: string; // "CAT-001" from the sheet
  names: LangMap;
  descriptions: LangMap;
  order: number; // display order
}

const CategorySchema = new Schema<CategoryDoc>(
  {
    externalId: { type: String },
    names: langFields(),
    descriptions: langFields(),
    order: { type: Number, default: 0 },
  },
  { timestamps: true }
);

CategorySchema.plugin(i18nPlugin);
CategorySchema.index({ externalId: 1 }, { unique: true, sparse: true });

export const Category = model<CategoryDoc>('Category', CategorySchema);
