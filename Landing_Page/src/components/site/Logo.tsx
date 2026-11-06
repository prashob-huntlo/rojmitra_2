import logo from "@/assets/rojmitra-logo.png";
import { cn } from "@/lib/utils";

const sizes = {
  sm: "h-8 w-auto sm:h-9",
  md: "h-11 w-auto sm:h-12",
  lg: "h-14 w-auto",
} as const;

export function Logo({
  className,
  href = "#home",
  size = "sm",
}: {
  className?: string;
  href?: string;
  size?: keyof typeof sizes;
}) {
  return (
    <a
      href={href}
      className={cn(
        "inline-flex shrink-0 items-center rounded-lg focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        className,
      )}
      aria-label="RojMitra home"
    >
      <img
        src={logo}
        alt="RojMitra, Mapping India's Workforce"
        width={1628}
        height={540}
        className={sizes[size]}
      />
    </a>
  );
}
