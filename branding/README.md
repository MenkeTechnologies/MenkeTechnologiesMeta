# MenkeTechnologies — corporate mark

`DIE`: an MT monogram inside a hex package with pin stubs. This is the
**company** mark. Products keep their own icons — the chamfered frame in
`zwire/branding/icon.svg` and `zpwr-daw/icon.svg` is what unifies the product
family, and this mark does not replace it.

Selected from nine directions; see `../logos.html` for the full board.

## Files

| File | Use |
|---|---|
| `mark.svg` | Default. Anywhere at 32px and above. |
| `mark-compact.svg` | 32px and below. Pin stubs dropped, strokes thickened. |
| `mark-mono.svg` | One ink — print, foil, laser etch, anything that cannot carry the cyan. |
| `favicon.svg` | Browser tabs only. Carries its own ground; hex dropped for the tile. |
| `lockup.svg` | Mark plus wordmark, horizontal. |
| `icon-1024.svg` | App icon on the house ground. |
| `avatar-1024.svg` | GitHub account avatar. Same ground as the app icon, mark scaled x14 instead of x16 so nothing lands under the circular crop. |

## Colour

| Hex | Role |
|---|---|
| `#04060c` | Void — deepest ground |
| `#0b1020` | Panel — icon ground, favicon ground |
| `#8cdbff` | Package — the hex outline and pin stubs |
| `#00b0ff` | Monogram — the MT |
| `#0069a8` | Paper-safe monogram |

All values are already in use in the product icons; nothing here is a new
colour to maintain.

`mark.svg`, `mark-compact.svg` and `lockup.svg` draw the package in
`currentColor` and the monogram in `var(--neon)`. Set both from the host page
and one file serves every ground:

```css
.brand-mark { color: #8cdbff; --neon: #00b0ff; }         /* dark ground */
.brand-mark { color: #0b1020; --neon: #0069a8; }          /* light ground */
```

**On light grounds the monogram must be `#0069a8`, not `#00b0ff`.** Bright cyan
on white does not carry enough contrast to read at any size.

## Rules

- **Clear space** — one hex width on every side. Nothing intrudes, including
  the wordmark in a custom lockup.
- **Minimum size** — 32px for `mark.svg`, 20px for `mark-compact.svg`, 16px for
  `favicon.svg`. Below 32px the pin stubs fuse into the package edge, which is
  what the compact variant exists to solve. Do not scale the full variant below
  32px and hope.
- **Below 20px, use `favicon.svg` and nothing else.** It drops the hex entirely
  and lets the tile stand in as the package, because at 16px a stroked hex and
  the monogram inside it compete for the same pixels and both turn to mush. This
  was measured, not assumed — the earlier hex-in-tile favicon read as a solid
  blob at 16px. `favicon.svg` is a tab icon, not a small mark; do not use it
  anywhere the full variants fit.
- **Keep the M and the T apart.** They sit 4 units clear at x=31 and x=35 and the
  monogram is drawn with `stroke-linecap="butt"` to hold that. Square caps
  extend every endpoint by half the stroke width, which closes the gap and fuses
  the two letters into one blob — this is the specific failure the geometry is
  shaped to avoid, so do not change the caps.
- **Never set the package and the monogram to the same value** in the two-colour
  variants. The MT reads as figure only because it is a different value from the
  hex around it. If one ink is all that is available, use `mark-mono.svg`, which
  is drawn to survive that by weight instead of by colour.
- **Do not redraw the geometry.** `icon-1024.svg` scales the canonical 64-unit
  paths by 16 rather than restating them at 1024, so it cannot drift. Any new
  variant should do the same.
- **Do not rotate, shear, add a drop shadow to the paths, or place the mark on a
  photographic ground.** The glow filter in `icon-1024.svg` is the one sanctioned
  effect and it belongs to that file only.

## Branch marks

Four branches sit under the parent: **MTAudio**, **MTPublishing**, **MTApp**,
**MTOpensource**. Files are in `branches/`; the board is `../logos-branches.html`.

