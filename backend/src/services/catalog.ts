import { Types } from 'mongoose';
import { Company, Skill, Job } from '../models';
import { catalogView } from '../models/i18n';
import { Lang, parseLang } from '../config/languages';
import { LEVEL_KEYS, levelView } from '../config/levels';

export function normalize(s: string): string {
  return s.normalize('NFC').trim().replace(/\s+/g, ' ').toLowerCase();
}

function escapeRegex(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

async function resolveCompany(doc: any) {
  let cur = doc;
  while (cur?.mergedInto) {
    const next = await Company.findById(cur.mergedInto);
    if (!next) break;
    cur = next;
  }
  if (!cur || cur.status === 'rejected') return null;
  return cur;
}

async function resolveSkill(doc: any) {
  let cur = doc;
  while (cur?.mergedInto) {
    const next = await Skill.findById(cur.mergedInto);
    if (!next) break;
    cur = next;
  }
  if (!cur || cur.status === 'rejected') return null;
  return cur;
}

export async function getOrCreateCompany({
  name,
  partnerId,
}: {
  name: string;
  partnerId: Types.ObjectId | string;
}) {
  const trimmed = name.trim();
  const nameNormalized = normalize(name);
  const doc = await Company.findOneAndUpdate(
    { nameNormalized },
    {
      $setOnInsert: { name: trimmed, status: 'pending' },
      $addToSet: { suggestedBy: partnerId },
    },
    { upsert: true, new: true },
  );
  return resolveCompany(doc);
}

export async function getOrCreateSkill({
  name,
  lang,
  partnerId,
}: {
  name: string;
  lang?: string;
  partnerId: Types.ObjectId | string;
}) {
  const trimmed = name.trim();
  const term = normalize(name);
  let doc = await Skill.findOne({ searchTerms: term });

  if (!doc) {
    try {
      doc = await Skill.create({
        names: { [lang ?? 'en']: trimmed },
        aliases: [],
        searchTerms: [term],
        status: 'pending',
        suggestedBy: partnerId,
      });
    } catch (err: any) {
      if (err?.code !== 11000) throw err;
      doc = await Skill.findOne({ searchTerms: term });
    }
  }

  return resolveSkill(doc);
}

async function resolveJob(doc: any) {
  if (!doc || doc.status === 'rejected') return null;
  return doc;
}

/** Partner-suggested main work (job/trade). Created as pending for admin review. */
export async function getOrCreateJob({
  name,
  lang,
  partnerId,
}: {
  name: string;
  lang?: string;
  partnerId: Types.ObjectId | string;
}) {
  const trimmed = name.trim();
  const term = normalize(name);
  let doc = await Job.findOne({ searchTerms: term });

  if (!doc) {
    try {
      doc = await Job.create({
        names: { [lang ?? 'en']: trimmed },
        aliases: [],
        searchTerms: [term],
        skills: [],
        status: 'pending',
        suggestedBy: partnerId,
      });
    } catch (err: any) {
      if (err?.code !== 11000) throw err;
      doc = await Job.findOne({ searchTerms: term });
    }
  }

  return resolveJob(doc);
}

export function jobDisplayName(
  job: { names?: Map<string, string> | Record<string, string> },
  lang?: string,
): string {
  return skillDisplayName(job, lang);
}

export function buildSearchTerms(
  names: Map<string, string> | Record<string, string> | Iterable<[string, string]>,
  aliases: string[] = [],
): string[] {
  const values =
    names instanceof Map
      ? [...names.values()]
      : Array.isArray(names)
        ? names.map(([, v]) => v)
        : Object.values(names);
  const seen = new Set<string>();
  for (const v of [...values, ...aliases]) {
    if (v == null || v === '') continue;
    seen.add(normalize(String(v)));
  }
  return [...seen];
}

export async function searchSkills(q: string, limit = 10) {
  const term = normalize(q);
  if (!term) return [];
  return Skill.find({
    status: 'accepted',
    searchTerms: { $regex: `^${escapeRegex(term)}` },
  }).limit(limit);
}

export async function searchJobs(q: string, limit = 20) {
  const term = normalize(q);
  if (!term) {
    return Job.find({ status: 'accepted' }).sort({ 'names.en': 1 }).limit(limit);
  }
  return Job.find({
    status: 'accepted',
    searchTerms: { $regex: `^${escapeRegex(term)}` },
  }).limit(limit);
}

export async function searchCompanies(q: string, limit = 10) {
  const term = normalize(q);
  if (!term) return [];
  return Company.find({
    status: 'accepted',
    nameNormalized: { $regex: `^${escapeRegex(term)}` },
  }).limit(limit);
}

export function skillDisplayName(
  skill: { names?: Map<string, string> | Record<string, string> },
  lang?: string,
): string {
  const names = skill.names;
  if (!names) return '';
  const get = (k: string) =>
    names instanceof Map ? names.get(k) : (names as Record<string, string>)[k];
  if (lang) {
    const hit = get(lang);
    if (hit) return hit;
  }
  const en = get('en');
  if (en) return en;
  if (names instanceof Map) {
    const first = names.values().next();
    return first.done ? '' : first.value;
  }
  const vals = Object.values(names as Record<string, string>);
  return vals[0] ?? '';
}

export function jobView(job: any, lang?: string) {
  const l = parseLang(lang);
  const base = catalogView(job, l, false);
  return {
    ...base,
    skillIds: Array.isArray(job.skills)
      ? job.skills.map((s: any) => (s?._id ? String(s._id) : String(s)))
      : [],
  };
}

export function levelsForLang(lang?: string) {
  const l = parseLang(lang);
  return LEVEL_KEYS.map((key) => levelView(key, l));
}

export type { Lang };
