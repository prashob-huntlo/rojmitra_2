import { BadgeCheck, Building2, Check, Compass, HardHat, House, Minus } from "lucide-react";
import {
  BuildingBadge,
  Headline,
  IconBadge,
  LiveBadge,
  Reveal,
  SectionHeader,
  SectionLabel,
  StoryPhoto,
} from "@/components/site/primitives";
import { problemImages, storyImage } from "@/content/imagery";
import { bento, networkStrip, problem, story, whatItIs } from "@/content/site";

export function NetworkStrip() {
  return (
    <section aria-label="Grassroots network" className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
      <p className="mono-label mb-5 text-center text-muted-foreground">Potential channels</p>
      <ul className="flex flex-wrap items-center justify-center gap-2 sm:gap-2.5">
        {networkStrip.map((item) => (
          <li
            key={item}
            className="rounded-full border border-border bg-card px-4 py-2 font-mono text-[0.66rem] uppercase tracking-[0.1em] text-foreground shadow-soft"
          >
            {item}
          </li>
        ))}
      </ul>
    </section>
  );
}

export function BentoGrid() {
  return (
    <section
      id="architecture"
      aria-labelledby="bento-heading"
      className="mx-auto max-w-7xl px-4 pb-20 sm:px-6 lg:px-8"
    >
      <Reveal className="mb-10 max-w-2xl">
        <SectionLabel>Architecture</SectionLabel>
        <Headline
          id="bento-heading"
          text="The village is the unit. Everything else is a view."
          className="text-3xl text-foreground sm:text-4xl lg:text-[2.85rem]"
        />
      </Reveal>

      <div className="grid gap-4 lg:grid-cols-2">
        <Reveal as="article" className="card-surface card-lift flex h-full flex-col p-7 sm:p-8">
          <IconBadge icon={House} tone="brand" className="mb-4" />
          <SectionLabel>{bento.districtCoverage.label}</SectionLabel>
          <h3 className="display-type text-3xl text-navy sm:text-4xl">
            {bento.districtCoverage.title}
          </h3>
          <div className="mt-4 max-w-md space-y-3 text-base leading-relaxed text-muted-foreground">
            {bento.districtCoverage.body.map((paragraph) => (
              <p key={paragraph}>{paragraph}</p>
            ))}
          </div>
          <ul className="mt-8 space-y-4 border-t border-border pt-6 lg:mt-auto">
            {bento.districtCoverage.points.map((point) => (
              <li key={point.title} className="flex gap-3">
                <House aria-hidden className="mt-1 h-4 w-4 shrink-0 text-brand" strokeWidth={1.6} />
                <div>
                  <p className="text-sm font-semibold text-foreground">{point.title}</p>
                  <p className="text-sm text-muted-foreground">{point.detail}</p>
                </div>
              </li>
            ))}
          </ul>
        </Reveal>

        <Reveal
          as="article"
          delay={0.1}
          className="flex h-full flex-col rounded-[1.25rem] bg-gradient-navy p-7 text-on-dark shadow-glow sm:p-8"
        >
          <SectionLabel tone="on-dark">{bento.systemLayers.label}</SectionLabel>
          <h3 className="display-type text-2xl sm:text-3xl">{bento.systemLayers.title}</h3>
          <p className="mt-3 max-w-xl text-sm leading-relaxed text-on-dark/75 sm:text-base">
            {bento.systemLayers.body}
          </p>
          <ol className="mt-7 grid flex-1 grid-cols-2 gap-3 sm:grid-cols-3">
            {bento.systemLayers.points.map((point) => (
              <li
                key={point.step}
                className="flex flex-col justify-between rounded-2xl border border-on-dark/15 bg-on-dark/5 p-4 transition hover:bg-on-dark/10"
              >
                <div className="flex items-start justify-between gap-2">
                  <span className="font-mono text-[0.7rem] text-sky-soft">{point.step}</span>
                  {point.status === "building" ? <BuildingBadge /> : null}
                </div>
                <p className="mt-4 text-sm font-semibold">{point.title}</p>
              </li>
            ))}
          </ol>
        </Reveal>
      </div>
    </section>
  );
}

