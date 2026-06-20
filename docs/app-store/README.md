# app-store

[![CI](https://github.com/MenkeTechnologies/app-store/actions/workflows/ci.yml/badge.svg)](https://github.com/MenkeTechnologies/app-store/actions/workflows/ci.yml)

MenkeTechnologies App Store — a static storefront for the MenkeTechnologies
stack.

Every MenkeTechnologies-authored repo in the meta collection is listed, across
six categories (Desktop Apps, Audio Plugins, Developer Tools, CLI Tools, Zsh
Plugins, stryke Packages):

- **Paid** — `audio haxor`, `traderview`, `zpwr-synth`, `zpwr-fx`,
  `zpwr-midi-fx`.
- **Free / open source** — everything else: `zshrs`, `stryke`, the Rust CLI
  tools, the **stryke package ecosystem** (23 packages), `zpwr`,
  `zsh-more-completions`, `fusevm`, and the rest of the zsh-plugin family.

**Third-party forks are intentionally excluded** (`fzf-tab`, `zsh-z`, `zunit`,
`kubectl-aliases`, `revolver`, `tmux-fzf-url`, `fasd-simple`, etc.) — they are
other people's projects mirrored in the org, not MenkeTechnologies products, so
storefronting them would misattribute authorship.

### Free vs paid, and download targets

A product is free whenever its first tier price is `0` (the `isFree` helper).
Free products render a **Download** button; paid products render Add-to-cart.
The download target is chosen automatically:

- a GitHub **release** exists → links to `releases/latest`;
- **no release** → links to the repo's `/tags` page (per-tag source archives).

### Catalog structure (single source of truth = `store.js`)

- Distinct products (apps, plugins, CLI tools) are explicit objects in the
  `PRODUCTS` array.
- The 23 stryke packages are generated from a compact table via `strykePkg()`.
- The other repos (zsh plugins, dev tools) are generated via `metaProduct()`.
- Long-form detail copy (`overview` + rich `features`) lives in the `DETAILS`
  map — ported from each repo's README/source — and is merged into `PRODUCTS`
  at load. The product-detail page renders the overview and the full feature
  list; cards/search/filters/stats are all derived, no hardcoded counts.

To add another repo: append one object (or one table row) and, optionally, a
`DETAILS` entry for the rich copy.

### Screenshots

GUI products (the desktop apps and audio plugins) carry a `screenshots` array
in their `DETAILS` entry — `[{ src, cap }]`. When present:

- the grid card and the product-detail hero render the **first** screenshot
  instead of the letter glyph (products with no `screenshots` keep the glyph);
- the detail page renders a **Screenshots** gallery when there is more than one
  shot, and any image (hero or thumbnail) opens a keyboard-navigable lightbox
  (`←` / `→` to step, `Esc` to close).

Images live under `assets/` (one folder per multi-shot product, e.g.
`assets/audio-haxor/`). Source captures are retina PNGs; they are downsized to
≤1600 px and converted to WebP (`cwebp -q 82`) so each is ~50–160 KB. To add
shots for a product: drop the WebP files in `assets/`, then list them in that
product's `screenshots` array. A test asserts every referenced asset exists on
disk.

Uses the same HUD / cyberpunk design system as the strykelang docs
(`hud-static.css`, `tutorial.css`, `hud-theme.js`) so the store and the docs
share one visual language: Orbitron + Share Tech Mono, CRT scanlines, neon
borders, and five swappable color schemes (Cyberpunk, Midnight, Matrix, Ember,
Arctic) plus light/dark.

## Run

Pure static site — no build step. Open `index.html` in a browser, or serve the
directory:

```
python3 -m http.server 8000   # then visit http://localhost:8000
```

## Tests / CI

The storefront logic is covered by a dependency-free `node:test` suite that
loads `store.js` into a minimal DOM shim and asserts on the rendered HTML —
catalog size and unique ids, free-vs-paid download wiring, per-major-version
pricing copy, every detail page having an overview + rich features, and the
HTML pages referencing the shared assets. Run locally with:

```
node --test
```

`.github/workflows/ci.yml` runs this plus `node --check` on the JS and an
HTML sanity check on every push and pull request.

## Layout

| File            | Purpose                                                        |
|-----------------|---------------------------------------------------------------|
| `index.html`    | Storefront: hero, search, category filters, product grid      |
| `product.html`  | Product detail page, reads `?id=<product>` from the URL        |
| `checkout.html` | Shopify-style checkout: express wallets, card form, summary    |
| `docs/index.html`  | Developer documentation (HUD-themed)                       |
| `docs/report.html` | Engineering report (live catalog stats + metrics)         |
| `store.js`      | Product catalog (single source of truth) + grid/cart/checkout |
| `store.css`     | Commerce surfaces (cards, prices, cart, modal, checkout)      |
| `hud-static.css`| Vendored design system — CSS variables, header, buttons, CRT  |
| `tutorial.css`  | Vendored section / card / animation styles                    |
| `hud-theme.js`  | Theme / CRT / neon toggles + color-scheme switcher            |

## Editing the catalog

All products, prices, license tiers, and feature copy live in the `PRODUCTS`
array at the top of `store.js`. The grid, the detail page, the cart, and the
checkout all read from it — nothing is duplicated. To add a product, append one
object; to change a price, edit its `tiers`.

Prices are whole USD; `price: 0` (or a `$0` tier) renders as **Free**.

## Checkout

`checkout.html` is a two-column Shopify-style checkout (express wallet buttons,
contact, credit-card / Shop Pay / PayPal payment methods, billing address, and
a sticky order summary with discount codes). Add to cart → cart modal →
**Checkout** navigates here. Discount codes live in the `DISCOUNTS` map in
`store.js` (`LAUNCH20` = 20% off, `HUD10` = $10 off by default).

### Payments are client-side placeholders

`completeOrder()` in `store.js` simulates a successful order — **no real charge
happens**. GitHub Pages is static-only (no server), so wire each method to a
provider that supports a client-side or redirect flow:

- **Shopify (recommended for this layout)** — the screenshot's checkout is
  Shopify's own hosted page. Point the wallet/Shop-Pay buttons (and the
  `goCheckout` redirect) at your Shopify checkout URL; Shopify hosts the real
  checkout, so no backend is needed. Requires your store domain + variant IDs.
- **PayPal** — load the PayPal JS SDK with your public client ID and render
  Smart Buttons into `#paypalButtonContainer`. Works on static hosting; for
  verified server-side capture add a serverless function.
- **Stripe / Google Pay / Venmo** — drop their SDKs into the matching
  `startWallet()` / method branches.

The integration hooks are marked with `INTEGRATION HOOKS:` comments in
`wireCheckoutPage()`.

## Hosting on GitHub Pages

This is a pure static site, so GitHub Pages is the natural host — nothing is
disallowed. Enable it under repo **Settings → Pages → Source: Deploy from a
branch → `main` / root**, or via the CLI:

```
gh api -X POST repos/MenkeTechnologies/app-store/pages \
  -f 'source[branch]=main' -f 'source[path]=/'
```

The site then serves at `https://menketechnologies.github.io/app-store/`.
