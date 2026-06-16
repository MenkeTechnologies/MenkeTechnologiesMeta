# app-store

MenkeTechnologies App Store — a static storefront for selling the
MenkeTechnologies audio products: **audio haxor** (Tauri/JUCE plugin scanner),
**traderview** (self-hosted trading journal), **zpwr-synth** (JUCE synthesizer
plugin), and **zpwr-fx** (JUCE multi-effect plugin).

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

## Layout

| File            | Purpose                                                        |
|-----------------|---------------------------------------------------------------|
| `index.html`    | Storefront: hero, search, category filters, product grid      |
| `product.html`  | Product detail page, reads `?id=<product>` from the URL        |
| `checkout.html` | Shopify-style checkout: express wallets, card form, summary    |
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
