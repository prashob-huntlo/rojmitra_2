import { createFileRoute } from "@tanstack/react-router";
import { AboutStatement } from "@/components/site/AboutStatement";
import {
  Ecosystem,
  FAQSection,
  FinalCTA,
} from "@/components/site/ClosingSections";
import { Footer } from "@/components/site/Footer";
import { Hero } from "@/components/site/Hero";
import { Navbar } from "@/components/site/Navbar";
import {
  BuiltOnTrust,
  BusinessModel,
  HowItWorks,
  Impact,
  WhatWeMap,
  WhoItServes,
} from "@/components/site/PlatformSections";
import {
  BentoGrid,
  NetworkStrip,
  OurStory,
  TheProblem,
  WhatItIs,
} from "@/components/site/StorySections";
import { faq } from "@/content/site";

const title = "RojMitra by EarlyJobs | Village-Level Workforce Intelligence for India";
const description =
  "RojMitra maps, verifies and connects India's workforce at the grassroots. Village-level labour mapping, worker experience, availability and migration intelligence, so employers can finally see and reach nearby talent.";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title },
      { name: "description", content: description },
      { property: "og:title", content: title },
      { property: "og:description", content: description },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
      { name: "twitter:title", content: title },
      { name: "twitter:description", content: description },
    ],
    scripts: [
      {
        type: "application/ld+json",
        children: JSON.stringify({
          "@context": "https://schema.org",
          "@type": "FAQPage",
          mainEntity: faq.items.map((item) => ({
            "@type": "Question",
            name: item.question,
            acceptedAnswer: { "@type": "Answer", text: item.answer },
          })),
        }),
      },
    ],
  }),
  component: HomePage,
});

function HomePage() {
  return (
    <>
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-[100] focus:rounded-full focus:bg-brand focus:px-4 focus:py-2 focus:font-mono focus:text-xs focus:uppercase focus:tracking-wider focus:text-primary-foreground"
      >
        Skip to content
      </a>
      <Navbar />
      <main id="main">
        <Hero />
        <NetworkStrip />
        <AboutStatement />
        <BentoGrid />
        <OurStory />
        <TheProblem />
        <WhatItIs />
        <HowItWorks />
        <WhatWeMap />
        <WhoItServes />
        <BuiltOnTrust />
        <Impact />
        <BusinessModel />
        <Ecosystem />
        <FAQSection />
        <FinalCTA />
      </main>
      <Footer />
    </>
  );
}
