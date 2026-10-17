```
 ________  _____ _____ ___ ____ _____       ____ ___  ____  _____ 
|__  / _ \|  ___|  ___|_ _/ ___| ____|     / ___/ _ \|  _ \| ____|
  / / | | | |_  | |_   | | |   |  _| _____| |  | | | | |_) |  _|  
 / /| |_| |  _| |  _|  | | |___| |__|_____| |__| |_| |  _ <| |___ 
/____\___/|_|   |_|   |___\____|_____|     \____\___/|_| \_\_____|
```

![Rust](https://img.shields.io/badge/Rust-2024-05d9e8?style=flat-square)
![crate-type](https://img.shields.io/badge/crate--type-rlib%20%C2%B7%20staticlib%20%C2%B7%20cdylib-ff2a6d?style=flat-square)
![status](https://img.shields.io/badge/status-in%20development-39ff14?style=flat-square)
![MenkeTechnologies](https://img.shields.io/badge/MenkeTechnologies-stack-d300c5?style=flat-square)

### `[EMBEDDABLE OFFICE ENGINE]`

**zoffice-core** is the pure-Rust embeddable engine behind [`zoffice`](https://github.com/MenkeTechnologies/zoffice) — document / spreadsheet / presentation parsing + editing, no GUI dependencies. Links natively into Rust/Tauri hosts and over a C ABI elsewhere.

### The embed — a mountable office view, not just a library

A host that links the engine still needs a document surface. The crate ships one too — a **mountable view** (`webui/zoffice-view.js`, declared in `package.json`'s `zguiView`) and a **feature-gated Tauri backend** (`src/tauri_plugin.rs`, behind the off-by-default `tauri` feature), so a host wires the whole thing in two lines:

```rust
// host main.rs — a BARE app command, so no Tauri v2 permission schema and no capability ACL
.invoke_handler(tauri::generate_handler![zoffice_core::tauri_plugin::zoffice_invoke, /* … */])
.setup(|app| { zoffice_core::tauri_plugin::setup(app.handle())?; Ok(()) })
```

```js
// host frontend — one call per pane; N independent views may share one document
const view = window.mountZoffice(paneEl, { path: "/docs/q3.xlsx" });
```

The view opens `.docx`/`.odt`, `.xlsx`/`.ods`, `.pptx`/`.odp`, `.odg`, `.odf` and `.odb`, choosing the engine command from the file's own type, and renders three surfaces per document: **Document** (the real page/grid/deck, drawn by the same builders the standalone app uses — `webui/zoffice-dom.js` is shared verbatim by both frontends, so one engine node has exactly one DOM rendering), **Data** (the document flattened to sortable, fuzzy-filterable rows), and **Analysis** (the engine analyses below).

Three properties make it host-agnostic. **Transport is pluggable** — `zoffice_invoke` for hosts that register the plugin, `office_invoke` for the standalone app's own command shape, a JUCE native function for the plugin hosts, and a mock that still renders chrome and refuses honestly when there is no backend. **Everything is pane-scoped** — all state lives in the mount closure and every DOM lookup is scoped to the mount root, so a host can tile one view per pane. And **it contributes rather than seizes**: the view renders no command palette and no settings window (those are end-app surfaces), it *offers* command descriptors through `api.commands()` and the host's `setCommands`, and it registers a typed automation surface — verbs `zoffice.view.{open,close,reload,show,find,export,invoke}`, state `zoffice.view.{state,outline}`, events `zoffice.view.{opened,closed,error}` — so one stryke script can drive an office document living inside somebody else's app. The mount body runs inside `ZGui.embed.view()`, which turns any app-level global call into a throw at init instead of a silent fight with the host.

### `zmerge` — git-native 3-way structural merge

Line-based merge treats `.docx`/`.odt` as opaque blobs, so any concurrent edit is an all-or-nothing conflict. `zmerge` instead reconciles the *parsed* document models: it aligns the base/ours/theirs paragraph and table sequences by SHA-256 content hash, auto-resolves every region only one side changed (or both changed identically), and emits a merged, reopenable file plus a typed conflict set for genuine overlaps.

Install the driver once per repo (registers `merge.zoffice` in `.git/config` and appends to `.gitattributes`):

```sh
scripts/git-zoffice-merge --install
```

That writes:

```gitattributes
*.docx merge=zoffice
*.odt  merge=zoffice
```

After that a normal `git merge` reconciles those files structurally: exit `0` = clean, non-zero = the merged file keeps *ours* and the path stays conflicted, with the typed conflict set printed for a resolver. The engine surface is the `writer.merge3` command (JSON `{ base, ours, theirs, out }`) and the C ABI `zoffice_merge3(base, ours, theirs, pathname)`; the GUI renders each conflict in the shared `ZGui.mergeView` three-pane merge tool (OURS · Result · THEIRS, line-aligned diff3 with per-hunk apply chevrons, apply-all-non-conflicting and a live conflict count) and writes the assembled result back by splicing the region, so a resolution may change its paragraph count. Conflicts are ordered by **decision weight** — the character volume of the divergence between the two sides — which is a text measure, not a blast radius: the merge is writer-only, so the conflicting units are prose paragraphs with no dependents to rank. **Writer (`.docx`/`.odt`) is implemented; calc/impress report an unsupported-format error until their models grow the same treatment.**

Every merge also reports **provenance**: one entry per merged paragraph naming which input it came from and its index there. Base-sided entries are exactly the ancestor paragraphs that survived, which is how a caller carries per-paragraph state across the merge.

That matters because some document state never reaches the paragraph model. The docx reader folds only `<w:t>` text into a paragraph, so a `<w:instrText>` payload — a citation field, say — is invisible to the content hash: two documents with identical visible text but divergent payloads merge clean, and one side's payload is dropped with no signal. The `FieldReconciler` hook closes that gap. It can fold out-of-model state into paragraph identity (`identity_salt`, turning a payload-only divergence into a region to resolve) and rewrite each merged paragraph once its provenance is known (`reconcile`). Both methods default to doing nothing, so `merge3` is unchanged by the hook's existence; `merge3_with` takes a reconciler explicitly, and `merge::set_reconciler` installs one process-wide for the `writer.merge3` command and the `zoffice_merge3` C ABI entry, neither of which can take one as an argument.

### `zblame` — structural revision blame for office documents

`git blame` attributes each *line* of a text file to the revision that last touched it — but it can't see inside a `.docx`/`.odt`, so binary office files get no blame at all. `zblame` does it over the *parsed* document: given the file's revision history ordered oldest→newest (the open document last), it attributes every paragraph of the current document to the revision that last gave it its content. Each paragraph starts attributed to the newest revision, then is pushed back one revision at a time for as long as it keeps hash-matching (the same SHA-256 / LCS alignment `zmerge` uses) — so the result is the earliest *unbroken* revision the paragraph has existed in, exactly git blame's "last touched at" semantics, applied to structural nodes instead of text lines.

The engine surface is the `writer.blame` command (JSON `{ versions: [oldest, …, newest], labels?: [...] }`) returning one `{ index, text, version, label }` per paragraph; the GUI adds a Writer command-palette entry (**Structural Blame (revisions)…**) that picks the older snapshots, appends the open document as the newest revision, and renders a per-revision attribution table.

### The office operations, over the same engine

Alongside the analyses below, the engine covers the everyday LibreOffice/Microsoft-Office operations a document is actually opened to perform. Each is one dispatcher command, reachable from the automation bus, the ⌘K palette, and the native menu:

| Command | What it does |
| --- | --- |
| `convert` | Universal conversion (LibreOffice's `--convert-to`), target read from the output extension. A sibling office format (`.odt` ⇄ `.docx`, `.ods` ⇄ `.xlsx`, `.odp` ⇄ `.pptx`) round-trips through the app's model so the result stays editable; PDF/EPUB/HTML/Markdown/text/SVG/MathML go through that app's exporter. A cross-family target is refused, never half-done. |
| `writer.epub` | EPUB 3 export (with an EPUB 2 `toc.ncx` fallback). Chapters split at top-level headings, the source package's images carried into the book, `mimetype` stored first and uncompressed per OCF. |
| `writer.redact` | Redaction. Terms are masked character-for-character, so run boundaries stay aligned and a term split across two runs is masked in **both** — `save_docx` writes the runs, so a run-local mask would ship the secret. Returns a per-location hit report. |
| `writer.mail_merge` | Mail merge against a spreadsheet data source (`.csv`/`.ods`/`.xlsx`, first row names the fields): one combined document, or one file per record. |
| `writer.insert_toc` | Insert a table of contents built from the live heading structure, with dot-leader tab stops and page numbers taken from the same pagination the PDF export uses. |
| `writer.track_changes` | Accept / reject all revisions, or one by index. |
| `writer.headings` | The heading outline a contents block is built from — the preview behind `writer.insert_toc`. |
| `writer.change_case` | Format ▸ Text ▸ Change Case — UPPERCASE, lowercase, Sentence case, Capitalize Every Word or tOGGLE cASE over every paragraph, run and table cell. |
| `writer.autocorrect` | Tools ▸ AutoCorrect ▸ Apply — typographic quotes and apostrophes, dash replacement (`A - B` / `A -- B` → en dash, `A--B` → em dash, `1--2` → en dash), double spaces collapsed, sentence capitals (abbreviations and initials excepted), TWo INitial CApitals, and a fixed replacement table (`(c)` `(r)` `(tm)` `...` and standalone `1/2` `1/4` `3/4`). Each rule can be switched off; the report counts corrections per rule and lists every changed paragraph. A correction that changes the text's length is mapped back onto the runs by source position, so formatting stays on the characters it was on. |
| `writer.sort` | Tools ▸ Sort over a paragraph range — any number of keys, each a 1-based column of the tab- (or character-) separated paragraph compared alphanumerically, numerically or as a date, ascending or descending, optionally case-sensitive. Stable; paragraphs move whole with their runs and formatting. A range with a table inside it is refused rather than detaching the table from its text. |
| `calc.subtotals` | Data ▸ Subtotals: group by a column, aggregate any number of data fields, grand total included. |
| `calc.remove_duplicates` | Drop repeat rows keyed on chosen columns (empty = the whole row), keeping the first occurrence and re-addressing the survivors. |
| `calc.text_to_columns` | Split a column on a delimiter, shifting later columns right rather than overwriting them. |
| `calc.consolidate` | Combine the same report across several sheets by its row labels, recording which sheets contributed each value. |
| `calc.goal_seek` | Tools ▸ Goal Seek — solve for the input that drives a formula to a target. |
| `calc.what_if` | Data ▸ Multiple Operations — one- or two-variable what-if table. |
| `calc.filter` | AutoFilter / Standard Filter with Excel criteria strings (`">10"`, `"<>0"`, an exact value, a text prefix). |
| `calc.pivot_compute` | Compute a pivot from the sheet's own rows (several row fields, several measures), beyond `calc.pivot_tables`, which only reads a stored definition. |
| `calc.descriptive_stats` | Data ▸ Statistics ▸ Descriptive Statistics — per column (every numeric column by default): count, sum, mean, standard error, median, mode, quartiles, variance, standard deviation, kurtosis, skewness, range, min, max. Figures match the worksheet functions LibreOffice's dialog writes (AVERAGE, STDEV, KURT, SKEW, QUARTILE…); one that is undefined for the sample is `null`, not 0. |
| `calc.correlation` | Data ▸ Statistics ▸ Correlation — the Pearson matrix over chosen columns, each pair computed over the rows where both cells are numeric, with the row count per pair. |
| `calc.regression` | Data ▸ Statistics ▸ Regression — least-squares line of one column on another: slope, intercept, r, r², standard error of the estimate and of both coefficients. |
| `calc.anova` | Data ▸ Statistics ▸ Analysis of Variance, single factor — one group per column (every numeric column by default): per-group count, sum, mean, variance; between / within / total SS, df, MS; F, its right-tail p-value and the critical F at `alpha` (default 0.05). F is `null` when every group is constant. |
| `calc.t_test` | Data ▸ Statistics ▸ t-test — `kind` `paired` (rows where both cells are numeric), `equal_variance` (pooled) or `unequal_variance` (Welch): means, variances, observations, pooled variance or Pearson r, df, t, one- and two-tailed p and critical t. The t statistic comes from the same code path as the T.TEST worksheet function. |
| `calc.f_test` | Data ▸ Statistics ▸ F-test — variance ratio of two columns with df, right / left / two-tailed p (the two-tailed figure is F.TEST's) and both critical values. |
| `calc.moving_average` | Data ▸ Statistics ▸ Moving Average — trailing mean over `interval` values of one column; positions before the window fills are `null`. |
| `calc.exponential_smoothing` | Data ▸ Statistics ▸ Exponential Smoothing — `s₀ = x₀`, `sₜ = α·xₜ + (1 − α)·sₜ₋₁`, plus the mean squared one-step-ahead error for comparing α values. |
| `calc.histogram` | Data ▸ Statistics ▸ Histogram — counts per bin with cumulative %, using FREQUENCY's interval rule (`lower < v ≤ upper`, overflow bin last). Given `bins` are upper edges; without them Sturges' rule picks equal-width bins over min..max. |
| `calc.transpose` | Paste Special ▸ Transpose over the whole sheet — rows become columns, merged ranges and text-typed numbers move with their cells, formulas are kept as their values. Previewed in memory; written only to an explicit `out`. |
| `calc.fill_series` | Sheet ▸ Fill Cells ▸ Fill Series — linear, growth or date (day / weekday / month / year) series down, right, up or left across a range, one series per column or row, stopping at an optional end value in the direction the series travels. Month and year steps are counted from the start date (Jan 31 → Feb 29 → Mar 31), weekday steps skip weekends. Previewed in memory; written only to an explicit `out`. |
| `impress.hide_slides` | Slide ▸ Show / Hide Slide (`.pptx`) — set or clear the slideshow-skip flag on chosen slides by splicing the `show` attribute of each slide's root; every other part is copied verbatim. |
| `impress.summary_slide` | Slide ▸ Summary Slide (`.pptx` / `.odp`) — append a slide whose bullets are the titles of the chosen slide and every slide after it, in the deck's own slide-list order. The slide is added as a new part (on the Title-and-Content layout for `.pptx`); every existing part is copied verbatim. |
| `impress.outline` | The deck as its outline, structured and as text. |
| `impress.from_outline` | Author a deck from an outline — a flush-left line starts a slide, an indented or bulleted line is a bullet. `outline_text` emits exactly what this parses, so the pair round-trips. |

### Recalculation critical path — the longest formula dependency chain

Every spreadsheet is a dependency graph: each formula reads other cells, which read others, forming a DAG. The graph-level question is *what is the single longest chain of dependent formulas in this workbook?* That chain is the recalculation **critical path**: the deepest sequence of cells that must be evaluated strictly in order, and therefore the workbook's minimum recalc depth — the spreadsheet analog of a build system's or PERT chart's critical path.

`calc.critical_path` builds the workbook-wide formula DAG (nodes keyed `sheet!ref`, cross-sheet and range references resolved, so `'My Sheet'!A1:B3` edges are followed), then finds the longest chain by a memoized longest-path pass over the graph's topological order (`O(V+E)`). Cells caught in a circular reference are excluded from the acyclic path and reported separately. It returns `{ chain: [{ cell, formula, depth }, …], depth, formula_cells, edges, circular }`, where `chain` runs input-nearest (`depth 1`) → final dependent (`depth == depth`). The GUI adds a Calc command-palette entry (**Recalculation Critical Path**) that renders the chain as a depth-ordered table with the node/edge counts and any circular-reference warning. Formulas are retained for `.xlsx`; other formats yield an empty analysis.

### Dependency blast radius — the keystone cell

The critical path measures the formula DAG's longest *chain* (recalc depth). Its orthogonal question is each cell's downstream *cone*: **if this one cell were wrong, how much of the workbook is wrong with it?** The cell with the largest transitive dependent count is the **keystone** — the value the most of the model rests on, and therefore the highest-consequence place for an error.

`calc.impact_map` builds the same workbook-wide formula DAG as the critical path, but adds a node for every raw *input* cell a formula reads (not just formula cells), so a keystone can be an assumption cell that hundreds of formulas depend on. For each node it reports `direct` (immediate dependents) and `blast` (the transitive dependent set size — how many formulas recalc if the cell changes). `blast` is exact, not double-counted across shared sub-trees: reachable downstream nodes are always formula cells, so each node's reachable set is a bit set over the formula count, unioned in reverse topological order (`O(V·E/word)`), with each set freed once its precedents have consumed it to bound memory to the graph's width. It returns `{ keystones: [{ cell, kind, direct, blast, sheets }, …], keystone, nodes, formula_cells, input_cells, edges, max_blast, circular, truncated }`, ranked blast-descending and capped to the top load-bearing cells. `sheets` is how many distinct sheets a cell's dependent set spans — unioned in the same reverse-topological pass, so it costs one extra word per edge and no second traversal; it separates a mistake that stays in one tab from one that reaches six. Cells in a circular reference are excluded and reported separately. The GUI adds a Calc command-palette entry (**Dependency Blast Radius (keystone)**) that renders the ranking as a table headed by the keystone and its blast radius. Formulas are retained for `.xlsx`; other formats yield an empty analysis.

#### Pre-commit gate — `calc.cell_impact`

`calc.impact_map` answers "which cells are load-bearing?", which is a browsing question. `calc.cell_impact` answers the question a person has with a new value already typed: *if I commit this, what recalculates?* Given `{ path, sheet, ref }` — the same coordinates `calc.edit_cell` writes with, and `ref` may qualify its own sheet (`"Budget!B3"`) — it returns that one cell's `direct`, `blast`, `sheets` and its **exact rank** among the workbook's load-bearing cells, plus `ranked` (how many there are) and `keystone_limit`. The rank is computed over the *untruncated* ranking, so a cell below the top `keystone_limit` that `impact_map` lists still reports its true rank instead of vanishing; `rank` is `null` only when nothing depends on the cell at all.

Two states are kept apart. `analyzable: false` means the analysis never ran — formulas are retained for `.xlsx` only, so an `.ods`/`.xls` workbook produces an all-zero dependency graph indistinguishable from "nothing depends on this cell". A caller must render that as **unknown**, never as **safe**. `truncated: true` means the transitive pass was skipped on a very large workbook, so `blast` is a one-hop lower bound rather than the answer. The GUI wires this into the Calc **Edit cell** flow: the reference and the new value are collected, then the gate reports what the edit would set off and asks for confirmation before `calc.edit_cell` runs. An edit that the analysis proves inert does not interrupt — it reports with the save toast instead.

### `zcause` — root-cause attribution of spreadsheet value changes

The blast radius asks what a cell *could* affect. `zcause` asks the question that exists once there are two revisions: **which edit made this number change?**

`calc.rootcause` (JSON `{ path: <newer revision>, base: <older revision> }`) runs three passes. **Align and classify:** rows are matched between revisions by content hash — LCS over row hashes supplies the anchors (the rows that did not change, the only ones LCS can match), then the rows between consecutive anchors are paired positionally, which is what turns "row deleted, row inserted" into "row modified". Each difference is then an *edit* (formula rewritten, raw value retyped, formula added) or an *output delta* (a formula cell whose text is unchanged but whose value moved). **Prune by cone:** the new revision's formula DAG gives each edit its exact transitive downstream bit set — reusing the same reverse-topological reachability pass as the blast radius — so an output's candidate causes are a bit test rather than a graph walk, pruning hundreds of edits to a handful. **Counterfactual:** each surviving edit is reverted *alone* in a copy of the new revision and only its downstream cone is re-evaluated through the workbook's own formula evaluator, in topological order, measuring how much of each output's observed move disappears. One re-evaluation per edit serves every output in its cone, so cost scales with edits, not edits × outputs.

It returns `{ outputs: [{ cell, formula, before, after, delta, causes: [{ cell, kind, contribution, share }, …], interaction, unattributable }, …], edits: [{ cell, kind, before, after, outputs }, …], blame_center, blame_center_outputs, changed_outputs, alignment_confidence, aligned_rows, added_rows, removed_rows, formula_cells, edges, circular, truncated }` — per output a ranked cause list with contribution shares, and per workbook the **blame center**: the single edit that is the top cause of the most changed outputs.

Three places it reports uncertainty instead of guessing, because each is a place the analysis could quietly start lying. A formula the evaluator cannot handle taints itself and everything downstream of it, and affected outputs are flagged `unattributable` rather than scored as a zero contribution — a silent zero would be a fabricated causal claim. When contributions do not sum to the observed move the causes interact (reverting one edit of a product over-counts), so the output carries an explicit `interaction` flag and the shares are left as measured, never rescaled to 100%. And row alignment reports `alignment_confidence` — the fraction of rows matched unambiguously — rather than assuming same-address comparison holds.

The GUI adds a Calc command-palette entry (**Root Cause of Changes… (vs revision)**) that picks the older revision, then renders the ranked (output → cause) attribution table headed by the blame center, the alignment confidence, and warnings for interacting, unattributable, circular and truncated results. Formulas are retained for `.xlsx`; other formats yield an empty analysis.

### Cross-document impact — the blast radius that leaves the file

The blast radius stops at the workbook edge, because a workbook is all a spreadsheet application can see. Real work does not stop there: the number in a workbook is charted on a slide, quoted in a report, and read by a second workbook that a third one reads. **Change one cell, and the question is which of those go stale.**

Every part of the answer is already written down inside the files, and none of it needs an application to read. A workbook records the workbooks it reads in `xl/externalLinks/`, its `<externalReferences>` list fixing the `[n]` index its own formulas use (`[1]Sheet1!A1`, ISO/IEC 29500-1 §18.2.8). A chart names the spreadsheet its data comes from in `<c:externalData r:id>` — per ISO/IEC 29500-1, "the data can be linked, pointing to a spreadsheet in another file" — and the exact range per series in `<c:f>`. A Word `LINK`/`DDEAUTO`/`INCLUDETEXT` field names its source file and R1C1 range in its own instruction text. An ODF linked section or sheet names its source in `xlink:href`.

`workspace.links` (JSON `{ dir }`) extracts those facts across a folder and resolves each target against the files actually present, returning `{ files, links: [{ from, anchor, kind, target, to, sheet, reference }, …], unreadable }`. A target whose file is absent comes back with an empty `to` rather than being dropped — a deck wired to a workbook nobody kept is the finding, not noise. A filename that matches two files in the corpus resolves to neither: guessing between them would put an edge in the graph that no document ever stated.

`workspace.impact` (JSON `{ dir, file, sheet, ref }`) then walks the union of that cross-file graph and each workbook's **own** formula graph. Inside a workbook, `calc::dependents_of` returns the members of the blast radius `calc.cell_impact` only counts — the same graph, the same normalization, the same single reverse-topological pass, projected to labels instead of a total. Across files, any link whose range covers one of those moved cells carries the staleness to its consumer; a consumer that is itself a workbook cell re-enters its own workbook's graph, so the closure is transitive across file boundaries rather than one hop out. It returns `{ origin, analyzable, files_scanned, links, unresolved, local_cells, anchors: [{ file, anchor, kind, format, hops, via, cell }, …], files_reached, formats, depth, truncated }`. `hops` counts file boundaries crossed; `cell` names the cell that anchor reads, so each row can be checked instead of taken on faith. Every file stays closed the whole time — nothing is opened, recalculated, or evaluated.

The GUI adds a Calc command-palette entry (**Cross-Document Impact… (what else goes stale)**) that picks the folder, takes the cell as `Sheet!Ref`, and renders the stale anchors hop-ordered with the cell each one reads, plus a Tools entry (**Document Link Graph…**) for the raw edges. Cell-level anchors come from OOXML, whose links carry an explicit range; ODF links are recorded at file granularity because ODF cell coordinates are positional, and an ODF anchor says `document` rather than approximating a cell. A non-`.xlsx` origin reports `analyzable: false`, which a caller must render as *incomplete*, never as *safe*.

### Stale numbers — reconciling what a folder displays against what its sources hold

`workspace.impact` answers a hypothetical: what *would* go stale if this cell changed. The question that needs no hypothetical is which numbers are wrong **right now** — and it is answerable, on closed files, because both sides of every link already store their value and the two stores are written at different times.

The consumer's side is the cache its own application wrote at its last refresh. A workbook keeps the cells it read out of another workbook in `xl/externalLinks/externalLinkN.xml`, whose `cell` element ISO/IEC 29500-1 defines as used "to store cached values from external sources such as other workbooks", indexed to a sheet through the part's own `<sheetNames>`. A chart in a deck or a report keeps its plotted series in `<c:numCache>`, which the same standard defines as "the last data shown on the chart for a series", with `<c:f>` naming the range those points came from. The producer's side is the value in its own worksheet as of its last save.

`workspace.audit` (JSON `{ dir }`) reads both stores across the folder and compares them cell by cell, returning `{ files_scanned, links, compared, drifts: [{ file, anchor, kind, format, producer, cell, shown, current, delta, missing }, …], unverified: [{ file, anchor, kind, target, reason }, …], files_affected, formats, truncated }`. `shown` is what the closed document will display when opened; `current` is what its source holds; `delta` is the arithmetic between them. A cached value whose source cell is now empty comes back `missing` and sorts first, ahead of every numeric move. Rows are ordered by *relative* change, so a doubled percentage is not buried under a rounding change to a headcount. Numbers are compared numerically with a relative tolerance, so a re-serialized float is not a finding. Nothing is opened, refreshed, recalculated or evaluated.

`compared` is the denominator and the report is honest about it: a clean audit means nothing among *those* values drifted, never that nothing anywhere drifted. Every link that could not be checked is listed in `unverified` with its reason — an ODF linked section records no per-cell value, a Word `LINK` field caches its result as formatted text rather than as a value (comparing it would test the number format, not the number), a rectangular series range has no unambiguous cache-index order, and a target outside the folder has no producer to read.

### Reconcile — writing the folder back into agreement, in dependency order

`workspace.audit` reports which numbers are wrong. `workspace.reconcile` (JSON `{ dir, apply }`) fixes them: it writes the value each source holds now into the cache each consumer displays it from, in place, across formats, with every file closed the whole time.

The reason this is a different problem from "refresh this document" is that **a repair has to travel**. When `A.xlsx` feeds `B.xlsx` feeds `deck.pptx`, refreshing the deck first copies `B`'s stale number into it and leaves the folder looking done; only refreshing `B` first makes the deck's refresh correct. So the walk runs in `refresh_order` — a topological order of the link graph, ties broken by path so the same corpus always walks the same way — and carries each producer's repaired values forward in memory as it goes. That carry-forward is what lets a change reach a slide *two file boundaries away in one pass*, and rows that only exist because of an earlier repair come back flagged `propagated`, so the transitive part of a run is countable rather than asserted. Documents the graph cannot order — those on or downstream of a cycle of mutually-referencing files — are returned in `unordered` and walked last, and must be rendered as *not guaranteed converged*.

Three caches carry displayed values and all three are rewritten: a workbook's `xl/externalLinks/externalLinkN.xml` cell cache, with the `<cell>` element's `t` attribute moved to match the value so text never lands in a cell still marked numeric; the anchor cell's own cached `<v>`, but **only** where the formula is that external reference and nothing else, because nothing here evaluates a formula; and a chart's `<c:numCache>`/`<c:strCache>` points, which ISO/IEC 29500-1 defines as "the last data shown on the chart for a series" and which therefore *are* what a deck displays before anybody refreshes it. Each patcher streams the original part with quick-xml, records the byte range of the text it must change, and splices — so everything outside a replaced value survives byte-for-byte, and every other part of the package is copied verbatim.

It returns `{ applied, files_scanned, order, unordered, repairs: [{ file, anchor, kind, part, producer, cell, was, now, propagated }, …], deferred: [{ file, anchor, kind, cell, reason }, …], files_written, parts_written, propagated, truncated }`. `apply` defaults to `false`, which plans: identical rows, computed against the same carry-forward so the plan matches what applying would do, and not one byte written. Nothing is ever written that was not already a value in another file on disk, and anything that cannot be written is listed in `deferred` with its reason — a source outside the folder, a source cell that is now empty (blanking the cache would hide a number that was there and writing a zero would invent one), text where a numeric chart cache demands a number, a formula whose result this engine will not invent.

### [`MenkeTechnologies`](https://github.com/MenkeTechnologies) &middot; [`MenkeTechnologiesMeta`](https://github.com/MenkeTechnologies/MenkeTechnologiesMeta)
