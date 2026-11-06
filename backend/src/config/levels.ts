// How experienced a person was in a skill (work domain).
// A small fixed list kept in code: no collection, no admin screen.
// Stored on the person's work-history entry as the `key`, e.g. level: 'helper'.
//
// NOTE: translations below are a first draft, have a native speaker review them.
import { Lang } from './languages';

export const LEVEL_KEYS = ['helper', 'skilled', 'expert', 'supervisor'] as const;
export type LevelKey = (typeof LEVEL_KEYS)[number];

export const LEVELS: Record<LevelKey, { rank: number; names: Record<Lang, string> }> = {
  // assists others, still learning
  helper: {
    rank: 1,
    names: { en: 'Helper', hi: 'हेल्पर', gu: 'હેલ્પર', kn: 'ಸಹಾಯಕ', bn: 'সহকারী' },
  },
  // does the work independently
  skilled: {
    rank: 2,
    names: { en: 'Skilled', hi: 'कुशल', gu: 'કુશળ', kn: 'ನುರಿತ', bn: 'দক্ষ' },
  },
  // technician-level: sets up, repairs, inspects
  expert: {
    rank: 3,
    names: { en: 'Expert', hi: 'विशेषज्ञ', gu: 'નિષ્ણાત', kn: 'ತಜ್ಞ', bn: 'বিশেষজ্ঞ' },
  },
  // leads others
  supervisor: {
    rank: 4,
    names: { en: 'Supervisor', hi: 'सुपरवाइज़र', gu: 'સુપરવાઇઝર', kn: 'ಮೇಲ್ವಿಚಾರಕ', bn: 'সুপারভাইজার' },
  },
};

export const isLevel = (v: unknown): v is LevelKey =>
  typeof v === 'string' && (LEVEL_KEYS as readonly string[]).includes(v);

// Same display rule as skills: English first, chosen language added next to it.
export const levelView = (key: LevelKey, lang: Lang) => {
  const n = LEVELS[key].names;
  return { key, name: n.en, localName: lang !== 'en' ? n[lang] : undefined };
};
