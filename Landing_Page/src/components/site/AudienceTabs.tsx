import { motion } from "framer-motion";
import { CheckCircle2 } from "lucide-react";
import { useId, useRef, useState } from "react";
import { Pill, StoryPhoto } from "@/components/site/primitives";
import { audienceImages } from "@/content/imagery";
import { audiences } from "@/content/site";
import { cn } from "@/lib/utils";

type AudienceId = (typeof audiences.tabs)[number]["id"];

export function AudienceTabs() {
  const [active, setActive] = useState<AudienceId>(audiences.tabs[0].id);
  const baseId = useId();
  const tabRefs = useRef<Partial<Record<AudienceId, HTMLButtonElement | null>>>({});
  const current = audiences.tabs.find((tab) => tab.id === active) ?? audiences.tabs[0];
  const ids = audiences.tabs.map((t) => t.id);
  const image = audienceImages[current.id];

  const selectAt = (index: number, focus = false) => {
    const next = ids[(index + ids.length) % ids.length];
    if (!next) return;
    setActive(next);
    if (focus) requestAnimationFrame(() => tabRefs.current[next]?.focus());
  };

  return (
    <div>
      <div
        role="tablist"
        aria-label="Audiences"
        className="no-scrollbar mx-auto flex w-fit max-w-full gap-1 overflow-x-auto rounded-full border border-border bg-card p-1 shadow-soft"
      >
        {audiences.tabs.map((tab, index) => {
          const selected = tab.id === active;
          return (
            <button
              key={tab.id}
              ref={(node) => {
                tabRefs.current[tab.id] = node;
              }}
              id={`${baseId}-tab-${tab.id}`}
              type="button"
              role="tab"
              aria-selected={selected}
              aria-controls={`${baseId}-panel`}
              tabIndex={selected ? 0 : -1}
              className={cn(
                "shrink-0 rounded-full px-4 py-2.5 font-mono text-[0.66rem] uppercase tracking-[0.1em] transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
                selected ? "bg-navy text-on-dark" : "text-muted-foreground hover:text-foreground",
              )}
              onClick={() => setActive(tab.id)}
              onKeyDown={(event) => {
                if (event.key === "ArrowRight") {
                  event.preventDefault();
                  selectAt(index + 1, true);
                }
                if (event.key === "ArrowLeft") {
                  event.preventDefault();
                  selectAt(index - 1, true);
                }
                if (event.key === "Home") {
                  event.preventDefault();
                  selectAt(0, true);
                }
                if (event.key === "End") {
                  event.preventDefault();
                  selectAt(ids.length - 1, true);
                }
              }}
            >
              {tab.title}
            </button>
          );
        })}
      </div>

      <div
        id={`${baseId}-panel`}
        role="tabpanel"
        aria-labelledby={`${baseId}-tab-${current.id}`}
        className="card-surface mt-6 grid gap-6 p-2 lg:grid-cols-[1.05fr_1fr] lg:items-stretch"
      >
        <div className="p-5 sm:p-8">
          <p className="mono-label text-brand">{current.title}</p>
          <h3 className="display-type mt-3 text-2xl text-foreground sm:text-3xl">{current.body}</h3>
          <ul className="mt-7 grid gap-2.5">
            {current.points.map((point) => (
              <li
                key={point}
                className="flex items-center gap-3 rounded-2xl border border-border bg-surface px-4 py-3 text-sm text-foreground sm:text-base"
              >
                <CheckCircle2 aria-hidden className="h-5 w-5 shrink-0 text-signal" strokeWidth={1.8} />
                {point}
              </li>
            ))}
          </ul>
          <div className="mt-8">
            <Pill href={current.cta.href} variant="primary" arrow>
              {current.cta.label}
            </Pill>
          </div>
        </div>
        {image ? (
          <motion.div
            key={current.id}
            initial={{ opacity: 0, scale: 1.02 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.5, ease: [0.2, 0.7, 0.2, 1] }}
            className="group"
          >
            <StoryPhoto image={image} className="aspect-[4/3] h-full lg:aspect-auto lg:min-h-[26rem]">
              <p className="glass-dark absolute bottom-3 left-3 rounded-full px-3 py-1.5 font-mono text-[0.6rem] uppercase tracking-[0.12em] text-on-dark">
                {current.title}
              </p>
            </StoryPhoto>
          </motion.div>
        ) : null}
      </div>
    </div>
  );
}
