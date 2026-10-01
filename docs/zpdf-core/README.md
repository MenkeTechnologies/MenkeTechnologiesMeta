```
 _________  ____  _____      ___ ___  ___ ___
|__  /  _ \|  _ \|  ___|    / __/ _ \| _ \ __|
  / /| |_) | | | | |_      | (_| (_) |   / _|
 / /_|  __/| |_| |  _|      \___\___/|_|_\___|
/____|_|   |____/|_|
              [ E M B E D D A B L E   P D F   E N G I N E ]
```

![Rust](https://img.shields.io/badge/Rust-2021-05d9e8?style=flat-square)
![Engine](https://img.shields.io/badge/pure__rust-lopdf%20%C2%B7%20MIT-ff2a6d?style=flat-square)
![Role](https://img.shields.io/badge/embeddable-engine%20%2B%20GUI-39ff14?style=flat-square)
![MenkeTechnologies](https://img.shields.io/badge/MenkeTechnologies-desktop%20stack-d300c5?style=flat-square)

### `[ZPDF-CORE // PARSE + EDIT + ANNOTATE + SIGN + EMBED]`

> *"The PDF engine that drops into any window."*

The embeddable core behind **[zpdf](https://github.com/MenkeTechnologies/zpdf)** — a
pure-Rust PDF engine plus the mountable viewer GUI (`frontend/`) that wraps it. It is the
unit that gets embedded: the desktop editor is one host that serves `frontend/` directly,
and the same engine + GUI mounts into the other MenkeTechnologies apps — **traderview**
renders and marks up PDFs in-window without launching a separate program. Hosts consume
this as a submodule and load `frontend/` as-is; there is no copy/sync step. Same
shared-component pattern as [`zpwr-clip-engine`](https://github.com/MenkeTechnologies/zpwr-clip-engine)
and [`zpwr-file-browser`](https://github.com/MenkeTechnologies/zpwr-file-browser).
Created by MenkeTechnologies.

---

## Table of Contents

- [\[0x00\] Why It's Separate](#0x00-why-its-separate)
- [\[0x01\] API](#0x01-api)
- [\[0x02\] Embedding](#0x02-embedding)
- [\[0x03\] Modules](#0x03-modules)
- [\[0x04\] Port Report](#0x04-port-report)
- [\[0x05\] Build & Test](#0x05-build--test)
- [\[0xFF\] License](#0xff-license)

---

## [0x00] WHY IT'S SEPARATE

A PDF *editor* you can embed inside another app does not exist — Acrobat, Preview,
Foxit, and PDF Expert are all monolithic. zpdf-core is the opposite: the engine is
extracted as a standalone component so any host can link it.

- **Pure Rust, MIT** — backed by `lopdf`. No PDFium C++ blob, no MuPDF AGPL, so it
  ships inside a paid, closed-source host cleanly.
- **Bundled mountable GUI** — `frontend/` is the viewer (markup palette, page view, panels)
  built entirely from [`zgui-core`](https://github.com/MenkeTechnologies/zgui-core)
  components (vendored as a submodule at `frontend/lib/zgui-core`). Hosts mount it as-is via
  submodule; nothing is copied or re-implemented per app.
- **No platform deps in the engine** — the Rust crate is just the document model and
  operations; the desktop app and every embed share this exact crate + `frontend/`.
- **In-memory I/O** — `from_bytes` / `to_bytes` so a host that already holds the
  buffer never touches the filesystem.

## [0x01] API

Everything hangs off `Pdf`:

```rust
use zpdf_core::Pdf;

let mut pdf = Pdf::open("in.pdf")?;
println!("{} pages, v{}", pdf.page_count(), pdf.version());
println!("{}", pdf.extract_all_text()?);                      // text extraction
pdf.rotate_page(1, 90)?;                                       // page ops
pdf.add_note(1, [72.0, 720.0, 92.0, 740.0], "review this")?;  // annotate
pdf.save("out.pdf")?;
```

## [0x02] EMBEDDING

Host apps that already hold the bytes (e.g. traderview showing a report) use the
in-memory path — no temp files:

```rust
let mut pdf = Pdf::from_bytes(&buffer)?;     // host owns the buffer
let text = pdf.extract_all_text()?;
pdf.add_note(1, rect, "flag")?;
let out: Vec<u8> = pdf.to_bytes()?;          // hand back to the host
```

The GUI embed lives in `frontend/` (HTML/CSS/JS over the global Tauri API, built from
`zgui-core` components). A host Tauri app points its `frontendDist` at this submodule's
`frontend/` directory and exposes the engine through `#[tauri::command]`s — exactly how the
zpdf desktop app does it. No copy step: `frontend/` and its vendored submodules
(`zgui-core` at `frontend/lib/zgui-core`, `zpwr-i18n` at `frontend/vendor/zpwr-i18n`,
`zpwr-clip-engine` at `frontend/vendor/zpwr-clip-engine`) are loaded directly from the
checked-out submodule. `zpwr-clip-engine` carries its own nested `zgui-core`, so clone with
`--recursive` (or `git submodule update --init --recursive`) — a shallow init leaves the grid
engine's imports unresolved.

`window.mountZpdf(root, opts)` builds one independent viewer into `root` (own state, own
transport, all lookups scoped to `root`, so a host can tile one per pane) and returns that
instance's handle — the way a host *drives* the view rather than only displaying it:

```js
const zp = window.mountZpdf(paneEl, { transport: window.zpdfPluginTransport() });
await zp.openPath(pathThePickerReturned);   // open · navigate · undo
zp.goToPage(7);
zp.selectedPage();                          // → 7
zp.paletteItems();                          // the whole command vocabulary, with ids
zp.dispatchCommand("zp.cmd_rotate");        // run one by id (unknown ids no-op)
zp.buildCommandModel();                     // the same model the ⌘K palette + OS menu build
zp.reload();                                // repaint · zp.transport is the live transport
```

Every entry is the instance's own function, so a host command and the same command from ⌘K
or the native menu bar are one code path. The headless suites in the host repo mount through
this handle too, which is why they assert over the shipped instance and not a copy of it.

## [0x03] MODULES

| Module | Responsibility |
| --- | --- |
| `doc` | open/save, in-memory I/O, version, document properties (`/Info`), merge, overlay, outline edit + bookmark styling/URI-actions, layer (OCG) toggle + manage (create/rename/delete/list) + print/view state + membership (OCMD) + flatten, portfolio, repair, image alt text (structure tagging), preflight + accessibility audit, initial-view options (page layout/mode, viewer preferences, open action), document-level JavaScript (list/set/remove), article threads (read/create), TOC page from bookmarks, content-derived filename suggestion, document language + custom `/Info` properties, XMP metadata write, discard embedded thumbnails + search index |
| `page` | count, rotate, rotate-all-pages, delete, reorder, swap two pages, move a page to a new position, uniform resize-all-pages (normalize mixed sheet sizes), per-page size/orientation audit (`page_dimensions`), extract, insert/replace, page labels, headers/footers (with `{page}`/`{pages}` macros), insert page numbers, Bates, watermark (text + image), background, split by bookmarks/page-count, page boxes (Media/Crop/Bleed/Trim/Art set+read), flip/mirror, duplicate, split-into-grid, interleave/alternate-mix, whiteout, printer marks, remove blank pages, combine to a single long page, insert blank page, split by odd/even, tab order, large-format `/UserUnit`, presentation transitions + auto-advance duration |
| `linearize` | serialize a **linearized** ("fast web view") PDF — a self-contained writer (lopdf has none): page-1 objects ordered first, `/Linearized` parameter dictionary, dual `/Prev`-linked cross-reference (first-page + main), and a primary hint stream with a per-page locator table (real; structure is ISO-shaped and reopen-verified) |
| `text` | extraction + region (marquee) text extraction, free-standing text placement (single line, or a multi-line box laid out from the box's displayed top-left and rotated to match the page's `/Rotate`, in any installed face — embedded as a subset — and any fill colour), in-place edit, find & replace, highlight-all / find-and-redact search, **Advanced Search** (`search_matches` — Match case / Whole words only, whitespace runs and line breaks matched as one space so a wrapped phrase is found, every hit returned with its surrounding text), image add/replace (real) |
| `ocr` | recognize machine-printed text in a scanned page — pure-Rust template-matching against a compiled-in bitmap font (`font8x8`), no model/network/C; decodes raw/FlateDecode and JPEG (`jpeg-decoder`) scans; returns positioned words and can add an invisible searchable text layer over the scan (real) |
| `render` | rasterize a page to a bitmap / PNG, thumbnails, embed per-page `/Thumb` images, print-to-PDF, grayscale/invert/brightness-contrast recolour, auto-crop to content margins, scanner-image split (whitespace projection profiles), skew detection + deskew, binarize, image downsampling, contact sheet, annotation flattening, image stamping, extract embedded images (JPEG passthrough / PNG), visual page compare (pixel diff) + mark changed regions, transparency flattening, CMYK colour separations, and ink enumeration + coverage — pure-Rust content-stream interpreter on `tiny-skia` (graphics state, CTM, vector fill/stroke, clipping paths `W`/`W*`; image XObjects — JPEG (`DCTDecode`, including Flate-wrapped and Adobe CMYK), Flate/raw samples at 1/2/4/8/16 bits with PNG/TIFF predictors, and CCITT Group 3/4 fax (`CCITTFaxDecode`, the encoding of scanned/faxed pages), through DeviceGray/RGB/CMYK, ICCBased, Indexed, Separation/DeviceN and `/Decode` inversion; glyph outlines from embedded TrueType (`/FontFile2`), OpenType and bare CFF (`/FontFile3` — `Type1C`/`CIDFontType0C`, what Distiller and InDesign emit for nearly every subset font), honouring `/Encoding /Differences` glyph names, simple `/Widths` and Type0 `/W` CID advances, the full text state (`Tc`, `Tw`, `Tz`, `Ts`, `TL`, and render mode — invisible OCR layers stay invisible), and non-embedded standard-14 text through a **metric-compatible face the machine already has** — the real Helvetica/Times/Courier on macOS, the URW/Liberation clones on Linux, with the bundled DejaVu only as a last resort: a base-14 font is normally written with no `/Widths` at all, so a wider substitute makes every run overrun the absolutely-positioned run after it) (real) |
| `annot` | sticky notes, markup family, callouts, measure annotations, file attachments, external (`/URI`), internal (`/Dest` GoTo), remote (`/GoToR`), launch (`/Launch`), and named-action (`/Named`) links, page + document JavaScript actions (`/AA`), freehand ink with point-erase and undo-last, per-annotation property editing (colour, contents, author, rect, opacity, subject, border, flags), delete by type or author, burn-in of redaction marks, and comment import/export as FDF, XFDF or CSV (real) |
| `review` | **comment review workflow** — Acrobat's Comments panel as engine ops: threaded **replies** (`/IRT` + `/RT /R`), **review status** (`/StateModel` + `/State`, the Review model's Accepted/Rejected/Cancelled/Completed/None and the Marked model's pair) recorded as a new status annotation per change so the status *history* survives, a panel-shaped `review_comments` view that folds replies and the newest status back onto the comment they refer to, per-comment thread expansion in date order, and **Create Comment Summary** — paginated summary pages appended to the document, laid out in Courier so the wrap is exact rather than estimated (real) |
| `media` | rich/multimedia annotations — Sound, Screen (media rendition), Movie, 3D and RichMedia. Each embeds its payload as a stream/embedded file and builds a spec-valid annotation dictionary, so the multimedia annotations an arbitrary PDF may carry can be authored too, not just the static markup family (real) |
| `form` | AcroForm detection, field enumeration, per-widget geometry (`field_widgets` — page + `/Rect` + on-states for every widget, what a viewer needs to put an editable control over the field on the page), fill, create text/checkbox/choice/signature/push-button/radio-group fields, field properties (flags, tooltip, max-length, default value, border/background colours, multiline/password/comb options, alignment, calculation script, export name), submit-form button, clear signature, reset form, flatten, structural validation, FDF export, JavaScript calc, and XFA forms — detect, extract the `datasets` (form-data) XML, fill it back in, and export the XDP (real) |
| `formdetect` | **Prepare Form** — the fields a *flat* page is drawn to have. A CTM-tracking content-stream walk collects every `re` rectangle and axis-aligned `m`/`l` segment in user space, classifies them by geometry into ruled lines (a field sits on top), boxed cells and tick-boxes, drops anything an existing widget annotation already covers, and pairs each survivor with its nearest label run (`text_run_boxes`) to name it — unique names, reading order, so the proposals can be created as-is. `detect_form_fields` proposes; `auto_create_form_fields` commits (real) |
| `sign` | signature detection, typed electronic signature, certificate signing (invisible, **visible** text `/AP` with signer/reason/location, or a scanned-signature **image** `/AP` with `/M` signing time) + verification (`adbe.pkcs7.detached` PKCS#7/CMS over SHA-256, RSA) with full `/ByteRange` digest binding, certify (DocMDP `/Perms`), and document timestamp (`DocTimeStamp`/`ETSI.RFC3161` — embeds a TSA token via a caller-supplied closure, keeping the network round-trip out of the engine) (real) |
| `security` | encryption detection, RC4 password encrypt (V2/R3, 128-bit) and **AES-256 encrypt (PDF 2.0, V5/R6, AESV3)** — ISO 32000-2 Algorithm 2.A/2.B key derivation + per-object AES-256-CBC, validated bidirectionally against qpdf, with optional permission restriction (deny print/edit/copy/annotate via the `/P` bitfield); password decrypt (RC4 V2/R3, **AES-128 V4/R4 AESV2** including documents whose objects live in encrypted object streams, and AES-256 V5/R6 — user or owner password, validated against `/U`) and **certificate encryption + decryption** (`/Adobe.PubSec` — build/parse the CMS `EnvelopedData` envelope via `cms`/`rsa`/`x509-cert`, single- or multi-recipient, `SHA-256(seed ‖ recipients)` AESV3 key, validated **bidirectionally** against pyHanko), read permissions, sanitize, text redaction + find-and-redact (true removal — the original content stream is deleted, not just unreferenced) (real) |
| `convert` | JPEG → PDF, text export to HTML / Markdown / Word `.docx` / Excel `.xlsx` / PowerPoint `.pptx` (dependency-free OPC ZIP), and PDF/A-1b / PDF/X-3 conversion (rasterize + `moxcms` sRGB `OutputIntent` + XMP identification; structural conformance, lossy) (real) |
| `font` | embed a **subsetted** TrueType/OpenType font (`Type0`/`CIDFontType2`, `Identity-H`, `/FontFile2`, only used glyphs) and draw searchable text with it via `/ToUnicode` (real, `ttf-parser` + `subsetter`); inventory the document's fonts with embed/subset status, extract embedded font programs, and unembed them to shrink files; `system_fonts` enumerates the installed TrueType/OpenType faces the subsetter can actually embed (`.ttc` collections skipped), which is the list the text-box font picker offers |
| `layout` | reading-order text extraction (CTM/text-matrix positions sorted into lines), per-run bounding boxes measured from the face's own advances rather than a half-em guess (`text_run_boxes`) plus search-hit rects, in-place restyle / move of an existing run, SVG page export, auto-tagging (`/StructTreeRoot` of `/P` paragraphs with `/ActualText`), text reflow / liquid mode (re-wrap the flow to a width), and auto-linking URLs in page text (real) |
| `tags` | **tag tree editing — Acrobat's Tags panel** over `/StructTreeRoot`. `layout`'s auto-tagging *builds* the logical structure; this is the editing half: browse the whole tree in reading order (tag, depth, page, `/Alt`, `/ActualText`, `/Lang`, child + marked-content counts), retag an element against the standard role set, set or clear a figure's alternate description, fix a wrong reading order by moving an element among its siblings, and delete a stray tag without touching the page content it referenced. Elements are addressed by `/K` index **path**, so an address stays valid across the read-modify-read cycle a panel performs and no object ids leak into the UI (real) |
| `insight` | content intelligence on the positioned-text machinery: table detection (`extract_tables` / geometry-preserving `extract_table_cells`), auto-bookmarking from heading sizes (`auto_outline`), word-level compare (`word_diff`, sharper than the line-level `compare`) plus structure diff and a similarity score, a PII classifier that finds emails, phone/SSN numbers and Luhn-valid card numbers with their page rectangles and feeds redaction (`scan_pii` / `redact_pii`), hidden-content audit (invisible sub-point and off-canvas text), a metadata-independent structural `content_fingerprint` for dedup/tamper detection, and Flesch `readability_stats`. Hand-rolled and deterministic — the PII and readability scanners take no regex dependency so they stay auditable (real) |
| `livecalc` | **live-recalculable page tables** — the numbers baked into a *static* page (not an AcroForm) become a spreadsheet, in the same file. A detected table (`extract_table_cells`, geometry-preserving) is bound to a [`zoffice-core`](https://github.com/MenkeTechnologies/zoffice-core) `Sheet` under A1 addressing; formulas come from cells whose text is literally a formula, plus **evidence-driven inference** — a column or row is bound as a `SUM` only where the document's own arithmetic already holds, so binding never invents a computation the author did not make. Editing one cell recalculates **only the dirty dependency subgraph** (transitive dependents, in Kahn topological order), rewrites just those values into the page's own content stream, and commits **one** revision through `vcs`. Presentation survives the write-back: currency/percent affixes, digit grouping, decimal places and accounting parentheses are re-applied, and a right-aligned money column keeps its **right edge** rather than ragging out from the preserved run origin. Fails closed — a value whose run text is not unique on the page is reported non-editable rather than rewritten alongside an unrelated run, and a dependency cycle is an error, never a hang. `live_table_preview` dry-runs the same recalculation writing nothing (real) |
| `actions` | action wizard / batch — replay a serializable `Action` sequence over a document (real) |
| `barcode` | draw a **Code 128**-B barcode (pure-Rust encoder cross-validated against `python-barcode`), a **QR code** (`qrcode` crate), or a **Data Matrix** (`datamatrix` crate) onto a page (real) |
| `js` | run document JavaScript and recalculate AcroForm fields on the embedded `boa_engine` interpreter, with a minimal Acrobat form JS API (`getField`, `event.value`, `AFSimple_Calculate`) (real) |
| `prepress` | print-production + document-identity + form-action extras: file identifier (`/ID`) read + regenerate, trapped flag (`/Trapped`), reading direction (`/ViewerPreferences /Direction`), all-five page-box read + document-wide set, layer (OCG) locking (`/D /Locked`), per-trigger form-field action scripts (Format/Keystroke/Validate) + action listing, rich-text field values (`/RV`), output-intent inventory, and object inventory (Preflight object/stream/font/image counts) (real) |
| `hairline` | **Fix Hairlines** — Acrobat's Print Production pass. Every page's content (and every form XObject it draws, nested forms included) is walked with the CTM tracked through `q`/`Q`/`cm`, so a `w` operand — or an `/ExtGState` `/LW` reached through `gs` — is judged at its **rendered** width, not its raw operand. `find_hairlines` reports per page how many width settings fall below the threshold and the thinnest; `fix_hairlines` rewrites each to the replacement width divided by the local scale (so it prints at exactly that width), and overrides a too-thin `/LW` by emitting a `w` after the `gs` rather than editing the shared graphics-state dictionary. A form is rewritten once, at the scale of its first invocation |
| `stamp` | **Stamp tool** — the ISO 32000 standard `/Stamp` names plus Acrobat's dynamic set (a second line: `By <author> at <h:mm AM>, <Mon D, YYYY>`, composed at placement from the author and local time). Every stamp is written with its own `/AP /N` appearance — a rounded border and the label in base-14 Helvetica-Bold, sized from the AFM advance widths to fit the box — so it looks the same in every viewer instead of depending on each one's icon for the name |
| `textpdf` | **Create PDF from a text file** — set in base-14 Courier, whose fixed 600/1000-em advance makes the column budget exact, so indentation and aligned columns survive. CRLF/CR/LF end lines, a form feed starts a page, tabs expand to tab stops, over-long lines wrap after the last space that fits (hard break otherwise), and the file's stem becomes `/Title` |
| `geo` | **geospatial PDF — Acrobat's Geospatial Location Tool.** A map page carries `/VP` viewports whose `/Measure /GEO` holds two parallel point lists: `/LPTS` (points as fractions of the viewport `/BBox`) and `/GPTS` (their latitude/longitude in the `/GCS`). `add_geo_viewport` writes that registration (WGS 84 / EPSG 4326, metres/square-metres/degrees display units), `geo_point` answers *what are the coordinates under the cursor* and `geo_distance` measures the great-circle arc between two page points on the IUGG mean sphere. The registration pairs define an affine map from BBox fractions to degrees, fitted by **least squares** so an over-determined registration is used in full; a degenerate (collinear) one declines rather than returning an arbitrary fix (real) |
| `fidelity` | **copy-fidelity audit — a per-glyph text-recoverability map** — a world-first for a PDF tool. For every glyph drawn on every page it decides whether a standards-compliant extractor can recover the correct Unicode, then scores the whole document. Pins the two irrecoverable cases that silently paste as garbage in *every* tool: a **Type0/CID font with no `/ToUnicode`** (text vanishes on copy) and a **simple font whose `/Encoding /Differences` remaps codes to un-named glyphs** (`g23`, `cid41`, …) with no `/ToUnicode` (mojibake). Resolvable `uniXXXX`/AGL-named differences, standard base encodings and present `/ToUnicode` maps score as clean. Returns a per-font breakdown (class, coverage %, sampled lost code points), the list of affected pages, and a weighted document **copy-fidelity score** — the warning no other tool gives you *before* you hit ⌘C. Pure structural analysis, no rasterization (real) |
| `vcs` | **in-file content-addressed Merkle VCS + per-glyph blame** — a world-first for a PDF editor. Every commit snapshots the object graph as a BLAKE3-content-addressed Merkle DAG (dedup across revisions) stored **inside the same `.pdf`** under a private `/ZPDFVCS` trailer key: `commit` / `log` / `diff` (object-level) / `checkout` (time-travel) / `bisect` (first-bad-revision search) plus object- and line-level `blame`. `branch` forks a named head off any revision (turning the linear history into a DAG, naming the existing history `main` on first fork) and `switch` materializes a tip; `merge` is a **three-way structural merge** against the computed merge base — it previews what resolves automatically, which object keys conflict, and which ids had to be renumbered, writing nothing, and `merge_resolve` commits a two-parent revision from an explicit per-conflict `ours`/`theirs`/`base` choice (an omitted conflict is an error, never a silent pick). `number_blame` joins that line-level blame to detected table geometry so each number on a page is attributed to the revision that introduced it, and `edit_value_tracked` binds an in-place value edit to a single commit. Persisted as one Flate stream layered on the native save; survives `optimize` and is carried across `linearize`. `page_timeline` turns that history into a **page × revision matrix**: every revision on head's chain with each of its changed objects attributed to the page that owns it (the same page/contents/resources ownership unit `merge` uses, so a page never splits across rows) and classified `added` / `modified` / `removed`. Page numbers are read from **that revision's own page tree**, so inserting a page at the front does not retroactively re-blame every page behind it, and a deleted page keeps the number it had in the revision that still had it. Every save auto-commits, so the full history travels with the file — no sidecar, no `.git`, no server (real) |
| `scrub` | **history-aware redaction — remove a term from the document *and* from the in-file revision DAG, re-anchoring the Merkle chain** — a capability only a document that carries its own history can have. The DAG makes a zpdf `.pdf` auditable and, by the same token, makes it *remember*: after a redaction the pre-redaction content stream is still in `/ZPDFVCS`, one `vcs_checkout` from being read back. Worse, blobs are stored base64-encoded inside that Flate stream, so `verify_redaction`'s plaintext scan cannot see them — it answers `clean` on a file the secret is one API call away from. `history_audit` is the untargeted detector: it reconstructs the text of every blob in the store and reports every run some revision says that the current document does not — no search term needed, because the document *is* the term list. `verify_redaction_deep` is the term-targeted proof over document **and** history, naming the revisions that still carry it. `vcs_scrub` is the fix: it rewrites every blob carrying the term (text-showing operands emptied, so `'`/`"`/`TJ` advancement never moves; other bytes masked; raster streams never touched), re-points every revision tree at the new blob hashes, recomputes every revision id oldest-first with parent, second parent, branch tips and head remapped, and prunes the now-unreachable blobs — `git filter-branch` for a PDF's own history, in place. Revision count, order, timestamps, messages and **per-line blame attribution** all survive; only the ids move. `vcs_verify` is the proof the surgery left a valid DAG: it re-derives every revision id from its own `(parent ‖ ts ‖ message ‖ tree)` and every blob key from its bytes, so a hand-edited history — or a botched re-anchor — surfaces as a mismatched id instead of passing silently. Every other tool's answer to "old content is still in the file" is to *delete the history* (Acrobat's Sanitize, `mutool clean`, qpdf's drop-prior-revisions); this removes the term and keeps the provenance. The scrub also records what it did — see `lineage`'s rewrite ledger — so a later reconciliation with a copy older than the scrub cannot undo it (real) |
| `redact_audit` | **redaction-leak audit — a pre-send scan for text that is visually hidden but still extractable** — a world-first for a PDF tool. A painter's-model content-stream pass records every opaque fill region and every positioned text run in draw order, then flags any run a **later, opaque fill fully covers yet leaves in the stream** — the classic "black-bar redaction" that copies straight back out of Acrobat, Preview, Foxit, and PDF Expert (all of which *perform* redaction but never *audit an existing file* for a leaked cover-up). Also flags **invisible text** (render-mode 3) on pages with no image layer — hidden text with no scan to justify it — while leaving legitimate OCR-under-scan layers alone. Semi-transparent fills (`/ca < 1`) are correctly *not* treated as covers. Returns per-leak page/kind/text/rect + covering box and a whole-document `safe` verdict — the warning no other tool gives you *before* you send. Pure structural analysis, one linear pass per page, no rasterization (real) |
| `lineage` | **cross-file lineage — decide how two independently-edited COPIES of one document relate, and reconcile them against their true common ancestor.** `vcs` gives one `.pdf` a history; the moment that file is copied — emailed out, edited by a counterparty, sent back — the two copies diverge and `vcs_merge`, which only ever reaches revisions inside its own DAG, cannot rejoin them. This is the distributed half. `vcs_relate` intersects the two files' Merkle ancestor sets and answers `identical` / `ahead` / `behind` / `diverged` / `unrelated` / `no-history`, names the merge base, and counts the revisions each side holds alone — decided, not inferred: a revision id is `BLAKE3(parent ‖ parent2 ‖ ts ‖ message ‖ tree)` over a tree that folds in every blob hash, so two files share an id **iff** they share that literal point of history. It also reports the blob-store Jaccard overlap, which is defined even for `unrelated` — a copy whose history a third-party tool stripped comes back `unrelated` with near-total content overlap, the signature of "same document, history destroyed". `vcs_pull` acts on that verdict: it re-derives the other file's whole chain first (`scrub::verify_dag`, every revision id recomputed and every blob key rehashed) and **refuses outright** on a forged history or on files sharing no ancestry, because a claimed revision id is a BLAKE3 preimage claim and grafting unrelated history would invent provenance; otherwise it imports the missing revisions and deduplicated blobs, then fast-forwards when strictly behind or runs the existing three-way merge against the real base when both sides moved — clean merges commit a two-parent revision, conflicted ones hand back per-object line-level hunks for `vcs_merge_resolve`. After the import the foreign head is an ordinary revision id in this document's DAG, so time-travel, blame and diff all reach into the history that arrived with it. **Scrub-safe by construction.** A `vcs_scrub` renames every revision downstream of the blob it touched, so a copy taken before the scrub still holds the expunged bytes under the hash they left by — and a plain union import puts them straight back, un-redacting the document while reporting a clean merge. Every scrub therefore writes a tamper-evident ledger entry into the DAG itself (`vcs_rewrites`): the BLAKE3 of the term — never the term — plus `old revision id → new` and `purged blob hash → its scrubbed replacement`. The ledger travels inside the file, so every copy of the scrubbed document is protected the same way the original is, and `vcs_verify` re-derives each entry's id exactly as it does a revision's. `vcs_relate` reads it to answer `rewritten` where the raw ancestor intersection would say `unrelated`, and to count the revisions of theirs that still carry expunged content. `vcs_pull` reads it to land each foreign revision on the nearest correct thing — *translated* when we already hold its scrubbed equivalent, *sanitized* when its tree names purged blobs (swapped for the replacements the scrub minted, then re-hashed), *rebased* when only a parent's id moved, *quarantined* when nothing can stand in — so the counterparty's work arrives and not one byte of the purged set enters the store. Deciding contamination is a set-membership test on BLAKE3, not a text scan, and the guarantee is over the exact expunged objects rather than any restatement of the secret in newly-authored content. `git` has no equivalent: `git replace` maps old commit → new but is not transferred by fetch/push and does not affect which objects a fetch transfers, and `filter-branch` leaves the un-rewritten copies to be cleaned up socially. No server, no repository, no sidecar: the two `.pdf` files are the only artifacts (real) |
| `xmerge` | **cross-format 3-way merge — a `.pdf` reconciled against the `.docx` it was exported from.** `vcs` merges a PDF against another revision of *itself*; this merges it against a *different format*. The common ancestor is the source `.docx`, **ours** is the PDF (edited here), **theirs** is that `.docx` after Word-side edits. zpdf-core reads the PDF's own content streams and [`zoffice-core`](https://github.com/MenkeTechnologies/zoffice-core) reads the Word model directly — both are in-process rlibs, so there is no export/re-import round trip and no intermediate file. A PDF has lines, not paragraphs, so the PDF side is **normalized** first: running headers/footers and page numbers are dropped, hyphenated breaks are rejoined, a rendered line at ≥85% of its page's widest line is treated as a wrap and joined to the next, and both sides are folded through one canonicalizer (ligature glyphs, typographic quotes/dashes, every flavour of space; case is preserved because a case change is a real edit). The normalized sequences go through zoffice-core's structural diff3 as text-only paragraphs, so DOCX formatting — which a PDF text layer cannot carry — never forces a conflict. **Alignment confidence is a typed state, not a footnote**: the LCS of the PDF units against the ancestor's, over the longer sequence, is the anchor ratio; ≥0.60 is `high`, ≥0.25 `low`, below that `unrelated`, and anything short of `high` can never be reported clean — a PDF that did not come from that `.docx` would otherwise diff3 into a confidently wrong "clean" merge of two wholesale insertions. Every region carries base/ours/theirs text, a conflict flag, whether its text came from the PDF or the DOCX, and **the PDF page number**, so a conflict is locatable in the document and not only in an abstract paragraph stream. Writes nothing (real) |
| `revision` | **incremental-update revision archaeology — reconstruct and recover every prior save a PDF carries inside its own incremental-update layers** — a world-first for a PDF tool. ISO 32000-1 §7.5.6 has editors *append* changes (new objects + a fresh xref + `%%EOF`) rather than rewrite the file, so the byte prefix up to **any** `%%EOF` is itself a complete, reopenable PDF — a document edited N times physically still *contains* all N prior states in-band. This walks those layers: finds every `%%EOF`, parses each prefix as a standalone document (self-validating — a spurious in-stream `%%EOF` never parses to a page-bearing PDF), and returns the whole timeline with per-revision stats (page/object counts, xref kind, signed/encrypted/form flags, `/Info` producer + mod-date) and consecutive-save diffs. `revision_extract` **materializes any prior revision's exact bytes** — recovering the pre-edit document. Forensic payload: when a later save *removed* text an earlier revision still holds, it flags `recoverable_removed_text` and samples it — the "edited a sentence out / dragged a box over a name and re-saved, but the original is still in the file" case. Works on **any producer's** file with no zpdf commit (distinct from `vcs`, zpdf's own `/ZPDFVCS` history) and across the incremental-update **time** dimension (distinct from `redact_audit`'s single-save draw-order scan). Acrobat, Preview, Foxit, PDF Expert, pdftk, mupdf and qpdf all show only the final flattened state. Pure structural analysis, no rasterization (real) |

Beyond the Rust modules, **`frontend/`** is the mountable viewer GUI: `index.html` + `js/zpdf.js`
(over the global Tauri API) + the `zgui-core` (`frontend/lib/`) and `zpwr-i18n` (`frontend/vendor/`)
submodules. The markup palette (highlight, underline, strikeout, squiggly, ink, ink eraser, free
text, stamp, note, rect, oval, line, polyline, polygon, caret, redact, link + colour + stroke
width + opacity) is built entirely from `zgui-core` components and drives the `annot` module; a
separate set of draw tools (line, box, Bézier, polyline, polygon, filled polygon) writes into the
page content stream instead.

`js/revision-grid.js` is the **revision timeline** — the in-file Merkle history drawn on the
shared `zpwr-clip-engine` arrangement grid (one lane per page, one column per revision, the
playhead on the checked-out revision, double-click a cell to time-travel there). It reuses
`createGrid` and the engine's renderer / model / interactions unchanged; the only zpdf-specific
piece is the `revisions` **domain**, which is the extension point that engine documents. It is an
ES module and takes the host viewer's own `invoke` / `status` / refresh callbacks, so a viewer
tiled per pane drives its own document.

The three polygon tools are the only ones that are neither a drag nor a stroke: `draw_path` takes a
whole point run in one call, so corners are **clicked** one at a time and the figure is finished by
double-clicking, pressing Enter, or — for the closed kinds — clicking back on the first corner. The
preview draws the committed segments, a rubber segment out to the pointer and a handle per corner.
Corners land in PDF user space through the same mapping the ink brush uses, and coincident ones are
dropped before the call, since the finishing double-click necessarily repeats the last corner and a
closing click repeats the first (`h` already draws the closing edge).

Being clicked rather than dragged makes a polygon the one figure whose input can outlive a scroll,
so a corner is held as a **fraction of its page** rather than as a point on the screen: a figure
bigger than the window is drawn by scrolling between corners, and viewport coordinates would shift
every corner placed before the scroll by the scroll distance. The finishing double-click is
recognised from the click run itself, not from a `dblclick` event — taking a corner cancels
`pointerdown`, which suppresses the compatibility mouse events — so a polyline, which has no
close-on-first-corner gesture, can always be finished.

### Command ids

The viewer publishes its whole vocabulary to the host's `ZGui.appShell` through `setCommands`, and
the shell turns every row into a ⌘K entry, a user-commands dropdown action, a `zgui:user-command`
chain target and an `appshell.<id>` automation verb. **The `id` is what makes a command reachable by
name**, so every row carries one and it is always a stable slug — never a label. The static commands
use their `zp.*` i18n key; each recently-opened document uses its file path, with `%` and whitespace
percent-escaped (`recent:/d/My%20Report.pdf`), because a whitespace-carrying verb name cannot be
typed into a script or saved in a chain. Deriving an id from the translated label instead would
rename the verb on every locale change and break every saved chain that referenced it.

The shell reports a breach of that contract — a row with no id, or an id containing whitespace — on
`window.ZGui.diagnostics` and a `zgui:diagnostic` document event rather than printing it;
`index.html` forwards that event to the page's error log. `test/palette-id-contract.test.js` in the
host repo pins the contract over the real vocabulary.

There are two freehand brushes, and they are not the same tool. **Ink** and **ink eraser** are
vector: a drag is captured on the page image, crossed into PDF user space through the same
mapping every overlay uses (the page's `/Rotate` included), and committed as one `/Ink`
annotation per stroke via `add_ink` — so the mark stays editable geometry that `erase_ink_at`
picks back out by proximity and `undo_annot` (⌘Z) pops, and it re-renders sharp at any zoom. The
**raster brush** is the shared `ZGui.paint` engine, which bakes pixels into the page through
`stamp_image` instead. Those two, the polygon tools and the drag-a-box placement are mutually
exclusive: arming one disarms the others.

The electronic-signature panel likewise offers both representations, and both stay because neither
subsumes the other. **Place** renders the name in a real cursive face as a transparent PNG and
stamps it with `stamp_image` — it looks handwritten, but it is a supersampled bitmap: it re-samples
on zoom and carries no text. That path also takes a freehand pad drawing and an imported scan of a
wet signature, neither of which can be expressed any other way. **Place as text** is the engine's
own `add_typed_signature`: the name set in base-14 Helvetica straight into the page's content
stream over a signature rule — a handful of text and path operators rather than an image XObject,
so it is crisp at any zoom and in print, and the name stays real text — searchable, extractable and
reachable by a screen reader. It cannot look handwritten, which is exactly why the raster path is
still the default.

## [0x04] PORT REPORT

Coverage of the Adobe-Acrobat / Apple-Preview surface lives in the **[zpdf](https://github.com/MenkeTechnologies/zpdf)**
app repo (the GUI is the product surface). Its generator scans this engine's `src/`
and **derives** each feature's status from source — a feature is `DONE` only when its
cited symbol exists here and is not a `NotImplemented` stub, so the number cannot be
faked in a manifest, only by writing engine code. See the
[feature port report](https://menketechnologies.github.io/zpdf/zpdf_port_report.html).

## [0x05] BUILD & TEST

```sh
cargo build      # local dev (never --release per house rule)
cargo test       # self-contained: builds its PDFs in memory; the few binary fixtures
                 # (qpdf/pyHanko cross-validation files, a public-domain test TTF) are
                 # compiled in with include_bytes! — nothing is fetched over the network
```

## [0xFF] LICENSE

Commercial. © MenkeTechnologies. All rights reserved.
