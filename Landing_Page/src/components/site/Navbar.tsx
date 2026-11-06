import { Menu, X } from "lucide-react";
import { useEffect, useId, useState } from "react";
import { Logo } from "@/components/site/Logo";
import { Pill } from "@/components/site/primitives";
import { navLinks, site } from "@/content/site";
import { cn } from "@/lib/utils";

const sectionIds = navLinks.map((link) => link.href.slice(1));

export function Navbar() {
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState("");
  const menuId = useId();

  useEffect(() => {
    const update = () => {
      const marker = 96;
      let current = "";
      let bestTop = Number.NEGATIVE_INFINITY;
      for (const id of sectionIds) {
        const el = document.getElementById(id);
        if (!el) continue;
        const top = el.getBoundingClientRect().top;
        if (top <= marker && top > bestTop) {
          bestTop = top;
          current = id;
        }
      }
      setActive((prev) => (prev === current ? prev : current));
    };

    update();
    window.addEventListener("scroll", update, { passive: true });
    window.addEventListener("resize", update);
    return () => {
      window.removeEventListener("scroll", update);
      window.removeEventListener("resize", update);
    };
  }, []);

  useEffect(() => {
    if (!open) return;
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") setOpen(false);
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [open]);

  return (
    <header className="sticky top-0 z-50 border-b border-border bg-card">
      <div className="mx-auto flex h-16 max-w-7xl items-center gap-3 px-4 sm:px-6 lg:px-8">
        <Logo />

        <nav aria-label="Primary" className="hidden min-w-0 flex-1 items-center justify-center xl:flex">
          {navLinks.map((link) => {
            const id = link.href.slice(1);
            const isActive = active === id;
            return (
              <a
                key={link.href}
                href={link.href}
                aria-current={isActive ? "true" : undefined}
                className={cn(
                  "rounded-full px-2.5 py-2 font-mono text-[0.62rem] uppercase tracking-[0.08em] transition",
                  isActive
                    ? "bg-sky-pale text-brand"
                    : "text-muted-foreground hover:bg-muted hover:text-foreground",
                )}
              >
                {link.label}
              </a>
            );
          })}
        </nav>

        <div className="ml-auto flex items-center gap-2">
          <Pill href="#partner" variant="primary" arrow className="hidden xl:inline-flex">
            Partner With Us
          </Pill>
          <button
            type="button"
            className="inline-flex h-10 w-10 items-center justify-center rounded-full bg-muted text-foreground transition hover:bg-sky-pale xl:hidden"
            aria-expanded={open}
            aria-controls={open ? menuId : undefined}
            aria-label={open ? "Close menu" : "Open menu"}
            onClick={() => setOpen((value) => !value)}
          >
            {open ? <X className="h-4 w-4" /> : <Menu className="h-4 w-4" />}
          </button>
        </div>
      </div>

      {open ? (
        <div id={menuId} className="border-t border-border bg-card xl:hidden">
          <nav aria-label="Mobile" className="mx-auto flex max-h-[calc(100dvh-4rem)] max-w-7xl flex-col gap-1 overflow-y-auto px-4 py-3 sm:px-6">
            {navLinks.map((link) => {
              const id = link.href.slice(1);
              const isActive = active === id;
              return (
                <a
                  key={link.href}
                  href={link.href}
                  aria-current={isActive ? "true" : undefined}
                  className={cn(
                    "rounded-2xl px-4 py-3 font-mono text-[0.72rem] uppercase tracking-[0.1em]",
                    isActive ? "bg-sky-pale text-brand" : "text-foreground hover:bg-muted",
                  )}
                  onClick={() => setOpen(false)}
                >
                  {link.label}
                </a>
              );
            })}
            <Pill
              href="#partner"
              variant="primary"
              arrow
              className="mt-2 w-full justify-between"
              onClick={() => setOpen(false)}
            >
              Partner With Us
            </Pill>
            <p className="mt-3 px-4 pb-1 text-xs text-muted-foreground">{site.brandRelationship}</p>
          </nav>
        </div>
      ) : null}
    </header>
  );
}
