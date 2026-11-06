import { LegalDocument } from '../models';

const DEFAULTS: Array<{
  slug: 'privacy' | 'terms';
  lang: string;
  title: string;
  body: string;
}> = [
  {
    slug: 'privacy',
    lang: 'en',
    title: 'Privacy policy',
    body: [
      'We collect only the information needed to register partners and the workers they onboard — such as name, phone number, location, and ID documents you upload.',
      'Account and registration data is used to verify partners, match workers to opportunities, and keep availability records accurate. We do not sell personal data.',
      'Documents and identity details are stored securely and shared only with authorised operations staff for verification and placement.',
      'You may request correction or deletion of your partner account data by contacting support@rojmitra.in or visiting https://rojmitra.in. Some records may be retained where required for compliance or dispute resolution.',
      'By continuing to use this app you agree to this privacy policy. We may update it; continued use after changes means you accept the updated policy.',
    ].join('\n\n'),
  },
  {
    slug: 'terms',
    lang: 'en',
    title: 'Terms and conditions',
    body: [
      'RojMitra (rojmitra.in) is for authorised sourcing partners to register and manage workers. You must provide accurate information and keep your login credentials private.',
      'You are responsible for the accuracy of worker details and documents you submit. Misuse, false data, or unauthorised access may result in account suspension.',
      'Availability status and job placement information are tools for coordination; they do not create employment contracts by themselves.',
      'We may suspend or terminate access if these terms are violated, or if your partner account is rejected or withdrawn by administrators.',
      'These terms are governed by applicable Indian law. If a section is found unenforceable, the rest remain in effect.',
    ].join('\n\n'),
  },
];

/** Insert default English privacy/terms if missing (idempotent). */
export async function ensureLegalDefaults(): Promise<void> {
  for (const doc of DEFAULTS) {
    await LegalDocument.updateOne(
      { slug: doc.slug, lang: doc.lang },
      {
        $setOnInsert: {
          slug: doc.slug,
          lang: doc.lang,
          title: doc.title,
          format: 'plain',
          body: doc.body,
        },
      },
      { upsert: true },
    );
  }
}

export async function getLegalDocument(slug: string, lang = 'en') {
  const normalizedSlug = slug.trim().toLowerCase();
  const normalizedLang = lang.trim().toLowerCase() || 'en';

  let doc = await LegalDocument.findOne({ slug: normalizedSlug, lang: normalizedLang }).lean();
  if (!doc && normalizedLang !== 'en') {
    doc = await LegalDocument.findOne({ slug: normalizedSlug, lang: 'en' }).lean();
  }
  return doc;
}