export function OurStory() {
  return (
    <section id="story" aria-labelledby="story-heading" className="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8">
      <Reveal className="mb-8 max-w-3xl">
          <SectionLabel>{story.label}</SectionLabel>
          <Headline
            id="story-heading"
            text={story.headline}
            className="text-3xl text-foreground sm:text-4xl lg:text-[2.85rem]"
          />
      </Reveal>
      <div className="grid gap-10 lg:grid-cols-[0.9fr_1.1fr] lg:items-center">
        <Reveal>
          <div className="group relative mb-6">
            <StoryPhoto image={storyImage} className="aspect-[4/3] rounded-[1.25rem] shadow-float [&_img]:object-top lg:aspect-[5/4]" />
            <div className="card-surface shadow-float absolute -bottom-6 right-4 w-[min(17rem,80%)] rounded-2xl p-4">
              <div className="flex items-center justify-between">
                <p className="mono-label text-muted-foreground">{bento.workerProfiles.label}</p>
                <BadgeCheck aria-hidden className="h-4 w-4 text-signal" strokeWidth={2} />
              </div>
              <p className="mt-2 text-sm font-semibold text-foreground">{bento.workerProfiles.title}</p>
              <ul className="mt-2 space-y-1">
                {bento.workerProfiles.points.map((point) => (
                  <li key={point} className="text-xs leading-relaxed text-muted-foreground">
                    {point}
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </Reveal>
        <div className="space-y-5 text-base leading-relaxed text-muted-foreground sm:text-lg">
          {story.body.map((paragraph, i) => (
            <Reveal key={paragraph.slice(0, 32)} delay={i * 0.05}>
              <p className={i === story.body.length - 1 ? "font-medium text-foreground" : undefined}>
                {paragraph}
              </p>
            </Reveal>
          ))}
          {story.pullQuote ? (
            <blockquote className="mt-8 border-l-4 border-flame pl-5">
              <p className="text-xl font-medium text-foreground">“{story.pullQuote.quote}”</p>
              <footer className="mono-label mt-3 text-muted-foreground">
                {story.pullQuote.attribution}
              </footer>
            </blockquote>
          ) : null}
        </div>
      </div>
    </section>
  );
}

const problemIcons = [Building2, HardHat, Compass];

export function TheProblem() {
  return (
    <section id="problem" aria-labelledby="problem-heading" className="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8">
      <SectionHeader label={problem.label} headline={problem.headline} id="problem-heading" />

      <div className="mt-10 grid gap-4 md:grid-cols-3">
        {problem.cards.map((card, i) => (
          <Reveal key={card.audience} delay={i * 0.08} as="article" className="group card-surface card-lift p-2">
            {problemImages[i] ? (
              <StoryPhoto image={problemImages[i]} className="aspect-[16/11]">
                <div className="absolute inset-x-3 bottom-3 flex items-center gap-2">
                  <IconBadge icon={problemIcons[i] ?? Building2} tone="sky" className="h-9 w-9" />
                  <p className="mono-label text-on-dark">{card.audience}</p>
                </div>
              </StoryPhoto>
            ) : null}
            <div className="p-5">
              <h3 className="text-xl font-semibold tracking-tight text-foreground">{card.title}</h3>
              <p className="mt-3 text-sm leading-relaxed text-muted-foreground sm:text-base">{card.body}</p>
            </div>
          </Reveal>
        ))}
      </div>

      <Reveal className="mt-6">
        <div className="rounded-[1.25rem] bg-gradient-navy px-6 py-8 text-on-dark shadow-glow sm:px-10">
          <p className="mono-label text-center text-on-dark/70">{problem.statsLabel}</p>
          <dl className="mt-6 grid gap-6 sm:grid-cols-3 sm:gap-4">
            {problem.stats.map((stat) => (
              <div
                key={stat.value}
                className="flex flex-col border-t border-on-dark/15 pt-4 text-center sm:border-l sm:border-t-0 sm:pt-0 sm:first:border-l-0"
              >
                <dt className="order-2 mt-2 text-sm leading-relaxed text-on-dark/75">{stat.label}</dt>
                <dd className="display-type order-1 text-3xl text-on-dark sm:text-4xl">{stat.value}</dd>
                <p className="order-3 mt-2 font-mono text-[0.6rem] uppercase tracking-[0.12em] text-sky-soft">
                  {stat.source}
                </p>
              </div>
            ))}
          </dl>
        </div>
      </Reveal>

      <Reveal>
        <p className="display-type mx-auto mt-10 max-w-3xl text-center text-2xl text-foreground sm:text-3xl">
          {problem.closer}
        </p>
      </Reveal>
    </section>
  );
}

export function WhatItIs() {
  const { portal, rojmitra } = whatItIs.comparison;
  return (
    <section id="what-it-is" aria-labelledby="what-heading" className="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8">
      <SectionHeader label={whatItIs.label} headline={whatItIs.headline} id="what-heading" />
      <div className="mx-auto mt-5 max-w-6xl space-y-4 text-center text-pretty text-base leading-relaxed text-muted-foreground sm:text-lg">
        {whatItIs.body.map((paragraph) => (
          <p key={paragraph}>{paragraph}</p>
        ))}
      </div>

      <div className="mt-12 grid gap-4 md:grid-cols-2">
        <Reveal as="article" className="rounded-[1.25rem] border border-border bg-muted p-7 sm:p-8">
          <p className="mono-label text-muted-foreground">{portal.title}</p>
          <ul className="mt-6 space-y-4">
            {portal.points.map((point) => (
              <li key={point} className="flex gap-3 text-sm text-muted-foreground sm:text-base">
                <span
                  aria-hidden
                  className="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-border text-muted-foreground"
                >
                  <Minus className="h-3 w-3" strokeWidth={2.5} />
                </span>
                {point}
              </li>
            ))}
          </ul>
        </Reveal>

        <Reveal as="article" delay={0.1} className="rounded-[1.25rem] bg-gradient-navy p-7 text-on-dark shadow-glow sm:p-8">
          <div className="flex items-center justify-between gap-3">
            <p className="mono-label text-on-dark/70">{rojmitra.title}</p>
            <LiveBadge className="border-signal/40 bg-signal/15">Verified</LiveBadge>
          </div>
          <ul className="mt-6 space-y-4">
            {rojmitra.points.map((point) => (
              <li key={point} className="flex gap-3 text-sm sm:text-base">
                <span
                  aria-hidden
                  className="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-signal text-on-dark"
                >
                  <Check className="h-3 w-3" strokeWidth={3} />
                </span>
                {point}
              </li>
            ))}
          </ul>
        </Reveal>
      </div>
    </section>
  );
}
