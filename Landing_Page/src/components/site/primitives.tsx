import { cva, type VariantProps } from "class-variance-authority";
import { motion } from "framer-motion";
import { ArrowUpRight } from "lucide-react";
import type { ComponentType, ReactNode } from "react";
import { cn } from "@/lib/utils";

/* ---------- Button ---------- */

const pillVariants = cva(
  "group inline-flex items-center justify-center gap-2 rounded-full font-mono text-[0.7rem] uppercase tracking-[0.1em] transition-all duration-300 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
  {
    variants: {
      variant: {
        primary: "bg-brand text-primary-foreground shadow-soft hover:bg-brand-deep",
        navy: "bg-navy text-on-dark shadow-soft hover:bg-navy-soft",
        ghost: "glass-dark text-on-dark hover:bg-on-dark/25",
        light: "bg-card text-foreground shadow-soft hover:bg-sky-pale",
        outline:
          "border border-border bg-card text-foreground hover:border-brand/40 hover:bg-sky-pale/60",
      },
      size: {
        default: "py-2.5 pl-5 pr-5",
        arrow: "py-1.5 pl-5 pr-1.5",
      },
    },
    defaultVariants: { variant: "primary", size: "default" },
  },
);

type PillProps = VariantProps<typeof pillVariants> & {
  children: ReactNode;
  href?: string;
  arrow?: boolean;
  className?: string;
  onClick?: () => void;
};

export function Pill({ children, href, arrow, variant, className, onClick }: PillProps) {
  const classes = cn(pillVariants({ variant, size: arrow ? "arrow" : "default" }), className);
  const content = (
    <>
      <span>{children}</span>
      {arrow ? (
        <span
          aria-hidden
          className={cn(
            "inline-flex h-7 w-7 items-center justify-center rounded-full transition-transform duration-300 group-hover:-translate-y-0.5 group-hover:translate-x-0.5",
            variant === "light" || variant === "outline"
              ? "bg-brand text-primary-foreground"
              : "bg-card text-brand",
          )}
        >
          <ArrowUpRight className="h-3.5 w-3.5" strokeWidth={2} />
        </span>
      ) : null}
    </>
  );

  if (href) {
    return (
      <a href={href} className={classes} onClick={onClick}>
        {content}
      </a>
    );
  }
  return (
    <button type="button" className={classes} onClick={onClick}>
      {content}
    </button>
  );
}

/* ---------- Card ---------- */

export function Card({
  children,
  className,
  hover = true,
  as: Tag = "div",
}: {
  children: ReactNode;
  className?: string;
  hover?: boolean;
  as?: "div" | "article" | "li";
}) {
  return <Tag className={cn("card-surface p-6", hover && "card-lift", className)}>{children}</Tag>;
}

/* ---------- Labels & badges ---------- */

export function SectionLabel({
  children,
  className,
  tone = "default",
}: {
  children: ReactNode;
  className?: string;
  tone?: "default" | "on-dark";
}) {
  return (
    <p
      className={cn(
        "mono-label mb-4 inline-flex items-center gap-2",
        tone === "on-dark" ? "text-on-dark/75" : "text-muted-foreground",
        className,
      )}
    >
      <span
        aria-hidden
        className={cn("h-1.5 w-1.5 rounded-full", tone === "on-dark" ? "bg-on-dark" : "bg-brand")}
      />
      {children}
    </p>
  );
}

export function BuildingBadge({ className }: { className?: string }) {
  return (
    <span
      className={cn(
        "inline-flex shrink-0 items-center gap-1.5 rounded-full border border-flame/25 bg-flame-pale px-2.5 py-0.5 font-mono text-[0.62rem] uppercase tracking-[0.1em] text-flame",
        className,
      )}
    >
      <span aria-hidden className="h-1 w-1 rounded-full bg-flame" />
      In build
    </span>
  );
}

