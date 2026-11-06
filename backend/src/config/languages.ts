// The one list of supported languages.
// Schema, API validation and import script all read from here,
// so adding a language later is a one-line change.

export const LANGS = ['en', 'hi', 'gu', 'kn', 'bn'] as const;
export type Lang = (typeof LANGS)[number];

// Native names, handy for the language picker and the admin panel.
export const LANG_LABELS: Record<Lang, string> = {
  en: 'English',
  hi: 'हिन्दी',
  gu: 'ગુજરાતી',
  kn: 'ಕನ್ನಡ',
  bn: 'বাংলা',
};

export const isLang = (v: unknown): v is Lang =>
  typeof v === 'string' && (LANGS as readonly string[]).includes(v);

// Use in routes: const lang = parseLang(req.query.lang);  -> falls back to 'en'
export const parseLang = (v: unknown): Lang => (isLang(v) ? v : 'en');
