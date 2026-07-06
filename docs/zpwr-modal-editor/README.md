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
engine/vim/keymap_vim.ts  ──imports──▶  adapters/monaco_adapter.ts   → a Monaco editor
                                        adapters/dom_adapter.ts       → a textarea / contenteditable   (next milestone)
```

Today one adapter ships (`monaco_adapter`, over a Monaco editor). A **DOM / contenteditable
adapter** implementing the same API would let the engine drive a raw page surface (a WYSIWYG
page, a slide text box) with no Monaco at all. Emacs (`engine/emacs`) is currently coupled to
the Monaco editor API and rides the Monaco adapter only.

## ⚠️ One Monaco per page

The default build **bundles its own Monaco**. If the host page ALSO loads another Monaco
bundle (e.g. `zpwr-hooks-editor`), a WebKit/WKWebView content process can crash on the second
full Monaco → **blank window** (Chromium tolerates two; WebKit does not). Two clean options:

1. **Share one Monaco** — have the app create the editor and call `attachVim(editor)` /
   `attachEmacs(editor)`; these need no bundled editor of their own. (A `monaco-editor`-external
   build variant is the tidy way to ship this — TODO.)
2. **Be the only Monaco** — use `create(...)` only in apps that don't already load one.

## Layout

- `src/index.ts` — the IIFE entry: Monaco theme + worker wiring and the `window.ZModal` facade.
- `src/engine/vim/keymap_vim.ts` — the vim engine (vendored; talks to an adapter as its "CodeMirror").
- `src/adapters/monaco_adapter.ts` — the CodeMirror-API adapter over a Monaco editor.
- `src/engine/emacs/*` — the emacs extension (vendored; Monaco-coupled) + a local lodash-free util.
- `src/statusbar.ts` — the vim mode / key-buffer / ex command-line status bar.
- `src/worker-entry.ts` — Monaco base web-worker entry.
- `scripts/build-modal-editor.mjs` — esbuild bundler; reads `src/`, writes into the consuming app.

## API (`window.ZModal`)

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

## Build (build-on-each-consumer)

The source lives here; the bundle is built inside the consuming app so esbuild resolves *that
app's* `monaco-editor` + `esbuild` devDeps and writes into its `frontend/lib/`. Invoke from the
consumer's project root (e.g. `tauri.conf.json` `beforeDevCommand`):

```
node <path-to-submodule>/scripts/build-modal-editor.mjs
```

Output dir defaults to `<cwd>/frontend/lib`; override with `MODAL_EDITOR_OUT`. The generated
`modal-editor.bundle.{js,css}` + `modal-editor.worker.js` are build artifacts (gitignore them in
the consumer). `index.html` loads `lib/modal-editor.bundle.css` (link) + `lib/modal-editor.bundle.js`
(script); the worker is fetched at runtime via `MonacoEnvironment.getWorker`. The Vim/Emacs engines
are vendored here — **no** `monaco-vim` / `monaco-emacs` deps needed in the consumer.

## The app stack

`zpwr-modal-editor` is a shared component of the MenkeTechnologies apps — browse the rest via the
[MenkeTechnologiesMeta](https://github.com/MenkeTechnologies/MenkeTechnologiesMeta) umbrella repo.

## License

MIT — see [`LICENSE`](LICENSE). Vendored `monaco-vim` / `monaco-emacs` / CodeMirror-vim sources
retain their upstream MIT licenses under `src/engine/`.
