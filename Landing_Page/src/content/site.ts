/**
 * RojMitra site content, edit this file to update copy, placeholders, and CTAs.
 * Keep [X] figures as editable placeholders until verified. Do not invent metrics.
 */

export const site = {
  name: "RojMitra",
  tagline: "India's Village-Level Workforce Intelligence Infrastructure",
  positioning: "RojMitra by EarlyJobs · India's Village-Level Workforce Intelligence Infrastructure",
  brandRelationship: "RojMitra by EarlyJobs · Village-Level Workforce Intelligence",
  trustLine: "Consent-based · Village-first · Built by EarlyJobs",
  contact: {
    partnerEmail: "partners@earlyjobs.ai",
    investorEmail: "investors@earlyjobs.ai",
    employerEmail: "employers@earlyjobs.ai",
    institutionEmail: "institutions@earlyjobs.ai",
  },
  /** Replace [X] values once verified. Keep them clearly editable. */
  stats: {
    districtsMapped: "[X]",
    workerProfiles: "[X]",
    communityPartners: "[X]",
    skillsCatalogued: "[X]",
  },
} as const;

export const navLinks = [
  { label: "Problem", href: "#problem" },
  { label: "Intelligence", href: "#what-we-map" },
  { label: "Architecture", href: "#architecture" },
  { label: "How It Works", href: "#how-it-works" },
  { label: "Migration", href: "#impact" },
  { label: "For Employers", href: "#business" },
  { label: "For Partners", href: "#partners" },
] as const;

export const hero = {
  headline: "A worker spends ten years building a skill. The next employer never knows.",
  headlineAccent: "",
  subhead:
    "RojMitra is building a village-level workforce intelligence infrastructure that helps make every worker's skills, experience, availability and work history visible.",
  trustLine: "Village-first · Consent-based · Built by EarlyJobs",
  primaryCta: { label: "Explore Workforce Intelligence", href: "#what-we-map" },
  secondaryCta: { label: "Partner With RojMitra", href: "#partner" },
  cards: {
    profile: {
      label: "Illustrative worker profile",
      disclaimer: "Illustrative profile – not a real worker record",
      fields: [
        { label: "Name", value: "Ramesh Kumar" },
        { label: "Home village", value: "Gaya, Bihar" },
        { label: "Industry experience", value: "Knitwear manufacturing" },
        { label: "Work location", value: "Tiruppur, Tamil Nadu" },
        { label: "Experience", value: "10 years" },
        { label: "Current status", value: "Returned home" },
        { label: "Availability", value: "Demonstration status" },
      ],
    },
    map: {
      label: "Village",
      title: "Village-first Intelligence",
      body: "Workforce information organised from the village level upward to Gram Panchayat, block, district, state and India.",
      layers: ["Village", "Block", "District", "India"],
    },
    intelligence: {
      label: "Experience",
      title: "Experience Intelligence",
      body: "Past roles, industries, work locations, experience and skills – captured in a record designed to travel with the worker.",
      tags: ["Roles", "Industries", "Tenure", "Skills"],
    },
    sectors: {
      label: "Industries",
      title: "Where the work is",
      items: ["Manufacturing", "Garments", "Textile", "Construction", "Logistics", "Retail"],
    },
    network: {
      label: "Partner network",
      title: "Village Workforce Mitra",
      body: "A trusted local partner who helps workers create and maintain their experience records with their consent.",
    },
  },
} as const;

export const networkStrip = [
  "Common Services Centres",
  "Community institutions",
  "Self-help groups",
  "Community mobilisers",
  "Village-level entrepreneurs",
  "Local employment coordinators",
  "Training institutions",
  "Grassroots organisations",
] as const;

export const aboutStatement = {
  lead: "Every village worker",
  visible: "seen",
  middle: ", every skill",
  informed: "recorded",
  and: ", every employer",
  accessible: "connected",
  period: ".",
  support: "The talent is already nearby. It just isn't visible.",
} as const;