The system is a rule, not four separate ideas. The hex package and the MT
monogram are byte-identical in all five marks — that is what makes them read as
one family — and the differentiator comes from a property of the hexagon itself:
**it leaves its four diagonal corners empty.** Each branch fills that void with a
different glyph type, at the same footprint, on the same grid, in its own accent.

| Branch | Corner glyph | Void | Paper |
|---|---|---|---|
| MenkeTechnologies | none — four pins on the package edges | `#00b0ff` | `#0069a8` |
| MTAudio | quarter arcs — curved | `#ff2a6d` | `#c4004f` |
| MTPublishing | filled triangles — solid, page corners | `#ffb020` | `#8a5a00` |
| MTApp | angular brackets — a viewport frame | `#9d6bff` | `#5b2fb8` |
| MTOpensource | paired bars of uneven height | `#2ee65f` | `#157a33` |

**Draw the detail in the corner void, never against the package.** This is the
rule the whole set turns on, and it was learned the expensive way: the first
three branches varied the pin stubs and hugged the hex, and every one of them
read as a double-stroke rendering artifact rather than a decision. Air around the
glyph is what makes it look deliberate.

**Mirror, do not repeat.** Each glyph is drawn once in the top-left void and
mirrored into the other three with `transform`, so the four corners cannot drift
out of symmetry when one is edited.

MTAudio's magenta is inherited, not invented — `zpwr-daw/icon.svg` already ships
`#ff2a6d` as the audio line's accent. MTApp does not take the GUI apps' cyan
because that is the parent's colour and the two would not separate.

**Never edit the hex or the monogram in a branch file.** They are the family
DNA; change them in `mark.svg` and propagate. A branch that redraws them stops
reading as part of the set, which is the only thing holding the five together.

### Consumers

| Where | How the geometry gets there |
|---|---|
| `app-store/store.js` | `BRANCH_CORE` + `branchCorners()` restate the paths as inline SVG; branch picked per product by category. |
| PDF covers | TikZ ports of these paths in each book's `scripts/reference_pdf_theme.tex` (`\mtmark`, `\mtcorners`, `\mtmark{audio,publishing,app,oss}`). |

Neither consumer can `<img>` these files — one is a JS string, the other is
LaTeX — so both restate the paths. That is the drift risk the geometry rules
above exist to contain: change a path here and both copies must follow.

**On a PDF cover the lockup is two marks: MTPublishing, then the branch of the
product the book documents.** Every book, reference manual and plugin catalog is
an MTPublishing product, so the left mark never varies; the right one is what
says whether the thing being documented is an app, a plugin or open source.
Books that document no product — the novels, the invention ledger — drop the
second mark rather than borrow a branch they do not belong to.

**The parent signs the cover once, above that row, as the full lockup**
(`\mtlockup` — mark plus wordmark, horizontal). It stands where the author line
used to, and there is no MENKETECHNOLOGIES rule under the branch marks any more:
between a labelled third mark, a foot rule and the lockup, the cover was setting
the same word three times.

`\mtlockup` is a port of the app-store header's `svg.brand-lockup`
(`app-store/index.html`), not a separate drawing — same 180×64 viewBox, MENKE at
26 units on the y=32 baseline, TECHNOLOGIES at 9.5 on y=48, both left-aligned at
x=78. It is specified in **grid units, not points**, and scaled as a whole, so
the source's proportions survive any size change. SVG letter-spacing is a length
and fontspec's `LetterSpace` is a percentage of the font size, so 6/26 and
2.9/9.5 become 23 and 30.5.

**In the TikZ port every y is `64 - y`** (SVG counts down the page, TikZ counts
up) **and the accent is a named colour, never a literal hex.** The print builds
rewrite `\definecolor` targets to greyscale for the black-ink interiors; a
literal hex survives that rewrite as a stray colour object and bills the whole
interior at the premium-colour rate. In black ink the four branches are told
apart by the corner glyph's shape alone, which is what the shapes are for.
