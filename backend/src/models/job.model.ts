import { Schema, model, Types } from 'mongoose';
import { LangMap, langFields, i18nPlugin } from './i18n';

// A job is a trade people recognise by name (243 from the sheet): Mason, Plumber,
// Electrician... It belongs to one category and points to the skills (work
// domains) it uses, so picking "Mason" can fill in the matching skills.
export interface JobDoc {
  _id: Types.ObjectId;
  externalId?: string; // Position ID from the sheet, e.g. "LMI-00728"
  names: LangMap; // at least ONE language required
  descriptions: LangMap; // all optional
  aliases: string[]; // e.g. "Raj Mistri", "Mali"
  searchTerms: string[]; // generated
  categoryId?: Types.ObjectId;
  skills: Types.ObjectId[]; // refs to Skill
  status: 'pending' | 'accepted' | 'rejected';
  suggestedBy?: Types.ObjectId;
}

const JobSchema = new Schema<JobDoc>(
  {
    externalId: { type: String },
    names: langFields(),
    descriptions: langFields(),
    aliases: [{ type: String, trim: true }],
    searchTerms: [{ type: String }],
    categoryId: { type: Schema.Types.ObjectId, ref: 'Category' },
    skills: [{ type: Schema.Types.ObjectId, ref: 'Skill' }],
    status: { type: String, enum: ['pending', 'accepted', 'rejected'], default: 'pending' },
    suggestedBy: { type: Schema.Types.ObjectId, ref: 'SourcingPartner' },
  },
  { timestamps: true }
);

JobSchema.plugin(i18nPlugin);
JobSchema.index({ externalId: 1 }, { unique: true, sparse: true });
JobSchema.index({ status: 1, searchTerms: 1 });
JobSchema.index({ categoryId: 1 });
JobSchema.index({ skills: 1 }); // "which jobs use this skill"

export const Job = model<JobDoc>('Job', JobSchema);