export const bento = {
  districtCoverage: {
    label: "Where we start",
    title: "Where workers actually live",
    body: [
      "Most workforce information is presented at the state or district level. RojMitra is designed to start at the village, where workers live and communities understand local employment patterns.",
      "Workforce information can then be organised upward, creating connected views at Gram Panchayat, block, district, state and national levels.",
    ],
    points: [
      { title: "Village", detail: "The unit. Everything else is a view." },
      { title: "Gram Panchayat", detail: "The next view up from the village." },
      { title: "Block", detail: "Then district, state and India." },
    ],
  },
  systemLayers: {
    label: "One record",
    title: "Six levels of insight",
    body: "Village → Gram Panchayat → Block → District → State → India. The same data, whether you are hiring for a plant or planning for a district.",
    points: [
      { step: "01", title: "Village", status: "live" as "live" | "building" },
      { step: "02", title: "Gram Panchayat", status: "live" as "live" | "building" },
      { step: "03", title: "Block", status: "live" as "live" | "building" },
      { step: "04", title: "District", status: "live" as "live" | "building" },
      { step: "05", title: "State", status: "live" as "live" | "building" },
      { step: "06", title: "India", status: "live" as "live" | "building" },
    ],
  },
  workerProfiles: {
    label: "Worker profile",
    title: "Ramesh Kumar · Gaya, Bihar",
    body: "10 yrs experience. Knitwear manufacturing, Tiruppur, Tamil Nadu. Returned home. Available.",
    points: ["10 yrs experience", "Knitwear manufacturing, Tiruppur", "Returned home · Available"],
  },
  consentFirst: {
    label: "Trust",
    title: "Workforce intelligence with consent",
    body: "Worker information is collected with the worker's consent. Data should open doors for the worker, not just be sold on.",
    pillars: ["Consent", "Open doors", "Responsible practice"],
  },
} as const;

export const story = {
  label: "The problem",
  headline: "India's workforce is everywhere. The intelligence about it is not.",
  body: [
    "Millions of skilled workers live in villages across India. They travel to different cities and states for employment, learn new skills, work across industries and return home with years of valuable experience.",
    "Yet much of this experience remains unrecorded and difficult for employers to discover.",
    "Employers struggle to identify suitable nearby workers. Workers struggle to make their experience visible beyond their immediate networks. Institutions and planners often lack granular, continuously updated workforce information.",
    "India's workforce is distributed. Its intelligence remains fragmented.",
    "RojMitra is being built to bridge this gap.",
  ],
  /** Omit or replace attribution only when confirmed. */
  pullQuote: null as null | { quote: string; attribution: string },
} as const;

export const problem = {
  label: "The problem",
  headline: "Employers guess. Workers go unseen.",
  cards: [
    {
      audience: "Employers",
      title: "No visibility, no way to reach them",
      body: "Keep hunting for fresh, nearby talent with no visibility into who is around and no way to reach them.",
    },
    {
      audience: "Workers",
      title: "Years of skill stay invisible",
      body: "Years of skill and experience stay invisible beyond the village or the contractor they know.",
    },
    {
      audience: "Planners",
      title: "Averages, not village evidence",
      body: "Decide on district averages, not village-level evidence.",
    },
  ],
  statsLabel: "What public data already shows",
  stats: [
    {
      value: "45 crore+",
      label: "Indians are internal migrants, most moving for work",
      source: "Census of India, 2011",
    },
    {
      value: "~90%",
      label: "of India's workforce is in informal employment, largely unrecorded",
      source: "PLFS, MoSPI",
    },
    {
      value: "2 in 3",
      label: "Indians live in rural areas, far from where hiring data is gathered",
      source: "Census of India, 2011",
    },
  ],
  closer: "The talent is already nearby. It just isn't visible.",
} as const;

export const whatItIs = {
  label: "Experience",
  headline: "Years of experience shouldn't end at the village boundary.",
  body: [
    "A worker's professional journey does not end when they leave a factory, change cities or return to their village.",
    "A stitching operator in Surat. A tiling mason on a Bengaluru construction site. A machine operator in a Kerala manufacturing unit.",
    "Each workplace adds experience, skills and knowledge.",
    "But when workers move, their employment history often remains scattered across contractors, employers and locations.",
    "RojMitra aims to create a connected workforce experience record that captures what workers have done, where they have worked, how long they have worked and what skills they have acquired.",
  ],
  comparison: {
    portal: {
      title: "When the record stops",
      points: [
        "Experience goes unrecorded once a worker goes home",
        "The next employer starts from zero",
        "A skill learned over years never leaves the last workplace",
        "Hiring searches for new talent a few kilometres away",
      ],
    },
    rojmitra: {
      title: "A record that travels",
      points: [
        "Past roles, industries, places and years, in the worker's own words",
        "Experience checked, not just claimed",
        "Match returning and local workers to roles that fit what they have already done",
        "A verified work history that travels with them",
      ],
    },
  },
} as const;

