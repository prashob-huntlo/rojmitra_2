import {
  BadgeIndianRupee,
  BriefcaseBusiness,
  CalendarClock,
  DoorOpen,
  Eye,
  Factory,
  FileCheck2,
  Handshake,
  History,
  Plane,
  Route as RouteIcon,
  ShieldCheck,
  Target,
  UserRoundCheck,
  Wrench,
} from "lucide-react";
import { AudienceTabs } from "@/components/site/AudienceTabs";
import {
  BuildingBadge,
  IconBadge,
  LiveBadge,
  Pill,
  Reveal,
  SectionHeader,
  StoryPhoto,
} from "@/components/site/primitives";
import { migrationImages, whatWeMapImages } from "@/content/imagery";
import { audiences, businessModel, howItWorks, impact, trust, whatWeMap } from "@/content/site";
import { cn } from "@/lib/utils";

export function HowItWorks() {
  return (
    <section id="how-it-works" aria-labelledby="how-heading" className="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8">
      <SectionHeader label={howItWorks.label} headline={howItWorks.headline} id="how-heading" />

      <ol className="relative mt-14 lg:grid lg:grid-cols-6 lg:gap-4">
        <div
          aria-hidden
          className="pointer-events-none absolute bottom-3 left-[1.3rem] top-3 w-px bg-brand/30 lg:bottom-auto lg:left-[8%] lg:right-[8%] lg:top-[1.3rem] lg:h-px lg:w-auto"
        />
        {howItWorks.layers.map((layer, i) => (
          <Reveal
            key={layer.step}
            as="li"
            delay={i * 0.06}
            className="relative flex gap-4 pb-8 last:pb-0 lg:block lg:pb-0 lg:text-center"
          >
            <span className="relative z-10 flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-navy font-mono text-xs text-on-dark ring-4 ring-background lg:mx-auto">
              {layer.step}
            </span>
            <div className="min-w-0 pt-1.5 lg:pt-5">
              <h3 className="text-base font-semibold tracking-tight text-foreground lg:text-sm">
                {layer.title}
              </h3>
              <p className="mt-2 text-sm leading-relaxed text-muted-foreground lg:text-xs">{layer.body}</p>
              <div className="mt-3 lg:flex lg:justify-center">
                {layer.status === "building" ? <BuildingBadge /> : <LiveBadge />}
              </div>
            </div>
          </Reveal>
        ))}
      </ol>
    </section>
  );
}

const mapIcons = [History, UserRoundCheck, Wrench, CalendarClock, Plane, BadgeIndianRupee, BriefcaseBusiness];

export function WhatWeMap() {
  return (
    <section id="what-we-map" aria-labelledby="map-heading" className="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8">
      <SectionHeader label={whatWeMap.label} headline={whatWeMap.headline} id="map-heading" />

      <div className="mt-12 grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
        {whatWeMap.items.map((item, i) => {
          const featured = i === 0;
          const image = whatWeMapImages[i];
          return (
            <Reveal
              key={item.title}
              as="article"
              delay={(i % 3) * 0.06}
              className={cn(
                "group card-lift flex flex-col p-2",
                featured
                  ? "rounded-[1.25rem] bg-gradient-brand text-on-dark shadow-glow sm:col-span-2 lg:row-span-2"
                  : "card-surface",
              )}
            >
              {image ? (
                <StoryPhoto image={image} className={featured ? "aspect-[16/10] lg:flex-1" : "aspect-[16/9]"}>
                  <div className="absolute inset-x-3 top-3 flex items-center justify-between">
                    <IconBadge
                      icon={mapIcons[i] ?? History}
                      tone="sky"
                      className="h-9 w-9 shadow-soft"
                    />
                    {item.building ? <BuildingBadge className="bg-card/90" /> : null}
                  </div>
                </StoryPhoto>
              ) : null}
              <div className={cn("flex flex-1 flex-col", featured ? "p-5 pt-4" : "p-4")}>
                <h3
                  className={cn(
                    "font-semibold tracking-tight",
                    featured ? "text-xl text-on-dark lg:text-2xl" : "text-base text-foreground",
                  )}
                >
                  {item.title}
                </h3>
                <p
                  className={cn(
                    "mt-2 text-sm leading-relaxed",
                    featured ? "text-on-dark/85" : "text-muted-foreground",
                  )}
                >
                  {item.body}
                </p>
              </div>
            </Reveal>
          );
        })}
      </div>
    </section>
  );
}

export function WhoItServes() {
  return (
    <section id="partners" aria-labelledby="audiences-heading" className="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8">
      <SectionHeader label={audiences.label} headline={audiences.headline} id="audiences-heading" />
      <Reveal className="mt-12">
        <AudienceTabs />
      </Reveal>
    </section>
  );
}

const trustIcons = [FileCheck2, DoorOpen, ShieldCheck];

