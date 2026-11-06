<!-- LOVABLE:BEGIN -->
> [!IMPORTANT]
> This project is connected to [Lovable](https://lovable.dev). Avoid rewriting
> published git history — force pushing, or rebasing/amending/squashing commits
> that are already pushed — as it rewrites history on Lovable's side and the
> user will likely lose their project history.
>
> Commits you push to the connected branch sync back to Lovable and show up in
> the editor, so keep the branch in a working state.

## What Lovable manages

Rules outside this block are the project's own. Change the pieces below in
Lovable, not by hand. With the [Lovable MCP](https://mcp.lovable.dev)
connected, `send_message` asks Lovable to do it; otherwise ask the user to
use the editor.

- **Database.** Do not add or edit `supabase/migrations/` or `drizzle/`.
  Ask Lovable to change the schema.
- **Generated files.** Do not edit a file whose header says it is automatically
  generated.
- **AI gateway.** Keep model calls on Lovable's gateway, and keep
  `LOVABLE_API_KEY` out of browser code.
- **Connectors.** Lovable provides native connectors. `list_connectors` shows
  which are enabled; `add_connector` only returns the dashboard link. When a
  connector is enabled, calls go through the connector gateway and need
  `LOVABLE_API_KEY`. When Lovable does not provide one, users can bring their
  own key and store it in Secrets.
- **Secrets.** Lovable manages them. Do not put secret values in the repo.
<!-- LOVABLE:END -->

## Project rules

- All marketing copy lives in `src/content/site.ts` (ported verbatim from the original Next.js source); sections read from it, so edit copy there, never inline in components. Why: keeps `[X]` placeholders and CTAs editable in one place.
- The landing page is one route (`/`) composed of section components in `src/components/site/`, with in-page hash anchors for nav. Why: preserves the original single-page layout and anchor URLs.
- Site primitives (Pill, Card, Headline, Reveal, badges) live in `src/components/site/primitives.tsx`; keep `src/components/ui/` as untouched shadcn. Why: avoids case-clashing filenames with shadcn.
- Custom utilities in `src/styles.css` must not start with `text-` (tailwind-merge drops them next to font-size classes). Why: a `text-display` utility was silently removed by `cn()`.
- Photographic section backgrounds use imported assets with explicit dimensions, full-cover framing and semantic contrast overlays. Why: keeps contextual imagery visible and text readable without background gaps on narrow screens.
- The hero's compact geographic map renders simplified source boundaries from a browser-safe data module. Why: preserves real geographic shapes without a map service or oversized map dependency.
