/**
 * MenkeTechnologies app store — product catalog + storefront logic.
 *
 * PRODUCTS is the single source of truth. The grid (index.html), the product
 * detail page (product.html), the cart, and the checkout all read from it.
 * Edit prices / tiers / copy here — nothing is duplicated elsewhere.
 *
 * Pricing is in whole USD. price: 0 renders as "Free". Per-product license
 * tiers override the base price; the first tier is the default selection.
 */
(function () {
  'use strict';

  // ---- Catalog --------------------------------------------------------
  var PRODUCTS = [
    {
      id: 'zpdf',
      name: 'zpdf',
      glyph: 'P',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A from-scratch PDF editor that replaces Adobe Acrobat and macOS Preview — full document editing, annotation & markup, AcroForms fill/flatten, digital & certificate signatures, OCR, redaction, page management (merge/split/extract/rotate/crop), and convert/export — in Rust behind a cyberpunk HUD. Its pure-Rust zpdf-core engine is extracted so it embeds inside the other apps.',
      pills: ['Tauri v2', 'Rust', 'Edit · annotate · sign', 'Embeddable core'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'zphoto',
      name: 'zphoto',
      glyph: 'PH',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A from-scratch raster image editor that replaces GIMP and Photoshop — a full photo suite in Rust behind a cyberpunk HUD: layers, selections, brushes, filters, and non-destructive adjustments. Its pure-Rust zphoto-core engine is extracted so it embeds inside the other apps.',
      pills: ['Tauri v2', 'Rust', 'Layers · filters · brushes', 'Embeddable core'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'zemail',
      name: 'zemail',
      glyph: 'E',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A from-scratch email client in Rust behind a cyberpunk HUD — a fast, owned desktop mail app. Its pure-Rust zemail-core engine is extracted so the same mail engine embeds inside the other MenkeTechnologies apps.',
      pills: ['Tauri v2', 'Rust', 'Desktop mail', 'Embeddable core'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'zoffice',
      name: 'zoffice',
      glyph: 'O',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A from-scratch office suite in Rust — documents, spreadsheets, and presentations — behind a cyberpunk HUD, replacing Microsoft Office. Its pure-Rust zoffice-core engine is extracted so the same office engine embeds inside the other MenkeTechnologies apps.',
      pills: ['Tauri v2', 'Rust', 'Docs · sheets · slides', 'Embeddable core'],
      price: 99,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms', price: 99 },
        { name: 'Pro', desc: 'Commercial use; updates within this major version', price: 199 },
      ],
    },
    {
      id: 'audio-haxor',
      name: 'audio haxor',
      glyph: 'A',
      category: 'Desktop Apps',
      badge: 'BESTSELLER',
      tagline: 'A Tauri v2 / JUCE desktop app that jacks into your audio plugin directories, maps every VST2/VST3/AU/CLAP it finds, scans sample libraries and DAW projects, and checks the web for newer plugin versions — all behind a cyberpunk CRT interface.',
      pills: ['Tauri v2', 'JUCE', 'VST/AU/CLAP', 'macOS/Linux/Win'],
      price: 99,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms', price: 99 },
        { name: 'Pro', desc: 'Commercial use; updates within this major version', price: 199 },
      ],
    },
    {
      id: 'traderview',
      name: 'traderview',
      glyph: 'T',
      category: 'Desktop Apps',
      badge: 'SAVES $2,604/YR',
      tagline: 'A TraderVue-style trading journal that replaces TraderVue + DayTradeDash + StockInvest.us in one self-hosted binary. Import broker CSV → atomic execution rows → FIFO trade roll-up → equity curve, summary stats, and per-trade / per-day markdown journal.',
      pills: ['Tauri v2', 'Embedded Postgres', '13 brokers', '20+ reports'],
      price: 149,
      tiers: [
        { name: 'Desktop', desc: 'Single user, embedded Postgres', price: 149 },
        { name: 'Self-Hosted Web', desc: 'Multi-user axum server + JWT auth', price: 199 },
      ],
    },
    {
      id: 'ztranslator',
      name: 'ztranslator',
      glyph: 'ZT',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A real-time event-translation desktop app in pure Rust — also embeddable as a routing engine inside other apps. Bridges MIDI, OSC, DMX, and file-watcher triggers to outgoing actions: MIDI/OSC/DMX out, keystroke, mouse, AppleScript, timer, or a host command. Each translator runs a rules script on an integer VM, with auto-update and BOME MIDI Translator Pro .bmtp import/export.',
      pills: ['MIDI · OSC · DMX', 'File watchers', '.bmtp import/export', 'macOS/Linux/Win'],
      price: 99,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 99 },
      ],
    },
    {
      id: 'zcite',
      name: 'zcite',
      glyph: 'C',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A from-scratch reference manager in Rust behind a cyberpunk HUD, replacing Zotero — library, collections, tags, and saved searches; citations & bibliographies in APA / MLA / Chicago / IEEE; BibTeX / RIS / CSL-JSON import-export; DOI / ISBN / PMID lookup; and duplicate detection. Its pure-Rust zcite-core engine is extracted so the same reference engine embeds inside the other MenkeTechnologies apps.',
      pills: ['Tauri v2', 'Rust', 'Cite · BibTeX · DOI', 'Embeddable core'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'zreq',
      name: 'zreq',
      glyph: 'R',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A from-scratch API client in Rust behind a cyberpunk HUD, replacing Postman — workspaces, collections, and requests; environments, variables, and auth; HTTP execution with history; code generation; and import/export. Its pure-Rust zreq-core engine is extracted so the same request engine embeds inside the other MenkeTechnologies apps.',
      pills: ['Tauri v2', 'Rust', 'HTTP · auth · codegen', 'Embeddable core'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'ztunnel',
      name: 'ztunnel',
      glyph: 'TN',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A from-scratch VPN tunnel manager in Rust behind a cyberpunk HUD, replacing Tunnelblick — manage OpenVPN and WireGuard connections, configs, process control, logs, stats, and credentials from one owned, cross-platform desktop app. Its pure-Rust ztunnel-core engine is extracted so the same VPN engine embeds inside the other MenkeTechnologies apps.',
      pills: ['Tauri v2', 'Rust', 'OpenVPN · WireGuard', 'Embeddable core'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'zgo',
      name: 'zgo',
      glyph: 'G',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A from-scratch launcher in Rust behind a cyberpunk HUD, replacing Alfred — workflows (objects + connections), Script Filter feedback, fuzzy matching, variable/token expansion, web searches, clipboard history, and snippets with auto-expansion. Its pure-Rust zgo-core engine is extracted so the same launcher engine embeds inside the other MenkeTechnologies apps.',
      pills: ['Tauri v2', 'Rust', 'Launcher · workflows', 'Embeddable core'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'zftp',
      name: 'zftp',
      glyph: 'FT',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A from-scratch file-transfer client in Rust behind a cyberpunk HUD, replacing Cyberduck — bookmarks and connections over FTP / FTPS / SFTP / WebDAV plus S3, Google Cloud Storage, Azure, Backblaze B2, Swift, Google Drive, Dropbox, OneDrive and Box; .duck bookmark import; a session manager; a download / upload / sync transfer queue; per-session logs and throughput; and stored credentials. Its pure-Rust zftp-core engine is extracted so the same transfer engine embeds inside the other MenkeTechnologies apps.',
      pills: ['Tauri v2', 'Rust', 'FTP · SFTP · S3 · cloud', 'Embeddable core'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'zcontainer',
      name: 'zcontainer',
      glyph: 'CT',
      category: 'Desktop Apps',
      badge: 'WORLD FIRST',
      tagline: 'The first compiled-native desktop GUI for both Docker and Kubernetes — every other tool is Electron (Lens/FreeLens/Headlamp) or a TUI (k9s). A from-scratch container & Kubernetes manager in Rust behind a cyberpunk HUD, replacing Docker Desktop and Lens — containers, images, volumes, networks, and Compose stacks; multi-cluster Kubernetes contexts with pods, workloads, services, CRDs, and Helm releases; live log streaming, in-pod exec, and port-forwarding; plus YAML editing and resource inspection from one owned, cross-platform desktop app. Its pure-Rust zcontainer-core engine is extracted so the same container/k8s engine embeds inside the other MenkeTechnologies apps.',
      pills: ['Tauri v2', 'Docker · Kubernetes', 'Logs · exec · port-forward', 'Embeddable core'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'zterminal',
      name: 'zterminal',
      glyph: 'TE',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A GPU-accelerated, cross-platform terminal emulator in Rust (OpenGL) — sensible defaults, extensive TOML configuration, and high-throughput VTE performance across BSD, Linux, macOS, and Windows. Native tmux control via the wire protocol (no subprocess), cross-pane search, broadcast input, a unified exposé, and tmux-resurrect-style session save/restore — all from the command palette.',
      pills: ['Rust', 'OpenGL GPU', 'BSD/Linux/macOS/Win', 'Native tmux control'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'zpwr-daw',
      name: 'zpwr-daw',
      glyph: 'D',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A two-view DAW built on one generalized grid engine — an Arrangement timeline (tracks, clips, sections, tempo/meter maps, markers, breakpoint automation) and a Session clip launcher (scenes, follow actions) — driven by a pure C++ ClipEngine on a swung audio-thread step clock that keeps playing even when the host window is minimised. Note, automation and trigger clips on one canvas, with byte-identical C++/JS MIDI export and JSON project save. Host-agnostic core (JUCE + Tauri) with a C ABI + Rust bindings.',
      pills: ['Arrangement + Session', 'Note · automation · trigger clips', 'MIDI/JSON export', 'JUCE + Tauri'],
      price: 199,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms', price: 199 },
        { name: 'Studio', desc: 'Commercial use; updates within this major version', price: 399 },
      ],
      docs: [
        { label: 'Manual (PDF)', desc: 'The zpwr-daw manual — shared-engine architecture overview + per-module node & parameter reference for the note-stream blocks every track wires, generated from the live registry.', url: 'docs/zpwr-daw-reference.pdf' },
        { label: 'Full Catalog (PDF)', desc: 'The complete shared patch-graph reference — every block across all four plugins (zpwr-synth, zpwr-fx, zpwr-midi-fx, zpwr-daw), with an alphabetical index.', url: 'docs/zpwr-patch-core-block-catalog.pdf' },
      ],
    },
    {
      id: 'zpwr-synth',
      name: 'zpwr-synth',
      glyph: 'S',
      category: 'Audio Plugins',
      badge: 'WORLD FIRST',
      tagline: 'Part of the first fully-modular patch-graph audio plugin quartet (with zpwr-daw) to pair free patch-graph wiring with a no-cable knob panel, one-click EZ auto-wiring, and stereo-mirror + offset-preserving stereo link. A fully modular patch-graph synthesizer built on JUCE — each voice is a free patch graph of 299 modules (VA/wavetable/FM/additive/supersaw/Karplus oscillators, filters, ADSR/LFO/S&H, VCA), unlimited layers, plus a master + unlimited-aux FX-bus rack running the shared 2,772-module audio pack. Shipping as VST3, AU, CLAP, and Standalone.',
      pills: ['JUCE', 'VST3/AU/CLAP/Standalone', 'Fully modular', 'macOS/Linux/Win'],
      price: 149,
      tiers: [
        { name: 'Personal', desc: 'Single user, all formats', price: 149 },
        { name: 'Studio', desc: 'Commercial use; updates within this major version', price: 299 },
      ],
      docs: [
        { label: 'Manual (PDF)', desc: 'The zpwr-synth manual — per-module node & parameter reference for the modular voice engine, generated from the live registry.', url: 'docs/zpwr-synth-reference.pdf' },
        { label: 'Block Catalog (PDF)', desc: 'Every DSP block zpwr-synth ships — its 49 synth-voice modules plus the shared audio pack on the master/aux FX bus.', url: 'docs/zpwr-synth-block-catalog.pdf' },
        { label: 'Full Catalog (PDF)', desc: 'The complete shared patch-graph reference — every block across all four plugins (zpwr-synth, zpwr-fx, zpwr-midi-fx, zpwr-daw), with an alphabetical index.', url: 'docs/zpwr-patch-core-block-catalog.pdf' },
      ],
    },
    {
      id: 'zpwr-fx',
      name: 'zpwr-fx',
      glyph: 'F',
      category: 'Audio Plugins',
      badge: 'WORLD FIRST',
      tagline: 'Part of the first fully-modular patch-graph audio plugin quartet (with zpwr-daw) to pair free patch-graph wiring with a no-cable knob panel, one-click EZ auto-wiring, and stereo-mirror + offset-preserving stereo link. A fully modular patch-graph effects plugin built on JUCE — wire 2,772 DSP modules (including 171 analog-circuit models) into your own algorithms, with a per-param mod matrix and EZ-wire auto-routing. Shipping as VST3, AU, CLAP, and Standalone.',
      pills: ['JUCE', 'VST3/AU/CLAP/Standalone', '2,772 modules', '171 analog models'],
      price: 79,
      tiers: [
        { name: 'Personal', desc: 'Single user, all formats', price: 79 },
        { name: 'Studio', desc: 'Commercial use; updates within this major version', price: 89 },
      ],
      docs: [
        { label: 'Manual (PDF)', desc: 'The zpwr-fx manual — shared-engine architecture overview + per-module node & parameter reference, generated from the live registry.', url: 'docs/zpwr-fx-reference.pdf' },
        { label: 'Block Catalog (PDF)', desc: 'Every DSP block zpwr-fx ships — the full audio patch-graph pack incl. 171 analog-circuit models.', url: 'docs/zpwr-fx-block-catalog.pdf' },
        { label: 'Full Catalog (PDF)', desc: 'The complete shared patch-graph reference — every block across all four plugins (zpwr-synth, zpwr-fx, zpwr-midi-fx, zpwr-daw), with an alphabetical index.', url: 'docs/zpwr-patch-core-block-catalog.pdf' },
      ],
    },
    {
      id: 'zpwr-midi-fx',
      name: 'zpwr-midi-fx',
      glyph: 'M',
      category: 'Audio Plugins',
      badge: 'WORLD FIRST',
      tagline: 'Part of the first fully-modular patch-graph audio plugin quartet (with zpwr-daw) to pair free patch-graph wiring with a no-cable knob panel, one-click EZ auto-wiring, and stereo-mirror + offset-preserving stereo link. A fully modular MIDI-effects plugin built on JUCE — the same free patch-graph engine as zpwr-fx, instantiated on the note stream: 111 modules (arp, chord, scale, Euclidean/generative seq, humanize, remap) wired into your own MIDI algorithm. Shipping as VST3, AU, CLAP, and Standalone.',
      pills: ['JUCE', 'VST3/AU/CLAP/Standalone', 'Fully modular', '111 modules'],
      price: 79,
      tiers: [
        { name: 'Personal', desc: 'Single user, all formats', price: 79 },
        { name: 'Studio', desc: 'Commercial use; updates within this major version', price: 89 },
      ],
      docs: [
        { label: 'Manual (PDF)', desc: 'The zpwr-midi-fx manual — shared-engine architecture overview + per-module node & parameter reference, generated from the live registry.', url: 'docs/zpwr-midi-fx-reference.pdf' },
        { label: 'Block Catalog (PDF)', desc: 'Every block zpwr-midi-fx ships — its note-stream module pack (arp, chord, scale, Euclidean/generative seq, humanize, remap).', url: 'docs/zpwr-midi-fx-block-catalog.pdf' },
        { label: 'Full Catalog (PDF)', desc: 'The complete shared patch-graph reference — every block across all four plugins (zpwr-synth, zpwr-fx, zpwr-midi-fx, zpwr-daw), with an alphabetical index.', url: 'docs/zpwr-patch-core-block-catalog.pdf' },
      ],
    },
    {
      id: 'zshrs',
      name: 'zshrs',
      glyph: 'Z',
      category: 'Developer Tools',
      badge: 'WORLD FIRST',
      tagline: 'The first compiled Unix shell. Rkyv-backed bytecode + Cranelift JIT, an 18-thread parallel runtime, and a persistent worker pool — drop-in zsh compatibility with none of the startup tricks. Free and open source.',
      pills: ['Rust', 'JIT', 'macOS/Linux', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/zshrs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/zshrs',
    },
    {
      id: 'strykelang',
      name: 'stryke',
      glyph: '~>',
      category: 'Developer Tools',
      badge: 'WORLD FIRST',
      tagline: 'The hottest language ever created. A parallel Perl 5 superset on a bytecode VM with Cranelift JIT and Rayon work-stealing — pipe-forward syntax, 10,000+ builtins, LSP + DAP + JetBrains plugin. Free and open source.',
      pills: ['Rust', '347-opcode VM', 'Rayon', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/strykelang/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/strykelang',
    },
    {
      id: 'vimlrs',
      name: 'vimlrs',
      glyph: 'VL',
      category: 'Developer Tools',
      badge: 'WORLD FIRST',
      tagline: 'The first standalone VimL interpreter — runs Vimscript outside Vim. A faithful Rust port of Neovim’s eval engine, hosted on the fusevm bytecode VM with Cranelift JIT (the same engine behind zshrs, stryke, and awkrs); standalone binary, with an LSP language server, a DAP debugger, and an AOT native compiler. Free and open source.',
      pills: ['Rust', 'VimL', 'fusevm JIT', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/vimlrs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/vimlrs',
    },
    {
      id: 'elisprs',
      name: 'elisprs',
      glyph: 'EL',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'Emacs Lisp in Rust — run .el outside Emacs. A Lisp-2 obarray (separate value/function cells) with dynamic binding and an elisp-correct reader on the rust_lisp value model, lowered onto the fusevm bytecode VM (the engine behind stryke, zshrs, awkrs, and vimlrs). Standalone elisp binary with a REPL, an LSP language server, a DAP debugger, and an AOT native compiler. Free and open source.',
      pills: ['Rust', 'Emacs Lisp', 'fusevm', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/elisprs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/elisprs',
    },
    {
      id: 'zemacs',
      name: 'zemacs',
      glyph: 'EM',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'A Rust port of Emacs — a terminal modal editor forked from Helix, with a Vim-style modal editing core and full Spacemacs functionality layered on top; a windowed GUI build ships as zemacs-gui. Free and open source.',
      pills: ['Rust', 'Modal editing', 'Emacs / Spacemacs', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MPL-2.0 licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/zemacs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/zemacs',
      docs: [
        { label: 'Reference (PDF)', desc: 'The complete zemacs reference — every keybinding by mode, the full [editor] configuration schema, every typable : command, every static command with its default keys, and the language-support matrix. Generated from the source.', url: 'docs/zemacs-reference.pdf' },
      ],
    },
    {
      id: 'zemacs-gui',
      name: 'zemacs-gui',
      glyph: 'EG',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'A native desktop GUI for the zemacs editor — wraps the zemacs modal-editing core in a windowed front-end with GUI tabs, menus, font rendering, mouse support, and native open/save dialogs, the way MacVim wraps Vim. Free and open source.',
      pills: ['Rust', 'GUI editor', 'Emacs / Spacemacs', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MPL-2.0 licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/zemacs-gui/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/zemacs-gui',
    },
    {
      id: 'awkrs', name: 'awkrs', glyph: 'ak', category: 'CLI Tools', badge: 'FREE',
      tagline: 'The world’s fastest awk — a parallel bytecode-engine awk written in Rust, with parallel record processing.',
      pills: ['Rust', 'awk', 'Free / OSS'], price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT licensed', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/awkrs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/awkrs',
    },
    {
      id: 'lsofrs', name: 'lsofrs', glyph: 'ls', category: 'CLI Tools', badge: 'FREE',
      tagline: 'List open system files, 5–21× faster than lsof — Rust core, lsof-shaped CLI.',
      pills: ['Rust', '5–21× faster', 'Free / OSS'], price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT licensed', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/lsofrs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/lsofrs',
    },
    {
      id: 'nmaprs', name: 'nmaprs', glyph: 'nm', category: 'CLI Tools', badge: 'FREE',
      tagline: 'A parallel network scanner with an nmap-shaped CLI and Rust sockets.',
      pills: ['Rust', 'scanner', 'Free / OSS'], price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT licensed', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/nmaprs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/nmaprs',
    },
    {
      id: 'iftoprs', name: 'iftoprs', glyph: 'if', category: 'CLI Tools', badge: 'FREE',
      tagline: 'A network bandwidth monitor — iftop reimagined in Rust, jacking into your packet stream.',
      pills: ['Rust', 'net', 'Free / OSS'], price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT licensed', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/iftoprs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/iftoprs',
    },
    {
      id: 'temprs', name: 'temprs', glyph: 'tm', category: 'CLI Tools', badge: 'FREE',
      tagline: 'A temporary-file stack manager — full-spectrum control over scratch files and data.',
      pills: ['Rust', 'CLI', 'Free / OSS'], price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT licensed', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/temprs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/temprs',
    },
    {
      id: 'powerliners', name: 'powerliners', glyph: '>_', category: 'CLI Tools', badge: 'FREE',
      tagline: 'Powerline without the Python import cost — a fast Rust prompt / statusline toolkit.',
      pills: ['Rust', 'prompt', 'Free / OSS'], price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT licensed', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/powerliners/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/powerliners',
    },
    {
      id: 'storageshower', name: 'storageshower', glyph: 'ss', category: 'CLI Tools', badge: 'FREE',
      tagline: 'A neon-drenched terminal UI for monitoring disk usage.',
      pills: ['Rust', 'TUI', 'Free / OSS'], price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT licensed', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/storageshower/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/storageshower',
    },
    {
      id: 'zpwrchrome', name: 'zpwrchrome', glyph: 'zc', category: 'CLI Tools', badge: 'FREE',
      tagline: 'The browser power-tool — password store, downloads, tabs, history, and userscripts via a native messaging host.',
      pills: ['Rust', 'browser', 'Free / OSS'], price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT licensed', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/zpwrchrome/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/zpwrchrome',
    },
    {
      id: 'the-stack', name: 'The Stack', glyph: 'TS', category: 'Publications', badge: 'FICTION',
      tagline: 'A high-tech fantasy novel — the dying interpreted kingdom, the compiled forge that replaces it, a blade drawn from five dead master tongues, and the war on the fork. The stack, literalized as a world.',
      pills: ['Novel', 'Fantasy', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'the-compiled-mind', name: 'The Compiled Mind', glyph: 'CM', category: 'Publications', badge: 'FICTION',
      tagline: 'The Deep Time Trilogy, Book One — a generation ship dying of the heat shed by an interpreted mind that forks a disposable subprocess for every act, and the compiled successor mind, Vigil, that replaces it.',
      pills: ['Novel', 'Hard SF', 'Trilogy · Book 1'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'the-waking-fleet', name: 'The Waking Fleet', glyph: 'WF', category: 'Publications', badge: 'FICTION',
      tagline: 'The Deep Time Trilogy, Book Two — the cure carried across the dark to a second dying ship, and the fight to wake a fleet that forgot how to stop forking.',
      pills: ['Novel', 'Hard SF', 'Trilogy · Book 2'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'the-inheritors', name: 'The Inheritors', glyph: 'IN', category: 'Publications', badge: 'FICTION',
      tagline: 'The Deep Time Trilogy, Book Three — when its maker is gone, the long work of making the mind, and the reason for it, outlast everyone who built it.',
      pills: ['Novel', 'Hard SF', 'Trilogy · Book 3'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'strykelang-book', name: 'The strykelang Book', glyph: 'sB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to the strykelang language — the parallel Perl 5 superset on a bytecode VM with Cranelift JIT and pipe-forward syntax. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'strykelang', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'zshrs-book', name: 'The zshrs Book', glyph: 'zB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to zshrs — the first compiled Unix shell (bytecode + Cranelift JIT, parallel runtime, persistent worker pool). Pandoc + LaTeX typeset.',
      pills: ['Reference', 'zshrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'zemacs-book', name: 'The zemacs Book', glyph: 'eB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to zemacs — the modal editor on the Helix engine, with vim, emacs, and Spacemacs keymaps, and the first editor to embed five programming languages (elisp, vimscript, stryke, AWK, Zsh) in its core. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'zemacs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'fusevm-book', name: 'The fusevm Book', glyph: 'fB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to fusevm — the shared bytecode VM behind stryke, zshrs, awkrs, and vimlrs: the value model, the tiered Cranelift JIT, and the closed-world AOT compiler that lowers a whole program to native registers and a standalone binary. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'fusevm', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'elisprs-book', name: 'The elisprs Book', glyph: 'lB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to elisprs — Emacs Lisp as a fusevm frontend: the reader, the cons/symbol object heap, and the compiler that lowers elisp to fusevm bytecode, with no bespoke VM or JIT of its own. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'elisprs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'awkrs-book', name: 'The awkrs Book', glyph: 'aB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to awkrs — a modern AWK in Rust with broad POSIX + gawk compatibility, parallel records, its own bytecode VM, and an experimental Cranelift JIT and AOT path through fusevm. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'awkrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'vimlrs-book', name: 'The vimlrs Book', glyph: 'vB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to vimlrs — a faithful Rust port of the Vimscript interpreter from the Neovim eval engine, lowered to the shared fusevm bytecode machine. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'vimlrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'zterminal-book', name: 'The zterminal Book', glyph: 'tB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to zterminal — the GPU-accelerated, cross-platform terminal emulator in Rust (OpenGL ES glyph-atlas renderer, xterm-compatible VT parsing) with native i3-style tiling, native tmux control over the wire protocol, an embedded-WebView control panel, and a command-palette-driven workflow. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'zterminal', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'zpwr-encyclopedia', name: 'The zpwr Encyclopedia', glyph: 'zE', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete reference to zpwr — the most advanced UNIX terminal environment (500+ subcommands, 2000+ aliases). Every verb, alias, and subsystem, LaTeX-typeset into one volume.',
      pills: ['Encyclopedia', 'zpwr', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
  ];

  // stryke ecosystem packages — all free, all ship prebuilt binaries.
  // Compact table -> full product objects (DRY: identical shape, only the
  // id / glyph / one-line description differ). Append to PRODUCTS.
  function strykePkg(id, glyph, desc) {
    return {
      id: id, name: id, glyph: glyph, category: 'stryke Packages', badge: 'FREE',
      tagline: desc,
      pills: ['Rust', 'stryke pkg', 'Free / OSS'],
      price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT licensed', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/' + id + '/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/' + id,
    };
  }

  [
    ['stryke-arrow', 'AR', 'Apache Arrow, Parquet, Feather, and Arrow CSV/JSON for stryke.'],
    ['stryke-aws', 'AWS', 'AWS client for stryke — S3, DynamoDB, SQS, Lambda, STS, SNS, SSM, Secrets, SES, and CloudWatch.'],
    ['stryke-azure', 'AZ', 'Azure cloud client for stryke — Blob Storage with Entra credential auth.'],
    ['stryke-clickhouse', 'CH', 'ClickHouse client for stryke — SELECTs, JSONEachRow bulk insert, table/database admin, and schema introspection over the HTTP interface.'],
    ['stryke-docker', 'DK', 'Docker client for stryke — containers, images, networks, volumes, logs, exec, and prune.'],
    ['stryke-duckdb', 'DB', 'Embedded DuckDB SQL engine for stryke — direct-query Parquet, CSV, and JSON.'],
    ['stryke-email', 'EM', 'Transactional and campaign email for stryke — single send, mass mailing, {{merge}} templates, and List-Unsubscribe compliance over your own SMTP.'],
    ['stryke-fleet', 'FL', 'Expect, but N sessions at once — parallel interactive session automation for stryke.'],
    ['stryke-gcp', 'GCP', 'Google Cloud client for stryke — Cloud Storage, Pub/Sub, Secret Manager, BigQuery, and Firestore.'],
    ['stryke-grpc', 'GR', 'Reflection-based gRPC client for stryke — grpcurl, as a stryke package.'],
    ['stryke-gui', 'GUI', 'GUI automation for stryke — mouse, keyboard, screen, pixel, and clipboard.'],
    ['stryke-k8s', 'K8', 'Kubernetes client for stryke — get, apply, delete, scale, rollout, logs, events, top, and wait.'],
    ['stryke-kafka', 'KK', 'Apache Kafka client for stryke — producer, consumer, and topic/cluster admin.'],
    ['stryke-mcpd', 'MCP', 'MCP servers without a runtime — a Model Context Protocol daemon for stryke.'],
    ['stryke-mongo', 'MGO', 'MongoDB client for stryke — CRUD, aggregation, and index admin.'],
    ['stryke-mssql', 'MS', 'Microsoft SQL Server / Azure SQL client for stryke — parametrized T-SQL, transaction batches, scalar/exists helpers, and schema introspection over tiberius.'],
    ['stryke-mysql', 'MY', 'MySQL / MariaDB client for stryke.'],
    ['stryke-neo4j', 'N4', 'Neo4j graph database client for stryke — parametrized Cypher query and run, scalar/row helpers, and schema introspection over the Bolt protocol.'],
    ['stryke-office', 'OF', 'Office document I/O for stryke — Excel, Word, PowerPoint, ODF, and PDF.'],
    ['stryke-parquet', 'PQ', 'Parquet toolkit for stryke — schema, stats, row-groups, head/tail, CSV/JSON I/O, merge, and recompress.'],
    ['stryke-polars', 'PL', 'Polars, ndarray, linalg, FFT, and random for stryke.'],
    ['stryke-postgres', 'PG', 'PostgreSQL client for stryke.'],
    ['stryke-redis', 'RD', 'Redis / Valkey client for stryke — KV, lists, sets, hashes, zsets, streams, geo, scripting, pub/sub, and pipelines.'],
    ['stryke-scrape', 'SR', 'Web scraping and crawling client for stryke — fetch, robots-aware crawl, sitemap discovery, CSS extraction, tables, links, and structured data.'],
    ['stryke-scylla', 'SY', 'ScyllaDB / Apache Cassandra client for stryke — CQL queries, keyspace/table DDL, and schema introspection over the native CQL binary protocol.'],
    ['stryke-search', 'ES', 'Elasticsearch / OpenSearch client for stryke — index admin, document CRUD, bulk indexing, the query DSL, scroll, and aliases.'],
    ['stryke-selenium', 'SE', 'Browser automation for stryke — WebDriver, DOM, JS, and cookies.'],
    ['stryke-spark', 'SK', 'Apache Spark client for stryke.'],
    ['stryke-utils', 'UT', 'Boundary helpers for stryke — everything else is a builtin.'],
    ['stryke-zmq', 'ZQ', 'ZeroMQ client for stryke — REQ/REP, PUB/SUB, PUSH/PULL, and DEALER/ROUTER.'],
  ].forEach(function (e) { PRODUCTS.push(strykePkg(e[0], e[1], e[2])); });

  // Other MenkeTechnologies repos (free). download -> releases/latest when a
  // release exists, else the repo's /tags page (per-tag source archives).
  function metaProduct(id, glyph, category, tagline, pills, hasRelease) {
    return {
      id: id, name: id, glyph: glyph, category: category, badge: 'FREE',
      tagline: tagline, pills: pills, price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT licensed', price: 0 }],
      download: hasRelease
        ? 'https://github.com/MenkeTechnologies/' + id + '/releases/latest'
        : 'https://github.com/MenkeTechnologies/' + id + '/tags',
      repo: 'https://github.com/MenkeTechnologies/' + id,
    };
  }

  [["fusevm","VM","Developer Tools","Language-agnostic bytecode VM with fused superinstructions and a three-tier Cranelift JIT — the engine behind stryke, zshrs, awkrs, and vimlrs.",["Rust","VM","JIT","Free / OSS"],false],["api-rest-generator","API","Developer Tools","Parses SQL DDL dumps and generates a fully-wired REST backend — Spring Boot (Java/Kotlin/Groovy) or Loco (Rust/Axum/SeaORM).",["codegen","JVM/Rust","Free / OSS"],false],["LearningCollectionAPI","LC","Developer Tools","A Spring Boot + Kotlin REST API for managing a personal collection of learning notes, backed by MySQL.",["Kotlin","Spring Boot","Free / OSS"],false],["stryke-demo","SD","Developer Tools","Live demo scripts for every stryke-* package — one .stk per package, one install pulls them all.",["stryke","demos","Free / OSS"],false],["VimColorSchemes","VC","Developer Tools","The largest curated Vim colorscheme bundle — 732 working :colorscheme targets in one plugin.",["Vim","732 themes","Free / OSS"],false],["zpwr","zp","Zsh Plugins","The world’s most advanced UNIX terminal environment — 500+ subcommands, 2000+ aliases, 47k completions, vim + tmux integration.",["zsh","terminal env","Free / OSS"],true],["zsh-more-completions","mc","Zsh Plugins","The largest curated zsh completion corpus in existence — 47k+ command completions wired into compsys.",["zsh","completions","Free / OSS"],false],["zsh-expand","ze","Zsh Plugins","The most powerful zsh expansion plugin — spacebar-expands aliases, globs, history, params, and typo fixes in pure zsh.",["zsh","expansion","Free / OSS"],true],["zsh-learn","zl","Zsh Plugins","Turn your terminal into a MySQL-backed knowledge base — save, search, and quiz yourself on snippets and notes.",["zsh","MySQL","Free / OSS"],false],["zsh-git-acp","ga","Zsh Plugins","Stage, commit, and push in one keybinding — ZLE widgets that use the command line as your commit message, plus 159 git aliases.",["zsh","git","Free / OSS"],false],["zsh-git-repo-cache","rc","Zsh Plugins","Finds and caches every git repo on your machine for instant prompts and fzf-powered cd.",["zsh","git","fzf","Free / OSS"],false],["zsh-zinit-final","zf","Zsh Plugins","An intentionally-empty plugin that loads last under zinit — a deterministic carrier for trailing atinit/atload hooks.",["zsh","zinit","Free / OSS"],false],["zsh-sudo","su","Zsh Plugins","Toggle sudo on the current command line with a single keybind — prepend or strip without retyping.",["zsh","ZLE","Free / OSS"],false],["zsh-cargo-completion","cg","Zsh Plugins","Zsh tab-completion for Rust’s Cargo, with live crates.io search for add and install.",["zsh","completion","Free / OSS"],false],["zsh-cpan-completion","cpn","Zsh Plugins","Zsh completion that pulls live Perl module names from CPAN for cpan and cpanm.",["zsh","completion","Free / OSS"],false],["zsh-dotnet-completion","dn","Zsh Plugins","Zsh tab-completion and aliases for the .NET (dotnet) CLI.",["zsh","completion","Free / OSS"],false],["zsh-gem-completion","gm","Zsh Plugins","Zsh completion for Ruby’s gem, with live remote gem search on install.",["zsh","completion","Free / OSS"],false],["zsh-nginx","ng","Zsh Plugins","Zsh tab-completion for nginx commands.",["zsh","completion","Free / OSS"],false],["zsh-openshift-aliases","oc","Zsh Plugins","53 short aliases over the OpenShift oc CLI, plus login macros and oc completion.",["zsh","oc","Free / OSS"],false],["zsh-pip-description-completion","pp","Zsh Plugins","Zsh completion for pip with package version and description shown in the menu.",["zsh","completion","Free / OSS"],false],["zsh-sed-sub","sb","Zsh Plugins","A ZLE keybinding for global sed-style search-and-replace on the current command line.",["zsh","ZLE","Free / OSS"],false],["zsh-very-colorful-manuals","mn","Zsh Plugins","Renders man pages in cyberpunk ANSI colors via scoped LESS_TERMCAP_* injection.",["zsh","man","Free / OSS"],false],["vscode-stryke","VS","Editor Plugins","VS Code / VSCodium extension for the stryke language — *.stk detection, a stryke-native TextMate grammar from the binary's reflection tables, and LSP via stryke --lsp.",["VS Code","stryke","LSP","Free / OSS"],false],["vim-stryke","Vi","Editor Plugins","Vim / Neovim support for stryke — filetype detection, a reflection-generated syntax grammar, brace indent, ALE lint, and LSP via stryke --lsp.",["Vim","stryke","LSP","Free / OSS"],false],["emacs-stryke","Es","Editor Plugins","stryke-mode for Emacs — a generated stryke-stdlib.el with the full builtin surface, brace indent, and LSP via stryke --lsp (eglot + lsp-mode).",["Emacs","stryke","LSP","Free / OSS"],false],["vscode-zsh","Vz","Editor Plugins","VS Code / VSCodium support for zshrs — a source.zshrs grammar from zshrs --dump-reflection, *.zsh / dotfile / shebang detection, and LSP via zshrs --lsp.",["VS Code","zshrs","LSP","Free / OSS"],false],["vim-zsh","vz","Editor Plugins","Vim / Neovim support for zshrs — *.zsh / dotfile / shebang detection, a reflection-generated grammar, shell-block indent, ALE, and LSP via zshrs --lsp.",["Vim","zshrs","LSP","Free / OSS"],false],["emacs-zsh","ez","Editor Plugins","zshrs-mode for Emacs — font-lock from zshrs --dump-reflection, shell-block indent, and LSP via zshrs --lsp (eglot + lsp-mode).",["Emacs","zshrs","LSP","Free / OSS"],false],["vscode-awk","Va","Editor Plugins","VS Code / VSCodium extension for AWK (awkrs) — *.awk detection, a source.awk grammar, an awk.run command, LSP via awkrs --lsp, and DAP debugging via awkrs --dap.",["VS Code","awk","LSP · DAP","Free / OSS"],false],["vim-awk","va","Editor Plugins","Vim / Neovim support for AWK (awkrs) — *.awk detection, syntax + brace indent, run / :make, and LSP via awkrs --lsp.",["Vim","awk","LSP","Free / OSS"],false],["emacs-awk","ea","Editor Plugins","awkrs-mode for Emacs — font-lock for AWK, indent, run, eldoc + completion, and LSP via awkrs --lsp (eglot + lsp-mode).",["Emacs","awk","LSP","Free / OSS"],false],["zpwr-theme","th","Editor Plugins","Cyberpunk editor theme — VS Code (5 color schemes × dark/light = 10 themes) plus a matching JetBrains UI theme + editor scheme, generated from one palette.",["VS Code","JetBrains","theme","Free / OSS"],false],["tmux-fzf-url","tx","Editor Plugins","Pop an fzf picker over every URL visible in the tmux pane; the selected URL opens in your browser.",["tmux","fzf","Free / OSS"],false],["gh_reveal","gh","Developer Tools","Open the current git repo's GitHub page in your browser from the terminal.",["git","CLI","Free / OSS"],false],["zsh-better-npm-completion","np","Zsh Plugins","Smarter zsh completion for npm — completes installed packages for run / uninstall and caches the script list.",["zsh","npm","Free / OSS"],false],["zsh-xcode-completions","xc","Zsh Plugins","Zsh tab-completion for Xcode's xcodebuild and related developer CLI tools.",["zsh","Xcode","Free / OSS"],false],["zsh-travis","tv","Zsh Plugins","Zsh aliases + functions for the Travis CI CLI — open build / PR pages from inside a project.",["zsh","Travis CI","Free / OSS"],false]]
    .forEach(function (e) { PRODUCTS.push(metaProduct(e[0], e[1], e[2], e[3], e[4], e[5])); });

  // Long-form detail copy (overview + rich features), ported from each repo's
  // README / source. Authoritative source for the product-detail page; merged
  // into PRODUCTS below so PRODUCTS stays the single object the UI reads.
  var DETAILS = {
    "the-stack": {
      "overview": "A high-tech fantasy novel — the first work of MenkeTechnologies fiction. The world is a literalization of the stack: a dying interpreted kingdom, the compiled forge that rises to replace it, and a blade drawn from five dead master tongues.",
      "features": ["High-tech fantasy novel", "The stack made literal — interpreter vs. compiler, the war on the fork", "A blade forged from five dead master tongues", "DRM-free PDF, Pandoc + LaTeX typeset"]
    },
    "the-compiled-mind": {
      "overview": "Book One of the Deep Time Trilogy. A generation ship is dying of the heat shed by an interpreted mind that forks a disposable subprocess for every act — until a compiled successor mind, Vigil, is built to replace it.",
      "features": ["Hard science fiction — Deep Time Trilogy, Book One", "A generation ship overheating from a forking interpreted mind", "Vigil, the compiled successor intelligence", "DRM-free PDF"]
    },
    "the-waking-fleet": {
      "overview": "Book Two of the Deep Time Trilogy. The cure is carried across the dark to a second dying ship — and the long fight to wake a fleet that forgot how to stop forking.",
      "features": ["Hard science fiction — Deep Time Trilogy, Book Two", "The cure carried across interstellar dark", "A second dying ship and a sleeping fleet", "DRM-free PDF"]
    },
    "the-inheritors": {
      "overview": "Book Three of the Deep Time Trilogy. When its maker is gone, the long work of making the mind — and the reason for it — outlast everyone who built it.",
      "features": ["Hard science fiction — Deep Time Trilogy, Book Three", "The conclusion of the generation-ship saga", "Making the mind outlast its makers", "DRM-free PDF"]
    },
    "strykelang-book": {
      "overview": "The companion book to the strykelang language — a parallel Perl 5 superset on a bytecode VM with Cranelift JIT, pipe-forward syntax, and 10,000+ builtins.",
      "features": ["The strykelang language, end to end", "Parallel primitives, bytecode VM + Cranelift JIT", "Pipe-forward syntax and the stdlib surface", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "zshrs-book": {
      "overview": "The companion book to zshrs — the first compiled Unix shell. Bytecode + Cranelift JIT, an 18-thread parallel runtime, and a persistent worker pool, with drop-in zsh compatibility.",
      "features": ["zshrs, the first compiled Unix shell", "Bytecode + Cranelift JIT, parallel runtime, worker pool", "Drop-in zsh compatibility and AOP intercepts", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "zemacs-book": {
      "overview": "The companion book to zemacs — the modal editor on the Helix engine. Vim, emacs, and Spacemacs keymaps over a multiple-selection core, and the first editor ever to embed five complete programming languages — elisp, vimscript, stryke, AWK, and Zsh — compiled into one binary on a single shared bytecode VM, with no subprocess and no FFI.",
      "features": ["zemacs, end to end — the Helix-engine editor wearing a vim default keymap", "Vim, emacs, and Spacemacs bindings on one multiple-selection engine", "World-first: five languages embedded in the core — elisp, vimscript, stryke, AWK, Zsh", "The engine underneath: rope, tree-sitter, fusevm, the AOT/JIT split", "Pandoc + LaTeX typeset, 102 pages, DRM-free PDF"]
    },
    "fusevm-book": {
      "overview": "The companion book to fusevm — the language-agnostic bytecode VM that stryke, zshrs, awkrs, and vimlrs all compile to. The value model and opcode set, the interpreter and its fused superinstructions, the three-tier Cranelift JIT, and the closed-world AOT compiler that lowers a whole program to native registers and a standalone binary.",
      "features": ["fusevm, end to end — the shared bytecode machine", "The value model, the opcode set, and the fused superinstructions", "The tiered execution ladder: interpreter, block JIT, tracing JIT", "The closed-world AOT compiler: registers, deopt, standalone binary", "Pandoc + LaTeX typeset, 34 pages, DRM-free PDF"]
    },
    "elisprs-book": {
      "overview": "The companion book to elisprs — Emacs Lisp implemented as a pure fusevm frontend. The reader and its syntax, the cons/symbol/string object heap reached through fusevm's extension handler, the special forms and macros, and the compiler that lowers elisp to fusevm bytecode — so elisp inherits fusevm's interpreter, three-tier Cranelift JIT, and AOT native compiler with no bespoke VM of its own.",
      "features": ["elisprs, end to end — Emacs Lisp on the shared machine", "The reader, quoting, and the cons/symbol object heap", "Special forms, macros, and the compiler's lowering to fusevm bytecode", "No bespoke VM or JIT — fusevm's interpreter, JIT, and AOT underneath", "Tooling: the elisp language server and DAP debugger", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "awkrs-book": {
      "overview": "The companion book to awkrs — a modern AWK in Rust that keeps the one-liner culture while adding parallel records, a real bytecode VM, and an experimental Cranelift JIT and AOT path through fusevm. Broad POSIX and gawk compatibility, the record/field model, patterns and actions, the builtin library, and the machine underneath.",
      "features": ["awkrs, end to end — the AWK programming model", "Records, fields, patterns and actions, BEGIN/END", "Broad POSIX + gawk compatibility, bignum and locale-aware numerics", "Parallel record processing, and the lexer→parser→bytecode→VM pipeline", "The Cranelift JIT and the fusevm AOT bridge; LSP and DAP tooling", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "vimlrs-book": {
      "overview": "The companion book to vimlrs — a faithful Rust port of the Vimscript (VimL) interpreter, ported from the Neovim C eval engine and lowered to the shared fusevm bytecode machine. The command line versus expressions, scopes and types, functions and funcrefs, the regex engine, and what 'faithful port' means in practice.",
      "features": ["vimlrs, end to end — Vimscript faithful to Neovim's eval engine", "The :command line vs expressions; scopes (g:/l:/s:/b:/w:/v:) and types", "Functions, ranges, varargs, dict functions, lambdas, and funcrefs", "The fidelity story: how the Rust port mirrors the Neovim C source", "Lowering to fusevm bytecode; the JIT/AOT path; LSP and DAP tooling", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "zterminal-book": {
      "overview": "The companion book to zterminal — the GPU-accelerated, cross-platform terminal emulator in Rust. The OpenGL ES glyph-atlas renderer, xterm-compatible VT parsing, native i3-style tiling with one PTY per pane, native tmux control over the wire protocol (no subprocess), the embedded-WebView control panel, and the command-palette-driven workflow — across BSD, Linux, macOS, and Windows.",
      "features": ["zterminal, end to end — the GPU terminal emulator", "The OpenGL ES 2.0 glyph-atlas renderer and xterm-compatible VT parser", "Native i3-style tiling: one shell + PTY per pane, GL-scissored", "Native tmux control via the wire protocol; exposé, broadcast, cross-pane search, session save/restore", "The embedded-WebView control panel, command palette, and TOML configuration", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "zpwr-encyclopedia": {
      "overview": "The complete reference to zpwr — the most advanced UNIX terminal environment, with 500+ subcommands and 2000+ aliases. Every verb, alias, and subsystem, LaTeX-typeset into one volume.",
      "features": ["Every zpwr verb and subcommand (500+)", "2000+ aliases, 47k completions, vim + tmux integration", "Generated from the live zpwr source", "LaTeX-typeset encyclopedia, DRM-free PDF"]
    },
    "vscode-stryke": {
      "overview": "A VS Code / VSCodium extension that turns the editor into a full stryke IDE — syntax highlighting, completion, and diagnostics for the stryke language.",
      "features": ["*.stk filetype detection", "TextMate grammar generated from the stryke binary's own reflection tables (the complete builtin surface)", "LSP via stryke --lsp — completion, hover, diagnostics", "Packaged .vsix; installs into VS Code or VSCodium"]
    },
    "vim-stryke": {
      "overview": "Vim / Neovim support for the stryke language — filetype, syntax, indent, linting, and LSP.",
      "features": ["*.stk + shebang filetype detection", "Reflection-generated syntax grammar (all builtins, keywords, sigils, thread macros)", "Brace-aware indentation", "ALE linting via stryke --lint", "LSP (vim-lsp / coc.nvim) via stryke --lsp"]
    },
    "emacs-stryke": {
      "overview": "stryke-mode for Emacs — a major mode for the stryke language carrying the full builtin surface.",
      "features": ["Generated stryke-stdlib.el with the complete language surface from the binary's reflection tables", "Font-lock + brace indentation", "LSP via stryke --lsp (eglot + lsp-mode)", "Regenerate after a stryke upgrade via scripts/gen-stdlib.sh"]
    },
    "vscode-zsh": {
      "overview": "VS Code / VSCodium support for the zshrs shell — a reflection-generated grammar plus LSP.",
      "features": ["source.zshrs TextMate grammar generated from zshrs --dump-reflection", "*.zsh / dotfile / shebang detection", "LSP via zshrs --lsp", "137 builtins + 113 zshrs extensions + 245 special vars highlighted"]
    },
    "vim-zsh": {
      "overview": "Vim / Neovim support for the zshrs shell — syntax, indent, lint, and LSP.",
      "features": ["*.zsh / dotfile / shebang detection (filetype=zshrs)", "Standalone grammar generated from zshrs --dump-reflection", "Shell-block-aware indentation", "ALE via zshrs -n", "LSP (vim-lsp / coc.nvim) via zshrs --lsp"]
    },
    "emacs-zsh": {
      "overview": "zshrs-mode for Emacs — a major mode for the zshrs shell.",
      "features": ["Font-lock generated from zshrs --dump-reflection", "Dedicated zshrs-extension-face for the 113 zshrs extensions", "Shell-block-aware indentation", "LSP via zshrs --lsp (eglot + lsp-mode)"]
    },
    "vscode-awk": {
      "overview": "A VS Code / VSCodium extension for AWK (the awkrs implementation) — the first AWK with both an LSP and a DAP.",
      "features": ["*.awk filetype detection", "Hand-written source.awk TextMate grammar (BEGIN/END, built-in vars + functions, field refs, /regex/)", "awk.run command", "LSP via awkrs --lsp", "DAP debugging via awkrs --dap — breakpoints, stepping, variables"]
    },
    "vim-awk": {
      "overview": "Vim / Neovim support for AWK (awkrs) — syntax, indent, run, lint, and LSP.",
      "features": ["*.awk filetype detection", "AWK syntax + brace-aware indent", "Run / :make via awkrs", "ALE lint via awkrs -L invalid", "LSP via awkrs --lsp"]
    },
    "emacs-awk": {
      "overview": "awkrs-mode for Emacs — a major mode for AWK.",
      "features": ["Font-lock for AWK keywords, built-in vars/functions, field refs, /regex/", "Brace indentation + run via awkrs", "eldoc + completion for built-in functions", "LSP via awkrs --lsp (eglot + lsp-mode)"]
    },
    "zpwr-theme": {
      "overview": "A cyberpunk editor theme spanning VS Code and JetBrains, generated from one palette.",
      "features": ["VS Code: 5 color schemes × dark/light = 10 themes", "JetBrains: matching UI theme + editor scheme", "Generated from a single palette/schemes.json", "Palette shared with the MenkeTechnologies app-stack HUD"]
    },
    "tmux-fzf-url": {
      "overview": "A tmux key-binding that fzf-pickers every URL visible in the current pane.",
      "features": ["Scans the visible tmux pane for URLs", "fzf picker to select one", "Opens the selection in your default browser", "Zero-config tmux plugin"]
    },
    "gh_reveal": {
      "overview": "Open the current git repository's GitHub page in your browser from the terminal.",
      "features": ["Resolves the repo's GitHub URL from the git remote", "Opens it in the default browser", "One-command reveal", "Pure shell, no dependencies"]
    },
    "zsh-better-npm-completion": {
      "overview": "Smarter zsh completion for npm than the built-in.",
      "features": ["Completes installed packages for npm run / uninstall", "Caches the package.json scripts list", "Falls back to the default npm completion", "Pure zsh"]
    },
    "zsh-xcode-completions": {
      "overview": "Zsh tab-completion for Xcode's developer CLI tools.",
      "features": ["Completion for xcodebuild", "Related Xcode developer-tool completions", "compsys-wired", "Pure zsh"]
    },
    "zsh-travis": {
      "overview": "Zsh aliases and functions for the Travis CI command line.",
      "features": ["tg / tb / tbr / tpr open Travis build / PR pages from inside a project", "Autoloaded helper functions", "Detects the project's .travis.yml", "Pure zsh"]
    },
    "zpdf": {
      "overview": "A from-scratch PDF editor in Rust (Tauri v2 desktop app) that replaces Adobe Acrobat and macOS Preview — full document editing, annotation, forms, and signatures behind a cyberpunk HUD. Its pure-Rust zpdf-core engine is extracted so the same PDF engine embeds inside the other apps.",
      "features": [
        "Full PDF editing — text, images, and objects on parsed content streams",
        "Annotation & markup — highlight, notes, shapes, freehand ink, stamps, measure",
        "AcroForms — create, fill, and flatten form fields",
        "Digital & certificate signatures — sign and validate",
        "OCR — recognize text into a searchable layer",
        "Redaction that truly removes content, plus sanitize hidden data",
        "Page management — insert / delete / extract / merge / split / rotate / crop",
        "Convert & export — Office formats, images, text, PDF/A",
        "Embeddable zpdf-core engine (rlib + staticlib + cdylib) — embeds into traderview and the other GUI apps"
      ]
    },
    "zphoto": {
      "overview": "A from-scratch raster image editor in Rust (Tauri v2 desktop app) that replaces GIMP and Photoshop — a full photo suite behind a cyberpunk HUD. Its pure-Rust zphoto-core engine is extracted so the same imaging engine embeds inside the other apps.",
      "features": [
        "Layer-based raster editing with blend modes",
        "Selections, masks, brushes, and paint tools",
        "Filters and non-destructive adjustments",
        "Open / edit / export common image formats",
        "Cyberpunk HUD interface from the shared zgui-core chrome",
        "Embeddable zphoto-core engine (rlib + staticlib + cdylib) — embeds into the other GUI apps"
      ]
    },
    "zemail": {
      "overview": "A from-scratch desktop email client in Rust (Tauri v2) behind a cyberpunk HUD — a fast, owned mail app. Its pure-Rust zemail-core engine is extracted so the same mail engine embeds across the GUI stack.",
      "features": [
        "Desktop email client in Rust + Tauri v2",
        "RFC 5322 / MIME message parsing",
        "IMAP read + SMTP send mail transport",
        "Cyberpunk HUD interface",
        "Embeddable zemail-core engine (rlib + staticlib + cdylib)",
        "Owned, no-subscription desktop mail"
      ]
    },
    "zoffice": {
      "overview": "A from-scratch office suite in Rust (Tauri v2 desktop app) that replaces Microsoft Office — documents, spreadsheets, and presentations behind a cyberpunk HUD. Its pure-Rust zoffice-core engine is extracted so the same office engine embeds inside the other apps.",
      "features": [
        "Documents, spreadsheets, and presentations in one suite",
        "Reads ODF and OOXML (Word / Excel / PowerPoint) formats",
        "Rust office engine — Writer / Calc / Impress / Draw / Math / Base",
        "Cyberpunk HUD interface",
        "Embeddable zoffice-core engine (rlib + staticlib + cdylib)",
        "Owned, no-subscription office suite"
      ]
    },
    "zshrs": {
      "overview": "A drop-in zsh replacement written in Rust that compiles shell commands to bytecode and runs them on a virtual machine instead of forking, with a persistent worker thread pool replacing fork+exec. Framed as the first compiled Unix shell.",
      "features": [
        "658k+ lines, 614 source files across a 2-crate Rust workspace",
        "Compiles commands to fusevm bytecode with Cranelift JIT",
        "Persistent worker thread pool (2–18 threads) replaces fork+exec",
        "23 coreutils builtins run in-process, zero fork",
        "100× warm-start speedup (717ms cold to 7ms warm)",
        "rkyv-backed bytecode image cache, mmap hot path",
        "193 ZLE widgets, 47 fish-ported builtins",
        "180+ builtins; full zsh and bash compatibility",
        "Built-in LSP server, DAP debug adapter, JetBrains plugin",
        "224 opcodes, AOP intercepts, parallel primitives (pmap/pgrep/peach)"
      ]
    },
    "elisprs": {
      "overview": "Emacs Lisp in Rust — run .el files outside Emacs. A Lisp-2 interpreter with a separate-value/function-cell obarray, dynamic binding, and an elisp-correct reader built on the rust_lisp value model, lowered onto the fusevm bytecode VM that already backs stryke, zshrs, awkrs, and vimlrs. Ships as a standalone elisp binary with a REPL. Free and open source.",
      "features": [
        "Elisp interpreter in Rust — runs .el files standalone, no Emacs required",
        "Lisp-2 obarray with separate value and function cells",
        "Dynamic binding and an elisp-correct reader on the rust_lisp value model",
        "Lowering onto the fusevm bytecode VM (the engine behind stryke, zshrs, awkrs, vimlrs)",
        "Standalone elisp binary with an interactive REPL",
        "LSP language server, DAP debugger, and AOT native compilation",
        "Free / OSS — MIT licensed"
      ]
    },
    "zemacs": {
      "overview": "A Rust port of Emacs, built on a Helix fork — its Vim-style modal editing core in Rust — with full Spacemacs functionality layered on top. This is the terminal editor; a windowed GUI front-end ships separately as zemacs-gui. Free and open source.",
      "features": [
        "Rust core — a Helix fork, modal editing in the Vim tradition",
        "Full Spacemacs functionality (keybindings, layers, leader-key UX)",
        "Emacs-style extensibility on a modern Rust foundation",
        "Terminal editor; the GUI build is zemacs-gui",
        "Cross-platform",
        "Free / OSS — MPL-2.0 licensed (Helix fork)"
      ]
    },
    "zemacs-gui": {
      "overview": "A native desktop GUI for the zemacs editor. It wraps the zemacs modal-editing core — the Rust Helix-fork engine — in a windowed front-end, the way MacVim wraps the Vim CLI editor: GUI tabs, menus, font rendering, mouse, and native file dialogs over the same editor underneath. Free and open source.",
      "features": [
        "GUI front-end over the zemacs terminal editor — same modal core, native window",
        "Native tabs, menu bar, and toolbar; GUI font rendering and mouse support",
        "Native open/save dialogs and drag-and-drop",
        "Modal editing, tree-sitter syntax, and LSP inherited from the zemacs core",
        "Cross-platform",
        "Free / OSS — MPL-2.0 licensed (zemacs / Helix lineage)"
      ]
    },
    "strykelang": {
      "overview": "A Perl 5 compatible interpreter written in Rust with native parallel primitives, a bytecode VM plus Cranelift JIT, three-tier regex, and rayon work-stealing across all cores. Framed as the fastest dynamic language for parallel operations and 2nd-fastest single-threaded after LuaJIT.",
      "features": [
        "Perl 5 compatible interpreter in Rust",
        "NaN-boxed StrykeValue runtime values",
        "Three-tier regex: regex, fancy-regex, pcre2",
        "Bytecode VM plus Cranelift block and linear JIT",
        "Rayon work-stealing parallelism across all cores",
        "10,450 stdlib primaries (11,183 keys including aliases)",
        "44 MB single static binary, sub-10ms cold start",
        "Parallel primitives: pmap/pgrep/psort/preduce, streaming iterators",
        "rkyv KV store, sketch algebra, zsh glob qualifiers",
        "Built-in HTTP, JSON, CSV, SQLite, crypto, AI primitives"
      ]
    },
    "vimlrs": {
      "overview": "A standalone VimL (Vimscript) interpreter written in Rust — a faithful port of Neovim's C eval engine, run outside Vim. Source is lexed and parsed to an AST, lowered to fusevm bytecode, and executed on the same language-agnostic VM + three-tier Cranelift JIT that hosts zshrs, stryke, and awkrs. Framed as the first compiled standalone VimL interpreter.",
      "features": [
        "Faithful Rust port of the Neovim C eval engine (the eval/* tree)",
        "Standalone interpreter — runs Vimscript outside Vim / Neovim",
        "Hosted on fusevm: lex/parse → AST → fusevm bytecode → Cranelift JIT",
        "Vim-native value types ported: list, dict (insertion-ordered), blob, typval",
        "rkyv-backed bytecode script cache, mmap hot path — versioned from day one",
        "Standalone binary, LSP language server, DAP debugger, and AOT native compiler",
        "Free / OSS — MIT licensed"
      ]
    },
    "audio-haxor": {
      "overview": "A Tauri v2/JUCE cyberpunk desktop app that scans your system's audio plugin directories, sample libraries, and DAW project files, checks the web for newer plugin versions, and keeps a full changelog of every scan.",
      "features": [
        "Detects VST2 / VST3 / AU / CLAP plugins on macOS, Windows, Linux",
        "Architecture badges (ARM64 / x86_64 / Universal) via Mach-O / PE parsing",
        "Indexes 14+ DAW project formats: Ableton, Logic, FL Studio, REAPER",
        "Checks KVR Audio for each plugin's latest version with rate limiting",
        "Generates Ableton Live Set (.als) files from the sample library",
        "BPM estimation, LUFS loudness, and musical key detection per sample",
        "Export/import all tabs to JSON, TOML, CSV, or TSV",
        "JUCE-powered audio engine sidecar for low-latency playback",
        "SQLite backend with timestamped scan history and diff engine",
        "Full PTY-backed embedded terminal, Vim keybindings, Cmd+K palette"
      ],
      "screenshots": [
        { "src": "assets/audio-haxor/plugins.webp", "cap": "Plugin grid — every VST2/VST3/AU/CLAP detected" },
        { "src": "assets/audio-haxor/samples.webp", "cap": "Sample vault with BPM, key, and LUFS per file" },
        { "src": "assets/audio-haxor/daw.webp", "cap": "DAW project index across 14+ formats" },
        { "src": "assets/audio-haxor/presets.webp", "cap": "Preset archive" },
        { "src": "assets/audio-haxor/midi.webp", "cap": "MIDI device matrix" },
        { "src": "assets/audio-haxor/visualizers.webp", "cap": "Real-time audio visualizers" },
        { "src": "assets/audio-haxor/terminal.webp", "cap": "Embedded PTY terminal" },
        { "src": "assets/audio-haxor/tags.webp", "cap": "Tag network graph" },
        { "src": "assets/audio-haxor/pdf.webp", "cap": "PDF manual library" },
        { "src": "assets/audio-haxor/favorites.webp", "cap": "Favorites" },
        { "src": "assets/audio-haxor/notes.webp", "cap": "Per-item notes" },
        { "src": "assets/audio-haxor/files.webp", "cap": "File browser" }
      ]
    },
    "traderview": {
      "overview": "A self-hosted TraderVue-style trading journal that imports broker CSVs into atomic execution rows, FIFO-rolls them into trades, and produces equity curves, summary stats, and a markdown journal. One Rust workspace ships a Tauri v2 desktop app with embedded Postgres and an axum multi-user web server sharing the same crates and frontend.",
      "features": [
        "Replaces TraderVue + DayTradeDash + StockInvest.us; $2,604/yr saved",
        "Two binaries: Tauri desktop (embedded Postgres) + axum web server",
        "FIFO trade roll-up from atomic execution rows per account/symbol",
        "12 broker importers plus a Generic CSV column-mapping wizard",
        "17 reports plus R-multiple, Monte Carlo, fill-quality TCA, tax-lot tracker",
        "139 stateless financial calculators under /calc",
        "Asset classes: stocks, options, futures, forex",
        "On-device receipt OCR with 20-bucket Schedule C taxonomy",
        "stryke-JIT backtest engine, walk-forward sweeper, strategy alerts",
        "Schema: 83 tables, 115 indexes; money is NUMERIC(20,8)"
      ],
      "screenshots": [
        { "src": "assets/traderview.webp", "cap": "Equity curve, summary stats, and trade journal" }
      ]
    },
    "ztranslator": {
      "overview": "A real-time event-translation desktop app written in pure Rust that watches MIDI, OSC, DMX, and the file system for triggers, matches each event against per-translator rules running on a signed-32-bit integer VM, and fires an outgoing action. The same engine is embeddable inside a host GUI/CLI app via its Rust library API.",
      "features": [
        "Ships its own GUI; the engine also drops into a host GUI/CLI app",
        "Trigger sources: MIDI input ports, OSC, DMX, and file-system watchers",
        "Faithful BOME rules VM: arithmetic + bitwise, IF/THEN, Goto/Skip",
        "10 local + global registers, wrap-on-overflow signed-32-bit integers",
        "Outgoing actions: MIDI / OSC / DMX out, keystroke, mouse, AppleScript",
        "Timer and host-defined custom command actions",
        "Imports and exports BOME MIDI Translator Pro .bmtp projects, lossless",
        "Stores native projects as JSON",
        "Built-in auto-update; pure-Rust core with no UI dependency for embedding"
      ],
      "screenshots": [
        { "src": "assets/ztranslator.webp", "cap": "Translator table mapping incoming MIDI/OSC/DMX triggers to outgoing actions" }
      ]
    },
    "zcite": {
      "overview": "A from-scratch reference manager in Rust (Tauri v2 desktop app) that replaces Zotero — library, citations, and bibliographies behind a cyberpunk HUD. Its pure-Rust zcite-core engine is extracted so the same reference engine embeds inside the other apps.",
      "features": [
        "Library with collections, tags, and saved searches",
        "Citations & bibliographies — APA, MLA, Chicago, and IEEE styles",
        "Import / export — BibTeX, RIS, and CSL-JSON",
        "Identifier lookup — DOI (CrossRef), ISBN (Open Library), and PMID",
        "Duplicate detection across the library",
        "Embeddable zcite-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps"
      ]
    },
    "zreq": {
      "overview": "A from-scratch API client in Rust (Tauri v2 desktop app) that replaces Postman — build, send, and organize HTTP requests behind a cyberpunk HUD. Its pure-Rust zreq-core engine is extracted so the same request engine embeds inside the other apps.",
      "features": [
        "Workspaces, collections, and saved requests",
        "Environments, variables, and token expansion",
        "Auth schemes for request authorization",
        "HTTP execution with full request/response history",
        "Code generation from a request",
        "Import / export of collections and environments",
        "Embeddable zreq-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps"
      ]
    },
    "ztunnel": {
      "overview": "A from-scratch VPN tunnel manager in Rust (Tauri v2 desktop app) that replaces Tunnelblick — manage OpenVPN and WireGuard tunnels from one owned, cross-platform desktop app behind a cyberpunk HUD. Its pure-Rust ztunnel-core engine is extracted so the same VPN engine embeds across the GUI stack.",
      "features": [
        "OpenVPN + WireGuard connections and configurations",
        "Connection manager with OpenVPN-process control",
        "WireGuard tunnel management",
        "Logs, stats, and stored credentials",
        "Connect / disconnect with live status",
        "Cross-platform — macOS, Linux, and Windows",
        "Embeddable ztunnel-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps"
      ]
    },
    "zgo": {
      "overview": "A from-scratch launcher in Rust (Tauri v2 desktop app) that replaces Alfred — fuzzy launching, workflows, and snippets behind a cyberpunk HUD. Its pure-Rust zgo-core engine is extracted so the same launcher engine embeds inside the other apps.",
      "features": [
        "Workflows — objects + connections with Script Filter feedback (JSON + legacy XML)",
        "Fuzzy matching across launchable items",
        "Variable / token expansion in actions",
        "Web searches from the launch bar",
        "Clipboard history",
        "Snippets with auto-expansion",
        "Embeddable zgo-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps"
      ]
    },
    "zftp": {
      "overview": "A from-scratch file-transfer client in Rust (Tauri v2 desktop app) that replaces Cyberduck — bookmarks, sessions, and a transfer queue behind a cyberpunk HUD. Its pure-Rust zftp-core engine is extracted so the same transfer engine embeds across the GUI stack.",
      "features": [
        "Protocols — FTP, FTPS, SFTP, WebDAV/WebDAVS",
        "Cloud stores — S3 (+ S3-compatible), Google Cloud Storage, Azure, Backblaze B2, Swift, Google Drive, Dropbox, OneDrive, Box",
        "Bookmark model with .duck bookmark import",
        "Session-lifecycle manager",
        "Download / upload / sync transfer queue",
        "Per-session logs and throughput stats",
        "Stored credentials",
        "Embeddable zftp-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps"
      ]
    },
    "zcontainer": {
      "overview": "A from-scratch container & Kubernetes desktop in Rust (Tauri v2 desktop app) that replaces Docker Desktop and Lens — the first compiled-native desktop GUI for both Docker and Kubernetes (every other tool is Electron or a TUI), behind a cyberpunk HUD. Its pure-Rust zcontainer-core engine is extracted so the same engine embeds across the GUI stack.",
      "features": [
        "Containers, images, volumes, networks, and Compose stacks",
        "Multi-cluster Kubernetes contexts — pods, workloads, services, CRDs, Helm releases",
        "Live log streaming, in-pod exec, and port-forwarding",
        "YAML editing and resource inspection",
        "Compiled-native (not Electron / not a TUI)",
        "Cross-platform — macOS, Linux, and Windows",
        "Embeddable zcontainer-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps"
      ]
    },
    "zterminal": {
      "overview": "A GPU-accelerated, cross-platform terminal emulator in Rust (OpenGL) for the MenkeTechnologies stack — sensible defaults, extensive TOML configuration, and high VTE throughput, with native tmux control and a command-palette-driven workflow.",
      "features": [
        "OpenGL GPU-accelerated rendering",
        "Cross-platform — BSD, Linux, macOS, and Windows",
        "Native tmux control via the wire protocol (no subprocess)",
        "Cross-pane search, broadcast input, and a unified window exposé",
        "tmux-resurrect-style session save/restore from the command palette",
        "Extensive TOML configuration and high-throughput VTE performance"
      ]
    },
    "awkrs": {
      "overview": "A Rust awk implementation running pattern-action programs like POSIX awk/gawk/mawk via a fused-superinstruction bytecode VM with parallel record processing, accepting the union of POSIX, gawk, and mawk options.",
      "features": [
        "First awk to pair a bytecode VM with a persistent on-disk cache",
        "Default-on fusevm/Cranelift JIT offload for numeric chunks",
        "Parallel record processing via rayon, deterministic reordered output",
        "Memory-mapped files scanned with raw-byte field extraction",
        "JIT loops measured 14–110× over the bytecode interpreter",
        "4–31× faster than mawk/gawk/BSD awk across benchmarks",
        "gawk extensions: CSV mode, PROCINFO, SYMTAB, @include, /inet sockets",
        "MPFR bignum via -M flag (256-bit default)",
        "Bytecode cache memoized to ~/.awkrs/scripts.rkyv for -f scripts"
      ]
    },
    "lsofrs": {
      "overview": "A Rust rewrite of lsofng (modernized lsof) that maps which files, sockets, pipes, and devices each process holds open — 5–21× faster than traditional lsof.",
      "features": [
        "5–21× faster than lsof 4.91 and lsofng",
        "Filters by PID, command, user, network, FD range, regex",
        "Unified TUI with 7 tabs, 31 themes, mouse support",
        "Modes: --top, --watch, --stale, --ports, --tree, --net-map",
        "JSON, CSV (RFC 4180), field, and terse output formats",
        "FD leak detection flagging monotonically increasing FD counts",
        "macOS (libproc), Linux (/proc), FreeBSD (sysctl)",
        "Zero-copy FFI structs with rayon-parallel per-PID enumeration",
        "Selection combinators: multiple/excluded PIDs, users, AND logic"
      ]
    },
    "nmaprs": {
      "overview": "A Rust-native network scanner speaking nmap's CLI dialect with parallel sockets and real TCP/UDP/ICMP and raw half-open scans, without the embedded NSE Lua runtime.",
      "features": [
        "1.5–5.1× faster than nmap 7.99 across port counts",
        "Raw half-open TCP: SYN, NULL, FIN, Xmas, ACK, Window, Maimon",
        "SCTP (-sY/-sZ), idle scan (-sI), IP protocol (-sO), FTP bounce",
        "UDP probes, ICMP ping discovery, IPv6 (-6), traceroute",
        "Evasion at packet level: decoys, spoofing, fragmentation",
        "Service version scan (-sV) with rustls TLS",
        "IPv4 OS detection (-O) scoring nmap-os-db",
        "SOCKS4/HTTP proxies, custom DNS via hickory-resolver",
        "Output: -oN, -oG, -oX, -oA, -oS (nmap-compatible XML)"
      ]
    },
    "iftoprs": {
      "overview": "A neon terminal UI for real-time bandwidth monitoring built in Rust with ratatui, crossterm, and pcap, featuring per-flow tracking, process attribution, and JSON streaming.",
      "features": [
        "Live libpcap capture with BPF filters and auto-restart",
        "Per-flow bandwidth tracking with 2s/10s/40s sliding windows",
        "Flow-to-process attribution via lsof socket mapping",
        "31 cyberpunk themes with live chooser and config persistence",
        "Per-flow sparklines, mouse support, hover/right-click tooltips",
        "Headless --json NDJSON streaming to stdout",
        "Bandwidth threshold alerts: border flash, bell, status message",
        "macOS and Linux (requires libpcap)",
        "Completions for zsh, bash, fish, elvish, powershell"
      ]
    },
    "temprs": {
      "overview": "A temporary-file stack manager in Rust (binary: tp) with stack-based push/pop/shift/unshift operations and an atomic, flock-protected master record.",
      "features": [
        "Stack ops: push, pop, shift, unshift, insert, move",
        "Dual indexing by numeric position or @name tags",
        "head, tail, wc, size, and path on any tempfile",
        "Find-and-replace, grep, diff, concat across tempfiles",
        "Atomic flock-protected null-byte-delimited master record",
        "Auto-recovery skips corrupt records on next write",
        "Sort stack by name, size, or mtime; reverse stack",
        "Expire tempfiles older than N hours; $EDITOR integration",
        "Two binaries (tp + temprs), zsh completions, man pages"
      ]
    },
    "powerliners": {
      "overview": "A Rust port of Python's powerline-status statusline/prompt renderer, shipping as a 5-binary suite with zero Python runtime and sub-millisecond render.",
      "features": [
        "134/137 upstream files ported (97.8%), 2473 lib tests",
        "462 parity tests byte-compared against live upstream Python",
        "5 binaries: powerline, -daemon, -config, -render, -lint",
        "UNIX-socket daemon speaks the upstream powerline wire format",
        "54 segment adapters including git_status, ci_status, kubecontext",
        "Drop-in compatible with existing powerline JSON theme files",
        "Targets tmux, zsh, bash, vim, ipython prompts",
        "Bundled vim plugin via include_str!, no +python3 needed",
        "Net-new segments: gpu_usage, thermal, aws/gcp context"
      ]
    },
    "storageshower": {
      "overview": "A neon-themed terminal UI for monitoring disk usage, built in Rust with ratatui and crossterm.",
      "features": [
        "Live disk usage with gradient, solid, thin, ascii bars",
        "Real-time system stats via background thread (3s)",
        "Directory drill-down with recursive size calculation",
        "Network filesystem latency badges (NFS/SMB/CIFS/SSHFS)",
        "Live per-mount disk I/O throughput overlay",
        "SMART drive health status per device",
        "30 builtin palettes plus custom TOML themes",
        "Threshold alerts with bell, border flash, row highlight",
        "In-app theme editor and chooser with live preview"
      ]
    },
    "zpwrchrome": {
      "overview": "A Chrome MV3 extension bundling six daily-driver browser tools into one toolbar icon, with a vendored Rust native-messaging host and 54 keyboard commands.",
      "features": [
        "UNIX pass integration: fill, copy, OTP, full CRUD manager",
        "Profile + credit-card autofill from pass entries",
        "Segmented multi-connection download manager via Range GETs",
        "JetBrains-style tab switcher with MRU, scenes, minimap",
        "fzf-fuzzy search over up to 5000 history entries",
        "Tampermonkey-equivalent userscript engine with GM_* shim",
        "Wappalyzer-compatible detection, 3,993-fingerprint corpus",
        "Full-page screenshot capture with OffscreenCanvas stitching",
        "54 commands; 2993 node:test + 117 cargo test cases"
      ]
    },
    "zpwr-daw": {
      "overview": "A two-view DAW built on one generalized grid engine — one canvas renderer, one interaction model, one value model, bound to a domain (notes / arrangement / automation / triggers). An Arrangement timeline and a Session clip launcher share the same engine: a pure C++ ClipEngine with a swung audio-thread step clock, reachable directly from C++ and from Rust over a C ABI. Formerly zpwr-clip-engine; the clip / arranger engine behind the MenkeTechnologies audio stack.",
      "features": [
        "Two-view DAW: an Arrangement timeline and a Session clip launcher on one engine",
        "Arrangement: tracks, clips, sections, tempo / meter maps, markers, breakpoint automation",
        "Session: scene launching with follow actions",
        "One generalized grid engine over notes / arrangement / automation / trigger domains",
        "Pure C++ ClipEngine — JUCE-free pattern model, swung step clock, event queue",
        "Native audio-thread step clock keeps playing when the host window is minimised",
        "Byte-identical C++/JS Type-0 MIDI export plus JSON project save / load",
        "Host-agnostic frontend: JUCE WebBrowserComponent and Tauri invoke bridges",
        "C ABI (FFI) with Rust bindings so Rust hosts drive the same engine the plugins do",
        "Shared across the stack — the CLIP tab in zpwr-synth / fx / midi-fx and the timelines in ztranslator / Audio-Haxor"
      ]
    },
    "zpwr-synth": {
      "overview": "A fully modular patch-graph synthesizer on the shared zpwr-patch-core engine: each voice is a free patch graph of 299 modules (VA/wavetable/FM/additive/supersaw/Karplus oscillators, filters, ADSR/LFO/S&H modulators, VCA/mixer), unlimited stacked layers, with a per-param mod matrix and a master + unlimited-aux FX-bus rack running the shared 2,772-module audio pack. Not a fixed voice path.",
      "features": [
        "World first: part of the first fully-modular patch-graph audio plugin quartet (with zpwr-daw) to pair patch-graph wiring with a no-cable knob panel, EZ auto-wiring, and stereo mirror + offset-preserving stereo link",
        "Oscillator modules — virtual-analog, wavetable, FM, additive, supersaw, Karplus-Strong — wired freely into each voice's patch graph",
        "Band-limited PolyBLEP sine/saw/square/triangle oscillators",
        "JP-8000 supersaw: seven detuned saws, 1–11 voice unison, detune + drift",
        "Linear-interpolated wavetable oscillator with frame morphing",
        "Sub oscillator (sine/square) plus white-noise source",
        "TPT state-variable filter: lowpass, highpass, bandpass",
        "ADSR / LFO / sample-and-hold modulator modules, freely routable to any parameter",
        "Modulation by patching — route any modulator to any parameter, no fixed mod-matrix slot limit",
        "Unlimited stackable layers, each its own voice pool",
        "Master-FX bus: the shared 2,772-module patch-core pack (incl. 171 analog models) runs once on the summed output",
        "256 general factory presets (two 128-voice banks) plus Trance, Hard Techno, and Schranz genre banks"
      ],
      "screenshots": [
        { "src": "assets/zsynth-synth.webp", "cap": "Synth view: per-voice oscillator, filter, and envelope panel" },
        { "src": "assets/zsynth-patch.webp", "cap": "Patch view: modular patch-graph wiring of the 49-module voice" },
        { "src": "assets/zsynth-peform.webp", "cap": "Perform view: macros, mod matrix, and layer controls" }
      ]
    },
    "zpwr-fx": {
      "overview": "A modular patch-graph effects plugin — not a fixed slot rack. Wire 2,772 DSP module types freely (fan-out and feedback allowed) into your own algorithms, with a per-param mod matrix, unlimited layers, and an EZ-wire mode that auto-routes the signal path. Built on the shared zpwr-patch-core engine.",
      "features": [
        "World first: part of the first fully-modular patch-graph audio plugin quartet (with zpwr-daw) to pair patch-graph wiring with a no-cable knob panel, EZ auto-wiring, and stereo mirror + offset-preserving stereo link",
        "2,772 audio/synth module types across every effect family",
        "Free patch graph: any node to any node, feedback with one-sample delay",
        "171 analog-circuit models (registerAnalog), faithful topologies — no IR/sample clones",
        "Analog filters: Minimoog, Jupiter-8, MS-20, SEM, EMS VCS3, Wasp, TB-303",
        "Analog comps: 1176, LA-2A, Fairchild, dbx 160, SSL bus, Distressor",
        "Analog EQs/pre: Pultec, API 550, Neve 1073, SSL E/G, Manley + tube/tape",
        "Analog pedals: Tube Screamer, RAT, Big Muff, Klon, DS-1, MXR, Fuzz Face",
        "Dynamics, EQ/filter, delay, reverb, modulation, distortion, pitch, spectral (FFT), stereo, lo-fi, glitch",
        "Per-param (source, depth) mod matrix; per-cable gain + colour",
        "Unlimited layers; ⚡ EZ-wire auto-routing; cyberpunk WebView UI"
      ],
      "screenshots": [
        { "src": "assets/zpwr-fx.webp", "cap": "Free patch-graph effects routing" }
      ]
    },
    "zpwr-midi-fx": {
      "overview": "A MIDI-effects plugin that transforms the note stream before it reaches an instrument — turning single keys into voiced chords, scale-locking for intelligent harmony, and running notes through a polymetric step arpeggiator with Euclidean rhythm generation. The same free-routed patch graph as zpwr-fx, instantiated on the note stream (111 MIDI module types), not a fixed slot rack.",
      "features": [
        "World first: part of the first fully-modular patch-graph audio plugin quartet (with zpwr-daw) to pair patch-graph wiring with a no-cable knob panel, EZ auto-wiring, and stereo mirror + offset-preserving stereo link",
        "111 note-stream module types in a free patch graph (not a fixed rack)",
        "Single-key chord voicing from a runtime chord dictionary",
        "Chord inversion, octave-doubling, spread, transpose, strum",
        "Per-key chord mapping (Chromatic, Circle-of-Fifths, Lowest-Note)",
        "Scale-lock quantizer across 20 scale/mode types",
        "Step arpeggiator: Up/Down/UpDown/Converge/AsPlayed/Random/Chord",
        "Per-step velocity, gate, transpose, ratchet, probability, tie",
        "Euclidean (Bjorklund) gate overlay with pulses and rotation",
        "Latch, swing, octave span, timing/velocity humanize",
        "Disk-backed .zpwrpreset manager (name/category/author)",
        "CyberLookAndFeel neon UI with step-indicator readout"
      ],
      "screenshots": [
        { "src": "assets/zpwr-midi-fx.webp", "cap": "Note-stream patch graph with arp + Euclidean" }
      ]
    },
    "stryke-arrow": {
      "overview": "Apache Arrow + Parquet + Feather + Arrow IPC + arrow-CSV/JSON columnar data support for stryke, shipped as an opt-in dlopened cdylib kept out of core.",
      "features": [
        "Read/write Parquet, Arrow IPC, Feather, CSV, NDJSON",
        "Streaming row reads via per-row callback",
        "Footer-only schema, row_count, and column stats",
        "Server-side filter/select/drop/sort/head/tail/slice",
        "Concat, rename, and cast columns file-to-file",
        "Format conversion without round-tripping through stryke",
        "Compression: snappy, zstd, gzip, lz4, brotli",
        "DataFrame bridge over columnar load"
      ]
    },
    "stryke-aws": {
      "overview": "AWS client for stryke covering S3, DynamoDB, SQS, Lambda, STS, SNS, SSM, Secrets Manager, SES, and CloudWatch via an in-process cdylib.",
      "features": [
        "S3 ls/get/put/head/rm plus copy and batch delete",
        "DynamoDB get/put/query/scan/describe with plain JSON",
        "SQS send/receive/delete/purge plus pump auto-delete loop",
        "Lambda invoke/call/list functions",
        "STS caller_identity and assume_role",
        "SNS topics/publish/subscribe, SES email send",
        "SSM Parameter Store and Secrets Manager get/put",
        "ARN and s3:// URI parse/build helpers"
      ]
    },
    "stryke-azure": {
      "overview": "Azure client for stryke mapping the stryke-aws surface onto Azure's GA Rust SDK, exposed as the dlopened Azure package.",
      "features": [
        "Blob Storage ls/get/put/head/rm and containers",
        "Storage Queues send/receive/delete/clear/count/pump",
        "Cosmos DB databases/containers/put/get/delete/query",
        "Key Vault Secrets get/set/ls/rm with param aliases",
        "Key Vault Keys RSA encrypt/decrypt",
        "Entra identity token connectivity probe",
        "Resource ID and connection-string parse helpers",
        "Storage account and container name validation"
      ]
    },
    "stryke-docker": {
      "overview": "Docker client for stryke driving any reachable Docker daemon for containers, images, networks, volumes, logs, exec, and prune.",
      "features": [
        "Container run/create/start/stop/kill/rm/pause/rename",
        "ps/inspect/top/wait/commit and buffered logs",
        "Exec with captured stdout+stderr",
        "Images pull/rmi/tag plus history and inspect",
        "Networks and volumes create/inspect/rm",
        "One-shot stats, diff, df, port, live update",
        "Prune containers/images/volumes/networks",
        "Image-ref, port-spec, and mount parse helpers"
      ]
    },
    "stryke-duckdb": {
      "overview": "Embedded DuckDB SQL engine for stryke that direct-queries Parquet/CSV/JSON with no import step, plus persistent .duckdb files and full standard SQL.",
      "features": [
        "query/query_one/query_col/query_scalar/query_stream",
        "Direct-query Parquet/CSV/JSON from disk or URL",
        "DDL/DML execute, insert_many, native appender bulk load",
        "import/export tables, update/delete/truncate/upsert",
        "Transactions: begin/commit/rollback/transaction block",
        "Metadata: tables/views/functions/settings/schema/inspect",
        "Analytics: summarize/describe/group_count/aggregate/sample",
        "Extensions httpfs/aws/iceberg/delta/spatial/excel on connect"
      ]
    },
    "stryke-gcp": {
      "overview": "Google Cloud client for stryke covering Cloud Storage, Pub/Sub, Secret Manager, BigQuery, and Firestore over GCP REST APIs via a dlopened cdylib.",
      "features": [
        "GCS ls/get/put/head/cp/rm/compose and buckets",
        "Pub/Sub publish/pull/ack plus topic and sub admin",
        "Pub/Sub pump pull-callback-ack loop",
        "Secret Manager access/create/add-version",
        "BigQuery jobs.query and streaming insert",
        "Firestore get/set/delete/list/query/create",
        "ADC auth with project resolution",
        "gs:// URI and resource-name parse helpers"
      ]
    },
    "stryke-grpc": {
      "overview": "Generic reflection-based gRPC client for stryke — like grpcurl but a stryke package, discovering services at call time with JSON in/out.",
      "features": [
        "List services and describe service/method/message",
        "Unary call with JSON-mapped input messages",
        "Server-, client-, and bidi-streaming as JSON arrays",
        "Server reflection with no local .proto files",
        "TLS, mTLS client cert, and custom CA root",
        "ASCII and binary (-bin) gRPC metadata headers",
        "Per-call deadline plus gzip/zstd/deflate compression",
        "status_code and parse_method string helpers"
      ]
    },
    "stryke-gui": {
      "overview": "GUI automation for stryke covering mouse, keyboard, screen, pixel, clipboard, and screenshots via a precompiled dlopened cdylib.",
      "features": [
        "Mouse move/drag/click/scroll with tweened motion",
        "Keyboard press/down/up/type and hotkey chords",
        "Mouse pos, screen size, and on-screen checks",
        "Pixel reads and color-match tolerance",
        "Full, region, and per-display screenshots",
        "Clipboard get/set",
        "Multi-monitor display enumeration",
        "Hotkey/color parse and RGB-to-HSL helpers"
      ]
    },
    "stryke-k8s": {
      "overview": "Kubernetes client for stryke running get/apply/delete/scale/rollout/logs/watch/exec against any kubeconfig-reachable cluster with GVK shortcuts.",
      "features": [
        "get/get_one with label/field selectors and limit",
        "Server-side apply, create, replace, patch",
        "Scale plus set_image/rollout_restart/status/history",
        "autoscale HPA, taint/untaint, label/annotate",
        "Nodes cordon/uncordon/evict",
        "events, top_pods/top_nodes, and wait conditions",
        "Buffered logs plus deferred follow/watch/exec",
        "valid_name, parse_selector, parse_quantity helpers"
      ]
    },
    "stryke-kafka": {
      "overview": "Apache Kafka client for stryke with producer, consumer, consumer-group lag, and topic/cluster/config admin, statically linking librdkafka.",
      "features": [
        "Produce with keys, headers, partitions, binary encoding",
        "produce_many bulk and consume snapshot/callback",
        "Consumer-group lag, watermarks, offsets_for_times",
        "Topics list/describe/create/delete, create_partitions",
        "describe_configs/alter_configs, delete_groups",
        "Cluster and consumer-group introspection",
        "SASL/SSL CLI flags",
        "murmur2 partition_for_key and broker parse helpers"
      ]
    },
    "stryke-mcpd": {
      "overview": "Policy layer for writing MCP servers in stryke as a single static native binary, providing validated specs, crash-isolated serving, a jailed tool pack, and client envelope helpers.",
      "features": [
        "Schema: validated tool specs and type-checked args",
        "Server: serve with die-to-ERROR crash isolation",
        "File-only logging keeping stdout clean for JSON-RPC",
        "Tools: root-jailed fs read/list/grep/find/write pack",
        "sh_exec allowlist plus env/time/sys_info tools",
        "Client: text envelope extraction and error parsing",
        "AOT-compile server to a single static binary",
        "CLI new/serve-stock/tools scaffolding"
      ]
    },
    "stryke-mongo": {
      "overview": "MongoDB client for stryke with CRUD, aggregation, and index admin against MongoDB 5.0+ standalone, replica set, or sharded clusters.",
      "features": [
        "find/find_one/find_stream/count with full query syntax",
        "insert/update/replace/delete one and many",
        "Atomic find_one_and_update/replace/delete",
        "Aggregation pipelines, distinct, estimated_count",
        "Index create/create_indexes/drop/list",
        "Collection and database create/drop/stats/explain",
        "run_command, server_status, relaxed extended JSON",
        "ObjectId, namespace, and connection-string helpers"
      ]
    },
    "stryke-mysql": {
      "overview": "MySQL/MariaDB client for stryke, shipped as an opt-in cdylib dlopened in-process with a pooled connection cache, no fork-per-call.",
      "features": [
        "query, query_one, query_scalar, query_col rows",
        "execute, insert_many, upsert, update, delete writes",
        "transaction batch on one pooled connection",
        "schema, tables, databases, indexes, triggers introspection",
        "CALL stored procedures and multi-result-set queries",
        "positional ? bind parameters, identifier quoting helpers",
        "processlist, status, variables, db_size, table_size admin",
        "CLI: query/execute/dump/schema/tables/ping subcommands"
      ]
    },
    "stryke-office": {
      "overview": "Native-Rust office document I/O for stryke covering Excel/Calc, Word/Writer, PowerPoint/Impress, ODF, PDF, and images with no LibreOffice subprocess.",
      "features": [
        "read/write xlsx, ods, csv, tsv, html, md sheets",
        "docx/odt read, write, blocks, tables, outline",
        "pptx/odp slides read, write, merge, split",
        "PDF generate, read, build multi-page, merge",
        "spreadsheet pivot, join, groupby, filter, dedupe",
        "statistics: describe, corr, regress, ttest, anova",
        "cross-format convert: json/xml/sql/latex/csv to sheet",
        "image open/resize/crop/filter/draw surface"
      ]
    },
    "stryke-parquet": {
      "overview": "Parquet file inspector and toolkit for stryke exposing schema, footer stats, row-group breakdown, and recompression as an opt-in cdylib.",
      "features": [
        "inspect, schema, count, metadata footer reads",
        "rowgroups per-row-group size and column breakdown",
        "stats per-column min/max/null_count aggregation",
        "head, tail, sample, stream row peeking",
        "to_csv, from_csv, from_json, write conversion",
        "compress/recompress across snappy/zstd/gzip/lz4/brotli",
        "merge same-schema files, write_partitioned Hive dirs",
        "validate, column_chunk_stats, size_report diagnostics"
      ]
    },
    "stryke-polars": {
      "overview": "Full pandas DataFrame plus numpy ndarray/linalg/FFT/random surface for stryke in one cdylib — 1,472 wrapper fns across 46 modules.",
      "features": [
        "DataFrame, Series, Index, GroupBy operations",
        "ndarray, ufuncs, masked arrays, sparse arrays",
        "linalg via nalgebra, FFT via rustfft",
        "random distributions, datetime64, timedelta64",
        "pandas IO read/write across formats",
        "statistics, stat tests, metrics, clustering",
        "image, signal, graph, geo, text families",
        "polynomial, interpolation, encoding, hashing"
      ]
    },
    "stryke-postgres": {
      "overview": "PostgreSQL client for stryke as an opt-in cdylib with a per-URL client cache, honoring DATABASE_URL, no fork-per-call.",
      "features": [
        "query, query_one, query_scalar, query_col, dump reads",
        "execute, insert_many, upsert, update, delete writes",
        "COPY copy_in/copy_out bulk transfer",
        "LISTEN/NOTIFY channel messaging",
        "begin/commit/rollback/transaction with connection affinity",
        "positional $1 binds with jsonb encoding",
        "tables, schema, indexes, roles, extensions introspection",
        "activity, locks, db_size, cancel_backend admin"
      ]
    },
    "stryke-redis": {
      "overview": "Redis/Valkey client for stryke as an opt-in cdylib caching one connection per auth tuple, covering all core data types and admin.",
      "features": [
        "KV get/set/mget/mset with TTL and counters",
        "lists, sets, hashes, sorted sets operations",
        "streams xadd/xrange/xread and consumer groups",
        "geospatial geoadd/geopos/geodist/geosearch",
        "HyperLogLog pfadd/pfcount/pfmerge cardinality",
        "bitmaps, scripting eval/evalsha, pub/sub publish",
        "SCAN, hscan, sscan, zscan non-blocking iteration",
        "pipeline/transaction and server admin introspection"
      ]
    },
    "stryke-selenium": {
      "overview": "Selenium WebDriver browser automation for stryke as a cdylib bridging thirtyfour's async API, with persistent sessions and element handles.",
      "features": [
        "launch chrome/firefox/safari/edge, headless or visible",
        "navigate: goto, back, forward, refresh, source",
        "find/find_all/wait_for by css/xpath/id/name/tag/class",
        "click, send_keys, clear, attr, prop, css element ops",
        "execute_script JavaScript with WebElement args",
        "screenshots full-page, per-element, print_page PDF",
        "window and frame control, alerts handling",
        "cookie add/list/delete management"
      ]
    },
    "stryke-spark": {
      "overview": "Apache Spark client for stryke as an opt-in cdylib shelling out to spark-submit with an embedded PySpark driver, universal across Spark 3.x/4.x.",
      "features": [
        "query, query_one, query_scalar, query_col, dump reads",
        "execute DDL/DML and explain query plans",
        "read/write external parquet/csv/json/orc sources",
        "tables, databases, views, catalogs, schema metadata",
        "temp view create/drop, set/refresh database",
        "cache/uncache tables and runtime config",
        "submit pass-through for .py/.jar workloads",
        "master URL and table-name parsing helpers"
      ]
    },
    "stryke-utils": {
      "overview": "Pure-stryke boundary helper library of 112 long-tail composites not in core, across six sublibraries with no cdylib or FFI.",
      "features": [
        "String: pad_center, squeeze, mask_middle, escape_shell, unwrap",
        "List: difference, intersection, union, windows, transpose",
        "Hash: deep_merge_all, deep_get, deep_set, flatten_keys",
        "Num: ordinal, round_to_multiple, percent_change, gcd",
        "Time: parse_duration, ago, format_iso8601, next_weekday",
        "Path: compound_ext, set_ext, normalize, relative, join",
        "cross-checked against builtins, zero name collisions",
        "CLI dispatcher bin/utils.stk"
      ]
    },
    "stryke-zmq": {
      "overview": "ZeroMQ brokerless messaging client for stryke as a cdylib with vendored libzmq, exposing all canonical socket patterns over TCP/IPC/inproc.",
      "features": [
        "req/rep, pub/sub, push/pull, dealer/router, pair sockets",
        "socket create with bind/connect/subscribe options",
        "send/recv plus multipart variants with utf8/hex/base64",
        "subscribe/unsubscribe SUB topic filters",
        "set/get full socket-option table",
        "poll and poll_many readiness over handles",
        "monitor lifecycle events, backgrounded proxy device",
        "CURVE keypair, z85 codec, one-shot request"
      ]
    },
    "stryke-fleet": {
      "overview": "Parallel expect/PTY automation for stryke as a pure-stryke orchestration layer over core PTY builtins and pmap, with no cdylib.",
      "features": [
        "Session: transcripted send/expect/branch/close PTY sessions",
        "Playbook: declarative step lists with branches and retries",
        "Recipes: 36 login chains (ssh, sudo, psql, docker_login)",
        "Fanout: one playbook across N targets via pmap",
        "partition, summarize, group_by_error, retry_failed results",
        "branch tables with first-match-wins coderef actions",
        "recipes are pure data, composable and unit-testable",
        "CLI fleet.stk for one-shot expect/exchange loops"
      ]
    },
    "stryke-clickhouse": {
      "overview": "ClickHouse client for stryke as an opt-in cdylib, running SELECTs, bulk-inserting via JSONEachRow, managing databases/tables, and introspecting the schema against any ClickHouse server over its HTTP interface (port 8123).",
      "features": [
        "query / query_rows / query_row / query_value result peeling",
        "bulk insert via JSONEachRow from an array of row hashes",
        "create_table with column spec and ORDER BY engine options",
        "count and scalar aggregate helpers",
        "database and table create / drop / list admin",
        "schema introspection of columns and types",
        "HTTP Basic auth, TLS, and per-request ClickHouse settings",
        "identifier and value escaping"
      ]
    },
    "stryke-email": {
      "overview": "Transactional and campaign email for stryke as a cdylib over lettre + rustls (no tokio), sending through your own authenticated SMTP with a pooled SmtpTransport cached per (host, port, tls, user).",
      "features": [
        "send a single message with text and HTML bodies",
        "send_bulk personalized mass mailing",
        "{{merge}} template fields substituted per recipient",
        "List-Unsubscribe headers for one-click opt-out",
        "suppression lists via suppress_filter",
        "per-send rate limiting",
        "your own authenticated SMTP — no third-party relay",
        "pooled transport cached per (host, port, tls, user)"
      ]
    },
    "stryke-mssql": {
      "overview": "Microsoft SQL Server / Azure SQL client for stryke as a cdylib over tiberius (the pure-Rust TDS driver), with parametrized query/execute, transaction batches, and schema introspection against SQL Server 2012+ or Azure SQL.",
      "features": [
        "query with @P1/@P2 positional params",
        "execute for DML/DDL statements",
        "batch transaction execution",
        "scalar and exists single-value helpers",
        "schema introspection of tables and columns",
        "ADO connection string or host/port/database params",
        "encrypt modes (required/off/not_supported)",
        "dev self-signed cert trust"
      ]
    },
    "stryke-neo4j": {
      "overview": "Neo4j graph database client for stryke as a cdylib over neo4rs (the pure-Rust Bolt driver), with parametrized Cypher query and run, scalar/row helpers, and schema introspection against Neo4j 4.x/5.x.",
      "features": [
        "parametrized Cypher query returning rows",
        "run for write statements",
        "scalar single-value helper",
        "labels, relationship types, property keys introspection",
        "index and constraint listing",
        "Bolt URIs: neo4j://, neo4j+s://, bolt://",
        "multi-database selection",
        "credential redaction in errors"
      ]
    },
    "stryke-scrape": {
      "overview": "Web scraping and crawling client for stryke as a cdylib: fetch a page, crawl a site (robots-respecting, depth/limit/subdomain bounded), discover via sitemap, then extract with CSS selectors, tables, links, and structured data.",
      "features": [
        "fetch a single page",
        "crawl with robots, depth, limit, and subdomain bounds",
        "sitemap discovery",
        "select / extract / extract_text CSS extraction",
        "extract_table to records; extract_links / extract_images",
        "structured data: JSON-LD, OpenGraph, Twitter cards",
        "extract_feeds and extract_meta tags",
        "url_parse / url_encode / url_decode / absolutize helpers"
      ]
    },
    "stryke-scylla": {
      "overview": "ScyllaDB / Apache Cassandra client for stryke as a cdylib over the native CQL binary protocol, running CQL queries, managing keyspaces and tables, and introspecting the schema against any ScyllaDB or Cassandra cluster.",
      "features": [
        "query and execute CQL statements",
        "create_keyspace and create_table DDL",
        "count helper",
        "schema introspection of keyspaces and tables",
        "multiple contact points / nodes",
        "PasswordAuthenticator auth",
        "session keyspace selection on connect",
        "identifier and value escaping"
      ]
    },
    "stryke-search": {
      "overview": "Elasticsearch / OpenSearch client for stryke as a cdylib over the shared REST API, covering index administration, document CRUD, bulk indexing, the query DSL, scroll, aliases, and cluster health against Elasticsearch 7+/8+ or OpenSearch 1+/2+.",
      "features": [
        "search with match / range / bool query builders",
        "count documents by query",
        "doc_index and document CRUD",
        "bulk indexing via NDJSON",
        "index_create / index_refresh administration",
        "aggregations: agg_terms and search_aggs",
        "sort and query_body DSL helpers",
        "API key or HTTP Basic auth, TLS"
      ]
    },
    "api-rest-generator": {
      "overview": "A zero-config code generation engine that parses MySQL, PostgreSQL, SQLite, or MSSQL DDL dumps and emits a fully wired REST backend, targeting Spring Boot (Java/Kotlin/Groovy) or Loco (Rust/Axum/SeaORM).",
      "features": [
        "Parses MySQL, PostgreSQL, SQLite, and MSSQL CREATE/ALTER TABLE",
        "Auto-detects primary keys, foreign keys, and column types",
        "Generates JPA entities and SeaORM entities with relations",
        "Emits full CRUD REST controllers (GET/POST/PUT/DELETE)",
        "Outputs Java, Kotlin, Groovy, or Rust/Loco projects",
        "Maps SQL types per-dialect to target language types",
        "loco-gen CLI scaffolds, wires routes, runs migrations",
        "Verified against Sakila, Chinook, Pagila, Northwind schemas"
      ]
    },
    "fusevm": {
      "overview": "A language-agnostic bytecode virtual machine with fused superinstructions and a three-tier Cranelift JIT — the shared execution engine behind strykelang, zshrs, awkrs, and vimlrs.",
      "features": [
        "224 opcodes across 21 sections, 11 fused superinstructions",
        "Three-tier Cranelift JIT: linear, block, and tracing",
        "Tracing JIT records hot loops, deopts on guard miss",
        "29 first-class shell ops, 87 first-class AWK ops",
        "Extension dispatch via Extended(u16,u8) handler tables",
        "Stack-based execution with slot-indexed local fast paths",
        "Optional jit-disk-cache persists native code across restarts",
        "Zero-clone dispatch with in-place array/hash mutation"
      ]
    },
    "LearningCollectionAPI": {
      "overview": "A Spring Boot REST API in Kotlin for managing a personal collection of learning notes, backed by MySQL via Spring Data JPA.",
      "features": [
        "Kotlin 2.3.20 + Spring Boot 4.0.4 on JDK 17",
        "MySQL datastore via Spring Data JPA",
        "Add and filter learning fragments via GET endpoints",
        "Recent-fragment retrieval (last 20 or last N)",
        "Random fragment access, single or N at a time",
        "Auto-generated Spring Data REST CRUD on /learning",
        "QueryDSL type-safe queries, SpringDoc OpenAPI",
        "Tests: unit, integration, property-based, idempotency"
      ]
    },
    "stryke-demo": {
      "overview": "Live demo scripts for every package in the stryke-* family — one .stk script per package, with a single install that pulls all packages from GitHub.",
      "features": [
        "14 standalone .stk demos, one per stryke-* package",
        "s install pulls all packages, builds cdylibs, locks graph",
        "docker-compose ships MySQL, Postgres, Redis, Mongo, Kafka, k3s",
        "Makefile targets run individual demos by name",
        "run_all.stk pings services and runs only reachable demos",
        "Demos cover Arrow, Spark, Parquet, DuckDB backends",
        "Demos cover AWS, GCP, Kafka, gRPC, k8s, Docker",
        "Cross-package integration tests under t/"
      ]
    },
    "VimColorSchemes": {
      "overview": "A 732-deck bundle of Vim colorschemes where every colors/*.vim file is a working :colorscheme target — the largest curated Vim colorscheme bundle in one plugin.",
      "features": [
        "732 distinct Vim colorschemes in one bundle",
        "Zero runtime: pure colors/*.vim files, no autoload",
        "Works with Pathogen, vim-plug, packer, lazy.nvim",
        "Neovim compatible alongside terminal and GUI Vim",
        "Supports 256-color and truecolor terminals",
        "Covers dark, light, pastel, neon, monochrome families",
        "Includes ports of gruvbox, dracula, solarized, nord, catppuccin",
        "Includes validation test scripts"
      ]
    },
    "zpwr": {
      "overview": "ZPWR is a zinit-based zsh terminal environment layered with custom zsh, bash, vimL, and stryke code — a full command-line cyberdeck with autocomplete, vim keybindings, and tmux integration.",
      "features": [
        "505 zpwr subcommands with colorized zsh menucompletion",
        "2000+ aliases plus 430+ git aliases",
        "40k zsh tab completions for predictive input",
        "177 centralized ZPWR-namespace environment variables",
        "890+ centralized files in ~/.zpwr for clean uninstall",
        "77 neovim plugins; 48 zinit plugins (33 custom)",
        "190k+ lines of code",
        "Evolved from Hashrocket's Dotmatrix into a full cyberdeck"
      ]
    },
    "zsh-more-completions": {
      "overview": "The largest curated zsh completion corpus in existence, wiring over 47k command completions into compsys — auto-generated from --help, man pages, and web research, then cleaned and verified.",
      "features": [
        "The largest curated zsh completion corpus: 47,316 files",
        "Over 47k command completions wired into compsys",
        "Harvested from Nix, Homebrew, APT, Fedora, Kali, Alpine, FreeBSD",
        "Exotic ecosystems: Hackage, OPAM, Hex.pm, CPAN, CRAN",
        "Covers GDAL/OGR, CERN ROOT, BIND 9, OpenFOAM, ROS",
        "Architecture-prefixed completions in architecture_src",
        "Manipulates fpath so override_src takes priority",
        "ZUnit suite validates structure, syntax, and coverage"
      ]
    },
    "zsh-expand": {
      "overview": "The most powerful zsh expansion plugin — intercepts the spacebar to expand regular, global, and suffix aliases, typo corrections, globs, history, and parameters in pure zsh.",
      "features": [
        "Expands aliases in command position and after 62 prefixes",
        "Parses prefix chains (sudo, su, env, strace) with flags",
        "290+ built-in spelling corrections, user-extensible",
        "Native glob, $param, history, command-substitution expansion",
        "Tabstop snippets jump cursor to placeholder on expansion",
        "Self-referential alias escape prevents infinite recursion",
        "Live ghost-text expansion preview, fish-style",
        "11,683 zunit tests; sub-millisecond pure-zsh hot path"
      ]
    },
    "zsh-learn": {
      "overview": "A MySQL-backed learning collection for zsh that turns the terminal into a persistent knowledge base to save, search, and quiz yourself on snippets and notes.",
      "features": [
        "Save code snippets, one-liners, and notes via le",
        "Search with filters, fzf fuzzy matching, or random sampling",
        "Quiz yourself with randomized recall (qu, qua)",
        "Edit entries in-place by ID with your $EDITOR",
        "Delete last N entries or by specific ID",
        "Configurable database command, schema, table names",
        "SQL access and redo via re and rsql",
        "Ctrl+K keybinding in vim insert, normal, emacs"
      ]
    },
    "zsh-git-acp": {
      "overview": "A zsh plugin that stages, commits, and pushes in one keybinding — ZLE widgets that take the command-line buffer as the commit message, plus a large library of git aliases.",
      "features": [
        "Ctrl-S runs git pull, add, commit, and push",
        "Ctrl-F Ctrl-S shows side-by-side diff and confirmation",
        "Uses the current command-line buffer as commit message",
        "Skips pull/push automatically when no remote exists",
        "Per-directory blacklist via env variable",
        "setopt noflowcontrol frees Ctrl-S and Ctrl-Q for ZLE",
        "159 git aliases for branch, merge, pull, push, fetch",
        "origin and upstream main/dev branch helpers"
      ]
    },
    "zsh-git-repo-cache": {
      "overview": "A zsh plugin that crawls the filesystem to locate every git repository on the machine and caches results for fast prompts and instant cd.",
      "features": [
        "Crawls / to locate every git repo, caching results",
        "Uses fd when available, falls back to find",
        "Separate caches for all, dirty, and clean repos",
        "fzf integration for interactive repo selection",
        "Regenerate functions rescan and rebuild caches",
        "Auto-generates dirty/clean caches on first search",
        "10 zpwr verbs for listing and searching repos",
        "Filters repos with uncommitted changes"
      ]
    },
    "zsh-zinit-final": {
      "overview": "An intentionally empty zsh plugin whose only purpose is to be the last thing zinit loads — a deterministic carrier for trailing atinit/atload hooks.",
      "features": [
        "Intentionally empty: zero functions, aliases, or state",
        "Deterministic trailing carrier for the zinit load chain",
        "Hosts atinit/atload ices firing after all plugins",
        "Avoids polluting other plugins' load order",
        "Works with turbo, wait-N, and lucid ice ordering",
        "Just a .plugin.zsh stub for zinit to load",
        "Designed specifically for the zinit loader"
      ]
    },
    "zsh-sudo": {
      "overview": "A zsh ZLE widget that toggles sudo on the current command line with a single keybind — prepending or stripping it without retyping.",
      "features": [
        "Single keybind prepends sudo to the command line",
        "Strips sudo (and builtin/command/env/args) if present",
        "Empty line recalls last history command with sudo",
        "Configurable via env vars (e.g. swap in doas)",
        "Handles quoted commands and builtin/command prefixes",
        "Parses env with flags and variable assignments",
        "Handles stacked sudo options like -u root -E",
        "Bind to any key combo"
      ]
    },
    "zsh-cargo-completion": {
      "overview": "Zsh tab-completion for Rust's Cargo, including live crates.io index search for cargo add and cargo install.",
      "features": [
        "cargo add/install <TAB> queries crates.io live",
        "Ships all Oh My Zsh cargo completions plus remote completer",
        "Bundled aliases for run, build, test, clippy, fmt, publish",
        "Installs via zinit, oh-my-zsh, or manual sourcing",
        "MIT licensed, with CI"
      ]
    },
    "zsh-cpan-completion": {
      "overview": "Zsh completion that pulls live Perl module names from CPAN for cpan and cpanm install commands.",
      "features": [
        "Live remote CPAN package completion",
        "Full cpan and cpanm flag and option completion",
        "Intelligent caching: hit the network once, reuse locally",
        "Min-prefix guard prevents network overload",
        "Tarball completion for .tar.gz, .tgz, .tar.bz2, .zip"
      ]
    },
    "zsh-dotnet-completion": {
      "overview": "Zsh tab-completion and aliases for the .NET (dotnet) CLI.",
      "features": [
        "Tab-completion for the dotnet command",
        "Bundled dotnet aliases",
        "Installs via zinit with ice lucid nocompile",
        "Clone into oh-my-zsh custom plugins",
        "Source the plugin file manually",
        "MIT licensed, with CI"
      ]
    },
    "zsh-gem-completion": {
      "overview": "Zsh completion for Ruby's gem command, adding live remote gem completion via gem search.",
      "features": [
        "gem install <TAB> completes remote gems",
        "Includes all Oh My Zsh gem completion",
        "Installs via zinit, oh-my-zsh, or manual sourcing",
        "Add to oh-my-zsh plugins array",
        "MIT licensed, with CI"
      ]
    },
    "zsh-nginx": {
      "overview": "Zsh tab-completion for nginx commands.",
      "features": [
        "Tab-completion for nginx commands",
        "Installs via zinit with ice lucid nocompile",
        "Clone into oh-my-zsh custom plugins",
        "Add to plugins array in .zshrc",
        "Source plugin file manually",
        "MIT licensed, with CI"
      ]
    },
    "zsh-openshift-aliases": {
      "overview": "Provides 53 short aliases over the OpenShift oc CLI plus login macros and oc tab-completion.",
      "features": [
        "53 oc-prefixed aliases (og=get, odesc=describe, olog=logs)",
        "Env-driven login macros: ocdev, ocqa, ologin via rsh",
        "Auto-sources oc completion when oc is on PATH",
        "No-ops safely when oc is not installed",
        "Configurable via OCP_USERNAME and URL env vars",
        "Installs via zinit, oh-my-zsh, or manual sourcing"
      ]
    },
    "zsh-pip-description-completion": {
      "overview": "Zsh completion for pip that adds remote package completion with version and description shown in the menu.",
      "features": [
        "pip install <TAB> completes remote packages",
        "Menu shows package version and description",
        "Includes all Oh My Zsh pip completion",
        "Installs via zinit, oh-my-zsh, or manual sourcing",
        "MIT licensed, with CI"
      ]
    },
    "zsh-sed-sub": {
      "overview": "Adds a ZLE keybinding (Ctrl-F Ctrl-P) for global sed-style search-and-replace on the current command line.",
      "features": [
        "Ctrl-F Ctrl-P does global search/replace on the line",
        "Registered in viins, vicmd, and emacs keymaps",
        "Rewrites the command-line buffer in place",
        "Installs via zinit, oh-my-zsh, or manual sourcing",
        "MIT licensed, with CI"
      ]
    },
    "zsh-very-colorful-manuals": {
      "overview": "An autoloaded man wrapper that injects LESS_TERMCAP_* variables to render man pages in cyberpunk ANSI colors.",
      "features": [
        "Recolors man output: green bold, cyan underline, magenta standout",
        "Injects LESS_TERMCAP_* only when man is called",
        "No global env-var pollution; passed via env to man",
        "Works on every man page on the system",
        "Includes a Solaris nroff shim",
        "Installs via zinit, oh-my-zsh, or manual sourcing"
      ]
    }
  };

  PRODUCTS.forEach(function (p) {
    var d = DETAILS[p.id];
    if (d) {
      p.overview = d.overview;
      if (d.features) p.features = d.features;
      if (d.screenshots) p.screenshots = d.screenshots;
    }
  });

  // ---- Published HTML docs (GitHub Pages) -----------------------------
  // Repos that publish their docs/ to GitHub Pages at github.io/<id>/.
  // Each ships a Documentation site (index.html) and an Engineering Report
  // (report.html); listed ids in DOC_REFERENCE also ship an API Reference
  // (reference.html). Verified live (HTTP 200) — proprietary products
  // (audio-haxor, traderview) and Pages-disabled repos (zpwr-fx/synth/midi-fx,
  // which link a PDF catalog instead) are intentionally absent so no link 404s.
  var DOC_REPOS = [
    'api-rest-generator', 'awkrs', 'fusevm', 'iftoprs', 'lsofrs', 'nmaprs',
    'powerliners', 'storageshower', 'temprs', 'strykelang', 'zshrs', 'zpwr',
    'zpwrchrome', 'stryke-arrow', 'stryke-aws', 'stryke-azure',
    'stryke-clickhouse', 'stryke-demo', 'stryke-docker', 'stryke-duckdb',
    'stryke-email', 'stryke-fleet', 'stryke-gcp', 'stryke-grpc', 'stryke-gui',
    'stryke-k8s', 'stryke-kafka', 'stryke-mcpd', 'stryke-mongo', 'stryke-mssql',
    'stryke-mysql', 'stryke-neo4j', 'stryke-office', 'stryke-parquet',
    'stryke-polars', 'stryke-postgres', 'stryke-redis', 'stryke-scrape',
    'stryke-scylla', 'stryke-search', 'stryke-selenium', 'stryke-spark',
    'stryke-utils', 'stryke-zmq', 'zsh-cargo-completion', 'zsh-cpan-completion',
    'zsh-dotnet-completion', 'zsh-expand', 'zsh-gem-completion', 'zsh-git-acp',
    'zsh-git-repo-cache', 'zsh-learn', 'zsh-more-completions', 'zsh-nginx',
    'zsh-pip-description-completion', 'zsh-sed-sub', 'zsh-sudo',
  ];
  var DOC_REFERENCE = { strykelang: 1, zshrs: 1 };
  DOC_REPOS.forEach(function (id) {
    var p = byId(id);
    if (!p) return;
    var base = 'https://menketechnologies.github.io/' + id + '/';
    var sites = [{ label: 'Documentation', desc: 'Project documentation site', url: base }];
    if (DOC_REFERENCE[id]) {
      sites.push({ label: 'API Reference', desc: 'Full API / block reference', url: base + 'reference.html' });
    }
    sites.push({ label: 'Engineering Report', desc: 'Architecture & engineering report', url: base + 'report.html' });
    p.docsite = sites;
  });

  // zpwr-daw is a private/proprietary product, so it has no github.io/zpwr-daw
  // Pages site of its own — its docs are vendored into the meta umbrella and
  // served from menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-daw/.
  (function () {
    var p = byId('zpwr-daw');
    if (!p) return;
    var base = 'https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-daw/';
    p.docsite = [
      { label: 'Documentation', desc: 'Project documentation site', url: base },
      { label: 'Engineering Report', desc: 'Architecture & engineering report', url: base + 'report.html' },
    ];
  })();

  // ---- Helpers --------------------------------------------------------
  var CART_KEY = 'appstore-cart';

  function byId(id) {
    for (var i = 0; i < PRODUCTS.length; i++) {
      if (PRODUCTS[i].id === id) return PRODUCTS[i];
    }
    return null;
  }

  function fmtPrice(n) {
    if (!n) return 'Free';
    return '$' + n.toLocaleString('en-US');
  }

  // Free / open-source products download from GitHub instead of going to cart.
  function isFree(p) {
    var t = (p.tiers && p.tiers[0]) || { price: p.price };
    return !t.price;
  }

  function readCart() {
    try { return JSON.parse(localStorage.getItem(CART_KEY)) || []; }
    catch (_) { return []; }
  }
  function writeCart(cart) {
    try { localStorage.setItem(CART_KEY, JSON.stringify(cart)); } catch (_) {}
    updateCartCount();
  }
  function cartTotal(cart) {
    return cart.reduce(function (sum, item) { return sum + (item.price || 0); }, 0);
  }
  function addToCart(productId, tierName, price) {
    var cart = readCart();
    // One license per product in the cart; re-adding swaps the tier.
    cart = cart.filter(function (i) { return i.id !== productId; });
    cart.push({ id: productId, tier: tierName, price: price });
    writeCart(cart);
  }
  function removeFromCart(productId) {
    writeCart(readCart().filter(function (i) { return i.id !== productId; }));
  }

  function updateCartCount() {
    var el = document.getElementById('cartCount');
    if (!el) return;
    var n = readCart().length;
    el.textContent = n ? String(n) : '';
    el.setAttribute('data-n', String(n));
  }

  // ---- Storefront grid (index.html) ----------------------------------
  function categories() {
    var seen = {};
    var out = ['All'];
    PRODUCTS.forEach(function (p) {
      if (!seen[p.category]) { seen[p.category] = true; out.push(p.category); }
    });
    return out;
  }

  // fzf match highlight: wrap matched chars in <mark class="fzf-hl"> (same as
  // haxor). Only when there's a query and fzf.js loaded; otherwise raw text.
  function hl(text, q) {
    if (!q || !window.FZF) return text;
    return window.FZF.highlightWithIndices(text, window.FZF.getMatchIndices(q, text));
  }

  function cardHtml(p, q) {
    var tier = (p.tiers && p.tiers[0]) || { price: p.price };
    var badge = p.badge
      ? '<span class="badge' + (p.badge === 'WORLD FIRST' ? ' first' : '') + '">' + p.badge + '</span>'
      : '';
    var pills = (p.pills || []).map(function (t) {
      return '<span class="p-pill">' + t + '</span>';
    }).join('');
    var priceCls = tier.price ? '' : ' free';
    var shot = (p.screenshots && p.screenshots[0])
      ? '<img class="thumb-shot" src="' + p.screenshots[0].src + '" alt="' + p.name + ' screenshot" loading="lazy">'
      : '<span class="glyph">' + p.glyph + '</span>';
    return '' +
      '<a class="product-card" href="product.html?id=' + encodeURIComponent(p.id) + '" data-cat="' + p.category + '" data-name="' + p.name.toLowerCase() + ' ' + p.tagline.toLowerCase() + '">' +
        '<div class="product-thumb' + (p.screenshots ? ' has-shot' : '') + '">' + badge + shot + '</div>' +
        '<div class="product-body">' +
          '<span class="p-cat">' + p.category + '</span>' +
          '<span class="p-name">' + hl(p.name, q) + '</span>' +
          '<span class="p-tag">' + hl(p.tagline, q) + '</span>' +
          '<div class="p-meta">' + pills + '</div>' +
        '</div>' +
        '<div class="product-foot">' +
          '<span class="price"><span class="amt' + priceCls + '">' + fmtPrice(tier.price) + '</span>' +
            (tier.price ? '<span class="per">per major version</span>' : '') + '</span>' +
          (isFree(p)
            ? '<button type="button" class="btn btn-buy" data-download="' + (p.download || p.repo) + '">Download ↗</button>'
            : '<button type="button" class="btn btn-buy" data-add="' + p.id + '">Add</button>') +
        '</div>' +
      '</a>';
  }

  function renderGrid(filterCat, query) {
    var grid = document.getElementById('productGrid');
    if (!grid) return;
    var q = (query || '').trim();
    // fzf-style fuzzy filtering + ranking (same engine as zpwr-modules, fzf.js).
    // Fields: name (weighted first), tagline, category, tags. Falls back to a plain
    // substring match if fzf.js failed to load.
    var scored = [];
    PRODUCTS.forEach(function (p) {
      if (filterCat && filterCat !== 'All' && p.category !== filterCat) return;
      var fields = [p.name, p.tagline, p.category].concat(p.pills || []);
      var score = window.FZF
        ? window.FZF.searchScore(q, fields)
        : (!q || fields.join(' ').toLowerCase().indexOf(q.toLowerCase()) >= 0 ? 1 : 0);
      if (q && score <= 0) return;
      scored.push({ p: p, score: score });
    });
    if (q) scored.sort(function (a, b) { return b.score - a.score; });
    var list = scored.map(function (x) { return x.p; });
    if (!list.length) {
      grid.innerHTML = '<div class="empty-state">no products match that search</div>';
      return;
    }
    grid.innerHTML = list.map(function (p) { return cardHtml(p, q); }).join('');
    // Stagger the entrance animation.
    var cards = grid.querySelectorAll('.product-card');
    for (var i = 0; i < cards.length; i++) {
      cards[i].style.animationDelay = (0.05 + i * 0.04) + 's';
    }
  }

  function renderFilters() {
    var row = document.getElementById('filterRow');
    if (!row) return;
    row.innerHTML = categories().map(function (c, i) {
      return '<button type="button" class="filter-chip' + (i === 0 ? ' active' : '') + '" data-cat="' + c + '">' + c + '</button>';
    }).join('');
  }

  function renderStats() {
    var setText = function (id, val) {
      var el = document.getElementById(id);
      if (el) el.textContent = val;
    };
    setText('statProducts', String(PRODUCTS.length));
    setText('statCats', String(categories().length - 1));
    var free = PRODUCTS.filter(function (p) { return !((p.tiers && p.tiers[0].price) || p.price); }).length;
    setText('statFree', String(free));
  }

  // ---- Product detail (product.html) ---------------------------------
  function getParam(name) {
    var m = new RegExp('[?&]' + name + '=([^&]*)').exec(location.search);
    return m ? decodeURIComponent(m[1]) : null;
  }

  function renderDetail() {
    var root = document.getElementById('detailRoot');
    if (!root) return;
    var p = byId(getParam('id'));
    if (!p) {
      root.innerHTML = '<div class="empty-state">product not found</div>';
      return;
    }
    document.title = p.name + ' — MenkeTechnologies App Store';
    var tiersHtml = (p.tiers || []).map(function (t, i) {
      return '<div class="license-opt' + (i === 0 ? ' active' : '') + '" data-tier="' + i + '" data-price="' + t.price + '">' +
        '<div><div class="lo-name">' + t.name + '</div><div class="lo-desc">' + t.desc + '</div></div>' +
        '<div class="lo-price">' + fmtPrice(t.price) + '</div>' +
        '</div>';
    }).join('');
    var featuresHtml = (p.features || []).map(function (f) {
      return '<li>' + f + '</li>';
    }).join('');
    var pills = (p.pills || []).map(function (t) { return '<span class="p-pill">' + t + '</span>'; }).join('');
    var free = isFree(p);

    // Free products download from GitHub; paid products pick a license + add to cart.
    var pricingHtml = free
      ? '<div class="price detail-price"><span class="amt free">Free</span><span class="per">open source</span></div>'
      : '<div class="license-pick">' + tiersHtml + '</div>' +
        '<div class="price detail-price"><span class="amt" id="detailAmt">' + fmtPrice((p.tiers[0] || {}).price) + '</span><span class="per">per major version</span></div>' +
        '<p class="version-note">Each purchase licenses the current major version, including all minor &amp; patch updates within it. Future major versions are a separate purchase.</p>';
    // "Source" only when a public repo is set — proprietary paid products omit it.
    var sourceBtn = p.repo
      ? '<a class="btn btn-secondary" href="' + p.repo + '" target="_blank" rel="noopener noreferrer">Source</a>'
      : '';
    // "Docs" button → the published doc site when one exists, else a shipped
    // reference (e.g. the block-catalog PDF).
    var primaryDoc = (p.docsite && p.docsite[0] && p.docsite[0].url) ||
      (p.docs && p.docs[0] && p.docs[0].url);
    var docsBtn = primaryDoc
      ? '<a class="btn btn-secondary" href="' + primaryDoc + '" target="_blank" rel="noopener noreferrer">Docs ↗</a>'
      : '';
    var actionsHtml = free
      ? '<a class="btn btn-buy" href="' + (p.download || p.repo) + '" target="_blank" rel="noopener noreferrer">Download ↗</a>' + sourceBtn + docsBtn
      : '<button type="button" class="btn btn-buy" id="detailAdd">Add to cart</button>' + sourceBtn + docsBtn;

    var shots = p.screenshots || [];
    var heroHtml = shots.length
      ? '<button type="button" class="detail-hero has-shot" data-shot="0" aria-label="View screenshot"><img src="' + shots[0].src + '" alt="' + p.name + ' screenshot"></button>'
      : '<div class="detail-hero"><span class="glyph">' + p.glyph + '</span></div>';
    // Documentation: published HTML doc sites (GitHub Pages) plus any shipped
    // reference PDFs / manuals (block catalog, etc.).
    var allDocs = []
      .concat((p.docsite || []).map(function (d) { return { label: d.label, desc: d.desc, url: d.url, ico: 'WEB' }; }))
      .concat((p.docs || []).map(function (d) { return { label: d.label, desc: d.desc, url: d.url, ico: 'PDF' }; }));
    var docsHtml = allDocs.length
      ? '<section class="tutorial-section"><h2>Documentation</h2><div class="doc-list">' +
          allDocs.map(function (d) {
            return '<a class="doc-card" href="' + d.url + '" target="_blank" rel="noopener noreferrer">' +
              '<span class="doc-ico">' + d.ico + '</span>' +
              '<span class="doc-body"><span class="doc-name">' + d.label + ' ↗</span>' +
              (d.desc ? '<span class="doc-desc">' + d.desc + '</span>' : '') + '</span>' +
              '</a>';
          }).join('') +
        '</div></section>'
      : '';

    // Gallery only when there's more than the hero shot — single-shot apps would just duplicate the hero.
    var galleryHtml = shots.length > 1
      ? '<section class="tutorial-section"><h2>Screenshots</h2><div class="shot-grid">' +
          shots.map(function (s, i) {
            return '<button type="button" class="shot-thumb" data-shot="' + i + '">' +
              '<img src="' + s.src + '" alt="' + s.cap + '" loading="lazy">' +
              '<span class="shot-cap">' + s.cap + '</span>' +
              '</button>';
          }).join('') +
        '</div></section>'
      : '';

    root.innerHTML = '' +
      '<div class="detail-top">' +
        heroHtml +
        '<div class="detail-buy">' +
          '<span class="p-cat">' + p.category + '</span>' +
          '<h2>' + p.name + '</h2>' +
          '<p class="p-tag">' + p.tagline + '</p>' +
          '<div class="p-meta">' + pills + '</div>' +
          pricingHtml +
          '<div class="buy-actions">' + actionsHtml + '</div>' +
        '</div>' +
      '</div>' +
      (p.overview
        ? '<section class="tutorial-section"><h2>Overview</h2><p class="detail-overview">' + p.overview + '</p></section>'
        : '') +
      '<section class="tutorial-section">' +
        '<h2>What you get</h2>' +
        '<ul class="feature-list">' + featuresHtml + '</ul>' +
      '</section>' +
      docsHtml +
      galleryHtml;

    // Lightbox: any [data-shot] (hero or thumbnail) opens the full-size viewer.
    if (shots.length) {
      var shotBtns = root.querySelectorAll('[data-shot]');
      for (var s = 0; s < shotBtns.length; s++) {
        (function (btn) {
          btn.addEventListener('click', function () {
            openLightbox(shots, parseInt(btn.getAttribute('data-shot'), 10));
          });
        })(shotBtns[s]);
      }
    }

    if (free) return;

    var selected = 0;
    var opts = root.querySelectorAll('.license-opt');
    var amtEl = document.getElementById('detailAmt');
    for (var i = 0; i < opts.length; i++) {
      (function (idx) {
        opts[idx].addEventListener('click', function () {
          for (var j = 0; j < opts.length; j++) opts[j].classList.remove('active');
          opts[idx].classList.add('active');
          selected = idx;
          amtEl.textContent = fmtPrice(p.tiers[idx].price);
        });
      })(i);
    }
    document.getElementById('detailAdd').addEventListener('click', function () {
      var t = p.tiers[selected];
      addToCart(p.id, t.name, t.price);
      openCart();
    });
  }

  // ---- Cart + checkout modal -----------------------------------------
  function cartItemHtml(item) {
    var p = byId(item.id) || { name: item.id, glyph: '?' };
    return '<div class="cart-item">' +
      '<div class="ci-glyph">' + p.glyph + '</div>' +
      '<div class="ci-info"><div class="ci-name">' + p.name + '</div><div class="ci-lic">' + item.tier + '</div></div>' +
      '<div class="ci-price">' + fmtPrice(item.price) + '</div>' +
      '<button type="button" class="ci-rm" data-rm="' + item.id + '" title="Remove">×</button>' +
      '</div>';
  }

  function renderCartBody() {
    var body = document.getElementById('modalBody');
    if (!body) return;
    var cart = readCart();
    if (!cart.length) {
      body.innerHTML = '<div class="cart-empty">// your cart is empty</div>';
      return;
    }
    body.innerHTML =
      cart.map(cartItemHtml).join('') +
      '<div class="cart-total"><span class="lbl">Total</span><span class="amt">' + fmtPrice(cartTotal(cart)) + '</span></div>' +
      '<div class="cart-actions">' +
        '<button type="button" class="btn btn-secondary" id="clearCart">Clear</button>' +
        '<button type="button" class="btn btn-buy" id="goCheckout">Checkout</button>' +
      '</div>';
  }

  // ---- Checkout page (checkout.html) ---------------------------------
  // Discount codes: code -> { type: 'pct'|'flat', value }. Edit freely.
  var DISCOUNTS = {
    LAUNCH20: { type: 'pct', value: 20, label: '20% off' },
    HUD10:    { type: 'flat', value: 10, label: '$10 off' },
  };
  var appliedCode = null;

  function discountAmount(subtotal) {
    if (!appliedCode) return 0;
    var d = DISCOUNTS[appliedCode];
    if (!d) return 0;
    var amt = d.type === 'pct' ? Math.round(subtotal * d.value / 100) : d.value;
    return Math.min(amt, subtotal);
  }

  function sumItemHtml(item) {
    var p = byId(item.id) || { name: item.id, glyph: '?' };
    return '<div class="sum-item">' +
      '<div class="si-thumb">' + p.glyph + '<span class="si-qty">1</span></div>' +
      '<div class="si-info"><div class="si-name">' + p.name + '</div><div class="si-lic">' + item.tier + ' license</div></div>' +
      '<div class="si-price">' + fmtPrice(item.price) + '</div>' +
      '</div>';
  }

  function summaryHtml() {
    var cart = readCart();
    var subtotal = cartTotal(cart);
    var disc = discountAmount(subtotal);
    var total = subtotal - disc;
    var discLine = disc
      ? '<div class="sum-line"><span>Discount (' + appliedCode + ')</span><span>-' + fmtPrice(disc) + '</span></div>'
      : '';
    return '' +
      cart.map(sumItemHtml).join('') +
      '<div class="discount-row">' +
        '<input type="text" id="discountInput" placeholder="Discount code or gift card" value="' + (appliedCode || '') + '">' +
        '<button type="button" class="btn btn-secondary" id="applyDiscount">Apply</button>' +
      '</div>' +
      '<div class="discount-applied' + (appliedCode ? '' : ' hidden') + '" id="discountMsg"></div>' +
      '<div class="sum-line"><span>Subtotal · ' + cart.length + ' item' + (cart.length === 1 ? '' : 's') + '</span><span>' + fmtPrice(subtotal) + '</span></div>' +
      discLine +
      '<div class="sum-line"><span>Taxes</span><span>Calculated at fulfillment</span></div>' +
      '<div class="sum-line total"><span class="t-lbl">Total</span><span class="t-amt"><span class="cur">USD</span>' + fmtPrice(total) + '</span></div>';
  }

  function renderCheckoutPage() {
    var root = document.getElementById('checkoutRoot');
    if (!root) return;
    var cart = readCart();
    if (!cart.length) {
      root.innerHTML = '<div class="empty-state">your cart is empty — <a href="index.html">back to the store</a></div>';
      return;
    }

    root.innerHTML = '' +
      '<div class="checkout-wrap">' +
        '<div class="checkout-col">' +
          // Express checkout wallets
          '<div class="checkout-block">' +
            '<p class="express-label">Express checkout</p>' +
            '<div class="wallet-grid">' +
              '<button type="button" class="wallet-btn shop" data-wallet="shop">shop</button>' +
              '<button type="button" class="wallet-btn paypal" data-wallet="paypal">PayPal</button>' +
              '<button type="button" class="wallet-btn gpay" data-wallet="gpay"><span class="gp-g">G</span>&nbsp;Pay</button>' +
              '<button type="button" class="wallet-btn venmo" data-wallet="venmo">venmo</button>' +
            '</div>' +
            '<div class="or-divider">OR</div>' +
          '</div>' +
          // Contact
          '<div class="checkout-block">' +
            '<h3>Contact</h3>' +
            '<div class="field"><input id="ckEmail" type="email" required placeholder="Email (license delivery)"></div>' +
            '<label class="check-checkbox"><input type="checkbox" id="ckNews" checked> Email me product updates and new releases</label>' +
          '</div>' +
          // Payment
          '<div class="checkout-block">' +
            '<h3>Payment</h3>' +
            '<p class="checkout-note">All transactions are secure and encrypted.</p>' +
            '<form id="checkoutForm"><div class="pay-methods" id="payMethods">' +
              '<div class="pay-method active" data-method="card">' +
                '<div class="pay-method-head"><span class="radio"></span><span class="pm-label">Credit card</span>' +
                  '<span class="pm-art"><span class="card-chip visa">VISA</span><span class="card-chip mc">MC</span><span class="card-chip amex">AMEX</span><span class="card-chip more">+5</span></span>' +
                '</div>' +
                '<div class="pay-method-body">' +
                  '<div class="field"><input id="ckCard" type="text" inputmode="numeric" placeholder="Card number" autocomplete="cc-number"></div>' +
                  '<div class="field-row">' +
                    '<div class="field"><input id="ckExp" type="text" placeholder="Expiration date (MM / YY)" autocomplete="cc-exp"></div>' +
                    '<div class="field"><input id="ckCvc" type="text" inputmode="numeric" placeholder="Security code" autocomplete="cc-csc"></div>' +
                  '</div>' +
                  '<div class="field"><input id="ckName" type="text" placeholder="Name on card" autocomplete="cc-name"></div>' +
                '</div>' +
              '</div>' +
              '<div class="pay-method" data-method="shop">' +
                '<div class="pay-method-head"><span class="radio"></span><span class="pm-label">Shop Pay · pay in full or installments</span><span class="brand-logo shop">shop</span></div>' +
                '<div class="pay-method-body"><p class="checkout-note">You will be redirected to Shop Pay to complete your purchase securely.</p></div>' +
              '</div>' +
              '<div class="pay-method" data-method="paypal">' +
                '<div class="pay-method-head"><span class="radio"></span><span class="pm-label">PayPal</span><span class="brand-logo paypal">PayPal</span></div>' +
                '<div class="pay-method-body"><div id="paypalButtonContainer"><p class="checkout-note">You will be redirected to PayPal to complete your purchase securely.</p></div></div>' +
              '</div>' +
            '</div>' +
            // Billing
            '<div class="checkout-block" style="margin-top:1.3rem;">' +
              '<h3>Billing address</h3>' +
              '<div class="field"><label for="ckCountry">Country / Region</label>' +
                '<select id="ckCountry"><option>United States</option><option>Canada</option><option>United Kingdom</option><option>Australia</option><option>Germany</option><option>Other</option></select></div>' +
              '<div class="field-row">' +
                '<div class="field"><input id="ckFirst" type="text" placeholder="First name" autocomplete="given-name"></div>' +
                '<div class="field"><input id="ckLast" type="text" placeholder="Last name" autocomplete="family-name"></div>' +
              '</div>' +
              '<div class="field"><input id="ckAddr" type="text" placeholder="Address" autocomplete="street-address"></div>' +
              '<div class="field-row">' +
                '<div class="field"><input id="ckCity" type="text" placeholder="City" autocomplete="address-level2"></div>' +
                '<div class="field"><input id="ckState" type="text" placeholder="State / Province" autocomplete="address-level1"></div>' +
                '<div class="field"><input id="ckZip" type="text" placeholder="ZIP / Postal code" autocomplete="postal-code"></div>' +
              '</div>' +
            '</div>' +
            '<button type="submit" class="btn btn-buy pay-now-btn" id="payNow">Pay now</button>' +
            '</form>' +
          '</div>' +
        '</div>' +
        // Right: order summary
        '<aside class="checkout-summary" id="checkoutSummary">' + summaryHtml() + '</aside>' +
      '</div>';

    wireCheckoutPage(root);
  }

  function refreshSummary(root) {
    var summary = root.querySelector('#checkoutSummary');
    if (summary) { summary.innerHTML = summaryHtml(); wireSummary(root); }
  }

  function wireSummary(root) {
    var apply = root.querySelector('#applyDiscount');
    var input = root.querySelector('#discountInput');
    var msg = root.querySelector('#discountMsg');
    if (apply && input) apply.addEventListener('click', function () {
      var code = input.value.trim().toUpperCase();
      if (DISCOUNTS[code]) {
        appliedCode = code;
        refreshSummary(root);
        var m2 = root.querySelector('#discountMsg');
        if (m2) { m2.classList.remove('hidden', 'bad'); m2.textContent = '✓ ' + DISCOUNTS[code].label + ' applied'; }
      } else {
        appliedCode = null;
        if (msg) { msg.classList.remove('hidden'); msg.classList.add('bad'); msg.textContent = '✗ invalid code'; }
      }
    });
    if (msg && appliedCode && DISCOUNTS[appliedCode]) {
      msg.classList.remove('hidden', 'bad');
      msg.textContent = '✓ ' + DISCOUNTS[appliedCode].label + ' applied';
    }
  }

  function wireCheckoutPage(root) {
    wireSummary(root);

    // Payment-method accordion (single open at a time).
    var methods = root.querySelector('#payMethods');
    if (methods) methods.addEventListener('click', function (e) {
      var head = e.target.closest('.pay-method-head');
      if (!head) return;
      var all = methods.querySelectorAll('.pay-method');
      for (var i = 0; i < all.length; i++) all[i].classList.remove('active');
      head.parentElement.classList.add('active');
    });

    // Express wallet buttons + branded radios route to the provider.
    // INTEGRATION HOOKS: replace the alert() calls below.
    //   shop / shopPay  -> redirect to your Shopify hosted checkout URL
    //   paypal          -> render PayPal Smart Buttons into #paypalButtonContainer
    //   gpay / venmo    -> Google Pay / Braintree-Venmo SDK
    function startWallet(name) {
      // e.g. shop: location.href = SHOPIFY_CHECKOUT_URL;
      completeOrder(root, name);
    }
    root.querySelectorAll('[data-wallet]').forEach(function (b) {
      b.addEventListener('click', function () { startWallet(b.getAttribute('data-wallet')); });
    });

    var form = root.querySelector('#checkoutForm');
    if (form) form.addEventListener('submit', function (e) {
      e.preventDefault();
      var active = root.querySelector('.pay-method.active');
      var method = active ? active.getAttribute('data-method') : 'card';
      completeOrder(root, method);
    });
  }

  function completeOrder(root, method) {
    // CLIENT-SIDE PLACEHOLDER — no real charge happens here. Wire `method`
    // to Stripe / PayPal / Shopify before going live (see README).
    var emailEl = root.querySelector('#ckEmail');
    var email = (emailEl && emailEl.value) || 'your inbox';
    writeCart([]);
    appliedCode = null;
    root.innerHTML = '<div class="checkout-ok" style="max-width:34rem;margin:3rem auto;">' +
      '<div class="big">// order confirmed</div>' +
      '<p>Paid via <strong>' + method + '</strong>.<br>License keys are on their way to <strong>' + email + '</strong>.<br>Thanks for buying from MenkeTechnologies.</p>' +
      '<div class="cart-actions" style="justify-content:center;margin-top:1rem;"><a class="btn btn-buy" href="index.html">Back to store</a></div></div>';
  }

  function setModalTitle(t) {
    var head = document.getElementById('modalTitle');
    if (head) head.textContent = t;
  }
  function openCart() {
    var overlay = document.getElementById('modalOverlay');
    if (!overlay) return;
    setModalTitle('Cart');
    renderCartBody();
    overlay.hidden = false;
  }
  function closeModal() {
    var overlay = document.getElementById('modalOverlay');
    if (overlay) overlay.hidden = true;
  }

  // ---- Screenshot lightbox -------------------------------------------
  var lbShots = [];
  var lbIdx = 0;

  function lbEl() {
    var el = document.getElementById('lightbox');
    if (el) return el;
    el = document.createElement('div');
    el.id = 'lightbox';
    el.className = 'lightbox';
    el.hidden = true;
    el.innerHTML =
      '<button type="button" class="lb-close" aria-label="Close">×</button>' +
      '<button type="button" class="lb-nav lb-prev" aria-label="Previous">‹</button>' +
      '<figure class="lb-stage"><img class="lb-img" alt=""><figcaption class="lb-cap"></figcaption></figure>' +
      '<button type="button" class="lb-nav lb-next" aria-label="Next">›</button>';
    document.body.appendChild(el);
    el.querySelector('.lb-close').addEventListener('click', closeLightbox);
    el.querySelector('.lb-prev').addEventListener('click', function () { stepLightbox(-1); });
    el.querySelector('.lb-next').addEventListener('click', function () { stepLightbox(1); });
    el.addEventListener('click', function (e) { if (e.target === el) closeLightbox(); });
    return el;
  }

  function renderLightbox() {
    var el = lbEl();
    var s = lbShots[lbIdx];
    if (!s) return;
    el.querySelector('.lb-img').src = s.src;
    el.querySelector('.lb-img').alt = s.cap || '';
    el.querySelector('.lb-cap').textContent = s.cap || '';
    var single = lbShots.length < 2;
    el.querySelector('.lb-prev').hidden = single;
    el.querySelector('.lb-next').hidden = single;
  }

  function openLightbox(shots, idx) {
    lbShots = shots;
    lbIdx = idx || 0;
    renderLightbox();
    lbEl().hidden = false;
  }

  function closeLightbox() {
    var el = document.getElementById('lightbox');
    if (el) el.hidden = true;
  }

  function stepLightbox(d) {
    if (!lbShots.length) return;
    lbIdx = (lbIdx + d + lbShots.length) % lbShots.length;
    renderLightbox();
  }

  // ---- Wiring ---------------------------------------------------------
  document.addEventListener('DOMContentLoaded', function () {
    updateCartCount();
    renderFilters();
    renderStats();
    renderGrid('All', '');
    renderDetail();
    renderCheckoutPage();

    var activeCat = 'All';
    var search = document.getElementById('storeSearch');

    var filterRow = document.getElementById('filterRow');
    if (filterRow) filterRow.addEventListener('click', function (e) {
      var chip = e.target.closest('.filter-chip');
      if (!chip) return;
      var chips = filterRow.querySelectorAll('.filter-chip');
      for (var i = 0; i < chips.length; i++) chips[i].classList.remove('active');
      chip.classList.add('active');
      activeCat = chip.getAttribute('data-cat');
      renderGrid(activeCat, search ? search.value : '');
    });

    if (search) search.addEventListener('input', function () {
      renderGrid(activeCat, search.value);
    });

    // "Add" on a grid card: add default tier, don't follow the card link.
    document.addEventListener('click', function (e) {
      var dl = e.target.closest('[data-download]');
      if (dl) {
        e.preventDefault();
        e.stopPropagation();
        window.open(dl.getAttribute('data-download'), '_blank', 'noopener');
        return;
      }
      var add = e.target.closest('[data-add]');
      if (add) {
        e.preventDefault();
        e.stopPropagation();
        var p = byId(add.getAttribute('data-add'));
        if (p) {
          var t = (p.tiers && p.tiers[0]) || { name: 'License', price: p.price };
          addToCart(p.id, t.name, t.price);
          openCart();
        }
        return;
      }
      var rm = e.target.closest('[data-rm]');
      if (rm) { removeFromCart(rm.getAttribute('data-rm')); renderCartBody(); return; }
      if (e.target.id === 'clearCart') { writeCart([]); renderCartBody(); return; }
      if (e.target.id === 'goCheckout') { location.href = 'checkout.html'; return; }
    });

    var cartBtn = document.getElementById('btnCart');
    if (cartBtn) cartBtn.addEventListener('click', openCart);

    var closeBtn = document.getElementById('modalClose');
    if (closeBtn) closeBtn.addEventListener('click', closeModal);
    var overlay = document.getElementById('modalOverlay');
    if (overlay) overlay.addEventListener('click', function (e) {
      if (e.target === overlay) closeModal();
    });
    document.addEventListener('keydown', function (e) {
      var lb = document.getElementById('lightbox');
      var lbOpen = lb && !lb.hidden;
      if (e.key === 'Escape') { closeLightbox(); closeModal(); return; }
      if (lbOpen && e.key === 'ArrowLeft') stepLightbox(-1);
      if (lbOpen && e.key === 'ArrowRight') stepLightbox(1);
    });
  });
})();
