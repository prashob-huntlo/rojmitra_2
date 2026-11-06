import { motion, useScroll, useTransform } from "framer-motion";
import { Building2, Globe2, House, MapPin, Network } from "lucide-react";
import { useRef } from "react";
import heroLandscape from "@/assets/india-connected-landscape.jpg";
import { IndiaMap } from "@/components/site/IndiaMap";
import { Pill } from "@/components/site/primitives";
import { hero, site } from "@/content/site";
import { cn } from "@/lib/utils";

const layerTones = ["bg-brand", "bg-flame", "bg-sky", "bg-sky-soft text-navy"] as const;
const layerIcons = [House, Network, Building2, Globe2];

function HeroCards() {
  const { profile, map, intelligence, sectors, network } = hero.cards;
  const workerName = profile.fields.find((field) => field.label === "Name")?.value;

  return (
    <div className="tilt-stage mt-14 sm:mt-20">
      <motion.div
        initial={{ opacity: 0, y: 60 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1, delay: 0.35, ease: [0.2, 0.7, 0.2, 1] }}
        className="no-scrollbar -mx-5 flex snap-x snap-mandatory gap-4 overflow-x-auto px-5 pb-6 pt-2 text-left sm:mx-0 sm:grid sm:grid-cols-2 sm:overflow-visible sm:px-0 lg:tilt-plane lg:grid-cols-12"
      >
        <article className="hero-float w-[min(88vw,380px)] min-w-0 shrink-0 snap-center self-start overflow-hidden rounded-[1.75rem] bg-card text-foreground shadow-float ring-1 ring-on-dark/50 sm:col-span-2 sm:w-auto lg:col-span-5 lg:translate-y-2">
          <div className="bg-gradient-navy px-5 py-3.5 text-on-dark">
            <p className="font-mono text-[0.62rem] uppercase tracking-[0.16em]">{profile.label}</p>
          </div>
          <div className="px-5 pb-4 pt-4">
            <p className="font-mono text-[0.58rem] uppercase tracking-[0.14em] text-brand">Name</p>
            <h3 className="mt-1 text-2xl font-semibold tracking-tight text-foreground">{workerName}</h3>
            <dl className="mt-4 divide-y divide-border border-y border-border">
              {profile.fields
                .filter((field) => field.label !== "Name")
                .map((field) => (
                  <div key={field.label} className="grid grid-cols-[8.6rem_minmax(0,1fr)] gap-3 py-2.5">
                    <dt className="font-mono text-[0.58rem] uppercase leading-5 tracking-[0.08em] text-muted-foreground">
                      {field.label}
                    </dt>
                    <dd className="text-sm font-medium leading-5 text-foreground">{field.value}</dd>
                  </div>
                ))}
            </dl>
            <p className="mt-3.5 text-xs leading-relaxed text-muted-foreground">{profile.disclaimer}</p>
          </div>
        </article>

        <div className="flex w-[260px] shrink-0 snap-center flex-col gap-3 sm:col-span-2 sm:w-auto sm:grid sm:grid-cols-2 lg:col-span-7 lg:gap-4">
          <article className="hero-float-slow glass-card w-[250px] min-w-0 shrink-0 snap-center self-start rounded-3xl p-5 sm:w-auto">
            <div className="flex items-center justify-between">
              <p className="mono-label inline-flex items-center gap-2 text-muted-foreground">
                <House className="h-4 w-4 text-brand" strokeWidth={1.8} aria-hidden />
                {map.label}
              </p>
              <MapPin className="h-4 w-4 text-brand" strokeWidth={1.8} aria-hidden />
            </div>
            <IndiaMap className="mx-auto mt-3 h-28 w-28" />
            <h3 className="mt-2 text-lg font-semibold tracking-tight text-foreground">{map.title}</h3>
            <p className="mt-2 text-sm leading-relaxed text-muted-foreground">{map.body}</p>
            <ul className="mt-4 grid grid-cols-2 gap-2">
              {map.layers.map((layer, index) => {
                const LayerIcon = layerIcons[index] ?? House;
                return (
                  <li
                    key={layer}
                    className={cn(
                      "flex items-center gap-2 rounded-2xl px-3 py-2.5 font-mono text-[0.6rem] uppercase tracking-wider text-on-dark",
                      layerTones[index],
                    )}
                  >
                    <LayerIcon className="h-3.5 w-3.5 shrink-0" strokeWidth={1.8} aria-hidden />
                    {layer}
                  </li>
                );
              })}
            </ul>
          </article>

          <article className="hero-float w-[260px] min-w-0 shrink-0 snap-center self-start rounded-3xl bg-gradient-brand p-5 text-on-dark shadow-glow sm:w-auto">
            <p className="font-mono text-[0.6rem] uppercase tracking-[0.12em] text-on-dark/70">
              {intelligence.label}
            </p>
            <h3 className="mt-2 text-lg font-semibold leading-snug tracking-tight">
              {intelligence.title}
            </h3>
            <p className="mt-3 text-sm leading-relaxed text-on-dark/80">{intelligence.body}</p>
            <ul className="mt-4 flex flex-wrap gap-1.5">
              {intelligence.tags.map((item) => (
                <li
                  key={item}
                  className="rounded-full border border-on-dark/25 bg-on-dark/10 px-2.5 py-1 font-mono text-[0.58rem] uppercase tracking-wider text-on-dark/90"
                >
                  {item}
                </li>
              ))}
            </ul>
          </article>

          <article className="hero-float-slow relative w-[250px] min-w-0 shrink-0 snap-center self-start overflow-hidden rounded-3xl bg-gradient-navy p-5 text-on-dark shadow-glow sm:w-auto">
            <p className="font-mono text-[0.58rem] uppercase tracking-[0.12em] text-on-dark/65">
              {network.label}
            </p>
            <h3 className="mt-1.5 text-sm font-semibold">{network.title}</h3>
            <p className="mt-2 text-xs leading-relaxed text-on-dark/80">{network.body}</p>
          </article>

          <article className="hero-float glass-card w-[250px] min-w-0 shrink-0 snap-center self-start rounded-3xl p-5 sm:w-auto">
            <p className="mono-label text-muted-foreground">{sectors.label}</p>
            <h3 className="mt-1.5 text-sm font-semibold text-foreground">{sectors.title}</h3>
            <ul className="mt-3 flex flex-wrap gap-1.5">
              {sectors.items.map((item) => (
                <li
                  key={item}
                  className="rounded-full bg-sky-pale px-2.5 py-1 font-mono text-[0.58rem] uppercase tracking-wider text-brand"
                >
                  {item}
                </li>
              ))}
            </ul>
          </article>
        </div>
      </motion.div>
    </div>
  );
}

