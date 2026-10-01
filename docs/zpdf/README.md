```
███████╗██████╗ ██████╗ ███████╗
╚══███╔╝██╔══██╗██╔══██╗██╔════╝
  ███╔╝ ██████╔╝██║  ██║█████╗  
 ███╔╝  ██╔═══╝ ██║  ██║██╔══╝  
███████╗██║     ██████╔╝██║     
╚══════╝╚═╝     ╚═════╝ ╚═╝     
```

![Rust](https://img.shields.io/badge/Rust-2024-05d9e8?style=flat-square)
![PDF](https://img.shields.io/badge/PDF-editor-ff2a6d?style=flat-square)
![status](https://img.shields.io/badge/status-active-39ff14?style=flat-square)
![MenkeTechnologies](https://img.shields.io/badge/MenkeTechnologies-stack-d300c5?style=flat-square)

### `[THE FROM-SCRATCH PDF EDITOR]`

> *"Every feature in Acrobat and Preview, in one Rust binary."*

**zpdf** is a from-scratch PDF editor written in Rust — the most capable PDF editor, porting the full feature set of Adobe Acrobat (Pro) and macOS Preview into a single tool with a CLI and a desktop GUI. Created by MenkeTechnologies.

### [`Read the Docs`](https://menketechnologies.github.io/zpdf/) &middot; [`Engineering Report`](https://menketechnologies.github.io/zpdf/report.html) · [`Feature Port Report`](https://menketechnologies.github.io/zpdf/zpdf_port_report.html)

---

## Table of Contents

- [\[0x00\] Status](#0x00-status)
- [\[0x01\] What zpdf Is](#0x01-what-zpdf-is)
- [\[0x02\] Source Apps](#0x02-source-apps)
- [\[0x03\] Feature Areas](#0x03-feature-areas)
- [\[0x04\] Architecture](#0x04-architecture)
- [\[0x05\] Roadmap](#0x05-roadmap)
- [\[0xFF\] License](#0xff-license)

---

## [0x00] STATUS

**Shipping.** zpdf is a working Rust + Tauri PDF editor with a CLI and a desktop GUI, built on the `zpdf-core` engine that parses and writes the PDF object model directly. The [feature port report](https://menketechnologies.github.io/zpdf/zpdf_port_report.html) catalogs the full Acrobat (Pro) + Preview surface — every catalogued row except camera signature capture is implemented and cited to real code, each engine capability wired through a Tauri command and surfaced in the ⌘K command palette.

---

## [0x01] WHAT ZPDF IS

A from-scratch PDF editor in Rust. The goal is breadth: cover the union of what Adobe Acrobat Pro and macOS Preview can do — viewing, page management, text/object editing, annotation/markup, forms, signatures and security, redaction, OCR, convert/export, review/compare, optimization, accessibility, and batch automation — in one tool with a CLI and a GUI front end.

zpdf parses and writes the PDF object model directly (no shelling out to a third-party PDF engine for the core), so editing, optimization, and structure-level operations (linearization, font subsetting, redaction that truly removes content) are first-class rather than bolt-ons.

Feature status lives in the port report; every implemented row is cited to verifiable code.

---

## [0x02] SOURCE APPS

zpdf ports its feature set from two reference applications:

- **Adobe Acrobat (Pro)** — the full professional feature surface: AcroForms, digital signatures and certificates, redaction, OCR, PDF/A & PDF/X archival export, Action Wizard batch automation, accessibility tagging, compare, optimization.
- **macOS Preview** — the lightweight markup surface: annotation toolbar, signature capture, drag-to-combine PDFs, image editing, slideshow.

Each row in the port report names which app the feature comes from (Acrobat, Preview, or both).

---

## [0x03] FEATURE AREAS

The catalog is grouped into these areas (see the port report for the per-feature breakdown):

- **Viewing / navigation** — zoom, page layout (single / continuous / two-up / 4-up / 8-up / 16-up), thumbnails (**drag a page thumbnail off the rail to extract it as a PDF — drop into Finder, a new document tab, or any app**), **document tabs (many PDFs open at once, `+` to add)**, **split-view panes (2 / 3 / 4-up side-by-side — view multiple PDFs simultaneously, each with its own document / scroll / zoom)**, bookmarks/outline with **inline editing (rename, retarget page, reorder up/down, indent/outdent — subtree-aware)**, named destinations (**create + delete**), full-screen, read mode, rotate view, **reading direction (L2R / R2L)**, **layer locking**, **selectable text layer (drag to select, ⌘A to select all, ⌘C to copy — Preview-style text selection over the rendered page)**, **find-in-document (⌘F focuses the search box; typing highlights every match in place, Enter / Shift+Enter step through hits with a live match count)**, **Advanced Search (⌘K "Advanced Search…" — Match case and Whole words only, every hit listed with the text around it, click a hit to jump to its page; a phrase that wraps across lines is still found)**.
- **Page management** — insert, delete, extract, replace, split (by count / size / bookmark / **custom page range** / **text marker (chapter/heading split)**), **booklet (saddle-stitch) imposition**, merge/combine, **Page Organizer (⌘⇧P — drag page thumbnails from any open PDF into an assembly canvas, reorder / rotate / remove, then export a brand-new PDF)**, reorder, **swap two pages**, **move a page to a new position**, rotate, **rotate all pages**, crop, resize, **uniform resize (normalize mixed sheet sizes)**, **per-page size/orientation audit**, headers/footers, **line numbering (legal pleading style)**, **bakeable measurement grid overlay**, backgrounds, watermarks, Bates numbering.
- **Text / object editing** — edit text, **add text in place (⇧⌘A — click the spot and type on the page; the box is multi-line and stays movable, resizable and removable until you save, like a placed signature)**, edit images, add/remove objects, font handling, reflow, find & replace.
- **Annotations / markup** — highlight, underline, strikethrough, sticky notes, text boxes, callouts, shapes, freehand ink, stamps, **a Stamp palette (⌘K "Stamp…") with the ISO 32000 standard stamps (Approved, Not Approved, Draft, Confidential, …) and Acrobat's dynamic stamps, which add a second line naming the reviewer and the local time — every stamp is written with its own appearance stream, so it looks the same in Acrobat, Preview and zpdf**, file attachments (**add / extract / delete**), measure tools, **per-annotation property editing (color, contents, author, subject, opacity, border, `/F` flags, and drag-to-reposition / resize)**, **bulk delete by subtype / reviewer**, **comment interchange (FDF + XFDF import & export)**, link family — external (`/URI`), internal go-to, named-action, launch-file, and **cross-document go-to (`/GoToR`, link a hotspot to a page in another PDF)** — content-stream **pen tools (line, box, and Bézier curve dragged onto the page, plus polyline, polygon and filled polygon clicked corner by corner)**, plus a **GIMP/Photoshop-style raster paint layer painted directly over the page (brush, pencil, marker, airbrush, eraser, line/rectangle/ellipse, gradient, smudge, blur, clone stamp) with keyboard shortcuts (`[` `]` size · `B` brush · `E` eraser · `G` gradient · `,` `.` cycle tip · `v` `m` flip/mirror) and per-page undo/redo**, baked into the PDF on save. **Photoshop-style one-letter tool keys** pick the page tools too — `T` text · `C` crop · `P` pen · `U` shapes (`⇧U` cycles box → line → Bézier) · `Z` / `⇧Z` zoom.
- **Forms** — AcroForms create/fill/flatten, all field types, **in-page filling (⌥⌘F — every recognised field becomes an editable control right on the page; click it and type, Tab walks the form in reading order)**, **field lifecycle (delete, rename, drag-to-move / reposition)**, calculations, FDF/XFDF import/export, form JavaScript, **per-trigger field actions (Format / Keystroke / Validate scripts + action listing)**, **rich-text field values**, **Prepare Form** (auto-detect the fields a *flat*, printed-looking page is drawn to have — ruled lines, boxed cells and tick-boxes read back out of the content stream, each named from the label text beside it, reviewed in a panel and created in one step).
- **Signatures & security** — digital and certificate signing, validation, certify, **electronic signatures four ways — three raster (type a name in a cursive face, draw one freehand on an in-app smoothed, supersampled ink pad, or import a scan/photo of a wet signature), which produce the same placeable float you move, resize and bake into the page, plus **a vector one that sets the name as real Helvetica text in the page's content stream over a signature rule** — searchable and extractable, crisp at any zoom, for when the signature does not have to look handwritten**, password/permission encryption, redaction (including **regex / pattern Find & Redact**), sanitize/remove hidden data.
- **OCR / scan** — text recognition, searchable PDF output, multi-language, **skew detection + deskew**, **bi-level (black & white) conversion**, **image enhance (posterize / gamma / sharpen / despeckle)**.
- **Convert / export** — to/from Office formats, HTML, images, text; **create a PDF from a plain-text file (set in Courier so indentation and aligned columns survive; form feeds start new pages)**; **table extraction (rows/columns, plus a geometry-preserving per-cell variant that backs live table editing)**; **multi-page contact sheet (all pages in one PNG grid)**; scan to PDF; print to PDF; PDF/A & PDF/X.
- **Review / compare** — diff two PDFs (line, **word**, and **structural** level), and a full **comment review workflow**: threaded **replies** (`/IRT`), **review status** (`/StateModel` + `/State` — Accepted / Rejected / Cancelled / Completed / None, plus the Marked model) recorded per change so the status *history* survives, a **Comments review panel** that folds replies and the newest status back onto the comment they answer, per-comment thread expansion in date order, and **Create Comment Summary** — paginated summary pages appended to the document itself.
- **Optimize / print production** — reduce file size, **lossless stream recompression**, downsample images, embed/subset fonts, linearize (fast web view), color separations, **Fix Hairlines (find every stroke that renders thinner than a threshold — judged at its rendered size through scaled drawings, form XObjects and graphics states — and thicken it to a printable width)**, **per-page ink coverage / total-area-coverage (TAC) prepress report**, **page-box read + document-wide set (Media / Crop / Bleed / Trim / Art)**, **trapped flag**, **output-intent inventory**, **file identifier (/ID) read + regenerate**, **object inventory (Preflight object analysis)**, **geospatial PDF** (`/VP` + `/Measure /GEO` — georeference a map against its corner coordinates, read the latitude/longitude under any page point, and measure the great-circle distance between two of them, with the registration fitted by least squares so an over-determined one is used in full).
- **Accessibility** — auto-tagging, reading order, alt text, accessibility check, **PDF/A & PDF/UA preflight validation and PDF/UA tagging**, and a full **Tags panel** over `/StructTreeRoot`: browse the logical structure (tag, depth, page, `/Alt`, `/ActualText`, child + marked-content counts), **retag** an element against the standard role set, set or clear a figure's **alternate description**, **fix reading order** by moving an element among its siblings, and **delete a stray tag** without touching the page content it referenced.
- **Preview-specific** — markup toolbar, signature capture (draw pad or imported scan; camera / Continuity capture is the one catalogued row still unimplemented), drag-to-combine, image/GIF editing, slideshow.
- **Automation** — Action Wizard / batch, CLI, scripting, **document JavaScript console (run a script through the embedded interpreter, result shown in the text pane)**.
- **⭐ zpdf originals (beyond every competitor)** — a PII scanner and one-shot privacy-sweep redaction (email / phone / SSN / Luhn-valid card detection with page rectangles); a **verifiable redaction guarantee** (machine-checkable proof that a term survives nowhere in the file's internals); a hidden-content audit (invisible sub-point and off-canvas text); a metadata-independent structural content fingerprint and **near-duplicate similarity score**; **deterministic / reproducible export** (canonical object order, byte-stable output); word-level and **semantic structural** document diff; and Flesch readability analytics; **live recalculable page tables** — the numbers baked into a *static* page (not an AcroForm) are bound to a spreadsheet under A1 addressing, so editing one cell recalculates only the dirty dependency subgraph and rewrites just those values back into the page's own content stream, right-aligned money columns keeping their right edge; and **per-number provenance** — each numeric cell attributed to the revision that introduced the value the page shows, from the in-file revision history rather than a sidecar; and an **in-file content-addressed Merkle version-control DAG** — every commit snapshots the object graph into a private trailer stream inside the same `.pdf`, so `log` / `diff` / `blame` (down to the content-stream line) / time-travel `checkout` / `bisect` all work on one file with no sidecar, no `.git` and no server, and — uniquely — that history **branches and three-way merges**: fork a document, edit both lines independently, and reconcile them structurally against the common ancestor, with objects only one side touched taken automatically, conflicts surfaced per object with line-level hunks, and a page's content streams and resource dict resolved as one unit so a merged page can never reference a resource it lost. Because the blob store is content-addressed and deduplicating, resolution is hash equality over two object maps, so a merge costs what changed since the merge base rather than what the document weighs; and that merge also crosses **formats** — a `.pdf` reconciles against the `.docx` it was exported from, with the source Word document as the common ancestor, the PDF as one side and the edited `.docx` as the other, both engines linked in-process so nothing round-trips through an export/re-import. The PDF side is normalized first (page furniture dropped, hyphenated breaks rejoined, wrapped lines re-joined by measured line width, typography folded on both sides), every reported region carries the **PDF page number** so a conflict is locatable in the document, and the alignment's confidence is a typed state — a PDF that did not come from that `.docx` is reported `unrelated` and can never surface as a clean merge — all pure-Rust, in-engine, with tests. That history is also **navigable as a page × revision timeline** (the **History** tab · ⌘K "Revision timeline"): one lane per page, one column per revision, a cell wherever a revision added, changed or removed *that page*, with the playhead parked on the revision currently checked out — **double-click a cell and the whole document time-travels there**. Every changed object is attributed to the page that owns it (the same page/contents/resources unit a merge uses), and page numbers are read from the page tree **of that revision**, so inserting a page at the front never retroactively re-blames the pages behind it and a deleted page keeps the number it had while it existed. The grid is the shared `zpwr-clip-engine` arrangement engine — the same renderer, model and interaction layer the DAW timeline uses, repurposed by a `revisions` domain rather than forked. And because that history rides *inside* the file, the document **remembers** — so zpdf also ships the only cure for it: **history-aware redaction** (⌘K "What history still remembers…" · "Scrub term from history…" · "Verify history integrity…"). After an ordinary redaction the pre-redaction content stream is still in the DAG, one time-travel from being read back, and because the blobs are base64-encoded inside that stream a plaintext scan reports the file clean — so the audit reconstructs the text of every stored object version and reports every run *some revision says that the current document does not*, with no search term needed because the document is the term list; the deep proof answers a term over document **and** history and names the revisions still carrying it; and the scrub rewrites that term out of **every revision** — emptying text operands so nothing after them shifts, never touching raster streams, re-pointing every revision tree at the new content hashes, recomputing every revision id oldest-first with parents, branch tips and head remapped, and dropping the now-unreachable blobs. Revision count, order, timestamps, messages and per-line blame attribution all survive; only the ids move, and `Verify history integrity` re-derives every one of them from its own contents so a hand-edited history — or a botched rewrite — surfaces as a mismatch instead of passing silently. Every other tool's answer to "the old content is still in the file" is to **delete the history** (Acrobat's Sanitize, `mutool clean`, qpdf dropping prior revisions); this is the one that removes the secret and keeps the provenance. All three are also **argument-taking automation verbs** (`zp.history.scrub { term }`), with the scrub declared `irreversible` so a cross-app transaction refuses it up front rather than stranding a chain it cannot compensate. And because that history is content-addressed, it also travels **between files**: **cross-file lineage** (⌘K "Compare history with another file…" · "Pull from another copy…") reconciles two independently-edited COPIES of one document — the copy that was emailed out, edited by a counterparty and sent back. Every PDF comparison tool on the market diffs the two files as they stand and infers the rest; here the relationship is *decided*, because a revision id is a BLAKE3 hash over a tree folding in every object hash, so two files share an id if and only if they share that literal point of history. Intersecting the two ancestor sets yields `identical` / `ahead` / `behind` / `diverged` / `unrelated` / `no-history`, the true merge base, and the revisions each side holds alone — plus the content overlap, which is defined even when the histories are unrelated, so a copy whose history a third-party tool stripped is reported `unrelated` with near-total overlap rather than silently mistaken for a stranger. The pull then imports only what the other file holds and this one does not and does the smallest correct thing: nothing when already ahead, a fast-forward when strictly behind, and a real three-way merge against the true common ancestor when both sides moved — with conflicts handed straight to the same branch merge panel, because after the import the other file's head is an ordinary revision in this document's own DAG. The other file is untrusted input, so its whole chain is re-derived before a byte is imported and a forged history is **refused outright**: a fabricated revision naming this document's head as its parent presents as a clean fast-forward to the ancestry walk alone, and only the re-derivation catches it, since claiming a revision id means producing a preimage for it. Unrelated histories are refused for the same reason from the other side — grafting one on would invent provenance. No server, no repository, no sidecar: the two `.pdf` files are the only artifacts. Both are argument-taking verbs too (`zp.lineage.pull { path }`). Those two capabilities compose into a hole, and zpdf is the only tool that closes it: a scrub renames every revision downstream of the blob it touched, so a copy taken **before** the scrub still holds the expunged bytes under the hash they left by — and a plain import puts them straight back, un-redacting the document while reporting a clean merge. So every scrub now writes a tamper-evident **rewrite ledger** entry into the DAG itself (⌘K "History rewrites recorded here…"): the BLAKE3 of the term — never the term, which would re-leak exactly what was removed — plus old revision id → new and purged object hash → its scrubbed replacement. The ledger rides inside the file, so every copy of a scrubbed document is protected the way the original is, and `Verify history integrity` re-derives each entry's id exactly as it does a revision's. Comparing then answers **`rewritten`** where the raw ancestor intersection would say `unrelated` — the same document, standing on a past this file renamed — and counts the revisions of theirs that still carry expunged content. Pulling lands each foreign revision on the nearest correct thing: *translated* when the scrubbed equivalent is already here, *sanitized* when its objects carry purged content (swapped for the replacements the scrub minted, then re-hashed), *rebased* when only a parent's id moved, *quarantined* when nothing can stand in — so the counterparty's work arrives and not one byte of the purged set enters the file. Contamination is a set-membership test on content hashes rather than a text scan, and pulling the same stale copy twice adds nothing the second time because the re-mint is a pure function of its inputs. Git has no equivalent: `git replace` maps old commit → new but is **not transferred by fetch/push** and does not affect which objects a fetch transfers, and `filter-branch` leaves the un-rewritten clones to be cleaned up socially. The ledger is also a read-only automation verb (`zp.history.rewrites`).

---

## [0x04] ARCHITECTURE

The shipped architecture — `zpdf-core` (the engine) plus the CLI and Tauri GUI front ends.

- **Core PDF model** — direct parse/serialize of the PDF object model (objects, xref, streams, content streams). Owns linearization, incremental update, and object-level edits.
- **Render** — a page rasterizer for the viewer and for raster export (image export, OCR input, thumbnails).
- **Editing engine** — text and object editing on parsed content streams; page-tree operations for insert/delete/extract/reorder/merge.
- **Forms / signatures** — AcroForm field model, FDF/XFDF, and the cryptographic path for signing/validation and encryption.
- **OCR pipeline** — rasterize → recognize → inject a searchable text layer.
- **CLI + GUI** — a scriptable command-line front end for batch/automation, and a desktop GUI for interactive editing and markup. The GUI's command palette (⌘K) is the single source of truth for every command; an **in-app menu bar and the native OS menu bar (macOS / Windows / Linux) are both generated from it**, so nothing in the palette is missing from the menus. Multi-document **tabs** and **split-view panes** let several PDFs be open and viewed side by side at once.

### Every command is reachable by name

The viewer publishes its whole vocabulary to `ZGui.appShell` (`crates/zgui-core`) in one list, and the
shell turns each row into a ⌘K entry, a user-commands dropdown action, a `zgui:user-command` chain
target and an `appshell.<id>` automation verb a stryke script can call. The `id` is what makes a
command reachable by name, so **every row carries one and it is always a stable slug, never a
label**: the static commands use their `zp.*` i18n key, and each recently-opened document uses its
file path with `%` and whitespace percent-escaped. An id taken from the translated label would rename
its verb on the next locale change and break every saved chain that referenced it — so the shell
never invents one either, and reports a row it cannot reach on `window.ZGui.diagnostics` and a
`zgui:diagnostic` event instead of printing it.

`test/palette-id-contract.test.js` pins that over the real vocabulary: it boots the real toolkit over
a DOM shim, publishes the viewer's actual command list, and asserts every row is id-carrying, unique,
slug-shaped and on the automation bus — and that the shell's guard still fires for the shapes that
breach it.

---

## [0x05] ROADMAP

The port report tracks status per feature across the Acrobat + Preview surface. Every row but camera signature capture is implemented and cited to code; status is derived from the actual `fn` symbols in `zpdf-core`, so no feature is marked done without verifiable code.

---

## [0xFF] LICENSE

MIT &middot; [MenkeTechnologies](https://github.com/MenkeTechnologies) &middot; [zpdf](https://github.com/MenkeTechnologies/zpdf) &middot; [MenkeTechnologiesMeta](https://github.com/MenkeTechnologies/MenkeTechnologiesMeta)
