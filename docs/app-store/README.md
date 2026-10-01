```
    _    ____  ____    ____ _____ ___  ____  _____
   / \  |  _ \|  _ \  / ___|_   _/ _ \|  _ \| ____|
  / _ \ | |_) | |_) | \___ \ | || | | | |_) |  _|
 / ___ \|  __/|  __/   ___) || || |_| |  _ <| |___
/_/   \_\_|   |_|     |____/ |_| \___/|_| \_\_____|
```

![Static](https://img.shields.io/badge/static-HTML%20%2F%20CSS%20%2F%20JS-05d9e8?style=flat-square)
![No build](https://img.shields.io/badge/build-none-39ff14?style=flat-square)
![Docs](https://img.shields.io/badge/docs-meta%20Pages%20mirror-ff2a6d?style=flat-square)
![MenkeTechnologies](https://img.shields.io/badge/MenkeTechnologies-storefront-d300c5?style=flat-square)

### `[MENKETECHNOLOGIES APP STORE // DEPENDENCY-FREE STATIC STOREFRONT FOR THE ENTIRE CATALOG]`

> *"One catalog, every product, no backend."*

### [`Read the Docs`](https://menketechnologies.github.io/MenkeTechnologiesMeta/app-store) &middot; [`Engineering Report`](https://menketechnologies.github.io/MenkeTechnologiesMeta/app-store/report)

[![CI](https://github.com/MenkeTechnologies/app-store/actions/workflows/ci.yml/badge.svg)](https://github.com/MenkeTechnologies/app-store/actions/workflows/ci.yml)

MenkeTechnologies App Store — a static storefront for the MenkeTechnologies
stack.

Every MenkeTechnologies-authored repo in the meta collection is listed, across
eleven categories (Desktop Apps, Audio Plugins, Developer Tools, CLI Tools, Zsh
Plugins, znative Plugins, zmax-native Plugins, Editor Plugins, stryke Packages,
arb Packages, Publications):

- **Paid** — every Desktop App except `zwire` and `zmax-gui`: `zmusic`,
  `ztorrent`, `zlatex`, `zpdf`, `zphoto`, `zemail`, `zstation`, `zoffice`,
  `audio-haxor`, `traderview`, `ztranslator`, `zcite`, `zreq`, `ztunnel`,
  `zthrottle`, `zgo`, `zftp`, `zcontainer`, `zterminal`, `zpwr-daw`; the three
  Audio Plugins `zpwr-synth`, `zpwr-fx`, `zpwr-midi-fx`; plus most Publications —
  every companion book without exception, and the language reference manuals
  whose subject is itself free (`strykelang`, `zshrs`, `zmax`, `vimlrs`,
  `elisprs`, `awkrs`, `rubyrs`, `pythonrs`, `rlang`, `phplang`, `node-js`,
  `javars`, `scalars`, `groovyrs`, `kotlinrs`, `go-rs`, `tclrs`, `texrs`, `arb`).
- **Free / open source** — everything else: `zwire`, `zmax-gui`, `zshrs`,
  `stryke`, the Rust CLI tools, the **stryke package ecosystem**, the **arb
  dashboard packages**, the **zmax-native editor plugins**, `zpwr`,
  `zsh-more-completions`, `fusevm`, and the rest of the zsh-plugin family. The
  references and block catalogs that ship *with* a paid product
  (`zpwr-daw`, `zpwr-synth`, `zpwr-fx`, `zpwr-midi-fx`) stay free.

Both tiers are derived from the catalog itself: a product is free when its first
tier has no price (`isFree`, `store.js:4479`). `docs/report.html` carries the
per-category composition table.

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
- The stryke packages are generated from a compact table via `strykePkg()`.
- The other repos (zsh plugins, dev tools, arb packages) are generated via
  `metaProduct()`. The arb dashboards ship no build artifacts — `arb install
  <name>` is a git clone through the `arb-registry` git index — so they carry
  `hasRelease: false` and link their `/tags` page of source archives.
- Long-form detail copy (`overview` + rich `features`) lives in the `DETAILS`
  map — ported from each repo's README/source — and is merged into `PRODUCTS`
  at load. The product-detail page renders the overview and the full feature
  list; cards/search/filters/stats are all derived, no hardcoded counts.

To add another repo: append one object (or one table row) and, optionally, a
`DETAILS` entry for the rich copy.

### Documentation links

Repos that publish their `docs/` to **GitHub Pages** (served at
`menketechnologies.github.io/<id>/`) are listed in `DOC_REPOS`. Each gets a
**Docs ↗** button plus doc-cards in the detail page's Documentation section:
**Documentation** (`index.html`) and **Engineering Report** (`report.html`)
for all of them, and an **API Reference** (`reference.html`) for the ids in
`DOC_REFERENCE` (`strykelang`, `zshrs`). Products with no published Pages site
(proprietary apps, or Pages-disabled plugins that ship a PDF catalog instead)
are intentionally omitted so no link 404s. A shipped reference PDF still lives
in a product's `docs` array and renders alongside the HTML doc-cards.

**Only free PDFs ship in `docs/`.** The paid publications — the companion books
and the language reference manuals — are sold, not served: their PDFs are built
in `MenkeTechnologiesPublications/<title>/docs/` and are deliberately absent
from this repo, so nothing in `docs/` is a paid product handed out for free.
What remains is the free set: the GUI Automation Bus *reference*, the
`zgui-core` component catalog, and the audio-plugin references and block
catalogs that ship with their paid plugin. Every companion **book** is paid,
including *The GUI Automation Bus* — no book ships as a direct download.

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
disk, that nothing under `assets/` is unreferenced, and that the tree holds
WebP only — so `assets/` is screenshots and nothing else. Brand artwork (the
corporate mark and the favicon) is SVG and lives in `brand/`, outside that
budget.

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
| `contact.html`  | Contact form: POSTs to the Web3Forms relay, emails the inbox behind `WEB3FORMS_KEY` |
| `docs/index.html`  | Developer documentation (HUD-themed)                       |
| `docs/report.html` | Engineering report (live catalog stats + metrics)         |
| `docs/zpwr-patch-core-block-catalog.pdf` | Full shared block catalog (every shared module across the four plugins, with an alphabetical index) — linked as the "Full Catalog" doc from all three audio-plugin product pages (`docs[]` in `store.js`) |
| `docs/zpwr-{synth,fx,midi-fx}-block-catalog.pdf` | Per-plugin block catalogs (only the blocks that plugin ships) — each linked as the "Block Catalog" doc from that plugin's product page |
| `store.js`      | Product catalog (single source of truth) + grid/cart/checkout |
| `store.css`     | Commerce surfaces (cards, prices, cart, modal, checkout)      |
| `hud-static.css` | Vendored design system — CSS variables, header, buttons, CRT  |
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

## Contact

`contact.html` is a name / email / subject / message form linked from the
storefront breadcrumb. Since the site is static (no backend), submitting POSTs
to the [Web3Forms](https://web3forms.com) relay via `fetch`, which forwards the
message on. The request has a 15s timeout and shows inline
success / error so it can never hang on a slow or down relay; a hidden
`botcheck` honeypot filters bots. The relay routes to the inbox registered to
the public Web3Forms access key (`WEB3FORMS_KEY` in `store.js`), so the raw
address is never exposed on the page. `renderContactPage()` mounts into
`#contactRoot`, mirroring the checkout render pattern.

### Payments

**PayPal is wired for live capture.** Selecting the PayPal method (or the
express **PayPal** button) loads the PayPal JS SDK and renders Smart Buttons
into `#paypalButtonContainer`. The order is itemized from the cart and its total
matches the summary panel (including discounts), captured client-side; the
buyer's PayPal email is used for license delivery. The Live client ID is already
set in `store.js`:

```js
var PAYPAL_CLIENT_ID = 'AZZQjvgm…';   // from a Live REST app at developer.paypal.com
```

The client ID is a public credential — it ships in client JS and is safe to
commit. The API secret is never needed (client-side capture requires no
secret). Blank it out and the PayPal method falls back to a "not configured"
note instead of rendering the buttons (`store.js:5241-5242`). For
verified server-side capture, add a serverless function; the client-side flow
above works on any static host with no backend.

**Purchase notification / fulfillment.** PayPal emails the merchant account on
every captured payment — that email is the notification. Each order is enriched
so that email and the transaction record carry what a manual fulfillment needs:

- **items** — one line per product, `"<App> — <Tier> license"`;
- **description** — `Deliver to <buyer email> — <App> (<Tier>), …`;
- **custom_id** — the buyer's delivery email (falls back to the PayPal payer
  email if the contact field was left blank).

For a formatted email to a specific inbox and/or automated delivery of the
download link + license key, add a PayPal webhook (`PAYMENT.CAPTURE.COMPLETED`)
pointing at a serverless function that sends the mail — this fires server-side,
so it is reliable even if the buyer closes the tab after paying.

**Other methods are still client-side placeholders.** Card, Shop Pay, Google
Pay, and Venmo route through `completeOrder()` / `startWallet()` in `store.js`,
which simulates a successful order — **no real charge happens**. Wire each to a
provider with a client-side or redirect flow (e.g. a Shopify hosted checkout
URL for the wallet buttons, or the Stripe / Braintree SDKs).

## Hosting

The repo carries no Pages deploy workflow and has no Pages site configured —
`.github/workflows/ci.yml` is the only workflow. The `docs/` pages are mirrored
by the meta repo and published at
`https://menketechnologies.github.io/MenkeTechnologiesMeta/app-store/`.

The store itself is pure static files, so any static file server works. To host
it on GitHub Pages, enable **Settings → Pages → Source: Deploy from a branch →
`main` / root**, or via the CLI:

```
gh api -X POST repos/MenkeTechnologies/app-store/pages \
  -f 'source[branch]=main' -f 'source[path]=/'
```

The site would then serve at `https://menketechnologies.github.io/app-store/`.