export const howItWorks = {
  label: "How it works",
  headline: "From discovery to a worker at work.",
  layers: [
    {
      step: "01",
      title: "Discovery",
      body: "Identify workers and workforce clusters at the village level.",
      status: "live" as "live" | "building",
    },
    {
      step: "02",
      title: "Registration",
      body: "Create consent-based worker profiles and capture past employment history.",
      status: "live" as "live" | "building",
    },
    {
      step: "03",
      title: "Verification",
      body: "Check relevant experience, skills and employment information using appropriate verification methods.",
      status: "live" as "live" | "building",
    },
    {
      step: "04",
      title: "Intelligence mapping",
      body: "Organise workforce information by occupation, skill, experience and geography.",
      status: "live" as "live" | "building",
    },
    {
      step: "05",
      title: "Employer discovery",
      body: "Enable employers to identify suitable local and returning workers using relevant workforce information.",
      status: "live" as "live" | "building",
    },
    {
      step: "06",
      title: "Hiring execution",
      body: "Connect suitable workers to employment opportunities through the EarlyJobs recruitment network.",
      status: "live" as "live" | "building",
    },
  ],
} as const;

export const whatWeMap = {
  label: "What we do",
  headline: "Seven layers of workforce intelligence, starting with what workers already know.",
  items: [
    {
      title: "Experience intelligence",
      body: "What a worker has done, where they have worked, for how long and what they have learned. A connected employment history designed to travel with them.",
      building: false,
    },
    {
      title: "Worker intelligence",
      body: "Consent-based worker profiles organised by location, occupation and employment history.",
      building: false,
    },
    {
      title: "Skills intelligence",
      body: "Understand the skills workers possess, their experience levels and the occupations they can perform.",
      building: false,
    },
    {
      title: "Availability intelligence",
      body: "Understand who may be available, from when and for how long, based on updated worker information.",
      building: false,
    },
    {
      title: "Migration intelligence",
      body: "Understand where workers move for employment, which industries they work in and when they return.",
      building: false,
    },
    {
      title: "Wage intelligence",
      body: "Understand wage expectations, prevailing compensation patterns and differences across locations and occupations.",
      building: true,
    },
    {
      title: "Employer demand intelligence",
      body: "Map employer requirements by geography, industry, occupation and workforce demand.",
      building: true,
    },
  ],
} as const;

export const audiences = {
  label: "Partner network",
  headline: "Every village needs a trusted local face.",
  tabs: [
    {
      id: "workers",
      title: "Workers",
      body: "RojMitra gives every village worker a verified record of what they can do. Worker information is collected with the worker's consent.",
      points: [
        "Past roles, industries, places and years",
        "Experience checked, not just claimed",
        "A verified work history that travels with them",
      ],
      cta: { label: "Partner With Us", href: "#partner" },
    },
    {
      id: "employers",
      title: "Employers",
      body: "Hiring for a plant, a site, a mill or a store? The talent you need is probably within a few kilometres. You just can't see it, and you can't reach it.",
      points: [
        "Who is nearby, with what skills and experience",
        "Workers who are available and open to the role",
        "Hiring around real local supply, season by season",
      ],
      cta: {
        label: "Talk to Us",
        href: `mailto:${site.contact.employerEmail}?subject=Employer%20enquiry`,
      },
    },
    {
      id: "institutions",
      title: "Institutions",
      body: "Collaborate with us. Planning works from village-level evidence, not district averages that are months or years old.",
      points: [
        "One village record, read at district and state level",
        "Consent-based workforce intelligence",
        "Community and institutional collaboration",
      ],
      cta: {
        label: "Get in Touch",
        href: `mailto:${site.contact.institutionEmail}?subject=Institution%20collaboration`,
      },
    },
    {
      id: "partners",
      title: "Village Workforce Mitras",
      body: "A Village Workforce Mitra is a local partner who helps workers become visible, on the worker's terms.",
      points: [
        "Identify workers in the village",
        "Record past experience and where they have worked",
        "Connect workers with suitable opportunities",
      ],
      cta: { label: "Become a Village Workforce Mitra", href: "#partner" },
    },
  ],
} as const;