export function BuiltOnTrust() {
  return (
    <section id="trust" aria-labelledby="trust-heading" className="px-2 py-10 sm:px-3">
      <div className="mx-auto max-w-[1440px] rounded-3xl bg-gradient-navy px-5 py-16 text-on-dark sm:px-10 sm:py-20 lg:px-16">
        <Reveal className="mx-auto max-w-3xl text-center">
          <p className="mono-label mb-4 inline-flex items-center gap-2 text-on-dark/70">
            <span aria-hidden className="h-1.5 w-1.5 rounded-full bg-signal" />
            {trust.label}
          </p>
          <h2 id="trust-heading" className="display-type text-balance text-3xl sm:text-4xl lg:text-[2.85rem]">
            {trust.headline}
          </h2>
          <p className="mt-5 text-base leading-relaxed text-on-dark/75 sm:text-lg">{trust.body}</p>
        </Reveal>

        <div className="mx-auto mt-12 grid max-w-6xl gap-4 md:grid-cols-3">
          {trust.pillars.map((pillar, i) => (
            <Reveal
              key={pillar.title}
              as="article"
              delay={i * 0.08}
              className="rounded-[1.25rem] border border-on-dark/12 bg-on-dark/5 p-7 transition duration-300 hover:-translate-y-1 hover:bg-on-dark/10"
            >
              <span
                aria-hidden
                className="inline-flex h-11 w-11 items-center justify-center rounded-full bg-signal/15 text-signal"
              >
                {(() => {
                  const Icon = trustIcons[i] ?? ShieldCheck;
                  return <Icon className="h-5 w-5" strokeWidth={1.6} />;
                })()}
              </span>
              <h3 className="mt-6 text-xl font-semibold tracking-tight">{pillar.title}</h3>
              <p className="mt-3 text-sm leading-relaxed text-on-dark/75 sm:text-base">{pillar.body}</p>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}

export function Impact() {
  return (
    <section id="impact" aria-labelledby="impact-heading" className="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8">
      <SectionHeader label={impact.label} headline={impact.headline} id="impact-heading" />

      <div className="mt-12 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {impact.tiles.map((tile, index) => {
          const dark = index === 0;
          const tinted = index === 2;
          const image = migrationImages[index];
          return (
            <Reveal
              key={tile.title}
              as="article"
              delay={index * 0.06}
              className={cn(
                "group card-lift flex flex-col p-2",
                dark
                  ? "rounded-[1.25rem] bg-gradient-navy text-on-dark shadow-glow"
                  : tinted
                    ? "rounded-[1.25rem] border border-sky-soft bg-sky-pale"
                    : "card-surface",
              )}
            >
              {image ? (
                <StoryPhoto image={image} className="aspect-[4/3]">
                  <div className="absolute inset-x-3 top-3 flex items-center justify-between">
                    <span className="glass-dark rounded-full px-2.5 py-1 font-mono text-[0.6rem] text-on-dark">
                      {String(index + 1).padStart(2, "0")}
                    </span>
                    {index < 3 ? (
                      <span className="glass-dark rounded-full px-2.5 py-1 font-mono text-[0.58rem] uppercase tracking-[0.12em] text-on-dark">
                        Illustrative
                      </span>
                    ) : null}
                  </div>
                  {index < 3 ? (
                    <svg
                      aria-hidden
                      viewBox="0 0 200 60"
                      className="absolute inset-x-4 bottom-9 h-10 w-[calc(100%-2rem)]"
                      fill="none"
                    >
                      <path
                        d="M10 50 C 60 -5, 140 -5, 190 50"
                        className="stroke-on-dark"
                        strokeWidth="1.5"
                        strokeDasharray="4 5"
                      />
                      <circle cx="10" cy="50" r="4" className="fill-flame" />
                      <circle cx="190" cy="50" r="4" className="fill-on-dark" />
                    </svg>
                  ) : null}
                  {image.caption ? (
                    <p className="absolute inset-x-3 bottom-3 font-mono text-[0.6rem] uppercase tracking-[0.12em] text-on-dark/90">
                      {image.caption}
                    </p>
                  ) : null}
                </StoryPhoto>
              ) : null}
              <div className="flex flex-1 flex-col p-4 pt-5">
                <div className="flex items-center gap-2">
                  <RouteIcon
                    aria-hidden
                    className={cn("h-4 w-4 shrink-0", dark ? "text-sky-soft" : index === 3 ? "text-flame" : "text-brand")}
                    strokeWidth={1.8}
                  />
                  <h3 className={cn("text-lg font-semibold tracking-tight", dark ? "text-on-dark" : "text-foreground")}>
                    {tile.title}
                  </h3>
                </div>
                <p className={cn("mt-3 text-sm leading-relaxed", dark ? "text-on-dark/80" : "text-muted-foreground")}>
                  {tile.body}
                </p>
              </div>
            </Reveal>
          );
        })}
      </div>
    </section>
  );
}

const businessIcons = [Eye, Handshake, Target, Factory];

export function BusinessModel() {
  return (
    <section id="business" aria-labelledby="business-heading" className="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8">
      <SectionHeader label={businessModel.label} headline={businessModel.headline} id="business-heading" />
      <div className="mx-auto mt-5 max-w-3xl space-y-4 text-center text-pretty text-base leading-relaxed text-muted-foreground sm:text-lg">
        {businessModel.body.map((paragraph) => (
          <p key={paragraph}>{paragraph}</p>
        ))}
      </div>

      <div className="mt-12 grid gap-4 sm:grid-cols-2">
        {businessModel.cards.map((card, i) => (
          <Reveal key={card.title} as="article" delay={(i % 2) * 0.08} className="card-surface card-lift flex gap-5 p-7">
            <IconBadge icon={businessIcons[i] ?? Eye} tone={i === 3 ? "signal" : "brand"} />
            <div>
              <h3 className="text-xl font-semibold tracking-tight text-foreground">{card.title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-muted-foreground sm:text-base">{card.body}</p>
            </div>
          </Reveal>
        ))}
      </div>

      <div className="mt-12 flex justify-center">
        <Pill href={businessModel.cta.href} variant="navy" arrow>
          {businessModel.cta.label}
        </Pill>
      </div>
    </section>
  );
}