export function Hero() {
  const sectionRef = useRef<HTMLElement>(null);
  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ["start start", "end start"],
  });
  const cardsY = useTransform(scrollYProgress, [0, 1], [0, 90]);
  const textY = useTransform(scrollYProgress, [0, 1], [0, -50]);
  const textOpacity = useTransform(scrollYProgress, [0, 0.6], [1, 0]);

  return (
    <section ref={sectionRef} id="home" aria-labelledby="hero-heading" className="px-2 pt-2 sm:px-3 sm:pt-3">
      <div className="relative mx-auto max-w-[1440px] overflow-hidden rounded-3xl bg-sky px-5 pb-32 pt-32 text-center sm:px-10 sm:pb-44 sm:pt-40 lg:px-16">
        <img
          src={heroLandscape}
          alt="Indian village homes, green fields and a textile factory connected by a village road"
          width={1920}
          height={1152}
          fetchPriority="high"
          className="ecosystem-hero-photo pointer-events-none absolute inset-x-0 bottom-0 w-full object-cover object-bottom"
        />
        <div aria-hidden className="hero-scrim pointer-events-none absolute inset-0" />

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: [0.2, 0.7, 0.2, 1] }}
          style={{ y: textY, opacity: textOpacity }}
          className="relative z-10 mx-auto max-w-4xl"
        >
          <p className="glass-dark mono-label mx-auto mb-7 inline-flex items-center gap-2 rounded-full px-3.5 py-1.5 text-on-dark">
            <span aria-hidden className="h-1.5 w-1.5 shrink-0 rounded-full bg-signal" />
            <span className="sm:hidden">{site.brandRelationship.split(" · ")[0]}</span>
            <span className="hidden sm:inline">{site.brandRelationship}</span>
          </p>
          <h1
            id="hero-heading"
            className="display-type text-balance text-4xl text-on-dark sm:text-5xl lg:text-[4.25rem]"
          >
            {hero.headline}
          </h1>
          <p className="mx-auto mt-6 max-w-3xl text-pretty text-base leading-relaxed text-on-dark/90 sm:text-lg">
            {hero.subhead}
          </p>

          <div className="mt-9 flex flex-wrap items-center justify-center gap-3">
            <Pill href={hero.primaryCta.href} variant="navy" arrow>
              {hero.primaryCta.label}
            </Pill>
            <Pill href={hero.secondaryCta.href} variant="light">
              {hero.secondaryCta.label}
            </Pill>
          </div>

          <p className="mt-7 font-mono text-[0.66rem] uppercase tracking-[0.14em] text-on-dark/80">
            {hero.trustLine}
          </p>
        </motion.div>

        <motion.div style={{ y: cardsY }} className="relative z-10 mx-auto max-w-6xl">
          <HeroCards />
        </motion.div>
      </div>
    </section>
  );
}