export const trust = {
  label: "Trust",
  headline: "Workforce intelligence with consent.",
  body: "Worker information is collected with the worker's consent. We design our data practices around the principle that data should open doors for the worker, not just be sold on. We are building responsible practices into the platform from the start.",
  pillars: [
    {
      title: "Consent",
      body: "Worker information is collected with the worker's consent, through local partners called Village Workforce Mitras.",
    },
    {
      title: "Open doors",
      body: "Data should open doors for the worker, not just be sold on.",
    },
    {
      title: "Responsible practice",
      body: "Responsible practices are being built into the platform from the start. Read Privacy and Terms for details.",
    },
  ],
} as const;

export const impact = {
  label: "Migration",
  headline: "Workers move. Their experience moves with them, and the data should too.",
  tiles: [
    {
      title: "Bihar → Tamil Nadu",
      body: "Example, A worker spends months stitching in a knitwear unit in Tiruppur, then travels home for Diwali or Chhath. Then he goes back again.",
    },
    {
      title: "Odisha → Gujarat",
      body: "Example, A worker joins a stitching or finishing unit, learns a trade over several years, and returns to a village with no record of that skill.",
    },
    {
      title: "Uttar Pradesh → NCR or Bengaluru",
      body: "Example, A mason or finishing worker moves between real estate and construction sites, building experience that no single employer ever sees.",
    },
    {
      title: "What we map",
      body: "Corridors, from source village to destination cluster. Seasonality, from festivals to harvests. Skills gained on the road. Return and redeploy, closer to home.",
    },
  ],
} as const;

export const businessModel = {
  label: "For employers",
  headline: "Find the right workforce. Starting at the village level.",
  body: [
    "Manufacturing plants, construction sites, textile units, warehouses and businesses often struggle to understand the workforce available around their operating locations.",
    "RojMitra is being built to provide structured workforce intelligence by geography, occupation, skill, experience and availability.",
    "Through the EarlyJobs recruitment network, relevant workforce intelligence can translate into actual hiring execution.",
  ],
  cards: [
    {
      title: "See",
      body: "Understand who is in the surrounding workforce, what skills they possess and where they have worked.",
    },
    {
      title: "Reach",
      body: "Connect with suitable workers who are interested and available for relevant opportunities.",
    },
    {
      title: "Plan",
      body: "Understand local workforce supply and plan hiring around industry and seasonal requirements.",
    },
    {
      title: "Industries",
      body: "Manufacturing, automotive, rubber, textile and apparel, real estate, construction, warehousing, logistics, retail, healthcare, hospitality and agriculture.",
    },
  ],
  cta: {
    label: "Talk to Us",
    href: `mailto:${site.contact.employerEmail}?subject=Employer%20enquiry`,
  },
} as const;

export const ecosystem = {
  label: "Ecosystem",
  headline: "Intelligence, recruitment, AI and gig hiring, in one system.",
  products: [
    {
      name: "RojMitra",
      role: "Village-level workforce intelligence and community mobilisation.",
      highlight: true,
    },
    {
      name: "EarlyJobs",
      role: "Distributed recruitment network and hiring execution.",
      highlight: false,
    },
    {
      name: "Huntlo",
      role: "AI-powered hiring infrastructure.",
      highlight: false,
    },
    {
      name: "GigKaro",
      role: "Pincode-level gig and frontline hiring network.",
      highlight: false,
    },
  ],
  closing:
    "Together, these platforms connect workforce intelligence, talent discovery, recruitment execution and employment outcomes.",
} as const;

