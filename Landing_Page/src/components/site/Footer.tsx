import { Logo } from "@/components/site/Logo";
import { Pill } from "@/components/site/primitives";
import googlePlayLogo from "@/assets/store/google-play.svg";
import appleLogo from "@/assets/store/apple.svg";
import { Smartphone } from "lucide-react";
import { footer, navLinks, site } from "@/content/site";

function LinkColumn({ title, links }: { title: string; links: readonly { label: string; href: string }[] }) {
  return (
    <div>
      <p className="mono-label text-muted-foreground">{title}</p>
      <ul className="mt-4 space-y-2.5">
        {links.map((link) => (
          <li key={link.label}>
            <a href={link.href} className="text-sm text-foreground transition hover:text-brand">
              {link.label}
            </a>
          </li>
        ))}
      </ul>
    </div>
  );
}

export function Footer() {
  return (
    <footer className="overflow-hidden border-t border-border bg-card">
      <div className="mx-auto grid max-w-7xl grid-cols-2 gap-x-6 gap-y-10 px-4 pt-16 sm:px-6 md:grid-cols-3 xl:grid-cols-[1.4fr_0.7fr_0.75fr_1.15fr] lg:px-8">
        <div className="col-span-2 md:col-span-3 xl:col-span-1">
          <Logo size="md" />
          <p className="mt-4 text-sm font-medium text-foreground">{site.tagline}</p>
          <p className="mt-2 max-w-sm text-sm leading-relaxed text-muted-foreground">{footer.blurb}</p>
          <div className="mt-6">
            <Pill href={footer.partnerCta.href} variant="navy" arrow className="max-w-full font-sans text-xs normal-case tracking-normal">
              {footer.partnerCta.label}
            </Pill>
          </div>
        </div>

        <LinkColumn title="Navigate" links={navLinks} />
        <LinkColumn title="Explore" links={footer.explore} />

        <div className="col-span-2 min-w-0 sm:col-span-1">
          <p className="mono-label text-muted-foreground">{footer.app.title}</p>
          <div className="mt-4 rounded-lg border border-border bg-sky-pale p-4">
            <div className="mb-4 flex items-center gap-2 text-brand">
              <Smartphone aria-hidden className="h-5 w-5" strokeWidth={1.6} />
              <span className="text-sm font-semibold">{footer.app.audience}</span>
            </div>
            <div className="space-y-2">
              {footer.app.stores.map((store) => {
                const content = <>
                  <img src={store.id === "apple" ? appleLogo : googlePlayLogo} alt="" width={22} height={24} className="h-6 w-6 shrink-0 object-contain" />
                  <span className="min-w-0">
                    {!store.href && <span className="block text-[0.6rem] text-muted-foreground">{footer.app.status}</span>}
                    <span className="block text-sm font-semibold text-foreground">{store.label}</span>
                  </span>
                </>;
                const classes = "flex min-h-14 items-center gap-3 rounded-lg border border-border bg-card px-3 py-2";
                return store.href ? <a key={store.id} href={store.href} className={classes}>{content}</a> : <div key={store.id} className={classes}>{content}</div>;
              })}
            </div>
          </div>
        </div>
      </div>

      <div className="pointer-events-none mx-auto mt-10 max-w-[1440px] select-none px-2 text-center">
        <p
          aria-hidden
          className="wordmark-outline whitespace-nowrap pb-[0.06em] text-[19vw] font-semibold leading-[1] tracking-[-0.05em] xl:text-[16rem]"
        >
          RojMitra
        </p>
        <p className="mono-label -mt-2 text-muted-foreground sm:-mt-4">by EarlyJobs</p>
      </div>

      <div className="border-t border-border">
        <div className="mx-auto flex max-w-7xl flex-col gap-2 text-center sm:text-left px-4 py-5 text-xs text-muted-foreground sm:flex-row sm:items-center sm:justify-between sm:px-6 lg:px-8">
          <p className="font-mono uppercase tracking-[0.1em]">{site.trustLine}</p>
          <p>
            {footer.copyright.split(/(EarlyJobs)/).map((part, index) =>
              part === "EarlyJobs" ? (
                <a
                  key={index}
                  href="https://www.earlyjobs.ai/"
                  className="text-brand underline-offset-2 hover:underline"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  EarlyJobs
                </a>
              ) : (
                <span key={index}>{part}</span>
              ),
            )}
          </p>
          <p>{site.positioning}</p>
        </div>
      </div>
    </footer>
  );
}
