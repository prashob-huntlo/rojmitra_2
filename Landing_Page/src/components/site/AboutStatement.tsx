import { motion, useScroll, useTransform, type MotionValue } from "framer-motion";
import { BarChart3, MapPin, Star } from "lucide-react";
import { useRef, type ReactNode } from "react";
import { aboutStatement } from "@/content/site";
import { cn } from "@/lib/utils";

type Token =
  | { kind: "text"; value: string; tone?: "brand" | "flame" | undefined }
  | { kind: "icon"; node: ReactNode; tone: "brand" | "flame" | "sky" };

const chipTones = {
  brand: "bg-brand text-on-dark",
  flame: "bg-flame text-on-dark",
  sky: "bg-sky text-on-dark",
} as const;

function words(value: string, tone?: "brand" | "flame"): Token[] {
  return value
    .split(/(\s+)/)
    .filter((w) => w.trim().length > 0)
    .map((w) => ({ kind: "text" as const, value: w, tone }));
}

const tokens: Token[] = [
  ...words(aboutStatement.lead),
  { kind: "icon", tone: "brand", node: <MapPin className="h-4 w-4" strokeWidth={2} /> },
  ...words(aboutStatement.visible + aboutStatement.middle.split(" ")[0], "brand"),
  ...words(aboutStatement.middle.split(" ").slice(1).join(" ")),
  { kind: "icon", tone: "flame", node: <BarChart3 className="h-4 w-4" strokeWidth={2} /> },
  ...words(aboutStatement.informed + aboutStatement.and.split(" ")[0], "flame"),
  ...words(aboutStatement.and.split(" ").slice(1).join(" ")),
  { kind: "icon", tone: "sky", node: <Star className="h-4 w-4" strokeWidth={2} /> },
  ...words(aboutStatement.accessible + aboutStatement.period, "brand"),
];

function Word({
  token,
  progress,
  range,
}: {
  token: Token;
  progress: MotionValue<number>;
  range: [number, number];
}) {
  const opacity = useTransform(progress, range, [0.14, 1]);
  if (token.kind === "icon") {
    return (
      <motion.span
        style={{ opacity }}
        className={cn(
          "mx-1 inline-flex h-9 w-9 -translate-y-1 items-center justify-center rounded-full align-middle sm:h-11 sm:w-11",
          chipTones[token.tone],
        )}
        aria-hidden
      >
        {token.node}
      </motion.span>
    );
  }
  return (
    <motion.span
      style={{ opacity }}
      className={cn(
        "mr-[0.25em] inline-block",
        token.tone === "brand" && "text-brand",
        token.tone === "flame" && "text-flame",
      )}
    >
      {token.value}
    </motion.span>
  );
}

export function AboutStatement() {
  const ref = useRef<HTMLHeadingElement>(null);
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start 85%", "end 45%"] });
  const label = `${aboutStatement.lead} ${aboutStatement.visible}${aboutStatement.middle} ${aboutStatement.informed}${aboutStatement.and} ${aboutStatement.accessible}${aboutStatement.period}`;

  return (
    <section
      aria-labelledby="about-heading"
      className="mx-auto max-w-5xl px-4 py-20 text-center sm:px-6 sm:py-28 lg:px-8"
    >
      <h2
        id="about-heading"
        ref={ref}
        aria-label={label}
        className="display-type text-balance text-3xl text-foreground sm:text-5xl lg:text-6xl"
      >
        {tokens.map((token, i) => {
          const start = i / tokens.length;
          const end = Math.min(1, start + 1.5 / tokens.length);
          return <Word key={i} token={token} progress={scrollYProgress} range={[start, end]} />;
        })}
      </h2>
      <p className="mx-auto mt-8 max-w-2xl text-base leading-relaxed text-muted-foreground sm:text-lg">
        {aboutStatement.support}
      </p>
    </section>
  );
}