export const faq = {
  label: "FAQ",
  headline: "Questions, answered clearly.",
  items: [
    {
      question: "What is RojMitra?",
      answer:
        "RojMitra by EarlyJobs is a village-level workforce intelligence initiative designed to map, document and connect workforce skills, experience, availability and employment journeys across India.",
    },
    {
      question: "Is RojMitra a job portal?",
      answer:
        "No. RojMitra is being built as workforce intelligence infrastructure. Recruitment and employment are important outcomes, but its primary focus is understanding India's workforce at the grassroots.",
    },
    {
      question: "Why does RojMitra start at the village level?",
      answer:
        "Because villages are where many workers live and maintain their community connections. Starting at the village level helps build more granular workforce information that can be organised upward to block, district, state and national levels.",
    },
    {
      question: "How can employers benefit from RojMitra?",
      answer:
        "Employers can use workforce intelligence to understand local talent availability, skills, occupations and work experience. Suitable workers can be connected to hiring opportunities through EarlyJobs.",
    },
    {
      question: "How does RojMitra record past work experience?",
      answer:
        "The platform is designed to capture past roles, industries, work locations, employment duration and skills acquired. Verification depends on the available evidence and verification process.",
    },
    {
      question: "Does RojMitra track worker migration?",
      answer:
        "RojMitra is designed to document worker migration patterns with appropriate consent. This includes source locations, work destinations, industries, return patterns and experience gained.",
    },
    {
      question: "Which industries does RojMitra cover?",
      answer:
        "The intended industry coverage includes manufacturing, automotive, rubber, textile and apparel, construction, real estate, warehousing, logistics, retail, healthcare, hospitality and agriculture.",
    },
    {
      question: "How is worker information collected?",
      answer:
        "Worker information is intended to be collected through consent-based registration, supported by local partners and appropriate verification processes.",
    },
    {
      question: "Is the workforce dashboard showing live data?",
      answer:
        "No. Any dashboard or worker profile shown on this website as a demonstration uses illustrative data. It does not represent live nationwide workforce coverage.",
    },
    {
      question: "How can I become a Village Workforce Mitra?",
      answer:
        "Interested individuals and organisations can submit an enquiry through the Village Workforce Mitra registration section. The team will review the enquiry and contact eligible applicants.",
    },
    {
      question: "Can government institutions collaborate with RojMitra?",
      answer:
        "Yes. RojMitra welcomes discussions with government institutions, industry associations, skill development organisations and grassroots networks interested in workforce intelligence and employment infrastructure.",
    },
    {
      question: "How can a company hire through RojMitra?",
      answer:
        "Employers can submit their workforce requirements through the employer enquiry form. The team can discuss suitable workforce intelligence and recruitment execution through EarlyJobs.",
    },
  ],
} as const;

export const finalCta = {
  headline: "One village at a time. One connected workforce intelligence network for India.",
  body: "Employers, find nearby talent you can finally see. Partners, become a Village Workforce Mitra. Institutions and collaborators, collaborate with us.",
  routes: [
    {
      label: "Talk to Us",
      href: `mailto:${site.contact.employerEmail}?subject=Employer%20enquiry`,
    },
    {
      label: "Partner With Us",
      href: `mailto:${site.contact.partnerEmail}?subject=Partner%20with%20RojMitra`,
    },
    {
      label: "Get in Touch",
      href: `mailto:${site.contact.institutionEmail}?subject=Institution%20collaboration`,
    },
  ],
} as const;

export const footer = {
  partnerCta: {
    label: "Join as Sourcing Partner",
    href: `mailto:${site.contact.partnerEmail}?subject=Sourcing%20partner%20enquiry`,
  },
  app: {
    title: "Get the app",
    audience: "For Sourcing Partners",
    status: "Coming soon",
    stores: [
      { id: "google-play", label: "Google Play", href: null as string | null },
      { id: "apple", label: "App Store", href: null as string | null },
    ],
  },
  blurb:
    "RojMitra maps, verifies and connects India's workforce at the grassroots, so employers can finally see and reach nearby talent.",
  explore: [
    { label: "What We Do", href: "#what-we-map" },
    { label: "Architecture", href: "#architecture" },
    { label: "How It Works", href: "#how-it-works" },
    { label: "FAQ", href: "#faq" },
    { label: "Partner With Us", href: "#partner" },
  ],
  legal: [
    { label: "Privacy", href: "#privacy" },
    { label: "Terms", href: "#terms" },
    { label: "Contact", href: `mailto:${site.contact.partnerEmail}` },
  ],
  copyright: "©Victa EarlyJobs technologies Pvt. Ltd.",
} as const;
