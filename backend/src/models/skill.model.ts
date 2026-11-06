import { Schema, model, Types } from 'mongoose';
import { LangMap, langFields, i18nPlugin } from './i18n';

// A skill is a WORK DOMAIN (400 from the sheet), e.g. "Jute Processing".
// How experienced someone is in it is NOT part of the skill: it is the
// `level` on the person's work-history entry (see config/levels.ts).
export interface SkillDoc {
  _id: Types.ObjectId;
  externalId?: string; // "LMI-DOM-jute-processing"; unset for partner-added skills
  names: LangMap; // at least ONE language required
  descriptions: LangMap; // all optional
  aliases: string[]; // flat, any language, Roman spellings included
  searchTerms: string[]; // generated, never typed by hand
  categoryId?: Types.ObjectId; // optional: a partner-added skill may not have one yet
  status: 'pending' | 'accepted' | 'rejected';
  suggestedBy?: Types.ObjectId; // empty when admin added it
}

const SkillSchema = new Schema<SkillDoc>(
  {
    externalId: { type: String },
    names: langFields(),
    descriptions: langFields(),
    aliases: [{ type: String, trim: true }],
    searchTerms: [{ type: String }],
    categoryId: { type: Schema.Types.ObjectId, ref: 'Category' },
    status: { type: String, enum: ['pending', 'accepted', 'rejected'], default: 'pending' },
    suggestedBy: { type: Schema.Types.ObjectId, ref: 'SourcingPartner' },
  },
  { timestamps: true }
);

SkillSchema.plugin(i18nPlugin);
SkillSchema.index({ externalId: 1 }, { unique: true, sparse: true });
SkillSchema.index({ status: 1, searchTerms: 1 });
SkillSchema.index({ categoryId: 1 });

export const Skill = model<SkillDoc>('Skill', SkillSchema);
