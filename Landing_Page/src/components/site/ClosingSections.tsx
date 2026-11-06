import { Plus } from "lucide-react";
import sharedEcosystem from "@/assets/india-shared-ecosystem.jpg";
import { Pill, Reveal, SectionHeader } from "@/components/site/primitives";
import { ecosystem, faq, finalCta, site } from "@/content/site";
import { cn } from "@/lib/utils";

export function Ecosystem() {
  return (
    <section id="ecosystem" aria-labelledby="ecosystem-heading" className="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8">
      <SectionHeader label={ecosystem.label} headline={ecosystem.headline} id="ecosystem-heading" />

      <ul className="mt-12 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {ecosystem.products.map((product, i) => (
          <Reveal
            key={product.name}
            as="li"
            delay={i * 0.06}
            className={cn(
              "card-lift flex min-h-[220px] flex-col p-6",
              product.highlight
                ? "rounded-[1.25rem] bg-gradient-navy text-on-dark shadow-glow"
                : "card-surface",
            )}
          >
            <p className={cn("mono-label", product.highlight ? "text-signal" : "text-muted-foreground")}>
              {product.highlight ? "Featured" : "Product"}
            </p>
            <div className="mt-auto min-h-[6.5rem] pt-10">
              <h3
                className={cn(
                  "text-2xl font-semibold tracking-tight",
                  product.highlight ? "text-on-dark" : "text-foreground",
                )}
              >
                {product.name}
              </h3>
              <p
                className={cn(
                  "mt-2 text-sm leading-relaxed",
                  product.highlight ? "text-on-dark/80" : "text-muted-foreground",
                )}
              >
                {product.role}
              </p>
            </div>
          </Reveal>
        ))}
      </ul>

      <Reveal className="mx-auto mt-10 max-w-3xl text-center">
        <p className="text-pretty text-base leading-relaxed text-foreground sm:text-lg">{ecosystem.closing}</p>
      </Reveal>
    </section>
  );
}

export function FAQSection() {
  return (
    <section id="faq" aria-labelledby="faq-heading" className="mx-auto max-w-3xl px-4 py-20 sm:px-6 lg:px-8">
      <SectionHeader label={faq.label} headline={faq.headline} id="faq-heading" />
      <div className="mt-12 space-y-3">
        {faq.items.map((item, index) => (
          <details
            key={item.question}
            name="rojmitra-faq"
            open={index === 0 ? true : undefined}
            className="group card-surface overflow-hidden"
          >
            <summary className="flex cursor-pointer list-none items-center justify-between gap-4 px-5 py-4 text-left text-base font-medium text-foreground marker:content-none hover:bg-surface focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring sm:px-6 sm:text-lg [&::-webkit-details-marker]:hidden">
              <span>{item.question}</span>
              <span
                aria-hidden
                className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full border border-border text-brand transition duration-300 group-open:rotate-45 group-open:border-transparent group-open:bg-navy group-open:text-on-dark"
              >
                <Plus className="h-4 w-4" />
              </span>
            </summary>
            <div className="border-t border-border px-5 py-4 sm:px-6">
              <p className="text-sm leading-relaxed text-muted-foreground sm:text-base">{item.answer}</p>
            </div>
          </details>
        ))}
      </div>
    </section>
  );
}

export function FinalCTA() {
  return (
    <section id="partner" aria-labelledby="final-cta-heading" className="px-2 pb-10 pt-4 sm:px-3">
      <div className="relative mx-auto max-w-[1440px] overflow-hidden rounded-3xl bg-sky px-5 pb-56 pt-20 text-center sm:px-12 sm:pb-72 sm:pt-28">
        <img
          src={sharedEcosystem}
          alt="Indian villagers walking and cycling between village homes, green fields and a nearby textile factory"
          width={1920}
          height={1152}
          loading="lazy"
          className="ecosystem-closing-photo pointer-events-none absolute inset-0 h-full w-full object-cover object-bottom"
        />
        <div aria-hidden className="cta-scrim pointer-events-none absolute inset-0" />

        <Reveal className="relative z-10 mx-auto max-w-3xl">
          <p className="glass-dark mono-label mx-auto mb-7 inline-flex items-center gap-2 rounded-full px-3.5 py-1.5 text-on-dark">
            <span aria-hidden className="h-1.5 w-1.5 rounded-full bg-flame" />
            {site.trustLine}
          </p>
          <h2
            id="final-cta-heading"
            className="display-type text-balance text-3xl text-on-dark sm:text-5xl lg:text-[3.5rem]"
          >
            {finalCta.headline}
          </h2>
          <p className="mx-auto mt-5 max-w-2xl text-base leading-relaxed text-on-dark/90 sm:text-lg">
            {finalCta.body}
          </p>
          <div className="mt-9 flex flex-wrap items-center justify-center gap-3">
            {finalCta.routes.map((route, index) => (
              <Pill
                key={route.label}
                href={route.href}
                variant={index === 0 ? "navy" : index === 1 ? "light" : "ghost"}
                arrow={index === 0}
              >
                {route.label}
              </Pill>
            ))}
          </div>
        </Reveal>
      </div>
    </section>
  );
}

export function Legal() {
  return (
    <section aria-label="Legal" className="mx-auto max-w-7xl px-4 pb-12 sm:px-6 lg:px-8">
      <div className="grid gap-4 md:grid-cols-2">
        <article id="privacy" className="card-surface p-6 sm:p-8">
          <h2 className="text-xl font-semibold tracking-tight text-foreground">Privacy</h2>
          <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
            Worker information is collected with the worker&apos;s consent. We design our data
            practices around the principle that data should open doors for the worker, not just be
            sold on. We are building responsible practices into the platform from the start. For
            privacy questions, contact{" "}
            <a
              className="text-brand underline-offset-2 hover:underline"
              href={`mailto:${site.contact.partnerEmail}?subject=Privacy%20enquiry`}
            >
              {site.contact.partnerEmail}
            </a>
            .
          </p>
        </article>
        <article id="terms" className="card-surface p-6 sm:p-8">
          <h2 className="text-xl font-semibold tracking-tight text-foreground">Terms</h2>
          <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
            This website describes RojMitra as an EarlyJobs initiative. Formal terms of use will be
            published here. Until then, reach out via{" "}
            <a
              className="text-brand underline-offset-2 hover:underline"
              href={`mailto:${site.contact.partnerEmail}?subject=Terms%20enquiry`}
            >
              {site.contact.partnerEmail}
            </a>{" "}
            for partnership or usage questions.
          </p>
        </article>
      </div>
    </section>
  );
}