export function LiveBadge({ className, children = "Live" }: { className?: string; children?: ReactNode }) {
  return (
    <span
      className={cn(
        "inline-flex shrink-0 items-center gap-1.5 rounded-full border border-signal/25 bg-signal-pale px-2.5 py-0.5 font-mono text-[0.62rem] uppercase tracking-[0.1em] text-signal",
        className,
      )}
    >
      <span aria-hidden className="h-1 w-1 rounded-full bg-signal" />
      {children}
    </span>
  );
}

type IconType = ComponentType<{ className?: string; strokeWidth?: number }>;

export function IconBadge({
  icon: Icon,
  tone = "brand",
  className,
}: {
  icon: IconType;
  tone?: "brand" | "navy" | "signal" | "sky" | "on-dark";
  className?: string;
}) {
  const tones = {
    brand: "bg-sky-pale text-brand",
    navy: "bg-navy text-on-dark",
    signal: "bg-signal-pale text-signal",
    sky: "bg-on-dark text-brand",
    "on-dark": "bg-on-dark/15 text-on-dark",
  } as const;
  return (
    <span
      aria-hidden
      className={cn(
        "inline-flex h-11 w-11 shrink-0 items-center justify-center rounded-full",
        tones[tone],
        className,
      )}
    >
      <Icon className="h-5 w-5" strokeWidth={1.6} />
    </span>
  );
}

/* ---------- Headline with muted trailing sentences ---------- */

export function Headline({
  text,
  id,
  as: Tag = "h2",
  className,
  mutedClassName = "text-muted-foreground/70",
}: {
  text: string;
  id?: string;
  as?: "h1" | "h2" | "h3";
  className?: string;
  mutedClassName?: string;
}) {
  const parts = text.match(/[^.!?]+[.!?]+\s*|[^.!?]+$/g) ?? [text];
  return (
    <Tag id={id} className={cn("display-type text-balance", className)}>
      {parts.map((part, i) => (
        <span key={i} className={i === 0 ? undefined : mutedClassName}>
          {part}
        </span>
      ))}
    </Tag>
  );
}

/* ---------- Story photo frame ---------- */

export function StoryPhoto({
  image,
  className,
  children,
  priority = false,
}: {
  image: { src: string; alt: string };
  className?: string;
  children?: ReactNode;
  priority?: boolean;
}) {
  return (
    <div className={cn("relative overflow-hidden rounded-[0.95rem] bg-muted", className)}>
      <img
        src={image.src}
        alt={image.alt}
        loading={priority ? "eager" : "lazy"}
        decoding="async"
        className="h-full w-full object-cover transition-transform duration-700 ease-out group-hover:scale-[1.04]"
      />
      <div aria-hidden className="photo-scrim pointer-events-none absolute inset-0" />
      {children}
    </div>
  );
}

/* ---------- Scroll reveal ---------- */

export function Reveal({
  children,
  className,
  delay = 0,
  as = "div",
}: {
  children: ReactNode;
  className?: string;
  delay?: number;
  as?: "div" | "li" | "article";
}) {
  const Comp = as === "li" ? motion.li : as === "article" ? motion.article : motion.div;
  return (
    <Comp
      className={className}
      initial={{ opacity: 0, y: 18 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-60px" }}
      transition={{ duration: 0.6, delay, ease: [0.2, 0.7, 0.2, 1] }}
    >
      {children}
    </Comp>
  );
}

export function SectionHeader({
  label,
  headline,
  id,
  body,
  align = "center",
  className,
}: {
  label: string;
  headline: string;
  id: string;
  body?: string;
  align?: "center" | "left";
  className?: string;
}) {
  return (
    <Reveal
      className={cn(
        "max-w-3xl",
        align === "center" ? "mx-auto text-center" : "text-left",
        className,
      )}
    >
      <SectionLabel>{label}</SectionLabel>
      <Headline
        id={id}
        text={headline}
        className="text-3xl text-foreground sm:text-4xl lg:text-[2.85rem]"
      />
      {body ? (
        <p className="mt-5 text-pretty text-base leading-relaxed text-muted-foreground sm:text-lg">
          {body}
        </p>
      ) : null}
    </Reveal>
  );
}
