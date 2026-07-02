# Vision

> **The design goal, in one line:** a CLI IDE that is *maximally powerful with
> zero user configuration* — install the binary, open a project, and have the
> full power of a graphical IDE in the terminal, with the muscle memory of
> **Spacemacs** and **JetBrains** already wired in.

zemacs is a modal IDE in Rust, built on a tree-sitter + LSP engine. It aims at a
single, opinionated target: **the most capable out-of-the-box terminal IDE you
can `brew install`.**

## The four pillars

1. **Zero user config.** Everything works on first launch. No `init.el`, no
   `init.vim`, no plugin manager, no Mason, no `:PackerSync`, no external
   language-server bootstrap ritual. The defaults *are* the product. (You *can*
   still customize — keymaps, themes, settings, `~/.zemacs/init.el` — but you
   should never *have* to in order to be productive.)

2. **Maximum power.** Not a minimal editor you grow into — the full IDE surface
   ships in the single static binary: LSP (completion, diagnostics, hover,
   inlay hints, rename, code actions), a DAP debugger, tree-sitter for the
   bundled languages, a fuzzy file picker, a project file tree, a real PTY
   terminal, magit-style git, diff/merge tooling, run configurations, a
   minimap, narrowing, folding, multiple selections, an org-mode agenda, a hex
   editor, settings/theme/keymap editors, a searchable help browser, and **five
   embedded scripting languages with a live REPL** (elisp, vimscript, awk, zsh,
   stryke) — no FFI, no external executables.

3. **CLI-first, native.** Terminal is the primary surface, not a fallback. No
   Electron, no DOM, no Node. Native-compiled Rust that runs in an SSH session
   on a Raspberry Pi as happily as on a workstation — open a 200 MB file, a line
   of minified JS, or ShiftJIS-encoded text and edit it without flinching.

4. **Parity with Spacemacs and JetBrains.** These are the two reference
   workflows. A Spacemacs user's `SPC` leader tree and a JetBrains user's
   keymap and IDE actions should both *just work* — same key, same result — so
   neither has to relearn anything to switch.

## Is the goal achieved?

**Substantially, yes — and the project refuses to claim it without proof.**

Coverage is not asserted by hand; it is **re-derived from zemacs source on every
report run** and measured against the *exhaustive, cited* feature inventories of
Vim/Neovim, Emacs, Spacemacs, and JetBrains (parsed from each tool's own
documentation). A mapping that points at non-existent code is flagged as broken,
not counted. See [`port/README.md`](../port/README.md) for the honesty contract.

The headline measure is **functionality coverage** — distinct editor
*capabilities*, counted once regardless of how many ancestor editors expose the
same feature (it answers "what can zemacs *do*," not "how many keys overlap").
By that measure the great majority of the tracked capability surface is
implemented today, with only a handful of genuine gaps remaining. Per the
muscle-memory tables, **JetBrains** and **Spacemacs** are both well into the
high range — every cited JetBrains action is at least partially covered, and the
Spacemacs `SPC` tree is largely complete — while the Emacs *chord* surface is
intentionally low because zemacs is modal (vim keys), not a chord editor.

Live numbers — denominator, ported, partial, broken, and the per-source and
per-capability breakdowns — are in the generated reports, never hardcoded here so
they cannot go stale:

- [`docs/port_report.md`](port_report.md) — full capability + per-source coverage
- [`docs/keybinding_report.md`](keybinding_report.md) — the key-press surface
- [`docs/spacemacs_gaps.md`](spacemacs_gaps.md) — remaining Spacemacs deltas

### What "achieved" does **not** mean

Honesty cuts both ways:

- **Not 100% parity with three giant editors.** The Emacs manual denominator
  includes Dired, Gnus, Calc, TeX-mode and games; zemacs deliberately does not
  chase that tail. "Parity" here means the Spacemacs and JetBrains *daily
  workflows*, not every esoteric command in every ancestor.
- **Refactoring is the known weak area.** Symbol-level refactors (extract,
  inline, change-signature) are mostly LSP-delegated and only partially wired;
  this is the largest open gap and the clearest place new work moves the number.
- **"Zero config" is the standard, and regressions count as bugs.** Any feature
  that needs a manual setup step to function is treated as not-yet-meeting the
  goal, not as "configurable."

## Non-goals

- **Not "everything for everyone."** zemacs has an opinion (modal, selection →
  action, batteries-included). It is not trying to be a blank canvas.
- **Not a code-golf keymap.** Consistency and memorability beat saving a
  keystroke.
- **Not a GUI app.** Native terminal first; no Electron/DOM.
- **Not config-mandatory.** Customization is allowed and supported, but the
  measure of success is how much you can do having configured *nothing*.
