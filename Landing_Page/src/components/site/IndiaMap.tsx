import { motion, useReducedMotion } from "framer-motion";
import { indiaStates } from "@/content/india-geography";

/** Geographic map with the worker's Bihar → Tamil Nadu journey. */
export function IndiaMap({ className }: { className?: string }) {
  const reducedMotion = useReducedMotion();
  return (
    <svg
      viewBox="0 0 190 205"
      role="img"
      aria-label="Geographic map of India showing Bihar and Tamil Nadu connected by a worker journey"
      className={className}
      fill="none"
    >
      {indiaStates.map((state) => (
        <path
          key={state.name}
          d={state.path}
          fill={state.name === "Bihar" || state.name === "Tamil Nadu" ? "var(--sky-soft)" : "var(--sky-pale)"}
          stroke="var(--brand)"
          strokeWidth={0.65}
          strokeLinejoin="round"
        />
      ))}
      <motion.path
        d="M105.8 90.29 Q112 140 62.9 170.9"
        stroke="var(--brand)"
        strokeWidth={1.5}
        strokeDasharray="3 3"
        initial={reducedMotion ? false : { pathLength: 0 }}
        animate={{ pathLength: 1 }}
        transition={{ duration: 1.4, delay: 0.5 }}
      />
      <circle cx={105.8} cy={90.29} r={3} fill="var(--flame)" stroke="var(--card)" strokeWidth={1} />
      <circle cx={62.9} cy={170.9} r={3} fill="var(--signal)" stroke="var(--card)" strokeWidth={1} />
    </svg>
  );
}