// Shared bits for everything that has names/descriptions in several languages
// (Category, Skill, Job).
import { Schema } from 'mongoose';
import { LANGS, Lang } from '../config/languages';

export type LangMap = Partial<Record<Lang, string>>;

// If your app already has a normalise function for search text, use that one
// here instead, so imported and admin-added entries search identically.
export const normalizeTerm = (s: string): string =>
  s.normalize('NFC').trim().toLowerCase().replace(/\s+/g, ' ');

// Every full name + every alias + each individual word of the names, all
// normalised and de-duplicated. Word tokens let "mas" find "Tile Mason".
export const buildSearchTerms = (names: LangMap = {}, aliases: string[] = []): string[] => {
  const nameList = Object.values(names).filter((v): v is string => typeof v === 'string' && v.trim().length > 0);
  const words = nameList.flatMap((n) => n.split(/[\s–,&/()\-]+/)).filter((w) => w.length >= 2);
  const all = [...nameList, ...aliases, ...words].filter((v) => v && v.trim()).map(normalizeTerm);
  return [...new Set(all)];
};

// { en: {type:String}, hi: {type:String}, ... } built from LANGS
export const langFields = () => Object.fromEntries(LANGS.map((l) => [l, { type: String, trim: true }]));

export const hasAnyName = (names?: LangMap) => LANGS.some((l) => names?.[l] && names[l]!.trim());

// Plugin: a name in at least ONE language is required (not necessarily English,
// since a partner may add a local trade only in their own language), and
// searchTerms is rebuilt on every save so nobody has to maintain it by hand.
export function i18nPlugin(schema: Schema) {
  schema.pre('validate', function () {
    const doc = this as any;
    if (!hasAnyName(doc.names)) {
      throw new Error('A name in at least one language is required');
    }
    if (schema.path('searchTerms')) {
      doc.searchTerms = buildSearchTerms(doc.names, doc.aliases);
    }
  });
}

// What the API sends to the app, for Category, Skill and Job alike.
//   list:   { id, name, localName? }
//   detail: adds description / localDescription
// English is the main line and the chosen language is added next to it.
// If English is missing, the first available text becomes the main line.
export const catalogView = (
  d: { _id: unknown; names?: LangMap; descriptions?: LangMap },
  lang: Lang,
  detail = false
) => {
  const main = (m: LangMap = {}) => m.en ?? LANGS.map((l) => m[l]).find(Boolean);
  const local = (m: LangMap = {}) => {
    const v = lang === 'en' ? undefined : m[lang];
    return v && v !== main(m) ? v : undefined;
  };
  const out: Record<string, unknown> = {
    id: String(d._id),
    name: main(d.names),
    localName: local(d.names),
  };
  if (detail) {
    out.description = main(d.descriptions);
    out.localDescription = local(d.descriptions);
  }
  return out;
};
