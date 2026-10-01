```
 ______ __  __  ___  ____   _   _
|__  / |  \/  |/ _ \|  _ \ / \ | |
  / /  | |\/| | | | | | | / _ \| |
 / /_  | |  | | |_| | |_| / ___ \ |___
/____| |_|  |_|\___/|____/_/   \_\_____|
```

![TypeScript](https://img.shields.io/badge/TypeScript-Vim%20%2B%20Emacs-05d9e8?style=flat-square)
![bundler](https://img.shields.io/badge/esbuild-IIFE%20bundle-ff2a6d?style=flat-square)
![engine](https://img.shields.io/badge/monaco--vim%20%2B%20monaco--emacs-vendored-39ff14?style=flat-square)
![adapter](https://img.shields.io/badge/surface-adapter%20driven-f5a623?style=flat-square)
![MenkeTechnologies](https://img.shields.io/badge/MenkeTechnologies-shared%20component-d300c5?style=flat-square)

### `[SHARED VIM / EMACS MODAL EDITOR // MONACO-VIM + MONACO-EMACS, VENDORED & ADAPTER-DRIVEN]`

> *"One modal engine, owned in source, droppable anywhere."*

### [`Read the Docs`](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-modal-editor) &middot; [`Engineering Report`](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-modal-editor/report)

Shared **Vim / Emacs modal-editing editor** for the MenkeTechnologies app stack. The Vim
engine (`src/engine/vim/keymap_vim.ts`) and Emacs engine (`src/engine/emacs/*`) are
**vendored from [`monaco-vim`](https://github.com/brijeshb42/monaco-vim) 0.4.4 and
[`monaco-emacs`](https://github.com/aioutecism/monaco-emacs) 0.3.0** and adapted so we own
them outright — no external runtime deps (the two `lodash` helpers monaco-emacs used are
replaced by `src/engine/emacs/localutil.ts`). esbuild bundles it to a vendored IIFE that
exposes a single `window.ZModal` facade.

## Why it drops in anywhere — the adapter seam

The Vim engine talks **only** to a surface *adapter* that implements the CodeMirror API it
expects. Swap the adapter and the same 7k-line engine drives a different surface:

```
                             ┌─ adapters/cm_core.ts ─┐   surface-agnostic half (text/key/event helpers)
                             │                       │
engine/vim/keymap_vim.ts  ──imports──▶  adapters/monaco_adapter.ts   → a Monaco editor
                                        adapters/dom_adapter.ts      → a contenteditable page (NO Monaco)
```

**Both adapters ship.** The DOM build aliases the engine's `../../adapters/monaco_adapter`
import to `dom_adapter.ts`, so the vendored engine is reused byte-for-byte while the bundle
never pulls in Monaco. `dom_adapter` treats the host's block-level descendants as "lines"
(inline nodes are transparent text, `<br>` is a hard break); intra-line edits go through
`execCommand` so surrounding inline formatting and the browser's native undo survive.
Multi-line / structural edits rebuild the affected blocks as paragraphs — formatting on those
lines is lost, except for the linewise yank/put case below.

Emacs (`engine/emacs`) is coupled to the Monaco editor API and rides the Monaco adapter only.

### Linewise yank/put keeps inline formatting

Reading a range (`yy`, `dd`) caches each fully-covered line's inline HTML keyed by its plain
text; rebuilding a line whose text matches restores it from that HTML. So `yy`+`p` and `dd`+`p`
preserve font / colour / size in a rich surface instead of dropping to plain text. The cache is
a bounded FIFO (256 lines) and yanks spanning more than 200 lines are skipped. The vendored vim
core is untouched — this lives entirely in `dom_adapter.ts`.

## ⚠️ One Monaco per page

The Monaco build **bundles its own Monaco**. If the host page ALSO loads another Monaco
bundle (e.g. `zpwr-hooks-editor`), a WebKit/WKWebView content process can crash on the second
full Monaco → **blank window** (Chromium tolerates two; WebKit does not). Three clean options:

1. **Use the DOM build** — `modal-editor-dom.bundle.js` has no Monaco at all and drives the
   app's existing contenteditable pages directly. This is what word / ppt / spreadsheet
   surfaces load.
2. **Share one Monaco** — have the app create the editor and call `attachVim(editor)` /
   `attachEmacs(editor)`; these need no bundled editor of their own. (A `monaco-editor`-external
   build variant of the Monaco bundle is still the tidy way to ship this — TODO.)
3. **Be the only Monaco** — use `create(...)` only in apps that don't already load one.

## Layout

- `src/index.ts` — the Monaco IIFE entry: theme + worker wiring and the `window.ZModal` facade.
- `src/index-dom.ts` — the Monaco-free IIFE entry: the same `window.ZModal` global, minus Monaco.
- `src/engine/vim/keymap_vim.ts` — the vim engine (vendored; talks to an adapter as its "CodeMirror").
- `src/adapters/cm_core.ts` — the surface-agnostic half of the CodeMirror shim (imports no Monaco).
- `src/adapters/monaco_adapter.ts` — the CodeMirror-API adapter over a Monaco editor.
- `src/adapters/dom_adapter.ts` — the same API over a contenteditable element, no Monaco.
- `src/completion.ts` — insert-mode completion popup for the DOM editor.
- `src/snippets.ts` — the user snippet store, dynamic-token expansion, stryke bodies, manager UI.
- `src/engine/emacs/*` — the emacs extension (vendored; Monaco-coupled) + a local lodash-free util.
- `src/statusbar.ts` — the vim mode / key-buffer / ex command-line status bar.
- `src/worker-entry.ts` — Monaco base web-worker entry.
- `scripts/build-modal-editor.mjs` — esbuild bundler; reads `src/`, writes into the consuming app.

## API — Monaco build (`window.ZModal`)

```js
// Convenience mount — creates a Monaco editor + applies the mode (bundles Monaco):
const h = window.ZModal.create(hostEl, {
  doc: "text",
  mode: "vim",          // 'default' | 'vim' | 'emacs'
  statusBar: statusEl,  // optional — vim mode / key-buffer / ex line render here
  language: "plaintext",
  onChange: (text) => save(text),
});
h.getValue(); h.setValue("…"); h.setMode("emacs"); h.focus(); h.layout(); h.destroy();

// Monaco-agnostic — attach a mode to an editor the host already created (no 2nd Monaco):
window.ZModal.attachVim(existingMonacoEditor, statusEl);
window.ZModal.attachEmacs(existingMonacoEditor);
```

## API — DOM build (`window.ZModal`, same global)

`modal-editor-dom.bundle.js` exposes a vim-only facade over a contenteditable element. A
consumer loads the Monaco bundle *or* the DOM bundle, never both.

```js
const h = window.ZModal.attach(pageEl, {
  mode: "vim",             // 'default' | 'vim' — 'default' hands typing back to the browser
  statusBar: statusEl,     // optional
  onChange: (text) => save(text),
  readOnly: false,
  completion: { source: (prefix, fullText) => [...] },  // see below
});
h.getValue(); h.focus(); h.setMode("default"); h.isVim(); h.destroy();
h.adapter;                 // the live vim adapter, or null when not engaged

// Lower level: attach vim to an element and get the adapter back (.dispose() detaches).
window.ZModal.attachVim(pageEl, statusEl);
```

### Insert-mode completion popup

While typing in INSERT mode the DOM editor queries a per-field source for candidates matching
the word before the caret and shows a popup:

| Key | Action |
| --- | --- |
| `Tab` / `Enter` | accept the selected candidate |
| `Ctrl-N` / `↓` | next candidate |
| `Ctrl-P` / `↑` | previous candidate |
| `Esc` | dismiss |

The source comes from `attach({ completion })` or, per element, from `host.zmodalCompletion`
(read at query time) — so a generic mount can attach fields whose candidate lists it doesn't
know. `CompletionConfig` also takes `separators` (characters that terminate the token),
`minChars` (default `1`) and `maxItems` (default `8`). With no source set the popup never
shows and every key, `Tab` included, flows straight to the Vim engine.

### Snippets

Snippets are `{ trigger, body }` pairs kept in `localStorage` (per app WebView). Type a trigger,
the completion popup offers it, `Tab` inserts the body. Bodies may carry dynamic tokens —
`$DATE`, `$TIME`, `$DATETIME`, `$DATE_ISO`, `$YEAR` — resolved at insertion time.

A snippet marked `stryke` treats its body as a **stryke script**: the body is run on expansion
and its output is what gets inserted. The host app registers the runtime once (e.g. wired to a
Tauri command); with no evaluator registered a stryke snippet inserts `""`.

```js
window.ZModal.snippets.setEvaluator((code) => invoke("run_stryke_hook", { code }));

window.ZModal.snippets.add("sig", "— sent $DATE");        // plain body
window.ZModal.snippets.add("uuid", "print uuid();", true); // stryke body
window.ZModal.snippets.list();          // Snippet[]
window.ZModal.snippets.match("si");     // completion candidates for a prefix
window.ZModal.snippets.expand(body);    // resolve dynamic tokens only
window.ZModal.snippets.runStryke(code); // run a body through the evaluator
window.ZModal.snippets.remove("sig");
window.ZModal.snippets.openManager();   // built-in list / add / update / remove UI
```

## Build (build-on-each-consumer)

The source lives here; the bundle is built inside the consuming app so esbuild resolves *that
app's* `monaco-editor` + `esbuild` devDeps and writes into its `frontend/lib/`. Invoke from the
consumer's project root (e.g. `tauri.conf.json` `beforeDevCommand`):

```
node <path-to-submodule>/scripts/build-modal-editor.mjs
```

Output dir defaults to `<cwd>/frontend/lib`; override with `MODAL_EDITOR_OUT`. Three artifacts are
emitted (all build artifacts — gitignore them in the consumer):

| Artifact | Contents |
| --- | --- |
| `modal-editor.bundle.{js,css}` | the Monaco editor + Vim/Emacs; bundles its own Monaco |
| `modal-editor.worker.js` | Monaco's base web worker, fetched at runtime via `MonacoEnvironment.getWorker` |
| `modal-editor-dom.bundle.js` | the Monaco-free contenteditable build (Vim only) |

`index.html` loads `lib/modal-editor.bundle.css` (link) + `lib/modal-editor.bundle.js` (script)
for the Monaco build, or just `lib/modal-editor-dom.bundle.js` for the DOM build — never both,
since each defines `window.ZModal`.

Set `MODAL_EDITOR_DOM_ONLY=1` to emit **only** the DOM bundle. That build imports no Monaco, so
the consumer needs no `monaco-editor` at all; otherwise the bundler requires `monaco-editor` in
the consumer's `node_modules` and fails fast if it is missing. The Vim/Emacs engines are
vendored here — **no** `monaco-vim` / `monaco-emacs` deps needed in the consumer either way.

## The app stack

`zpwr-modal-editor` is a shared component of the MenkeTechnologies apps — browse the rest via the
[MenkeTechnologiesMeta](https://github.com/MenkeTechnologies/MenkeTechnologiesMeta) umbrella repo.

## License

MIT — see [`LICENSE`](LICENSE). Vendored `monaco-vim` / `monaco-emacs` / CodeMirror-vim sources
retain their upstream MIT licenses under `src/engine/`.
