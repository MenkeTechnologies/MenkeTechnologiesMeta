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
      id: 'zmusic',
      name: 'zmusic',
      glyph: 'MU',
      category: 'Desktop Apps',
      badge: 'WIP',
      tagline: 'A Melodics superset in Rust behind a cyberpunk HUD — a play-along instrument trainer for keys, pads, and drums that ships 142 lessons AND takes YOUR OWN MIDI and audio files, instead of a closed subscription content library: drop in a file, get a chart, play it on your controller. The bundled lessons are real .mid files — scales and chord progressions plus house, techno, trance, disco, funk, hip-hop, trap, breakbeat, drum & bass, UK garage, dubstep, afro house, latin, hardstyle and downtempo — each with a backing track rendered from the same chart at the same tempo, so audio and grading targets align by construction. Charts are zpwr-clip-engine ClipSeq patterns — the same grid and sequencer engine as zpwr-daw, not a second note format — and a JUCE audio sidecar owns the scoring clock so MIDI input and the playhead share one process. Chord drills, dynamic difficulty, practice speed and Wait Mode, star paths and take history sit on top. Its pure-Rust zmusic-core engine is extracted so the same trainer embeds inside the other MenkeTechnologies apps. In development.',
      pills: ['Tauri v2', 'JUCE sidecar', 'Keys · pads · drums', 'Embeddable core'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'ztorrent',
      name: 'ztorrent',
      glyph: 'BT',
      category: 'Desktop Apps',
      badge: 'WIP',
      tagline: 'A from-scratch BitTorrent client in Rust behind a cyberpunk HUD, modeled on Transmission at 97.4% of its 114-feature surface — torrents, files, peers, trackers, and labels, plus the policy layer that sits above the wire: a download/seed queue, ratio and idle seeding limits, the alt-speed (turtle) scheduler, blocklists in every format the public providers ship, and watch folders with their own options. A second report tracks what the other clients do — categories and saved views, RSS feeds with regex and episode rules, super-seeding, disk preallocation, play-while-downloading — at 76.7% of 86 features. Byte-exact bencode means the info-hash is taken from the original info bytes, and a Transmission RPC compatibility layer answers in Transmission\'s own envelope over HTTP or HTTPS, so transmission-remote and the phone apps drive it unchanged. Its pure-Rust ztorrent-core engine is extracted so the same client embeds inside the other MenkeTechnologies apps. In development.',
      pills: ['Tauri v2', 'Rust', 'Transmission RPC', 'Embeddable core'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'zlatex',
      name: 'zlatex',
      glyph: 'LX',
      category: 'Desktop Apps',
      badge: 'WIP',
      tagline: 'A from-scratch LaTeX editor in Rust behind a cyberpunk HUD — source on the left, typeset pages on the right, with no TeX distribution behind the curtain. The whole typesetter is implemented here: the tokenizer and macro expander, a text mode that reads a document (preamble, sectioning, lists, tables, floats, cross-references, citations, bibliography), Knuth-Plass line breaking, page building, and math layout whose parameters come from the face\'s own OpenType MATH table rather than hardcoded. Every glyph carries the byte span of the source that produced it, so clicking the preview selects the source. A document exports as a multi-page PDF that carries its own LaTeX source, so dropping it back in re-opens editable source. Its pure-Rust zlatex-core engine is extracted so the same typesetter embeds inside the other MenkeTechnologies apps. In development.',
      pills: ['Tauri v2', 'Rust', 'Documents + math', 'No TeX install'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'zpdf',
      name: 'zpdf',
      glyph: 'P',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A from-scratch PDF editor that replaces Adobe Acrobat and macOS Preview — 293 catalogued features, all 293 implemented: full document editing, annotation & markup, AcroForms fill/flatten, digital & certificate signatures, OCR, redaction, page management (merge/split/extract/rotate/crop), convert/export, compare, accessibility tagging and PDF/UA preflight, optimize and print production, and Action Wizard batch automation — in Rust behind a cyberpunk HUD, with a CLI beside the GUI. It also does what no competitor does: a content-addressed Merkle version-control DAG living inside the .pdf itself, with log / diff / blame / bisect and three-way branch merges, no sidecar and no server. Its pure-Rust zpdf-core engine is extracted so it embeds inside the other apps.',
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
      tagline: 'A from-scratch image editor that replaces GIMP, Photoshop and Illustrator — in Rust behind a cyberpunk HUD. The raster side is 295 of 302 catalogued Photoshop features (97.7%): layers with blend modes, selections and masks, brushes, filters, non-destructive adjustment layers, 8/16/32-bit pixels, and PSD/XCF I/O. The vector side is a separate Illustrator port — 46 features, 32 vec.* commands over f64 Bézier geometry and an anti-aliased rasterizer — that renders into the same layer stack, so masks, blend modes and project save apply to vector artwork too. Its pure-Rust zphoto-core engine is extracted so it embeds inside the other apps.',
      pills: ['Tauri v2', 'Rust', 'Raster + vector', 'Embeddable core'],
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
      tagline: 'A from-scratch email client in Rust behind a cyberpunk HUD — 100% coverage of the Thunderbird feature surface plus a cross-client layer ported from Gmail, Apple Mail, Outlook, ProtonMail, Hey, Spark and Superhuman: IMAP IDLE / POP3 / SMTP with browser OAuth2 sign-in, OpenPGP crypto, CardDAV contacts, Sieve export, snooze and send-later, an offline Sender Identity Firewall that flags impersonation and account takeover, and a BLAKE3 attachment revision ledger that finds who is holding a stale copy. Its pure-Rust zemail-core engine is extracted so the same mail engine embeds inside the other MenkeTechnologies apps.',
      pills: ['Tauri v2', 'Rust', 'Desktop mail', 'Embeddable core'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'zstation',
      name: 'zstation',
      glyph: 'ST',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A workspace of isolated web apps in Rust behind a cyberpunk HUD — a from-scratch port of the defunct station.app. One window arranges Slack, Gmail, Discord, Notion, Linear, Claude and any site as Trello-like draggable tiles, each running in its OWN native, session-isolated webview so logging into one never spills cookies or storage into another (something an iframe fundamentally cannot do). Its pure-Rust zstation-core engine is extracted so the same station board embeds inside the other MenkeTechnologies apps.',
      pills: ['Tauri v2', 'Rust', 'Isolated webviews', 'Embeddable core'],
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
      tagline: 'A from-scratch office suite in Rust — documents, spreadsheets, presentations, drawings, formulas and databases — behind a cyberpunk HUD, replacing Microsoft Office and LibreOffice: 236 of 245 catalogued features implemented, reading and writing ODF + OOXML plus legacy .doc/.xls/.ppt and .rtf, with formula evaluation, page rendering and PDF export. It also makes office files real-VCS citizens — zmerge is a git merge driver that reconciles parsed document models, zblame attributes every paragraph to the revision that changed it, and Calc computes its own recalculation critical path and keystone cell. Its pure-Rust zoffice-core engine is extracted so the same office engine embeds inside the other MenkeTechnologies apps.',
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
      tagline: 'A real-time event-translation desktop app in pure Rust — also embeddable as a routing engine inside other apps. Bridges 20+ trigger sources — MIDI, OSC, Art-Net/sACN DMX, RTP-MIDI, MIDI clock/MTC/MMC, Ableton Link, serial, USB-HID, gamepad, audio, CV/gate, HTTP, TCP, WebSocket, MQTT, cron, system events, file watchers — to outgoing actions: MIDI/OSC/DMX out, keystroke, mouse, AppleScript, timers, HTTP/MQTT/WebSocket/TCP, speech, clipboard, or a host command. Each translator runs a rules script on a signed-32-bit integer VM; 71.9% of the BOME MIDI Translator Pro surface plus 65 superset extensions BOME does not ship, with .bmtp import/export.',
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
      tagline: 'A from-scratch reference manager in Rust behind a cyberpunk HUD, replacing Zotero at 96.6% of its feature surface — all 37 item types, nested collections, tags, saved searches, group libraries; bibliographies and in-text citations in APA / MLA / Chicago / IEEE / Vancouver / Harvard / AMA / Nature or any loaded .csl; BibTeX / BibLaTeX / RIS / CSL-JSON / EndNote / MODS / MARCXML / Zotero-RDF import-export; DOI / ISBN / PMID / arXiv lookup; duplicate detection with merge preview; serverless CRDT library sync; citation-aware .docx 3-way merge; quote & locator attestation; and a citation Language Server for .tex / .md / .qmd / .typ. Its pure-Rust zcite-core engine is extracted so the same reference engine embeds inside the other MenkeTechnologies apps.',
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
      tagline: 'A from-scratch API client in Rust behind a cyberpunk HUD, replacing Postman at 92.2% of its feature surface — workspaces, collections, and requests; environments, variables, cookies, and eight auth schemes through AWS SigV4 and Hawk; HTTP execution with history and per-request response restore; a collection runner with CSV/JSON data files; native pm.* test assertions; code generation to 16 targets; curl / Postman / OpenAPI / HAR / Insomnia / Bruno / HTTPie import; a GraphQL Explorer, an OAuth 2.0 token manager, a response-diff panel and a Tools workbench of stateless utilities. Its pure-Rust zreq-core engine is extracted so the same request engine embeds inside the other MenkeTechnologies apps.',
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
      tagline: 'A from-scratch VPN client in Rust behind a cyberpunk HUD, replacing Tunnelblick and going past it — OpenVPN (system binary + management interface) and WireGuard connections, configs, process control, logs, stats, and credentials, plus kill switch, split tunneling, split DNS, leak protection, multi-hop, obfuscation, a server catalog and a connection scheduler. Around the engine sit four host-network benches (diagnostics, TLS/DoH/MTU/speed tools, LAN scan, live monitor), an SSH port-forward manager, and an interface-less WireGuard handshake probe that validates a config without connecting. macOS and Linux. Its pure-Rust ztunnel-core engine is extracted so the same VPN engine embeds inside the other MenkeTechnologies apps.',
      pills: ['Tauri v2', 'Rust', 'OpenVPN · WireGuard', 'Embeddable core'],
      price: 20,
      tiers: [
        { name: 'Personal', desc: 'Single user, all platforms; updates within this major version', price: 20 },
      ],
    },
    {
      id: 'zthrottle',
      name: 'zthrottle',
      glyph: 'ZT',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A from-scratch system stress & benchmark tool in Rust behind a cyberpunk HUD — disk, network, CPU, and memory throughput/IOPS benchmarks that go beyond single-axis tools like Blackmagic Disk Speed Test with a world-first contention profiler: it drives every subsystem at once and reports the interaction matrix and bottleneck-migration timeline. It also carries a full system monitor: processes with signal control, per-interface network history and live flows, and a persistent storage tree — a SQLite directory index built by one full scan and then kept live by filesystem hooks (no re-walk), with junk detection and a "what can I free?" reclaim view. Its pure-Rust zthrottle-core engine is extracted so the same engine embeds inside the other MenkeTechnologies apps.',
      pills: ['Tauri v2', 'Rust', 'Benchmarks + contention', 'System monitor + storage'],
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
      tagline: 'A from-scratch launcher in Rust behind a cyberpunk HUD, replacing Alfred — workflows (objects + connections), Script Filter feedback, fuzzy matching, variable/token expansion, web searches, clipboard history with paste-to-front-app, and snippets with auto-expansion, plus an inline developer/productivity keyword surface (hash · hmac · jwt · cron · unit · ip · regex · json2csv · qr · screenshot · kill), a keyword-free smart query router, engine-sourced system actions, and four matcher-introspection panes that replay zgo\'s own ranking function. Its pure-Rust zgo-core engine is extracted so the same launcher engine embeds inside the other MenkeTechnologies apps.',
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
      tagline: 'A from-scratch file-transfer client in Rust behind a cyberpunk HUD, replacing Cyberduck — bookmarks and connections over FTP / FTPS / SFTP / SCP / WebDAV plus S3, Google Cloud Storage, Azure, Backblaze B2, Swift, Google Drive, Dropbox, OneDrive and Box; .duck / FileZilla / WinSCP bookmark import; Bonjour LAN discovery; a session manager; a download / upload / sync transfer queue; per-session logs and throughput; and OS-keychain credentials. On top of that sit four world-firsts no transfer client has: Hydra Swarm Fetch (one file pulled in disjoint ranges from mirrors on different protocols at once), Swarm Replicate (quorum broadcast upload with read-back Merkle proofs), Swarm Consensus Audit (per-block majority vote across replicas plus a minimal block-level heal plan) and Erasure Dispersal (Reed-Solomon k+m shards scattered across heterogeneous endpoints, rebuildable from any k). Its pure-Rust zftp-core engine is extracted so the same transfer engine embeds inside the other MenkeTechnologies apps.',
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
      id: 'zwire',
      name: 'zwire',
      glyph: 'ZW',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A Chromium/Blink browser forked into a cyberpunk tiling HUD — a 27-patch C++ source fork that restyles the native chrome (tab shapes, UI font, neon toolbar, omnibox, 8 schemes in the color mixer + DevTools) and compiles a browser-wide audio engine into the audio service, plus a full keyboard-driven workspace: a tmux-style tiling overlay (ztmux), a ⌘K command palette, vim navigation, durable named sessions, stryke lifecycle hooks, output triggers, pane pipelines, and 23 HUD pages that reimplement Chrome\'s own internal pages. Free and open source.',
      pills: ['Chromium fork', 'Tiling HUD', 'ztmux + ⌘K', 'Browser-wide audio', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/zwire/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/zwire',
    },
    {
      id: 'zpwr-synth',
      name: 'zpwr-synth',
      glyph: 'S',
      category: 'Audio Plugins',
      badge: 'WORLD FIRST',
      tagline: 'Part of the first fully-modular patch-graph audio plugin quartet (with zpwr-daw) to pair free patch-graph wiring with a no-cable knob panel, one-click EZ auto-wiring, and stereo-mirror + offset-preserving stereo link. A fully modular patch-graph synthesizer built on JUCE — each voice is a free patch graph of 309 voice modules (VA/wavetable/FM/additive/supersaw/Karplus oscillators, filters, ADSR/LFO/S&H, VCA) merged with the shared 3,366-block audio pack, unlimited layers, plus a master + unlimited-aux FX-bus rack. 3,675 blocks in all. Shipping as VST3, AU, CLAP, and Standalone.',
      pills: ['JUCE', 'VST3/AU/CLAP/Standalone', 'Fully modular', 'macOS/Linux/Win'],
      price: 149,
      tiers: [
        { name: 'Personal', desc: 'Single user, all formats', price: 149 },
        { name: 'Studio', desc: 'Commercial use; updates within this major version', price: 299 },
      ],
      docs: [
        { label: 'Manual (PDF)', desc: 'The zpwr-synth manual — per-module node & parameter reference for the modular voice engine, generated from the live registry.', url: 'docs/zpwr-synth-reference.pdf' },
        { label: 'Block Catalog (PDF)', desc: 'Every DSP block zpwr-synth ships — 3,675 blocks across 18 categories: its 309 voice modules plus the shared 3,366-block audio pack, 194 of them component-level analog-circuit models.', url: 'docs/zpwr-synth-block-catalog.pdf' },
        { label: 'Full Catalog (PDF)', desc: 'The complete shared patch-graph reference — every block across all four plugins (zpwr-synth, zpwr-fx, zpwr-midi-fx, zpwr-daw), with an alphabetical index.', url: 'docs/zpwr-patch-core-block-catalog.pdf' },
      ],
    },
    {
      id: 'zpwr-fx',
      name: 'zpwr-fx',
      glyph: 'F',
      category: 'Audio Plugins',
      badge: 'WORLD FIRST',
      tagline: 'Part of the first fully-modular patch-graph audio plugin quartet (with zpwr-daw) to pair free patch-graph wiring with a no-cable knob panel, one-click EZ auto-wiring, and stereo-mirror + offset-preserving stereo link. A fully modular patch-graph effects plugin built on JUCE — wire 3,366 DSP modules (including 189 component-level analog-circuit models) into your own algorithms, with a per-param mod matrix and EZ-wire auto-routing. Shipping as VST3, AU, CLAP, and Standalone.',
      pills: ['JUCE', 'VST3/AU/CLAP/Standalone', '3,366 modules', '189 analog models'],
      price: 79,
      tiers: [
        { name: 'Personal', desc: 'Single user, all formats', price: 79 },
        { name: 'Studio', desc: 'Commercial use; updates within this major version', price: 89 },
      ],
      docs: [
        { label: 'Manual (PDF)', desc: 'The zpwr-fx manual — shared-engine architecture overview + per-module node & parameter reference, generated from the live registry.', url: 'docs/zpwr-fx-reference.pdf' },
        { label: 'Block Catalog (PDF)', desc: 'Every DSP block zpwr-fx ships — the full 3,366-block audio patch-graph pack incl. 189 analog-circuit models.', url: 'docs/zpwr-fx-block-catalog.pdf' },
        { label: 'Full Catalog (PDF)', desc: 'The complete shared patch-graph reference — every block across all four plugins (zpwr-synth, zpwr-fx, zpwr-midi-fx, zpwr-daw), with an alphabetical index.', url: 'docs/zpwr-patch-core-block-catalog.pdf' },
      ],
    },
    {
      id: 'zpwr-midi-fx',
      name: 'zpwr-midi-fx',
      glyph: 'M',
      category: 'Audio Plugins',
      badge: 'WORLD FIRST',
      tagline: 'Part of the first fully-modular patch-graph audio plugin quartet (with zpwr-daw) to pair free patch-graph wiring with a no-cable knob panel, one-click EZ auto-wiring, and stereo-mirror + offset-preserving stereo link. A fully modular MIDI-effects plugin built on JUCE — the same free patch-graph engine as zpwr-fx, instantiated on the note stream: 563 modules across 11 categories (arp, chord, scale, Euclidean/generative seq, humanize, remap, cellular-automaton and number-theory sequencers) wired into your own MIDI algorithm. Shipping as VST3, AU, CLAP, and Standalone.',
      pills: ['JUCE', 'VST3/AU/CLAP/Standalone', 'Fully modular', '563 modules'],
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
      pills: ['Rust', '351-opcode VM', 'Rayon', 'Free / OSS'],
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
      tagline: 'Emacs Lisp in Rust — run .el outside Emacs. A Lisp-2 obarray (separate value/function cells) with dynamic binding and an elisp-correct reader on its own ElispHost value model, lowered onto the fusevm bytecode VM (the engine behind stryke, zshrs, awkrs, and vimlrs). Standalone elisp binary with a REPL, an LSP language server, a DAP debugger, and an AOT native compiler. Free and open source.',
      pills: ['Rust', 'Emacs Lisp', 'fusevm', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/elisprs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/elisprs',
    },
    {
      id: 'pythonrs',
      name: 'pythonrs',
      glyph: 'PY',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'Python in Rust — run .py outside CPython. Python as a fusevm frontend (lex/parse → AST → fusevm bytecode) on a PyHost object heap, no bespoke VM or JIT — the first compiled standalone Python runtime, on the shared bytecode VM + Cranelift JIT behind stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, and arb. Standalone python binary with an LSP language server, a DAP debugger, an AOT native compiler, and a transparent rkyv bytecode cache. Free and open source.',
      pills: ['Rust', 'Python', 'fusevm', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/pythonrs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/pythonrs',
    },
    {
      id: 'phplang',
      name: 'phplang',
      glyph: 'PH',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'PHP in Rust — run .php outside the Zend engine. PHP as a fusevm frontend (lex/parse → AST → fusevm bytecode) on a PhpHost object heap, no bespoke VM or JIT — the first compiled standalone PHP runtime, on the shared bytecode VM + Cranelift JIT behind stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb, and pythonrs. Standalone php binary with an LSP language server and DAP debugger, zsh completion, man pages, and an HTML docs site. Free and open source.',
      pills: ['Rust', 'PHP', 'fusevm', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/phplang/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/phplang',
    },
    {
      id: 'node-js',
      name: 'node-js',
      glyph: 'JS',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'JavaScript in Rust — a compiled standalone JavaScript runtime. JS as a fusevm frontend (lex/parse → AST → fusevm bytecode) on the shared bytecode VM + Cranelift JIT behind stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb, pythonrs, and php. Standalone node binary with an LSP language server and DAP debugger, zsh completion, man pages, and an HTML docs site. Free and open source.',
      pills: ['Rust', 'JavaScript', 'fusevm', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/node-js/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/node-js',
    },
    {
      id: 'javars',
      name: 'javars',
      glyph: 'JV',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'Java in Rust — a compiled standalone Java runtime with no JVM. Java as a fusevm frontend (lex/parse → AST → fusevm bytecode) on the shared bytecode VM + Cranelift JIT behind stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb, pythonrs, php, and js. Free and open source.',
      pills: ['Rust', 'Java', 'fusevm', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/javars/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/javars',
    },
    {
      id: 'kotlinrs',
      name: 'kotlinrs',
      glyph: 'KT',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'Kotlin in Rust — the first compiled standalone Kotlin runtime with no JVM. Kotlin as a fusevm frontend (lex/parse → AST → fusevm bytecode) on the shared bytecode VM + Cranelift JIT behind stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb, pythonrs, php, and js. Free and open source.',
      pills: ['Rust', 'Kotlin', 'fusevm', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/kotlinrs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/kotlinrs',
    },
    {
      id: 'scalars',
      name: 'scalars',
      glyph: 'SC',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'Scala in Rust — a compiled standalone Scala runtime with no JVM. Scala as a fusevm frontend (lex/parse → AST → fusevm bytecode) on the shared bytecode VM + Cranelift JIT behind stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb, pythonrs, php, and js. Free and open source.',
      pills: ['Rust', 'Scala', 'fusevm', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/scalars/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/scalars',
    },
    {
      id: 'groovyrs',
      name: 'groovyrs',
      glyph: 'GR',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'Groovy in Rust — the first compiled standalone Groovy runtime with no JVM. Groovy as a fusevm frontend (lex/parse → AST → fusevm bytecode) on the shared bytecode VM + Cranelift JIT behind stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb, pythonrs, php, and js. Free and open source.',
      pills: ['Rust', 'Groovy', 'fusevm', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/groovyrs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/groovyrs',
    },
    {
      id: 'rlang',
      name: 'rlang',
      glyph: 'RL',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'R in Rust — run .R outside GNU R. R as a fusevm frontend (lex/parse → AST → fusevm bytecode) on the shared bytecode VM + Cranelift JIT: every value is a vector with attributes on an RHost heap, so recycling, NA propagation, three-valued logic, and copy-on-modify are the runtime semantics themselves. All four index forms, closures and <<-, S3 UseMethod, 239 primitives and 20 operators — checked byte-for-byte against GNU R by a differential parity harness. Standalone Rscript binary + REPL, an LSP language server, a DAP debugger, inline-Rust FFI (.rust / .Call), and a transparent rkyv bytecode cache. Free and open source.',
      pills: ['Rust', 'R', 'fusevm', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/rlang/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/rlang',
    },
    {
      id: 'go-rs',
      name: 'go-rs',
      glyph: 'GO',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'Go in Rust — run Go with no garbage collector and no go toolchain. Go as a fusevm frontend (lex with automatic semicolon insertion / parse → AST → fusevm bytecode) on the shared bytecode VM + Cranelift JIT behind stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb, pythonrs, php, js, and rlang. No bespoke VM and no gc. Goroutines, channels, select, generics, defer/panic/recover, pointers, interfaces, type switches and variadics all run — goroutines on fusevm\'s cooperative scheduler, one VM per goroutine over a shared heap. Standalone go binary with an LSP language server, a DAP debugger, inline rust {} FFI, and corpus-driven docs. Free and open source.',
      pills: ['Rust', 'Go', 'fusevm', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/go-rs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/go-rs',
    },
    {
      id: 'tclrs',
      name: 'tclrs',
      glyph: 'TC',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'Tcl in Rust — run Tcl with no tclsh. Tcl as a fusevm frontend (parsed once, resolving every substitution the grammar permits → fusevm bytecode) on the shared bytecode VM + Cranelift JIT behind stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb, pythonrs, php, js, rlang, and go-rs. No bespoke VM and no dual-representation object model: a braced if / while / for body or braced expr compiles once instead of being re-parsed on every evaluation. Standalone tclrs binary with a line-editing REPL, --aot native executables, and a differential suite that runs every case under tclsh and compares byte for byte. Free and open source.',
      pills: ['Rust', 'Tcl', 'fusevm', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/tclrs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/tclrs',
    },
    {
      id: 'zvcs',
      name: 'zvcs',
      glyph: 'ZV',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'A git-shadowing superset VCS — a single Rust binary named git that replaces stock git on PATH and serves 181 subcommands natively over vendored gitoxide, with no fork/exec of stock git and no fallthrough. On top of git compatibility it adds 117 coordination verbs git structurally cannot have: a fair FIFO index-lock daemon in place of the O_EXCL lockfile, submodule reconcile that leaves HEAD attached, and forward-only gitlink bumps — built for a meta-repo of nested submodules driven by many concurrent automated agents. Free and open source.',
      pills: ['Rust', 'gitoxide', 'Git superset', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/zvcs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/zvcs',
    },
    {
      id: 'rubyrs',
      name: 'rubyrs',
      glyph: 'RB',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'Ruby in Rust — a compiled Ruby runtime. Ruby source is lexed and parsed to an AST, lowered to fusevm bytecode, and run on the same bytecode VM + three-tier Cranelift JIT behind zshrs, stryke, awkrs, and elisprs; arithmetic lowers to native VM ops while dispatch, blocks, and objects are served by a thread-local runtime host. Free and open source.',
      pills: ['Rust', 'Ruby', 'fusevm JIT', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/rubyrs/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/rubyrs',
    },
    {
      id: 'arb',
      name: 'arb',
      glyph: 'ar',
      category: 'Developer Tools',
      badge: 'WORLD FIRST',
      tagline: 'A TUI for every pipeline. Pipe any Unix stream into arb and it spawns a dynamic full-screen TUI (and, later, a web page) built from a declarative, Tcl/Tk-flavored spec — a jq/xpath/css/yq superset, an interactive megafilter/map over the live passthrough, running on the fusevm bytecode VM + Cranelift JIT. Free and open source.',
      pills: ['Rust', 'pipeline TUI', 'fusevm JIT', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MIT licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/arb/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/arb',
    },
    {
      id: 'zmax',
      name: 'zmax',
      glyph: 'EM',
      category: 'Developer Tools',
      badge: 'NEW',
      tagline: 'A zero-configuration modal CLI IDE in Rust — a Vim / Emacs / Spacemacs / JetBrains superset in one static binary: LSP, a DAP debugger, tree-sitter, a fuzzy file picker, a project tree, a real PTY terminal, magit-style git, and run configs, all working on first launch with no init.el and no plugin manager. It embeds 12 scripting interpreters — elisp, vimscript, awk, zsh, stryke, ruby, php, python, node, arb, tcl and R — as pure-Rust crates sharing one host API with no FFI between them, and :xpipe chains them in-process with no fork. A windowed GUI build ships as zmax-gui. Free and open source.',
      pills: ['Rust', 'Modal IDE', '12 embedded languages', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MPL-2.0 licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/zmax/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/zmax',
      docs: [
        { label: 'Reference (PDF)', desc: 'The complete zmax reference — every keybinding by mode, the full IDE configuration schema, every typable : command, every static command with its default keys, and the language-support matrix. Generated from the source.', url: 'docs/zmax-reference.pdf' },
      ],
    },
    {
      id: 'zmax-gui',
      name: 'zmax-gui',
      glyph: 'EG',
      category: 'Desktop Apps',
      badge: 'NEW',
      tagline: 'A native desktop GUI for the zmax IDE â wraps the zmax modal-editing core in a windowed front-end the way MacVim wraps Vim: a 21-menu menu bar, toolbar, ⌘K palette, context menu, drag-and-drop, and native open/save dialogs, every action bridged into the editor as an ex-command. On top of the MacVim surface it adds an IDE project workbench (quick open, find-in-files, project search & replace, go-to-symbol, find-definition, TODO markers, git blame / history / stage / branches / stash / commit graph) â and it searches and git-blames binary documents (docx / odt / xlsx / ods / pptx / odp / pdf) in-process, at document addresses like Sheet1!B14 and p. 7, with no pandoc or unoconv anywhere. Free and open source.',
      pills: ['Rust', 'GUI editor', 'Emacs / Spacemacs', 'Free / OSS'],
      price: 0,
      tiers: [
        { name: 'Open Source', desc: 'MPL-2.0 licensed', price: 0 },
      ],
      download: 'https://github.com/MenkeTechnologies/zmax-gui/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/zmax-gui',
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
      id: 'htoprs', name: 'htoprs', glyph: 'ht', category: 'CLI Tools', badge: 'FREE',
      tagline: 'A from-source Rust port of htop 3.5.1 — the interactive process viewer reimplemented function-for-function against the vendored htop C source, not a wrapper: process tree, per-core CPU/memory/swap meters, sort/filter/search/tag, signal sending, renice. Every fn under src/ported/ cites its &lt;File&gt;.c:&lt;line&gt; origin and a build gate rejects any Rust fn with no C counterpart. 1069 of 1093 C functions ported (97.8%) across 130 of the 131 C files, 1 stub left; the TUI runs on macOS and Linux. v0.5.12, MIT.',
      pills: ['Rust', 'htop port', 'MIT / OSS'], price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/htoprs/tags',
      repo: 'https://github.com/MenkeTechnologies/htoprs',
    },
    {
      id: 'grcrs', name: 'grcrs', glyph: 'gr', category: 'CLI Tools', badge: 'FREE',
      tagline: 'A from-source Rust port of grc (Generic Colouriser 1.13) — the two-binary suite grc (the wrapper: parses options, matches the command line against grc.conf regexps, runs the command and pipes its stdout/stderr through grcat, with --pty mode) plus grcat (the colouriser filter driving the per-command config rules), ported against the upstream grc sources rather than wrapping them. MIT — original Rust code.',
      pills: ['Rust', 'grc port', 'MIT / OSS'], price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/grcrs/tags',
      repo: 'https://github.com/MenkeTechnologies/grcrs',
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
      id: 'ztmux', name: 'ztmux', glyph: 'zx', category: 'CLI Tools', badge: 'FREE',
      tagline: 'The world\'s first 100%-functional tmux in Rust — a from-source port of the whole program (server + client), not a wrapper or control-mode client: the grid/screen model, the VT input parser, layouts, the command language, formats, and the terminal back end, reimplemented in memory-safe Rust and diffed byte-for-byte against the upstream tmux C source of truth — 1194/1194 parity cases passing. MIT-licensed.',
      pills: ['Rust', 'tmux port', 'MIT / OSS'], price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT licensed', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/ztmux/tags',
      repo: 'https://github.com/MenkeTechnologies/ztmux',
    },
    {
      id: 'zdbview', name: 'zdbview', glyph: 'db', category: 'CLI Tools', badge: 'FREE',
      tagline: 'A terminal CRUD editor for rkyv archives and SQLite databases — one binary for both halves of the cache. rkyv archives carry no schema, so eight registered formats are decoded AND edited in place through a validated format registry: add, edit, rename, delete a record, re-serialized byte-identically to what the producing host writes. Unregistered archives fall back to strings + hex; SQLite gets full generic CRUD. Backend chosen by header magic, not filename. MIT.',
      pills: ['Rust', 'rkyv + SQLite', 'MIT / OSS'], price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/zdbview/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/zdbview',
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
      id: 'zwire-host', name: 'zwire-host', glyph: 'wh', category: 'CLI Tools', badge: 'FREE',
      tagline: 'A universal local host — one ~500 KB Rust binary that exposes the machine (sysinfo, PTY terminals, filesystem watch/tail, exec, background jobs, a peered-mesh pub/sub event bus, and a per-app KV store) over both Chrome native-messaging and a newline-JSON local-socket daemon. Also embeddable as a Rust library.',
      pills: ['Rust', 'native host · daemon', 'sysinfo · PTY · FS · exec', 'Free / OSS'], price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT licensed', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/zwire-host/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/zwire-host',
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
      id: 'zmax-book', name: 'The zmax Book', glyph: 'eB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to zmax — the modal IDE with vim, emacs, and Spacemacs keymaps, and the first IDE to embed twelve programming languages (elisp, vimscript, stryke, AWK, zsh, Ruby, PHP, Python, JavaScript, arb, Tcl, R) in its core. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'zmax', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'zmax-native-book', name: 'The zmax-native Book', glyph: 'nP', category: 'Publications', badge: 'COMPANION',
      tagline: 'The plugin guide for zmax — how to write, build, ship and install a native (compiled Rust) editor plugin over the frozen C ABI. Why the boundary is #[repr(C)] function pointers and not a Rust API, what ABI_VERSION refuses and why the refusal is hard; the declare_plugin! macro read as its expansion (the static PluginInfo, the #[no_mangle] init, one extern "C" trampoline per handler); the six host callbacks and the context window that makes them legal; the five SDK examples line by line; then shipping — zmax-native.toml, the package manager, the content-addressed store at ~/.zmax/pkg, publishing an owner/repo plugin — and the rules of the road: TUI safety, panics that abort across FFI, ABI versioning, testing. Closes on an honest inventory of where the API stops. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'zmax-native', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'fusevm-book', name: 'The fusevm Book', glyph: 'fB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to fusevm — the shared bytecode VM behind sixteen language frontends (zshrs, stryke, awkrs, vimlrs, elisprs, rubylang, pythonrs, phplang, node-js, rlang, javars, kotlinrs, scalars, groovyrs, tclrs, arb): the value model, the tiered Cranelift JIT, and the closed-world AOT compiler that lowers a whole program to native registers and a standalone binary. Pandoc + LaTeX typeset.',
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
      id: 'rubyrs-book', name: 'The rubyrs Book', glyph: 'yB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to rubyrs — Ruby as a fusevm frontend: the lexer and parser, the lowering of Ruby to fusevm bytecode, native arithmetic ops for the JIT versus the RubyHost runtime that serves dispatch, blocks, and object construction, and the differential parity harness against real Ruby. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'rubyrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'pythonrs-book', name: 'The pythonrs Book', glyph: 'PB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to pythonrs — Python as a fusevm frontend: the indentation-aware lexer and parser, the lowering of Python to fusevm bytecode, native arithmetic ops for the JIT versus the PyHost runtime that serves dispatch, comprehensions, and object construction, and the differential parity harness against CPython. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'pythonrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'rlang-book', name: 'The rlang Book', glyph: 'Rb', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to rlang — R as a fusevm frontend: a compiled R runtime that lowers R to bytecode on the shared VM with a three-tier Cranelift JIT instead of walking a parse tree. The vector value model with no scalars, copy-on-modify semantics, three-valued logic and NA propagation, S3 dispatch, AOP intercepts, the AOT native-executable and inline-Rust FFI paths, the wasm build, and the differential parity harness against GNU R. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'rlang', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'zvcs-book', name: 'The zvcs Book', glyph: 'ZV', category: 'Publications', badge: 'COMPANION',
      tagline: 'The companion book to zvcs — a git-shadowing superset VCS: the shadow `git` binary, the per-repo zdaemon FIFO coordinator that replaces index.lock\'s O_EXCL flock with a fair arrival-order queue, RepoLock\'s RAII client, the zsync/zbump submodule discipline, and the vendored gitoxide engine underneath. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'zvcs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'phplang-book', name: 'The phplang Book', glyph: 'HB', category: 'Publications', badge: 'COMPANION',
      tagline: 'The companion book to phplang — PHP as a fusevm frontend and the first compiled standalone PHP runtime (no Zend engine): the dual-mode lexer, the recursive-descent parser, lowering PHP to fusevm bytecode, the PhpHost array/value runtime, the builtin library, and the differential parity harness against PHP. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'phplang', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'phplang-reference', name: 'The phplang Reference', glyph: 'HR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The phplang reference — every PHP keyword, construct, cast, and library function (string / array / math / type / output) the current phplang build recognizes, generated from the language-server corpus with a runnable example each. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'phplang', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'node-js-book', name: 'The node-js Book', glyph: 'JB', category: 'Publications', badge: 'COMPANION',
      tagline: 'The companion book to node-js — JavaScript as a fusevm frontend and a compiled standalone JS runtime: the ASI-aware lexer, the Pratt parser, lowering JS to fusevm bytecode (native arithmetic vs the JsHost object heap), the builtin standard library, and the differential parity harness against Node. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'node-js', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'node-js-reference', name: 'The node-js Reference', glyph: 'JR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The node-js reference — every JavaScript keyword, global, and array / string / number / Math / JSON method the current node-js build recognizes, generated from the language-server corpus with a runnable example each. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'node-js', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'javars-book', name: 'The javars Book', glyph: 'aB', category: 'Publications', badge: 'COMPANION',
      tagline: 'The companion book to javars — Java as a fusevm frontend and a compiled standalone Java runtime (no JVM): the lexer and recursive-descent parser, the single-class main entry model, lowering Java to fusevm bytecode, the host runtime and builtin set, and the DAP debugger. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'javars', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'javars-reference', name: 'The javars Reference', glyph: 'aR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The javars reference — every Java keyword, type, operator, and builtin the current javars build recognizes, generated from the language-server corpus with a runnable example each. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'javars', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'scalars-book', name: 'The scalars Book', glyph: 'cB', category: 'Publications', badge: 'COMPANION',
      tagline: 'The companion book to scalars — Scala as a fusevm frontend and a compiled standalone Scala runtime (no JVM): the newline-inferring lexer, the parser, lowering Scala to fusevm bytecode (the SDIV integer-division op vs native float arithmetic), the host runtime, and the differential parity-fuzz harness against real scala. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'scalars', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'scalars-reference', name: 'The scalars Reference', glyph: 'cR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The scalars reference — every Scala keyword, operator, and builtin the current scalars build recognizes, generated from the language-server corpus with a runnable example each. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'scalars', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'groovyrs-book', name: 'The groovyrs Book', glyph: 'gB', category: 'Publications', badge: 'COMPANION',
      tagline: 'The companion book to groovyrs — Groovy as a fusevm frontend and a compiled standalone Groovy runtime (no JVM): the newline-significant lexer, the script-model parser, lowering Groovy to fusevm bytecode (the GDIV division op, for-in range desugaring), the host runtime, and the differential parity harness against real groovy. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'groovyrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'groovyrs-reference', name: 'The groovyrs Reference', glyph: 'gR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The groovyrs reference — every Groovy keyword, operator, and builtin the current groovyrs build recognizes, generated from the language-server corpus with a runnable example each. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'groovyrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'kotlinrs-book', name: 'The kotlinrs Book', glyph: 'kB', category: 'Publications', badge: 'COMPANION',
      tagline: 'The companion book to kotlinrs — Kotlin as a fusevm frontend and a compiled standalone Kotlin runtime (no JVM): the tokenizer and parser, the top-level fun model, lowering Kotlin to fusevm bytecode (the Int/Double split and integer-division ops), inline Rust FFI via rust { } blocks compiled to a cached cdylib, and the DAP debugger. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'kotlinrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'kotlinrs-reference', name: 'The kotlinrs Reference', glyph: 'kR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The kotlinrs reference — every Kotlin keyword, operator, and builtin the current kotlinrs build recognizes, generated from the language-server corpus with a runnable example each. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'kotlinrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'arb-book', name: 'The arb Book', glyph: 'rB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to arb — the pipeline-to-TUI language on fusevm: pipe any Unix stream in and get a dynamic TUI (and web page) from a declarative, Tcl/Tk-flavored spec. The spec language and widget/source model, the jq/xpath/css/yq query superset, the interactive megafilter/map over the live passthrough, and the fusevm runtime underneath. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'arb', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'arb-reference', name: 'The arb Reference', glyph: 'rR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete arb reference — the pipeline-to-TUI language surface on fusevm: the spec directives, widget and source types, the jq/xpath/css/yq query operators, and the CLI, generated from the live implementation. The dense companion to The arb Book. DRM-free PDF.',
      pills: ['Reference', 'arb', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'arb-registry-book', name: 'The arb-registry Book', glyph: 'iB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to arb-registry — the community package index for arb: a server-less git-index registry on the crates.io-index / homebrew-core model. The index.json format, the arb client (update/search/install/publish), the import resolution chain, package anatomy (arb.toml + .arb modules), and the trust model of a shared JSON index in a git repo. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'arb-registry', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'zterminal-book', name: 'The zterminal Book', glyph: 'tB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to zterminal — the GPU-accelerated, cross-platform terminal emulator in Rust (OpenGL ES glyph-atlas renderer, xterm-compatible VT parsing) with native i3-style tiling, native tmux control over the wire protocol, an embedded-WebView control panel, and a command-palette-driven workflow. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'zterminal', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'powerliners-book', name: 'The powerliners Book', glyph: 'pB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to powerliners — the Rust port of the powerline statusline/prompt renderer: the segment model, the UNIX-socket daemon and its upstream wire protocol, the JSON theme/colorscheme system, and the shell/editor bindings, all with zero Python runtime. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'powerliners', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'desktop-in-rust-book', name: 'Rewriting the Desktop in Rust', glyph: 'dR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The cross-cutting book on the MenkeTechnologies desktop ports — zreq (Postman), zcite (Zotero), ztunnel (Tunnelblick), zgo (Alfred), zftp (Cyberduck), zcontainer (Docker Desktop / Lens), zoffice, zemail, zpdf, and zphoto — and the "engine core, thin shell" architecture they share: pure-Rust *-core engines with a C ABI, embedded across every app behind one Tauri v2 shell and the zgui-core toolkit. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'Architecture', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'the-operator-book', name: 'The Operator', glyph: 'Op', category: 'Publications', badge: 'REFERENCE',
      tagline: 'A working guide to writing software with coding agents. No prompt templates and no tool tutorials — the structure that has to sit around an agent before its output is safe to keep: what you write down before it starts, how you divide work, how you review what comes back, the specific ways it fails, and the discipline that separates a codebase from a pile of plausible code. Includes a full part on what it actually takes to get useful work out of a system optimized to agree with you. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'Method', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'studio-book', name: 'The Studio', glyph: 'St', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The cross-cutting book on the MenkeTechnologies audio stack — zpwr-synth, zpwr-fx, zpwr-midi-fx, and zpwr-daw, plus Audio-Haxor and zwire\'s ported browser audio path — and the two shared cores they stand on: zdsp-core (the shared DSP substrate) and zpwr-patch-core (the signal-agnostic patch graph, one templated engine instantiated for mono, stereo, and MIDI). Covers the mono-to-stereo block reuse, the mono and stereo plugin-host adapters, the voice/layer/MIDI engines, and the shared clip engine. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'Audio / DSP', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'cli-fleet-book', name: 'The CLI Fleet', glyph: 'cF', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The CLI-side companion to "Rewriting the Desktop in Rust" — one compendium mapping every command-line tool in the MenkeTechnologies stack. Full chapters for the tools with no book of their own: lsofrs (lsof), nmaprs (nmap), iftoprs (iftop), htoprs (htop), temprs (a shell temporary-file stack manager), storageshower (disk-usage TUI), zcolorizer (real-time log colouriser), grcrs (grc), and the two browser-adjacent native-messaging host binaries zpwrchrome-host and zwire-host — plus an opening shared-architecture chapter and a cross-reference index to the seven already documented (zshrs, strykelang, awkrs, vimlrs, elisprs, powerliners, ztmux). Every tool is MIT and original Rust; port-honest throughout — each reimplementation names its upstream and the original work is the Rust engineering. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'CLI fleet', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'editor-plugins-book', name: 'Editor Plugins', glyph: 'EP', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The how-to for the three-per-language editor matrix — the VS Code extensions, Emacs major modes, and Vim/Neovim plugins that give every fusevm language (arb, awkrs, vimlrs, elisprs, strykelang, zshrs, ...) first-class editing. Grounded verbatim in the shipped vscode-arb / emacs-arb / vim-arb sources: the shared language-binary contract (--lsp Language Server, --dap Debug Adapter, --check static check), the GUI-PATH binary resolver, the vscode-languageclient --stdio trap that breaks the LSP handshake, TextMate vs font-lock vs Vim-syntax grammars, the one indentation rule expressed three ways, and the run/debug wiring. Closes with a copy-vs-rewrite checklist for stamping out all three plugins for a new language: the wiring is copied, only the grammar is rewritten. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'Editor tooling', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'stryke-ecosystem-book', name: 'The Stryke Ecosystem', glyph: 'sE', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The book on the Stryke connector fleet — the "batteries." The strykelang core ships small; the reach into external systems lives in opt-in packages kept out of the core binary so the daily install stays slim. A full, source-grounded chapter for each of 33 packages: databases (postgres, mysql, mssql, mongo, redis, neo4j, scylla, clickhouse, search), data & analytics (arrow, parquet, polars, duckdb, spark), messaging & RPC (kafka, zmq, grpc), cloud & infrastructure (aws, gcp, azure, k8s, docker), web & automation (scrape, selenium, mcpd, email), documents (office), and foundation (utils, gui) — plus an opening chapter on the shared package model: a thin stryke library plus an in-process cdylib, dlopened on first use, a uniform JSON FFI boundary, and a URL-keyed connection cache. The strykelang reference documents the language; this book documents the batteries. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'Stryke packages', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'zpwr-encyclopedia', name: 'The zpwr Encyclopedia', glyph: 'zE', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete reference to zpwr — the most advanced UNIX terminal environment (500+ subcommands, 2000+ aliases). Every verb, alias, and subsystem, LaTeX-typeset into one volume.',
      pills: ['Encyclopedia', 'zpwr', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'inventions-book', name: 'Firsts', glyph: 'iF', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The narrative edition of the MenkeTechnologies invention ledger — 268 candidate "world\'s first" capabilities across the stack, each with its claim, its in-repo basis, and an honest caveat and confidence tag. From the solo from-scratch JIT VM hosting seventeen language frontends and the compiled Unix shell to the fully modular DAW and the first compiled-native Docker+Kubernetes GUI, with an appendix of adversarial prior-art analyses for five of the eight marquee claims. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'Inventions', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'ztmux-book', name: 'The ztmux Book', glyph: 'xB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to ztmux — the world\'s first 100%-functional tmux in Rust (the whole server + client, not a wrapper or control-mode client): the client/server split and libevent loop, the grid/screen and scrollback model, the VT input parser, the layout engine, the lalrpop command language and its one-file-per-command mirror of tmux\'s cmd-*.c, formats/config/keys, and the terminal back end — plus the port methodology (diffed byte-for-byte against the vendored tmux C source of truth, 1194/1194 parity cases passing) and the anti-drift gate that forbids fake functions. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'ztmux', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'zwire-book', name: 'The zwire Book', glyph: 'wB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to zwire — Chromium/Blink forked into the strykelang cyberpunk HUD (not a WebView wrapper, not a new engine): why a real Blink base is required for zpwrchrome\'s Manifest V3 surface, the 27 authored patches that compile the native chrome — tab shapes, UI font, neon toolbar, omnibox, the 8 schemes in the color mixer + DevTools, and the browser-wide audio engine — the ztmux tiling overlay and ⌘K palette, stryke lifecycle hooks, output triggers, pane pipelines, the 23 HUD pages, the native host, the dedicated profile, and the CDP overlay layer. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'zwire', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'znative-book', name: 'The znative Book', glyph: 'nB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to znative — the zshrs package manager, and the first shell package manager whose unit of installation can be native compiled code rather than shell text. The published, versioned ABI that makes a native plugin safe to install (the znative crate itself carries the plugin ABI, published from the zshrs repo to crates.io — cargo add znative + zmodload -R, #[repr(C)] boundary, ABI_VERSION checked at load); the eight-command surface (load / add / remove / list / info / update, plus gc / clean for the store); source auto-classification (owner/repo · github: · git+URL · path:) with @ref pinning and shallow clone; the content-addressed store at $ZSHRS_HOME/pkg/ with its installed.toml index and sha256 integrity; native-vs-script kind detection, the optional znative.toml manifest, the worked plugin ports (git-fuzzy, fasd, zsh-z, revolver, git-repos, forgit, reveal, kubectl-completion), and the one self-installing .zshrc line the whole workflow collapses to. Global-only, no lockfile — by design. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'znative', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'strykelang-reference', name: 'The strykelang Reference', glyph: 'sR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete strykelang language reference — every builtin, operator, sigil, and pipeline form of the parallel Perl 5 superset, generated from the live implementation. The dense companion to The strykelang Book. DRM-free PDF.',
      pills: ['Reference', 'strykelang', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'zshrs-reference', name: 'The zshrs Reference', glyph: 'zR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete zshrs reference — every builtin, option, parameter flag, and completion primitive of the first compiled Unix shell. The dense companion to The zshrs Book. DRM-free PDF.',
      pills: ['Reference', 'zshrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'zmax-reference', name: 'The zmax Reference', glyph: 'eR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete zmax reference — every command, keymap, and embedded-language entry point of the modal IDE. The dense companion to The zmax Book. DRM-free PDF.',
      pills: ['Reference', 'zmax', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'vimlrs-reference', name: 'The vimlrs Reference', glyph: 'vR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete vimlrs reference — the VimL builtin functions, commands, and options implemented as a fusevm frontend. DRM-free PDF.',
      pills: ['Reference', 'vimlrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'elisprs-reference', name: 'The elisprs Reference', glyph: 'lR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete elisprs reference — the Emacs Lisp subroutines and special forms implemented as a fusevm frontend. DRM-free PDF.',
      pills: ['Reference', 'elisprs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'awkrs-reference', name: 'The awkrs Reference', glyph: 'aR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete awkrs reference — the AWK language surface, builtins, and CLI of the parallel Rust AWK. DRM-free PDF.',
      pills: ['Reference', 'awkrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'rubyrs-reference', name: 'The rubyrs Reference', glyph: 'rR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete rubyrs reference — the Ruby surface of the compiled Ruby runtime on fusevm: builtins, core classes, and the CLI, generated from the live implementation. The dense companion to The rubyrs Book. DRM-free PDF.',
      pills: ['Reference', 'rubyrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'pythonrs-reference', name: 'The pythonrs Reference', glyph: 'PR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete pythonrs reference — the Python surface of the compiled Python runtime on fusevm: builtins, core types, and the CLI, generated from the live implementation. The dense companion to The pythonrs Book. DRM-free PDF.',
      pills: ['Reference', 'pythonrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'rlang-reference', name: 'The rlang Reference', glyph: 'RR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete rlang reference — the R surface of the compiled R runtime on fusevm: primitives, builtins, and the CLI, generated from the live implementation. The dense companion to The rlang Book. DRM-free PDF.',
      pills: ['Reference', 'rlang', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'go-rs-book', name: 'The go-rs Book', glyph: 'GB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to go-rs — Go as a fusevm frontend with no garbage collector: Go source lexed (with automatic semicolon insertion) and parsed, lowered to bytecode on the shared VM with a three-tier Cranelift JIT instead of the go toolchain. The frontend/engine split, functions and call-frame slots, Go int/int truncation and %v formatting, the string numeric hook, and the in-binary tooling — an LSP server, a DAP debugger, inline rust {} FFI, and corpus-driven docs. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'go-rs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'go-rs-reference', name: 'The go-rs Reference', glyph: 'GR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete go-rs reference — the Go surface on fusevm: keywords, operators, builtins, types, and the fmt print family, generated from the language-server corpus so the reference never drifts from the tooling. The dense companion to The go-rs Book. DRM-free PDF.',
      pills: ['Reference', 'go-rs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'tclrs-book', name: 'The tclrs Book', glyph: 'TB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to tclrs — Tcl as a fusevm frontend, compiled rather than re-parsed: the dodekalogue and the two rules that make a compiler worth building, rotated loops and why every loop goes through one emitter, a value model with no object heap, what Tcl\'s boolean rule costs in trace eligibility, lists as strings, arrays-as-variables against dicts-as-values, procedures as frame slots, catch as the one unwinder, coroutines as second VMs over the same chunk, and a tiers chapter that gives the JIT result unrounded — three million iterations in 5.6 ms inside a procedure, 5.8 ms at the top level, and nothing compiled at all when the same loop is written with foreach. It closes on the ledger rather than a claim. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'tclrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'tclrs-reference', name: 'The tclrs Reference', glyph: 'TR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The complete tclrs command reference — every command, ensemble subcommand, expr operator and format conversion the frontend implements, generated rather than written: gen-docs renders each command from the compiler\'s own tables, asks the compiler about each ensemble subcommand and the runtime about each conversion, and prints the expr ladder from the table the parser binds with. A command it lists exists; one it does not is invalid command name. The dense companion to The tclrs Book. DRM-free PDF.',
      pills: ['Reference', 'tclrs', 'DRM-free PDF'], price: 20,
      tiers: [{ name: 'PDF', desc: 'DRM-free PDF download', price: 20 }],
    },
    {
      id: 'zpwr-synth-reference', name: 'The zpwr-synth Reference', glyph: 'yR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The zpwr-synth manual — per-module node and parameter reference for the modular voice engine, generated from the live registry. Free, DRM-free PDF.',
      pills: ['Reference', 'zpwr-synth', 'Free · DRM-free PDF'], price: 0,
      tiers: [{ name: 'PDF', desc: 'Free DRM-free PDF download', price: 0 }],
      download: 'docs/zpwr-synth-reference.pdf',
    },
    {
      id: 'zpwr-fx-reference', name: 'The zpwr-fx Reference', glyph: 'xR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The zpwr-fx manual — shared-engine architecture overview plus per-module node and parameter reference, generated from the live registry. Free, DRM-free PDF.',
      pills: ['Reference', 'zpwr-fx', 'Free · DRM-free PDF'], price: 0,
      tiers: [{ name: 'PDF', desc: 'Free DRM-free PDF download', price: 0 }],
      download: 'docs/zpwr-fx-reference.pdf',
    },
    {
      id: 'zpwr-midi-fx-reference', name: 'The zpwr-midi-fx Reference', glyph: 'mR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The zpwr-midi-fx manual — shared-engine architecture overview plus per-module node and parameter reference, generated from the live registry. Free, DRM-free PDF.',
      pills: ['Reference', 'zpwr-midi-fx', 'Free · DRM-free PDF'], price: 0,
      tiers: [{ name: 'PDF', desc: 'Free DRM-free PDF download', price: 0 }],
      download: 'docs/zpwr-midi-fx-reference.pdf',
    },
    {
      id: 'zpwr-daw-reference', name: 'The zpwr-daw Reference', glyph: 'wR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The zpwr-daw manual — shared-engine architecture overview plus per-module node and parameter reference for the full audio block pack every track wires, generated from the live registry. Free, DRM-free PDF.',
      pills: ['Reference', 'zpwr-daw', 'Free · DRM-free PDF'], price: 0,
      tiers: [{ name: 'PDF', desc: 'Free DRM-free PDF download', price: 0 }],
      download: 'docs/zpwr-daw-reference.pdf',
    },
    {
      id: 'zpwr-clip-engine-reference', name: 'The zpwr Clip-Engine Reference', glyph: 'cR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The zpwr-daw clip-engine reference — the timeline, clip, and playback model behind the DAW. Free, DRM-free PDF.',
      pills: ['Reference', 'zpwr-daw', 'Free · DRM-free PDF'], price: 0,
      tiers: [{ name: 'PDF', desc: 'Free DRM-free PDF download', price: 0 }],
      download: 'docs/zpwr-clip-engine-reference.pdf',
    },
    {
      id: 'zpwr-synth-block-catalog', name: 'zpwr-synth Block Catalog', glyph: 'yC', category: 'Publications', badge: 'CATALOG',
      tagline: 'Every DSP block zpwr-synth ships — 3,675 blocks across 18 categories: its 309 voice modules plus the shared 3,366-block audio pack, 194 of them component-level analog-circuit models. Free, DRM-free PDF.',
      pills: ['Catalog', 'zpwr-synth', 'Free · DRM-free PDF'], price: 0,
      tiers: [{ name: 'PDF', desc: 'Free DRM-free PDF download', price: 0 }],
      download: 'docs/zpwr-synth-block-catalog.pdf',
    },
    {
      id: 'zpwr-fx-block-catalog', name: 'zpwr-fx Block Catalog', glyph: 'xC', category: 'Publications', badge: 'CATALOG',
      tagline: 'Every DSP block zpwr-fx ships — the full 3,366-block audio patch-graph pack across 18 categories, including 189 component-level analog-circuit models. Free, DRM-free PDF.',
      pills: ['Catalog', 'zpwr-fx', 'Free · DRM-free PDF'], price: 0,
      tiers: [{ name: 'PDF', desc: 'Free DRM-free PDF download', price: 0 }],
      download: 'docs/zpwr-fx-block-catalog.pdf',
    },
    {
      id: 'zpwr-midi-fx-block-catalog', name: 'zpwr-midi-fx Block Catalog', glyph: 'mC', category: 'Publications', badge: 'CATALOG',
      tagline: 'Every block zpwr-midi-fx ships — its note-stream module pack (arp, chord, scale, Euclidean/generative seq, humanize, remap). Free, DRM-free PDF.',
      pills: ['Catalog', 'zpwr-midi-fx', 'Free · DRM-free PDF'], price: 0,
      tiers: [{ name: 'PDF', desc: 'Free DRM-free PDF download', price: 0 }],
      download: 'docs/zpwr-midi-fx-block-catalog.pdf',
    },
    {
      id: 'zpwr-patch-core-block-catalog', name: 'The Full Patch-Graph Catalog', glyph: 'pC', category: 'Publications', badge: 'CATALOG',
      tagline: 'The complete shared patch-graph reference — every block across all four plugins (zpwr-synth, zpwr-fx, zpwr-midi-fx, zpwr-daw), with an alphabetical index. Free, DRM-free PDF.',
      pills: ['Catalog', 'zpwr audio', 'Free · DRM-free PDF'], price: 0,
      tiers: [{ name: 'PDF', desc: 'Free DRM-free PDF download', price: 0 }],
      download: 'docs/zpwr-patch-core-block-catalog.pdf',
    },
    {
      id: 'zgui-core-component-catalog', name: 'zgui-core Component Catalog', glyph: 'gC', category: 'Publications', badge: 'CATALOG',
      tagline: 'The zgui-core component catalog — every UI component in the shared GUI toolkit behind the desktop apps. Free, DRM-free PDF.',
      pills: ['Catalog', 'zgui-core', 'Free · DRM-free PDF'], price: 0,
      tiers: [{ name: 'PDF', desc: 'Free DRM-free PDF download', price: 0 }],
      download: 'docs/zgui-core-component-catalog.pdf',
    },
    {
      id: 'gui-automation-bus-book', name: 'The GUI Automation Bus', glyph: 'gB', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The companion book to the GUI Automation Bus — the typed verb-call layer that turns every app\'s existing engine command surface into a scriptable API: one stryke script calls a named verb on any app, in-process or over a local socket, and gets the return value back. Free, DRM-free PDF.',
      pills: ['Reference', 'gui-automation-bus', 'Free · DRM-free PDF'], price: 0,
      tiers: [{ name: 'PDF', desc: 'Free DRM-free PDF download', price: 0 }],
      download: 'docs/gui-automation-bus-book.pdf',
    },
    {
      id: 'gui-automation-bus-reference', name: 'The GUI Automation Bus Reference', glyph: 'gR', category: 'Publications', badge: 'REFERENCE',
      tagline: 'The dense reference for the GUI Automation Bus — the global catalog of every scriptable GUI-Script action across the app fleet: 2819 verbs over 15 apps, read from each app\'s live bus surface rather than hand-written. Free, DRM-free PDF.',
      pills: ['Reference', 'gui-automation-bus', 'Free · DRM-free PDF'], price: 0,
      tiers: [{ name: 'PDF', desc: 'Free DRM-free PDF download', price: 0 }],
      download: 'docs/gui-automation-bus-reference.pdf',
    },
    {
      id: 'zdbview-book', name: 'The zdbview Book', glyph: 'dB', category: 'Publications', badge: 'COMPANION',
      tagline: 'The companion book to zdbview — the terminal inspector and CRUD editor that opens both halves of the cache from one binary. Header-magic detection over filenames, generic CRUD on any SQLite database, and the format registry that makes non-self-describing rkyv archives readable and writable: faithful archive-type copies, magic pre-filter, rkyv validation, structural fallback when nothing matches — plus the atomic write-back path, the TUI state model, and the optional fusevm bytecode disassembler. Pandoc + LaTeX typeset.',
      pills: ['Reference', 'zdbview', 'DRM-free PDF'], price: 20,
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
    ['stryke-app', 'AP', 'App automation for stryke — call a MenkeTechnologies GUI app\'s verbs by name, read its state, and subscribe to its events over the GUI Automation Bus. Semantic, not synthetic clicks; cross-platform and JIT-compiled.'],
    ['stryke-arrow', 'AR', 'Apache Arrow, Parquet, Feather, and Arrow CSV/JSON for stryke.'],
    ['stryke-aws', 'AWS', 'AWS client for stryke — S3, DynamoDB, SQS, SNS, Lambda, Step Functions, Kinesis, EC2, ECR, IAM, KMS, STS, SSM, Secrets Manager, SES, CloudWatch, and CloudWatch Logs.'],
    ['stryke-azure', 'AZ', 'Azure client for stryke — Blob Storage, Storage Queues, Cosmos DB, Key Vault secrets and keys, Virtual Machines, AKS, Service Bus, Container Instances, Monitor, and resource-group admin over Entra credential auth.'],
    ['stryke-clickhouse', 'CH', 'ClickHouse client for stryke — SELECTs, JSONEachRow bulk insert, table/database admin, and schema introspection over the HTTP interface.'],
    ['stryke-docker', 'DK', 'Docker client for stryke — containers, images, networks, volumes, logs, exec, and prune.'],
    ['stryke-duckdb', 'DB', 'Embedded DuckDB SQL engine for stryke — direct-query Parquet, CSV, and JSON.'],
    ['stryke-email', 'EM', 'Transactional and campaign email for stryke — single send, mass mailing, {{merge}} templates, and List-Unsubscribe compliance over your own SMTP.'],
    ['stryke-fleet', 'FL', 'Expect, but N sessions at once — parallel interactive session automation for stryke: transcripted PTY sessions, declarative playbooks, a 49-recipe login corpus, and pmap fan-out across N hosts.'],
    ['stryke-gcp', 'GCP', 'Google Cloud client for stryke — Cloud Storage, Pub/Sub, BigQuery, Firestore, Secret Manager, Compute Engine, Cloud Run, Cloud Functions, Cloud Logging, Monitoring, and IAM.'],
    ['stryke-grpc', 'GR', 'Reflection-based gRPC client for stryke — grpcurl, as a stryke package.'],
    ['stryke-gui', 'GUI', 'GUI automation for stryke — mouse, keyboard, screen, pixel, clipboard, multi-display screenshots, and a 36-fn color toolkit (HSL/HSV/HWB/CMYK/Lab/OkLab/XYZ, blending, gradients, schemes, delta-E, contrast ratio).'],
    ['stryke-k8s', 'K8', 'Kubernetes client for stryke — get, apply, create, replace, patch, delete, scale, autoscale, rollout, label, annotate, node cordon/uncordon/drain/taint/evict, logs, events, top, and wait.'],
    ['stryke-kafka', 'KK', 'Apache Kafka client for stryke — producer, consumer, and topic/cluster admin.'],
    ['stryke-mcpd', 'MCP', 'MCP servers without a runtime — a Model Context Protocol daemon for stryke.'],
    ['stryke-mongo', 'MGO', 'MongoDB client for stryke — CRUD, aggregation, and index admin.'],
    ['stryke-mssql', 'MS', 'Microsoft SQL Server / Azure SQL client for stryke — parametrized T-SQL, transaction batches, scalar/exists helpers, and schema introspection over tiberius.'],
    ['stryke-mysql', 'MY', 'MySQL / MariaDB client for stryke — pooled in-process queries, insert_many and upsert writes, transaction batches, CALL stored procedures, schema/index/trigger introspection, and processlist/status/size admin.'],
    ['stryke-neo4j', 'N4', 'Neo4j graph database client for stryke — parametrized Cypher query and run, scalar/row helpers, and schema introspection over the Bolt protocol.'],
    ['stryke-office', 'OF', 'Office document I/O for stryke — Excel, Word, PowerPoint, ODF, PDF, a 111-fn imaging surface, charts, QR/1D barcodes, Markdown/HTML conversion, and mail merge.'],
    ['stryke-parquet', 'PQ', 'Parquet toolkit for stryke — schema, stats, row-groups, head/tail, CSV/JSON I/O, merge, and recompress.'],
    ['stryke-polars', 'PL', 'Full pandas/numpy surface for stryke — DataFrame, Series, Index, GroupBy, ndarray, masked and sparse arrays, linalg, FFT, signal, random, datetime64, statistics and stat tests, metrics, clustering, image, graph, geo, and text.'],
    ['stryke-postgres', 'PG', 'PostgreSQL client for stryke — pooled queries, COPY bulk transfer, LISTEN/NOTIFY, savepoints and transactions, schema/role/extension introspection, and vacuum/reindex/locks/activity admin.'],
    ['stryke-redis', 'RD', 'Redis / Valkey client for stryke — KV, lists, sets, hashes, zsets, streams, geo, bitmaps, HyperLogLog, scripting, pub/sub, pipelines, and server admin (ACL, config, client, slowlog, memory, object).'],
    ['stryke-scrape', 'SR', 'Web scraping and crawling client for stryke — fetch, robots-aware crawl, sitemap discovery, CSS extraction, tables, links, and structured data.'],
    ['stryke-scylla', 'SY', 'ScyllaDB / Apache Cassandra client for stryke — CQL queries, keyspace/table DDL, and schema introspection over the native CQL binary protocol.'],
    ['stryke-search', 'ES', 'Elasticsearch / OpenSearch client for stryke — index admin, document CRUD, bulk indexing, the query DSL, an 18-fn aggregation builder, scroll and point-in-time, aliases, component templates, ingest pipelines, snapshot repositories, tasks, and cluster health.'],
    ['stryke-selenium', 'SE', 'Browser automation for stryke — WebDriver sessions, DOM find and wait, JS execution, action chains, window and frame switching, alerts, screenshots and print-to-PDF, and cookies.'],
    ['stryke-spark', 'SK', 'Apache Spark client for stryke — SQL query and execute, explain plans, external parquet/csv/json/orc read and write, catalog and temp-view management, table cache control, and spark-submit pass-through.'],
    ['stryke-terminal', 'TR', 'Headless VT100 / VT220 / linux terminal emulator for stryke — a faithful pyte port; feed a program\'s raw byte stream and read the rendered screen model.'],
    ['stryke-utils', 'UT', 'Boundary helpers for stryke — 149 pure-stryke composites across String, List, Hash, Num, Time, and Path; everything else is a builtin.'],
    ['stryke-zmq', 'ZQ', 'ZeroMQ client for stryke — REQ/REP, PUB/SUB, PUSH/PULL, DEALER/ROUTER, and PAIR over TCP/IPC/inproc, with poll, socket monitoring, a backgrounded proxy device, and CURVE keypairs plus z85 codec.'],
  ].forEach(function (e) { PRODUCTS.push(strykePkg(e[0], e[1], e[2])); });

  // arb community packages: self-sourcing dashboards installed via `arb install
  // NAME` from the arb-registry index. Package name is NAME; the repo is arb-NAME.
  function arbPkg(id, glyph, desc) {
    return {
      id: 'arb-' + id, name: id, glyph: glyph, category: 'arb Packages', badge: 'FREE',
      tagline: desc,
      pills: ['arb', 'dashboard', 'Free / OSS'],
      price: 0,
      tiers: [{ name: 'Open Source', desc: 'MIT licensed', price: 0 }],
      download: 'https://github.com/MenkeTechnologies/arb-' + id + '/releases/latest',
      repo: 'https://github.com/MenkeTechnologies/arb-' + id,
    };
  }
  [
    ['ollama', 'Ol', 'Live view of the models loaded in the local Ollama LLM server (ollama ps).'],
    ['gpu', 'Gp', 'NVIDIA GPU utilization sparkline + gauge, self-sourced from nvidia-smi.'],
    ['ping', 'Pg', 'Round-trip latency sparkline, self-sourced by pinging once a second.'],
    ['uptime', 'Up', '1-minute load-average sparkline, self-sourced from uptime.'],
    ['battery', 'Bt', 'macOS battery charge gauge, self-sourced from pmset.'],
    ['du', 'Du', 'Largest immediate subdirectories bar chart, self-sourced from du.'],
    ['free', 'Fr', 'Used-vs-total memory gauge, self-sourced from free.'],
    ['weather', 'Wx', 'Current conditions from wttr.in, refreshed every 10 minutes.'],
    ['sensors', 'Se', 'Hardware temperature/fan/voltage readouts from lm-sensors.'],
    ['speedtest', 'SA', 'Ping/download/upload throughput from speedtest-cli.'],
    ['who', 'Wo', 'Logged-in users, their tty, and login time.'],
    ['crontab', 'Cr', 'The current user\'s scheduled cron jobs.'],
    ['brew', 'Br', 'Outdated Homebrew formulae, with a live count.'],
    ['npm', 'Np', 'Outdated npm dependencies in the current project.'],
    ['pip', 'Pi', 'Outdated pip packages.'],
    ['apt', 'Ap', 'Upgradable APT packages, with a live count.'],
    ['pacman', 'Pm', 'Pacman packages with pending updates.'],
    ['wifi', 'Wi', 'Visible Wi-Fi networks by signal strength (nmcli).'],
    ['swap', 'Sw', 'Active swap devices and their usage.'],
    ['inodes', 'In', 'Per-filesystem inode usage.'],
    ['mpstat', 'Mp', 'Per-CPU utilization from mpstat.'],
    ['iotop', 'Io', 'Per-process disk I/O from iotop.'],
    ['rustup', 'Ru', 'Installed Rust toolchains.'],
    ['usb', 'Ub', 'Connected USB devices.'],
    ['launchd', 'Ld', 'macOS launchd jobs, their PID and status.'],
    ['tokei', 'Tk', 'Lines of code by language from tokei.'],
    ['gitstatus', 'Gs', 'Short git working-tree status.'],
    ['ufw', 'Uf', 'UFW firewall rules and status.'],
    ['cal', 'Ca', 'The current month\'s calendar.'],
    ['lsblk', 'Lb', 'Block devices, their size and mountpoints.'],
    ['mount', 'Mt', 'Currently mounted filesystems.'],
    ['brewsvc', 'Bs', 'Homebrew-managed background services and their state.'],
  ].forEach(function (e) { PRODUCTS.push(arbPkg(e[0], e[1], e[2])); });

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

  [["fusevm","VM","Developer Tools","Language-agnostic bytecode VM with fused superinstructions and a three-tier Cranelift JIT — the shared execution engine behind sixteen language frontends, including zshrs, strykelang, awkrs, vimlrs, elisprs, rubylang, pythonrs, phplang, node-js, rlang, javars, kotlinrs, scalars, groovyrs, go-rs, and arb.",["Rust","234-op VM","JIT","Free / OSS"],false],["api-rest-generator","API","Developer Tools","Parses SQL DDL dumps and generates a fully-wired REST backend — Spring Boot (Java/Kotlin/Groovy) or Loco (Rust/Axum/SeaORM).",["codegen","JVM/Rust","Free / OSS"],false],["LearningCollectionAPI","LC","Developer Tools","A Spring Boot + Kotlin REST API for managing a personal collection of learning notes, backed by MySQL.",["Kotlin","Spring Boot","Free / OSS"],false],["stryke-demo","SD","Developer Tools","Live demo scripts for every stryke-* package — one .stk per package, one install pulls them all.",["stryke","demos","Free / OSS"],false],["VimColorSchemes","VC","Developer Tools","The largest curated Vim colorscheme bundle — 732 working :colorscheme targets in one plugin.",["Vim","732 themes","Free / OSS"],false],["zpwr","zp","Zsh Plugins","The world’s most advanced UNIX terminal environment — 500+ subcommands, 2000+ aliases, 47k completions, vim + tmux integration.",["zsh","terminal env","Free / OSS"],true],["zsh-more-completions","mc","Zsh Plugins","The largest curated zsh completion corpus in existence — 47k+ command completions wired into compsys.",["zsh","completions","Free / OSS"],false],["zsh-expand","ze","Zsh Plugins","The most powerful zsh expansion plugin — spacebar-expands aliases, globs, history, params, and typo fixes in pure zsh.",["zsh","expansion","Free / OSS"],true],["zsh-learn","zl","Zsh Plugins","Turn your terminal into a MySQL-backed knowledge base — save, search, and quiz yourself on snippets and notes.",["zsh","MySQL","Free / OSS"],false],["zsh-git-acp","ga","Zsh Plugins","Stage, commit, and push in one keybinding — ZLE widgets that use the command line as your commit message, plus 159 git aliases.",["zsh","git","Free / OSS"],false],["zsh-git-repo-cache","rc","Zsh Plugins","Finds and caches every git repo on your machine for instant prompts and fzf-powered cd.",["zsh","git","fzf","Free / OSS"],false],["zsh-zinit-final","zf","Zsh Plugins","An intentionally-empty plugin that loads last under zinit — a deterministic carrier for trailing atinit/atload hooks.",["zsh","zinit","Free / OSS"],false],["zsh-sudo","su","Zsh Plugins","Toggle sudo on the current command line with a single keybind — prepend or strip without retyping.",["zsh","ZLE","Free / OSS"],false],["zsh-cargo-completion","cg","Zsh Plugins","Zsh tab-completion for Rust’s Cargo, with live crates.io search for add and install.",["zsh","completion","Free / OSS"],false],["zsh-cpan-completion","cpn","Zsh Plugins","Zsh completion that pulls live Perl module names from CPAN for cpan and cpanm.",["zsh","completion","Free / OSS"],false],["zsh-dotnet-completion","dn","Zsh Plugins","Zsh tab-completion and aliases for the .NET (dotnet) CLI.",["zsh","completion","Free / OSS"],false],["zsh-gem-completion","gm","Zsh Plugins","Zsh completion for Ruby’s gem, with live remote gem search on install.",["zsh","completion","Free / OSS"],false],["zsh-nginx","ng","Zsh Plugins","nginx vhost management from zsh — en / dis enable and disable sites by symlink, vhost scaffolds a new server block from a template (plain_php, symfony2), each with its own compsys completion.",["zsh","completion","Free / OSS"],false],["zsh-openshift-aliases","oc","Zsh Plugins","53 short aliases over the OpenShift oc CLI, plus login macros and oc completion.",["zsh","oc","Free / OSS"],false],["zsh-pip-description-completion","pp","Zsh Plugins","Zsh completion for pip with package version and description shown in the menu.",["zsh","completion","Free / OSS"],false],["zsh-sed-sub","sb","Zsh Plugins","A ZLE keybinding for global sed-style search-and-replace on the current command line.",["zsh","ZLE","Free / OSS"],false],["zsh-very-colorful-manuals","mn","Zsh Plugins","Renders man pages in cyberpunk ANSI colors via scoped LESS_TERMCAP_* injection.",["zsh","man","Free / OSS"],false],["zshrs-forgit","fg","znative Plugins","forgit (interactive git + fzf) ported to a native zshrs plugin — the ga/glo/gd command set as compiled Rust builtins in a cdylib, no per-startup sourcing.",["zshrs","native","Free / OSS"],false],["zshrs-git-fuzzy","gz","znative Plugins","git-fuzzy (full-screen fzf git UI) status ported to a native zshrs plugin — self-reentrant helpers as builtins, no per-keystroke library sourcing.",["zshrs","native","Free / OSS"],false],["zshrs-git-repos","gp","znative Plugins","zsh-git-repo-cache ported to a native zshrs plugin — in-process filesystem walk with parallel clean/dirty classification, then fzf-jump.",["zshrs","native","Free / OSS"],false],["zshrs-revolver","rv","znative Plugins","revolver (shell progress spinner) ported to a native zshrs plugin — the animator runs on an in-process thread, no fork and no statefile.",["zshrs","native","Free / OSS"],false],["zshrs-kubectl-completion","kb","znative Plugins","kubectl completion as a native zshrs plugin — delegates to cobra's kubectl __complete, always in sync with the installed kubectl.",["zshrs","native","Free / OSS"],false],["zshrs-zsh-z","jz","znative Plugins","zsh-z (frecency directory jumper) ported to a native zshrs plugin — a faithful Rust reimplementation of the ~/.z datafile, frecency formula, and aging.",["zshrs","native","Free / OSS"],false],["zshrs-fasd","fd","znative Plugins","fasd (frecency for files AND directories — a/s/d/f/j/v) ported to a native zshrs plugin — a preexec hook tracks every path argument; regex + fuzzy matching and frecency scoring reimplemented in Rust.",["zshrs","native","Free / OSS"],false],["zshrs-reveal","rl","znative Plugins","reveal (open the current repo's GitHub / Heroku pages in the browser) ported to a native zshrs plugin — OS opener detection, git remote -v parsing, and SSH/HTTPS URL normalization in Rust.",["zshrs","native","Free / OSS"],false],["zmax-native-wc","Wc","zmax-native Plugins","wc for the editor buffer — :wc reports the current buffer's line / word / char / byte counts on the status line, a compiled Rust cdylib loaded over zmax's stable C ABI with no editor recompile.",["zmax","native","Free / OSS"],false],["zmax-native-uuid","Ud","zmax-native Plugins","Insert a random RFC 4122 v4 UUID at the cursor — :uuid and :uuid-upper, entropy from /dev/urandom, a zero-dependency native zmax cdylib plugin.",["zmax","native","Free / OSS"],false],["zmax-native-toc","Tc","zmax-native Plugins","Insert a nested Markdown table of contents built from the buffer's ATX headings — :toc, a zero-dependency native zmax cdylib plugin loaded over the stable C ABI.",["zmax","native","Free / OSS"],false],["zmax-native-lorem","Lo","zmax-native Plugins","Insert n paragraphs of lorem-ipsum placeholder text at the cursor — :lorem [n], a zero-dependency native zmax cdylib plugin.",["zmax","native","Free / OSS"],false],["vscode-stryke","VS","Editor Plugins","VS Code / VSCodium extension for the stryke language — *.stk detection, a stryke-native TextMate grammar from the binary's reflection tables, and LSP via stryke --lsp.",["VS Code","stryke","LSP","Free / OSS"],false],["vim-stryke","Vi","Editor Plugins","Vim / Neovim support for stryke — filetype detection, a reflection-generated syntax grammar, brace indent, ALE lint, and LSP via stryke --lsp.",["Vim","stryke","LSP","Free / OSS"],false],["emacs-stryke","Es","Editor Plugins","stryke-mode for Emacs — a generated stryke-stdlib.el with the full builtin surface, brace indent, and LSP via stryke --lsp (eglot + lsp-mode).",["Emacs","stryke","LSP","Free / OSS"],false],["vscode-zsh","Vz","Editor Plugins","VS Code / VSCodium support for zshrs — a source.zshrs grammar from zshrs --dump-reflection, *.zsh / dotfile / shebang detection, and LSP via zshrs --lsp.",["VS Code","zshrs","LSP","Free / OSS"],false],["vim-zsh","vz","Editor Plugins","Vim / Neovim support for zshrs — *.zsh / dotfile / shebang detection, a reflection-generated grammar, shell-block indent, ALE, and LSP via zshrs --lsp.",["Vim","zshrs","LSP","Free / OSS"],false],["emacs-zsh","ez","Editor Plugins","zshrs-mode for Emacs — font-lock from zshrs --dump-reflection, shell-block indent, and LSP via zshrs --lsp (eglot + lsp-mode).",["Emacs","zshrs","LSP","Free / OSS"],false],["vscode-arb","Vb","Editor Plugins","VS Code / VSCodium extension for arb — *.arb detection, a source.arb grammar, an arb.run command, LSP via arb --lsp, and DAP debugging via arb --dap.",["VS Code","arb","LSP · DAP","Free / OSS"],false],["vim-arb","vb","Editor Plugins","Vim / Neovim support for arb — *.arb detection, syntax + brace indent, run / :make, and LSP via arb --lsp.",["Vim","arb","LSP","Free / OSS"],false],["emacs-arb","eb","Editor Plugins","arb-mode for Emacs — font-lock for arb, indent, run, eldoc + completion, and LSP via arb --lsp (eglot + lsp-mode).",["Emacs","arb","LSP","Free / OSS"],false],["vscode-awk","Va","Editor Plugins","VS Code / VSCodium extension for AWK (awkrs) — *.awk detection, a source.awk grammar, an awk.run command, LSP via awkrs --lsp, and DAP debugging via awkrs --dap.",["VS Code","awk","LSP · DAP","Free / OSS"],false],["vim-awk","va","Editor Plugins","Vim / Neovim support for AWK (awkrs) — *.awk detection, syntax + brace indent, run / :make, and LSP via awkrs --lsp.",["Vim","awk","LSP","Free / OSS"],false],["emacs-awk","ea","Editor Plugins","awkrs-mode for Emacs — font-lock for AWK, indent, run, eldoc + completion, and LSP via awkrs --lsp (eglot + lsp-mode).",["Emacs","awk","LSP","Free / OSS"],false],["vscode-elisp","Vl","Editor Plugins","VS Code / VSCodium extension for Emacs Lisp (elisprs) — *.el / .emacs / shebang detection, a source.elisp grammar, an elisp.run command, LSP via elisp --lsp, and DAP debugging via elisp --dap.",["VS Code","elisp","LSP · DAP","Free / OSS"],false],["vim-elisp","vl","Editor Plugins","Vim / Neovim support for Emacs Lisp (elisprs) — *.el / .emacs detection, a standalone Emacs Lisp syntax grammar, indent, run / :make, LSP via elisp --lsp, and nvim-dap debugging via elisp --dap.",["Vim","elisp","LSP · DAP","Free / OSS"],false],["emacs-elisp","el","Editor Plugins","elisprs-mode for Emacs — derives from the built-in emacs-lisp-mode and layers the elisprs toolchain on top: run via elisp, eldoc + completion over the builtin surface, LSP via elisp --lsp (eglot + lsp-mode), and DAP via elisp --dap.",["Emacs","elisp","LSP · DAP","Free / OSS"],false],["zpwr-theme","th","Editor Plugins","Cyberpunk editor theme — the 8 canonical HUD colorschemes in dark and light: 16 VS Code themes plus 16 matching JetBrains UI themes and editor colour-scheme XMLs, all generated from one palette/schemes.json.",["VS Code","JetBrains","theme","Free / OSS"],false],["tmux-fzf-url","tx","Editor Plugins","Pop an fzf picker over every URL visible in the tmux pane; the selected URL opens in your browser.",["tmux","fzf","Free / OSS"],false],["gh_reveal","gh","Developer Tools","Open the current git repo's web page from the terminal — every remote, GitHub or GitLab or self-hosted, with Heroku remotes routed to their dashboard and herokuapp URL.",["git","CLI","Free / OSS"],false],["zsh-better-npm-completion","np","Zsh Plugins","Smarter zsh completion for npm — completes installed packages for run / uninstall and caches the script list.",["zsh","npm","Free / OSS"],false],["zsh-xcode-completions","xc","Zsh Plugins","Zsh tab-completion for 11 Xcode command-line tools — xcodebuild, xcrun, xcode-select, swift, swift-demangle, instruments, genstrings, plutil, nm, strings, dyldinfo.",["zsh","Xcode","Free / OSS"],false],["zsh-travis","tv","Zsh Plugins","Zsh aliases + functions for the Travis CI CLI — open build / PR pages from inside a project.",["zsh","Travis CI","Free / OSS"],false]]
    .forEach(function (e) { PRODUCTS.push(metaProduct(e[0], e[1], e[2], e[3], e[4], e[5])); });

  // arb ecosystem packages — dashboards distributed as git repos through the
  // arb-registry git index (no build artifacts; `arb install &lt;name&gt;` is a git
  // clone), so the download link is the repo's /tags page of source archives.
  // Reuses metaProduct so the shape stays identical to every other free repo.
  [
    ['arb-registry', 'RG', 'The community package index for arb — a git-index registry on the crates.io-index / homebrew-core model. No server and no API: the index is a JSON file in a git repo, every package is an ordinary git repo, resolution is a git pull, and publishing is a commit.', ['arb', 'registry', 'Free / OSS']],
    ['arb-procmon', 'PM', 'Top processes by CPU — a self-sourcing table that re-runs ps -A -o pcpu=,comm= every 2 seconds and keeps the 20 busiest, sorted by CPU% descending.', ['arb', 'dashboard', 'Free / OSS']],
    ['arb-memtop', 'MT', 'Top processes by resident memory — a self-sourcing table over ps -A -o rss=,comm= on a 2-second timer, sorted by RSS descending and capped at 20 rows.', ['arb', 'dashboard', 'Free / OSS']],
    ['arb-diskwatch', 'DW', 'Live disk-usage dashboard — self-sourced from df -P every 5 seconds, rendering each mount’s usage as a table. Nothing needs to be piped in.', ['arb', 'dashboard', 'Free / OSS']],
    ['arb-netstates', 'NS', 'TCP connection-states histogram — netstat -an re-run every 3 seconds, tallied into a bar chart of ESTABLISHED / LISTEN / TIME_WAIT / CLOSE_WAIT / SYN_SENT, plus a table of the raw connections.', ['arb', 'dashboard', 'Free / OSS']],
    ['arb-listeners', 'LI', 'Live dashboard of listening TCP sockets — lsof -iTCP -sTCP:LISTEN -P -n every 5 seconds, rendered as a total, a per-socket table, and a bar chart of listeners grouped by process command.', ['arb', 'dashboard', 'Free / OSS']],
    ['arb-pinglat', 'PL', 'Live ping latency dashboard — spawns ping, extracts the time=NN.N millisecond field from each reply, and renders a braille sparkline of the series plus the latest round-trip time.', ['arb', 'dashboard', 'Free / OSS']],
    ['arb-gitauthors', 'GA', 'Git commit activity by author for the current repository — git log --pretty=format:%an re-run every 15 seconds, tallied and rendered as a bar chart of the top 15 authors.', ['arb', 'dashboard', 'Free / OSS']],
    ['arb-streamstat', 'ST', 'Live statistics for any line stream — drop it in a pipe and get total lines, lines per second, distinct lines, and a tail of the most recent lines, all reading the same STDIN stream.', ['arb', 'dashboard', 'Free / OSS']],
    ['arb-logwatch', 'LW', 'Live stream log-watcher — pipe a log in and it scrolls in a tail widget capped at the last 2000 lines, flashing the border red on error/fail/panic/fatal/exception lines and yellow on warnings.', ['arb', 'dashboard', 'Free / OSS']],
    ['arb-jsonlog', 'JL', 'JSON-lines log viewer — projects each entry to ts / level / msg in a scrollable table alongside a bar chart of entry counts per level, with error and fatal lines flashing the table red.', ['arb', 'dashboard', 'Free / OSS']],
    ['arb-envbrowser', 'EB', 'Interactive fuzzy-search browser for environment variables — spawns env into an fzf-style select widget that matches your typing against the variable name while displaying the full KEY=value row.', ['arb', 'dashboard', 'Free / OSS']],
  ].forEach(function (e) { PRODUCTS.push(metaProduct(e[0], e[1], 'arb Packages', e[2], e[3], false)); });

  // Long-form detail copy (overview + rich features), ported from each repo's
  // README / source. Authoritative source for the product-detail page; merged
  // into PRODUCTS below so PRODUCTS stays the single object the UI reads.
  var DETAILS = {
    "rlang": {
      "overview": "R in Rust — run .R files outside GNU R. R as a fusevm frontend that lexes and parses R, lowers it to fusevm bytecode, and runs on an RHost vector heap with no bespoke VM or JIT, on the shared 3-tier Cranelift JIT behind the rest of the fleet. Every value is a vector with attributes, so recycling, NA propagation, three-valued logic, and copy-on-modify are the runtime semantics themselves. Free and open source.",
      "features": [
        "R interpreter in Rust — runs .R files standalone, no GNU R required",
        "Vector value model on an RHost heap — attributes, recycling, NA propagation, three-valued logic, copy-on-modify",
        "All four index forms, closures and <<-, replacement functions, S3 UseMethod, 239 primitives and 20 operators",
        "Byte-for-byte checked against GNU R by a differential parity harness",
        "Standalone Rscript binary + REPL, an LSP language server (--lsp), a DAP debugger (--dap), and Rscript --aot standalone native executables",
        "Inline-Rust FFI — .rust(code) compiles a pub extern \"C\" block to a cached cdylib, .Call(name, …) invokes it (shared fusevm FFI runtime)",
        "Transparent rkyv bytecode cache and AOP intercepts — free and open source (MIT)"
      ]
    },
    "go-rs": {
      "overview": "Go in Rust — run Go with no garbage collector and no go toolchain. Go as a fusevm frontend that lexes Go (with automatic semicolon insertion) and parses it, lowers it to fusevm bytecode, and runs on the shared 3-tier Cranelift JIT with no bespoke VM and no gc. Concurrency is not simulated away: go f(…), make(chan T), send/receive, close and select run on fusevm's cooperative scheduler, each goroutine its own VM over one single-threaded heap. Imports are executed, not reimplemented — a non-native package is resolved to its Go source and compiled into the same unit as main. Free and open source.",
      "features": [
        "Go compiler in Rust — runs Go standalone, no go toolchain, no garbage collector",
        "Go frontend lowered to fusevm bytecode on the shared bytecode VM + 3-tier Cranelift JIT",
        "Concurrency — go f(…) goroutines, buffered and unbuffered chan, send/receive, close, and select with default, on fusevm's cooperative scheduler; deadlocks are reported",
        "Generics by erasure — type parameters on funcs, types and methods, constraint interfaces (~int | ~float64), inferred and explicit instantiation",
        "defer / panic / recover — LIFO deferred calls with arguments snapshotted at defer time; integer divide-by-zero, index-out-of-range and nil dereference are recoverable runtime faults",
        "The type system — structs with value-copy semantics and embedded-field promotion, pointers and new(T), interfaces with dynamic dispatch, type assertions and type switches, defined types, arrays and backing-array-sharing slices",
        "Functions — variadics and spread, multi-value returns, named results, closures capturing by reference, first-class func values via Op::CallDynamic",
        "Go semantics — automatic semicolon insertion, int/int truncation, %v formatting, string concatenation and ordering, bitwise ops and base literals",
        "The go CLI — go run / build (AOT native executable via fusevm) / vet / env / doc / install-std / version / help, plus --tiers, --dump-tokens, --dump-ast and --disasm",
        "The standard library is executed, not reimplemented — a non-native import is resolved to its Go source and compiled into the same unit as main",
        "Standalone go binary with an LSP language server (--lsp) and DAP debugger (--dap)",
        "Inline rust {} FFI, corpus-driven reference docs, and --dump-tokens/--dump-ast/--disasm introspection",
        "Free and open source (MIT)"
      ]
    },
    "arb-reference": {
      "overview": "The dense reference companion to The arb Book — the complete surface of the pipeline-to-TUI language on fusevm. Generated from the live implementation rather than written by hand, so the directive, widget, source, and query listings track what the binary actually ships. DRM-free PDF.",
      "features": [
        "Every spec directive and the widget and source types arb renders",
        "The jq/xpath/css/yq query operator surface over the live passthrough",
        "The interactive megafilter/map and the full command-line interface",
        "Generated from the live implementation, so it does not drift from the binary",
        "The dense companion to The arb Book",
        "DRM-free PDF"
      ]
    },
    "go-rs-book": {
      "overview": "The companion book to go-rs — Go as a fusevm frontend with no garbage collector. The reference go toolchain ships a collector and a scheduler; go-rs keeps Go's syntax and semantics and does without the runtime, lowering Go to bytecode on the shared VM with a three-tier Cranelift JIT. The frontend/engine split, functions and call-frame slots, and the in-binary tooling.",
      "features": [
        "go-rs, end to end — Go on the shared fusevm machine, no gc and no go toolchain",
        "Own the language, rent the engine — the frontend/engine split that defines the project",
        "Functions, call-frame slots, and recursion; Go int/int truncation and %v formatting",
        "The string numeric hook and how strings stay strings in an arithmetic context",
        "The in-binary tooling — LSP server, DAP debugger, inline rust {} FFI, corpus-driven docs",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "go-rs-reference": {
      "overview": "The dense reference companion to The go-rs Book — the complete Go surface of the frontend on fusevm. Generated from the language-server corpus rather than written by hand, so the keyword, operator, builtin, and type listings track what the tooling and binary actually ship. DRM-free PDF.",
      "features": [
        "Every keyword, operator, builtin, and type the go-rs build recognizes",
        "The fmt print family and Go's %v value formatting",
        "The full command-line interface — go run, go on a file, and the introspection dumps",
        "Generated from the language-server corpus, so it never drifts from the tooling",
        "The dense companion to The go-rs Book",
        "DRM-free PDF"
      ]
    },
    "tclrs": {
      "overview": "Tcl in Rust — run Tcl with no tclsh. Tcl as a fusevm frontend that parses a script once, resolving every substitution the grammar permits at parse time, and lowers each command to fusevm bytecode on the shared 3-tier Cranelift JIT. No bespoke VM and no dual-representation object model: a value produced as a number stays a number in a VM slot and only acquires a string representation when something asks for one. The reference implementation is tclsh 9.0.4, and it is the specification. Free and open source.",
      "features": [
        "Tcl compiler in Rust — runs Tcl standalone, no tclsh required",
        "Compiled, not re-parsed — a braced if / while / for body or braced expr compiles once into bytecode instead of being re-parsed on every evaluation",
        "Native arithmetic — the comparisons, bitwise and shift operators and short-circuiting && / || lower to native fusevm ops; only /, % and **, whose Tcl meaning differs, take a frontend op",
        "Ahead-of-time compilation — tclrs --aot links a standalone native executable with no parser and no bytecode dispatch loop inside it",
        "JIT armed and measured — 3,000,000 iterations of while {$i < $n} {incr i} inside a procedure in 6.6 ms against 243.7 ms interpreted, and --tiers reports which tiers a given script actually reaches",
        "Differentially tested — every program in the suite runs under both tclsh and tclrs and the exit code, result and stdout are compared byte for byte; no expected output is written by hand",
        "Nothing is approximated — a construct the frontend has not built is an error, and BUGS.md is the ledger",
        "Free and open source (MIT)"
      ]
    },
    "tclrs-book": {
      "overview": "The companion book to tclrs — Tcl as a fusevm frontend. Tcl 9 evaluates through a bytecode engine wrapped around a dual-representation object model; tclrs parses once and lowers to shared bytecode, and this book is the narrative the generated reference cannot carry: what the dodekalogue costs a compiler, why every loop goes through one emitter, and where the JIT does and does not reach.",
      "features": [
        "The dodekalogue, and the two rules that make a compiler worth building",
        "Lowering to fusevm bytecode — rotated loops, and why every loop goes through one emitter",
        "A value model with no object heap; expr, and what Tcl's boolean rule costs in trace eligibility",
        "Lists are strings — including the quadratic lappend this loses on; arrays are variables, dicts are values",
        "Procedures are frames not tables; catch, the one unwinder; coroutines as second VMs over the same chunk",
        "What the tiers actually reach — three million iterations in 5.6 ms inside a procedure and 5.8 ms at the top level (since fusevm 0.15.0 the tracing tier promotes a referenced VM global to a register), while the same loop written with foreach compiles nothing at all, with fusevm's own predicates as the source",
        "Ahead of time, the binary and the REPL, and a closing ledger of what the shape does not do",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "tclrs-reference": {
      "overview": "The dense reference companion to The tclrs Book — the complete command surface of the Tcl frontend on fusevm. Generated by the crate's own gen-docs rather than written by hand: each command is rendered from the compiler's tables, each ensemble subcommand is answered by the compiler itself, each format conversion by the runtime, and the expr ladder is printed from the table the parser binds with. DRM-free PDF.",
      "features": [
        "Every command the tclrs build recognizes, rendered from the compiler's own tables",
        "The string, array and dict ensembles, with the compiler's own answer for each subcommand",
        "The expr operator ladder and the format conversions the runtime implements",
        "Generated by gen-docs, so it does not drift from the binary — a command it lists exists, one it does not is invalid command name",
        "The dense companion to The tclrs Book",
        "DRM-free PDF"
      ]
    },
    "pythonrs": {
      "overview": "Python in Rust — run .py files outside CPython. Python as a fusevm frontend that lexes and parses Python, lowers it to fusevm bytecode, and runs on a PyHost object heap with no bespoke VM or JIT, on the shared 3-tier Cranelift JIT behind the rest of the fleet. The first compiled standalone Python runtime. Free and open source.",
      "features": [
        "Python interpreter in Rust — runs .py files standalone, no CPython required",
        "Python frontend lowered to fusevm bytecode on a PyHost object heap",
        "Runs on the shared bytecode VM + 3-tier Cranelift JIT (stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb)",
        "Standalone python binary with an LSP language server (--lsp) and DAP debugger (--dap)",
        "576 vendored CPython stdlib modules plus 12 native C-accelerator ports (_io, _struct, binascii, _codecs, _csv, _ast, _opcode, _tokenize, _imp, marshal, _thread, _signal)",
        "Two build modes: CPython-free (vendored pylib on fusevm) or bridged to an embedded libpython for full drop-in imports and python -m",
        "Bignums, closures, classes with MRO dispatch, generators on stackful coroutines, match/case, comprehensions, f-strings incl. PEP 750 t-strings",
        "AOT native-binary compilation and a transparent rkyv bytecode cache",
        "Free and open source (MIT)"
      ]
    },
    "phplang": {
      "overview": "PHP in Rust — run .php files outside the Zend engine. PHP as a fusevm frontend that lexes and parses PHP, lowers it to fusevm bytecode, and runs on a PhpHost object heap with no bespoke VM or JIT, on the shared 3-tier Cranelift JIT behind the rest of the fleet. The first compiled standalone PHP runtime. Free and open source.",
      "features": [
        "PHP interpreter in Rust — runs .php files standalone, no Zend engine or PHP-FPM required",
        "PHP frontend lowered to fusevm bytecode on a PhpHost object heap",
        "Runs on the shared bytecode VM + 3-tier Cranelift JIT (stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb, pythonrs)",
        "OOP: classes, constructor property promotion, interfaces, traits, instanceof, abstract classes, static members and enforced visibility",
        "Enums (pure and backed), match expressions, named arguments, nullsafe ?->, first-class callable syntax and Closure::bind",
        "Generators and yield from as host-side stackful coroutines, so yield costs one stack switch and needs no VM change",
        "Arrays with true PHP value semantics, references ($b = &$a, &$x parameters), and by-reference OUT parameters",
        "Standard library across 26 dispatch modules including GMP and bcmath arbitrary precision, preg, mbstring, DateTime and the SPL data structures",
        "804 names across 40 chapters documented against the runtime, 590 with examples executed against the built binary, gated by tests/corpus_coverage.rs",
        "Standalone php binary with an interactive REPL (php -a), an LSP language server (--lsp), a DAP debugger (--dap) and --tiers tier reporting",
        "zsh completion, man pages, and an HTML docs/report site",
        "Free and open source (MIT)"
      ]
    },
    "node-js": {
      "overview": "JavaScript in Rust — a compiled standalone JavaScript runtime. JS as a fusevm frontend that lexes and parses JavaScript, lowers it to fusevm bytecode, and runs on the shared bytecode VM + 3-tier Cranelift JIT behind the rest of the fleet. Free and open source.",
      "features": [
        "JavaScript runtime in Rust — runs JS standalone on the fusevm engine",
        "JS frontend lowered to fusevm bytecode, no bespoke VM or JIT",
        "Runs on the shared bytecode VM + 3-tier Cranelift JIT (stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb, pythonrs, php)",
        "Language surface: classes and inheritance, async/await, generators, destructuring, Map/Set/WeakRef, Promise, BigInt on num-bigint, TypedArrays, and RegExp on fancy-regex",
        "Real I/O event loop with promises, microtasks and timers; a CommonJS loader whose require() executes real npm packages off disk",
        "49 require() specs across 45 core modules — fs, http, http2, net, tls and https on rustls, crypto, zlib, dgram, worker_threads, cluster, stream, child_process, dns, readline, vm, v8",
        "Unimplemented modules throw a named error instead of returning a silent fake",
        "84-script byte-parity corpus against the reference node, plus a delta-debugging differential fuzzer",
        "Standalone node binary with a REPL, an LSP language server (--lsp), a DAP debugger (--dap), AOT --build and an rkyv bytecode cache",
        "zsh completion, man pages, and an HTML docs/report site",
        "Free and open source (MIT)"
      ]
    },
    "javars": {
      "overview": "Java in Rust — a compiled standalone Java runtime with no JVM. Java as a fusevm frontend that lexes and parses Java to an AST, lowers it to fusevm bytecode, and runs on the shared bytecode VM + 3-tier Cranelift JIT behind the rest of the fleet, with a JavaHost object heap serving Java semantics. Free and open source.",
      "features": [
        "Java runtime in Rust — runs .java files standalone, no JVM required",
        "Hand-written lexer and recursive-descent parser; the single-class main-entry model",
        "Java frontend lowered to fusevm bytecode on a JavaHost object heap",
        "Runs on the shared bytecode VM + 3-tier Cranelift JIT (stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb, pythonrs, php, node-js)",
        "The class model — fields, constructors, single inheritance with extends/super, virtual dispatch, instanceof, abstract classes, interfaces with default methods, and overload resolution by most-specific parameter type",
        "record types with derived accessors and component-wise equals; enum types with per-constant state and bodies; anonymous classes that capture their enclosing scope",
        "Type-erased generics, lambdas, method references, functional interfaces, java.util.stream and Optional",
        "The java.util collections with Java's real HashMap iteration order, EnumSet/EnumMap, String.format and Arrays.toString",
        "Arrow switch as expression and statement (multi-label arms, yield), try/catch/finally, try-with-resources and multi-catch",
        "Verified against OpenJDK — examples and the test corpus diffed byte-for-byte against a reference java and frozen, so CI needs no JDK",
        "Standalone javars binary with an LSP language server (--lsp), a DAP debugger (--dap), --tiers reporting and inline rust { } FFI",
        "Free and open source (MIT)"
      ]
    },
    "kotlinrs": {
      "overview": "Kotlin in Rust — the first compiled standalone Kotlin runtime with no JVM. Kotlin as a fusevm frontend that tokenizes and parses Kotlin to an AST, lowers it to fusevm bytecode, and runs on the shared bytecode VM + 3-tier Cranelift JIT behind the rest of the fleet, with a KotlinHost object heap serving Kotlin semantics. Free and open source.",
      "features": [
        "Kotlin runtime in Rust — runs .kt files standalone, no JVM required",
        "Tokenizer and parser; the top-level fun entry model and the Int/Double split with integer-division ops",
        "Kotlin frontend lowered to fusevm bytecode on a KotlinHost object heap",
        "Inline Rust FFI via rust { } blocks compiled to a cached cdylib and called by name",
        "Char is a real runtime type, not an Int in disguise — CharRange, s[i], for (c in s), and the full member set",
        "Classes with primary-constructor properties, secondary constructors, data classes and data-class inheritance, companion objects, and object expressions",
        "Inheritance the compiler enforces — open/abstract/sealed/interface, the supertype list, override, interface default bodies, and qualified super&lt;T&gt;.m()",
        "Extension functions and extension/computed properties, vararg parameters, default and named arguments, overload resolution, generics, and casts",
        "Standalone kotlinrs binary with an LSP language server (--lsp), a DAP debugger (--dap), --tiers reporting, and inline rust { } FFI compiled to a cached cdylib",
        "Free and open source (MIT)"
      ]
    },
    "scalars": {
      "overview": "Scala in Rust — a compiled standalone Scala runtime with no JVM. Scala as a fusevm frontend with a newline-inferring lexer that parses Scala to an AST, lowers it to fusevm bytecode, and runs on the shared bytecode VM + 3-tier Cranelift JIT behind the rest of the fleet, with a ScalaHost object heap serving Scala semantics. Free and open source.",
      "features": [
        "Scala runtime in Rust — runs .scala files standalone, no JVM required",
        "Newline-inferring lexer; object/def-main and extends App entry models, val/var, range for",
        "Scala frontend lowered to fusevm bytecode on a ScalaHost object heap; the SDIV integer-division op vs native float arithmetic",
        "Runs on the shared bytecode VM + 3-tier Cranelift JIT (stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb, pythonrs, php, node-js)",
        "The object model — class/object/case class, trait, extends/with, override, super, virtual dispatch, apply/unapply, constructor patterns, isInstanceOf, structural equals/hashCode/toString, copy, Option",
        "First-class functions — x => …, block bodies, _ placeholders, enclosing-frame capture, and { case … } partial-function literals with a real isDefinedAt behind collect/collectFirst/lift/orElse",
        "The immutable collections List/Seq/Vector/Set/Map with the full combinator set, ::, k -> v and for … yield, reproducing Scala's own HashSet/HashMap trie ordering through a ported MurmurHash3",
        "The mutable collections — ListBuffer, ArrayBuffer, mutable.Set/Map with their hash table's own iteration order, LinkedHashMap/Set, PriorityQueue, ArrayDeque, Queue, Stack, StringBuilder, and sorted(Ordering) / Ordering.by",
        "Double.toString fidelity — plain in [1e-3, 1e7), Java computerized scientific notation outside it, matching scala",
        "A differential parity-fuzz harness across twenty-four generators, byte-diffed against a live scala",
        "Free and open source (MIT)"
      ]
    },
    "groovyrs": {
      "overview": "Groovy in Rust — the first compiled standalone Groovy runtime with no JVM. Groovy as a fusevm frontend with a newline-significant lexer and a script-model parser, lowered to fusevm bytecode and run on the shared bytecode VM + 3-tier Cranelift JIT behind the rest of the fleet, with a GroovyHost object heap serving Groovy semantics. Free and open source.",
      "features": [
        "Groovy runtime in Rust — runs .groovy scripts standalone, no JVM required",
        "Newline-significant lexer and the Groovy script-model parser",
        "Groovy frontend lowered to fusevm bytecode on a GroovyHost object heap; the GDIV division op and for-in range desugaring",
        "Runs on the shared bytecode VM + 3-tier Cranelift JIT (stryke, zshrs, awkrs, vimlrs, elisprs, rubyrs, arb, pythonrs, php, node-js)",
        "Real BigDecimal literals — an unsuffixed decimal keeps its scale (1.10 + 2.20 == 3.30) and integer / promotes to it, so 7 / 2 is 3.5",
        "Operator overloading — a user class's plus/minus/multiply/div/remainder/power/negative/getAt/compareTo drives +, -, *, /, %, **, unary -, [] and the comparisons, with primitives left on the native fast path",
        "Classes, single inheritance with virtual dispatch and super chaining, interfaces with Java 8 default methods, traits, and method and constructor overloading by parameter type",
        "The list/map GDK with spread — collect, collectEntries, takeWhile, dropWhile, flatten, findAll and the rest, over Groovy-printed insertion-ordered literals",
        "assert with Groovy's power-assert rendering, switch, do/while, labeled break/continue, static imports, and runtime faults raised as catchable Groovy throwables",
        "Every program in examples/ diffed byte-for-byte against Apache Groovy in the test suite",
        "Free and open source (MIT)"
      ]
    },
    "zvcs": {
      "overview": "A git-shadowing superset VCS: a single Rust binary named git that replaces stock git on PATH and serves subcommands natively over vendored gitoxide — no fork/exec of stock git, and no fallthrough when a subcommand is unported. The superset is the reason it exists: 117 z-verbs add the coordination layer git cannot have for a meta-repo of nested submodules driven by many concurrent automated agents. The parity harness scores git-compat depth separately from dispatch, and the latest generated report is 90.3% (3851/4264) across 184 dispatched subcommands. Free and open source.",
      "features": [
        "One binary named git — shadows stock git on PATH; 181 git-compat subcommands dispatched natively over vendored gitoxide, never shelling out to stock git",
        "zdaemon — a machine-wide daemon with a per-repo FIFO lane replaces git's O_EXCL index.lock, so a contended writer waits in arrival order instead of failing",
        "zsync / zbump — submodules reconciled to their tracked mainline with HEAD left attached, and forward-only gitlink bumps that are committed, never regressed",
        "117 superset z-verbs — parallel fleet query and fan-out, secret scan, commit-signature check, queryable audit trail, scheduler, AOP intercepts, and policy gates across every indexed repo",
        "zworktree — a private, object-sharing worktree of the whole submodule tree per agent",
        "Every read verb takes --json for NDJSON, checked by an integration test so the surface cannot drift",
        "Free and open source (MIT)"
      ]
    },
    "arb-apt": {
          "overview": "A self-sourcing arb TUI dashboard: upgradable APT packages, with a live count. It runs `apt list --upgradable` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Upgradable APT packages, with a live count.",
                "Self-sourcing \u2014 runs `apt list --upgradable` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install apt`",
                "Run standalone by package name with `arb apt`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-battery": {
          "overview": "A self-sourcing arb TUI dashboard: macOS battery charge gauge, self-sourced from pmset. It runs `pmset -g batt` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "macOS battery charge gauge, self-sourced from pmset.",
                "Self-sourcing \u2014 runs `pmset -g batt` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install battery`",
                "Run standalone by package name with `arb battery`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-brew": {
          "overview": "A self-sourcing arb TUI dashboard: outdated Homebrew formulae, with a live count. It runs `brew outdated` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Outdated Homebrew formulae, with a live count.",
                "Self-sourcing \u2014 runs `brew outdated` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install brew`",
                "Run standalone by package name with `arb brew`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-brewsvc": {
          "overview": "A self-sourcing arb TUI dashboard: homebrew-managed background services and their state. It runs `brew services list` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Homebrew-managed background services and their state.",
                "Self-sourcing \u2014 runs `brew services list` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install brewsvc`",
                "Run standalone by package name with `arb brewsvc`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-cal": {
          "overview": "A self-sourcing arb TUI dashboard: the current month's calendar. It runs `cal` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "The current month's calendar.",
                "Self-sourcing \u2014 runs `cal` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install cal`",
                "Run standalone by package name with `arb cal`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-crontab": {
          "overview": "A self-sourcing arb TUI dashboard: the current user's scheduled cron jobs. It runs `crontab -l` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "The current user's scheduled cron jobs.",
                "Self-sourcing \u2014 runs `crontab -l` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install crontab`",
                "Run standalone by package name with `arb crontab`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-du": {
          "overview": "A self-sourcing arb TUI dashboard: largest immediate subdirectories bar chart, self-sourced from du. It runs `du -d 1 -h` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Largest immediate subdirectories bar chart, self-sourced from du.",
                "Self-sourcing \u2014 runs `du -d 1 -h` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install du`",
                "Run standalone by package name with `arb du`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-free": {
          "overview": "A self-sourcing arb TUI dashboard: used-vs-total memory gauge, self-sourced from free. It runs `free -m` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Used-vs-total memory gauge, self-sourced from free.",
                "Self-sourcing \u2014 runs `free -m` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install free`",
                "Run standalone by package name with `arb free`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-gitstatus": {
          "overview": "A self-sourcing arb TUI dashboard: short git working-tree status. It runs `git status -s` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Short git working-tree status.",
                "Self-sourcing \u2014 runs `git status -s` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install gitstatus`",
                "Run standalone by package name with `arb gitstatus`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-gpu": {
          "overview": "A self-sourcing arb TUI dashboard: nVIDIA GPU utilization sparkline + gauge, self-sourced from nvidia-smi. It runs `nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "NVIDIA GPU utilization sparkline + gauge, self-sourced from nvidia-smi.",
                "Self-sourcing \u2014 runs `nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install gpu`",
                "Run standalone by package name with `arb gpu`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-inodes": {
          "overview": "A self-sourcing arb TUI dashboard: per-filesystem inode usage. It runs `df -i` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Per-filesystem inode usage.",
                "Self-sourcing \u2014 runs `df -i` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install inodes`",
                "Run standalone by package name with `arb inodes`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-iotop": {
          "overview": "A self-sourcing arb TUI dashboard: per-process disk I/O from iotop. It runs `iotop -b -n 1` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Per-process disk I/O from iotop.",
                "Self-sourcing \u2014 runs `iotop -b -n 1` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install iotop`",
                "Run standalone by package name with `arb iotop`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-launchd": {
          "overview": "A self-sourcing arb TUI dashboard: macOS launchd jobs, their PID and status. It runs `launchctl list` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "macOS launchd jobs, their PID and status.",
                "Self-sourcing \u2014 runs `launchctl list` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install launchd`",
                "Run standalone by package name with `arb launchd`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-lsblk": {
          "overview": "A self-sourcing arb TUI dashboard: block devices, their size and mountpoints. It runs `lsblk` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Block devices, their size and mountpoints.",
                "Self-sourcing \u2014 runs `lsblk` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install lsblk`",
                "Run standalone by package name with `arb lsblk`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-mount": {
          "overview": "A self-sourcing arb TUI dashboard: currently mounted filesystems. It runs `mount` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Currently mounted filesystems.",
                "Self-sourcing \u2014 runs `mount` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install mount`",
                "Run standalone by package name with `arb mount`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-mpstat": {
          "overview": "A self-sourcing arb TUI dashboard: per-CPU utilization from mpstat. It runs `mpstat -P ALL 1 1` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Per-CPU utilization from mpstat.",
                "Self-sourcing \u2014 runs `mpstat -P ALL 1 1` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install mpstat`",
                "Run standalone by package name with `arb mpstat`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-npm": {
          "overview": "A self-sourcing arb TUI dashboard: outdated npm dependencies in the current project. It runs `npm outdated` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Outdated npm dependencies in the current project.",
                "Self-sourcing \u2014 runs `npm outdated` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install npm`",
                "Run standalone by package name with `arb npm`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-ollama": {
          "overview": "A self-sourcing arb TUI dashboard: live view of the models loaded in the local Ollama LLM server (ollama ps). It runs `ollama ps` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Live view of the models loaded in the local Ollama LLM server (ollama ps).",
                "Self-sourcing \u2014 runs `ollama ps` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install ollama`",
                "Run standalone by package name with `arb ollama`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-pacman": {
          "overview": "A self-sourcing arb TUI dashboard: pacman packages with pending updates. It runs `pacman -Qu` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Pacman packages with pending updates.",
                "Self-sourcing \u2014 runs `pacman -Qu` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install pacman`",
                "Run standalone by package name with `arb pacman`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-ping": {
          "overview": "A self-sourcing arb TUI dashboard: round-trip latency sparkline, self-sourced by pinging once a second. It runs `ping -c 1 8.8.8.8` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Round-trip latency sparkline, self-sourced by pinging once a second.",
                "Self-sourcing \u2014 runs `ping -c 1 8.8.8.8` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install ping`",
                "Run standalone by package name with `arb ping`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-pip": {
          "overview": "A self-sourcing arb TUI dashboard: outdated pip packages. It runs `pip list --outdated` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Outdated pip packages.",
                "Self-sourcing \u2014 runs `pip list --outdated` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install pip`",
                "Run standalone by package name with `arb pip`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-rustup": {
          "overview": "A self-sourcing arb TUI dashboard: installed Rust toolchains. It runs `rustup toolchain list` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Installed Rust toolchains.",
                "Self-sourcing \u2014 runs `rustup toolchain list` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install rustup`",
                "Run standalone by package name with `arb rustup`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-sensors": {
          "overview": "A self-sourcing arb TUI dashboard: hardware temperature/fan/voltage readouts from lm-sensors. It runs `sensors` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Hardware temperature/fan/voltage readouts from lm-sensors.",
                "Self-sourcing \u2014 runs `sensors` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install sensors`",
                "Run standalone by package name with `arb sensors`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-speedtest": {
          "overview": "A self-sourcing arb TUI dashboard: ping/download/upload throughput from speedtest-cli. It runs `speedtest-cli --simple` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Ping/download/upload throughput from speedtest-cli.",
                "Self-sourcing \u2014 runs `speedtest-cli --simple` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install speedtest`",
                "Run standalone by package name with `arb speedtest`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-swap": {
          "overview": "A self-sourcing arb TUI dashboard: active swap devices and their usage. It runs `swapon --show` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Active swap devices and their usage.",
                "Self-sourcing \u2014 runs `swapon --show` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install swap`",
                "Run standalone by package name with `arb swap`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-tokei": {
          "overview": "A self-sourcing arb TUI dashboard: lines of code by language from tokei. It runs `tokei` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Lines of code by language from tokei.",
                "Self-sourcing \u2014 runs `tokei` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install tokei`",
                "Run standalone by package name with `arb tokei`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-ufw": {
          "overview": "A self-sourcing arb TUI dashboard: uFW firewall rules and status. It runs `ufw status` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "UFW firewall rules and status.",
                "Self-sourcing \u2014 runs `ufw status` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install ufw`",
                "Run standalone by package name with `arb ufw`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-uptime": {
          "overview": "A self-sourcing arb TUI dashboard: 1-minute load-average sparkline, self-sourced from uptime. It runs `uptime` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "1-minute load-average sparkline, self-sourced from uptime.",
                "Self-sourcing \u2014 runs `uptime` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install uptime`",
                "Run standalone by package name with `arb uptime`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-usb": {
          "overview": "A self-sourcing arb TUI dashboard: connected USB devices. It runs `lsusb` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Connected USB devices.",
                "Self-sourcing \u2014 runs `lsusb` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install usb`",
                "Run standalone by package name with `arb usb`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-weather": {
          "overview": "A self-sourcing arb TUI dashboard: current conditions from wttr.in, refreshed every 10 minutes. It runs `curl -s wttr.in/?format=%l:+%c+%t+%w` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Current conditions from wttr.in, refreshed every 10 minutes.",
                "Self-sourcing \u2014 runs `curl -s wttr.in/?format=%l:+%c+%t+%w` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install weather`",
                "Run standalone by package name with `arb weather`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-who": {
          "overview": "A self-sourcing arb TUI dashboard: logged-in users, their tty, and login time. It runs `who` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Logged-in users, their tty, and login time.",
                "Self-sourcing \u2014 runs `who` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install who`",
                "Run standalone by package name with `arb who`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-wifi": {
          "overview": "A self-sourcing arb TUI dashboard: visible Wi-Fi networks by signal strength (nmcli). It runs `nmcli -f SIGNAL,SSID dev wifi` on a timer and feeds each run into the stream, so nothing needs to be piped in.",
          "features": [
                "Visible Wi-Fi networks by signal strength (nmcli).",
                "Self-sourcing \u2014 runs `nmcli -f SIGNAL,SSID dev wifi` on a timer, no pipeline required",
                "Installs from the arb-registry git index with `arb install wifi`",
                "Run standalone by package name with `arb wifi`",
                "Free / OSS \u2014 MIT licensed"
          ]
    },
    "arb-registry": {
      "overview": "The community package index for arb, built on the crates.io-index / homebrew-core model: a git-index registry rather than a service. There is no HTTP API, no database, and no auth layer — the index is index.json in this repo, every package is an ordinary git repo, and the arb CLI is the client. Resolving a package is a git pull; publishing one is a commit.",
      "features": [
        "Git-index registry — no server to run, no API to call, no uptime to keep",
        "index.json maps a package name to its repo URL, description, and version",
        "Packages are ordinary git repos; installing one is a clone",
        "Resolution is a git pull; publishing is a commit and a pull request",
        "The arb CLI is the only client — arb install &lt;name&gt; reads the index directly",
        "Free / OSS — MIT licensed"
      ]
    },
    "arb-procmon": {
      "overview": "A live arb TUI dashboard of the busiest processes by CPU. The package is self-sourcing — nothing needs to be piped in. It re-runs ps -A -o pcpu=,comm= every 2 seconds and feeds each run into the stream; the trailing = on both field specifiers suppresses the ps header on macOS and Linux alike, so every emitted line is a data row.",
      "features": [
        "Two-column table of CPU% and COMMAND, sorted by CPU percentage descending",
        "Self-sourcing on a 2-second timer — no pipeline required",
        "Query pipeline drops blank lines, sorts numerically in reverse, keeps the top 20",
        "Runs as a terminal dashboard or, with -t web, a served browser dashboard",
        "Portable across macOS and Linux — uses only ps -A -o pcpu=,comm=",
        "Free / OSS — MIT licensed"
      ]
    },
    "arb-memtop": {
      "overview": "A self-sourcing arb TUI dashboard of the top processes by resident memory. It runs ps -A -o rss=,comm= on a 2-second timer and feeds each run into the stream, so nothing needs to be piped in. RSS is reported in kilobytes exactly as ps emits it.",
      "features": [
        "Table of resident memory (RSS, in KB) and command name, largest first",
        "Self-sourcing on a 2-second timer — no pipeline required",
        "Keeps numeric process rows, sorts numerically in reverse, takes the top 20",
        "Run by package name (arb -p memtop) or directly from the spec file",
        "Portable across macOS and Linux",
        "Free / OSS — MIT licensed"
      ]
    },
    "arb-diskwatch": {
      "overview": "A live disk-usage dashboard for arb. It is self-sourced: the spec polls df -P every 5 seconds and renders each mount's usage as a table, so no pipeline is needed to drive it.",
      "features": [
        "Per-mount disk usage rendered as a live table",
        "Self-sourcing — polls df -P on a 5-second timer, nothing piped in",
        "Installs from the arb-registry git index with arb install diskwatch",
        "Run by package name with arb -p diskwatch",
        "Free / OSS — MIT licensed"
      ]
    },
    "arb-netstates": {
      "overview": "A live TUI dashboard giving the fastest read on socket health: a histogram of TCP connection states built from netstat -an re-run every 3 seconds. A wall of TIME_WAIT means churn, a spike in SYN_SENT means a peer is not answering, and growing CLOSE_WAIT means the local app is not closing sockets it should.",
      "features": [
        "Bar chart tallying sockets per TCP state (ESTABLISHED, LISTEN, TIME_WAIT, CLOSE_WAIT, SYN_SENT, …)",
        "Companion table of the raw rows — proto, local address, foreign address, state",
        "States chart flashes yellow whenever a TIME_WAIT / CLOSE_WAIT line appears",
        "Self-sourcing — netstat -an on a 3-second timer, nothing piped in",
        "State extracted with field 6, which is the state column on both BSD and net-tools netstat",
        "Free / OSS — MIT licensed"
      ]
    },
    "arb-listeners": {
      "overview": "A live TUI dashboard of the machine's listening TCP sockets. It re-runs lsof -iTCP -sTCP:LISTEN -P -n every 5 seconds — LISTEN-state TCP sockets only, numeric ports, no reverse DNS — so it needs nothing piped in and works unchanged on macOS and Linux.",
      "features": [
        "Total count of listening file descriptors",
        "Table of one row per listening socket: COMMAND / PID / USER / TYPE / ADDRESS",
        "ADDRESS is the bound addr:port (*:22, 127.0.0.1:6986, [::1]:6986); the lsof header row is rejected",
        "Bar chart of listener count grouped by process command, busiest first, top 15",
        "Self-sourcing on a 5-second timer — no pipeline required",
        "Free / OSS — MIT licensed"
      ]
    },
    "arb-pinglat": {
      "overview": "A live ping latency dashboard for arb. The spec is self-sourcing: it spawns ping, pulls the round-trip time out of each reply line with a regex capture on the time=NN.N millisecond field, and drives two widgets from the same stream.",
      "features": [
        "Braille sparkline of the latency series over time",
        "Text readout of the most recent round-trip time in milliseconds",
        "Self-sourcing — spawns ping itself, nothing piped in",
        "extract /time=([0-9.]+)/ pulls the numeric milliseconds; numeric keeps the series clean",
        "Runs as a TUI dashboard or, with -t web, a served web dashboard",
        "Free / OSS — MIT licensed"
      ]
    },
    "arb-gitauthors": {
      "overview": "An arb TUI dashboard showing git commit activity by author for the current repository. Run from inside a git repo, it re-runs git log --pretty=format:%an every 15 seconds, tallies commits per author, and renders the most active as a bar chart.",
      "features": [
        "Bar chart of total commits per author across the repo's history",
        "Authors sorted by commit count descending, capped at the top 15",
        "Self-sourcing — spawns git log on a 15-second timer, nothing piped in",
        "Query pipeline trims whitespace, drops blank lines, and tallies into (author, count) pairs",
        "Requires only arb and git on PATH",
        "Free / OSS — MIT licensed"
      ]
    },
    "arb-streamstat": {
      "overview": "Live statistics for any line stream. Drop streamstat in a pipe and it renders a TUI dashboard that updates as lines flow through STDIN — tail -f, journalctl -f, ping, or any other line-oriented producer. Each statistic is a separate widget source reading the same shared input stream.",
      "features": [
        "Lines — total lines seen on the stream (count reducer)",
        "Lines/sec — throughput over the window (rate reducer)",
        "Distinct lines — count of unique lines seen (distinct reducer)",
        "Recent — a full-width tail of the most recent lines for context",
        "Layout is three stat widgets across the top row, the tail beneath",
        "Free / OSS — MIT licensed"
      ]
    },
    "arb-logwatch": {
      "overview": "A live stream log-watcher for arb. It reads a log stream on STDIN and renders it in a scrolling tail widget, tinting the border by severity as lines arrive. This package is not self-sourcing — it consumes whatever you pipe into it, so tail -f, journalctl -f, kubectl logs -f, and docker logs -f all work unchanged.",
      "features": [
        "Scrolling tail widget capped at the last 2000 lines",
        "Bound to the shared incoming stream — every piped line is appended",
        "Event-driven highlighting: error|fail|panic|fatal|exception flashes the border red",
        "warn|warning flashes the border yellow",
        "Case-insensitive matching via the inline (?i) flag inside the regex literal",
        "Free / OSS — MIT licensed"
      ]
    },
    "arb-jsonlog": {
      "overview": "An arb dashboard for JSON-lines logs — streams where every line is one JSON object. It projects the fields you care about into a scrollable table and shows a live count of entries per level, so error/warn/info volume is visible at a glance. Any producer that emits one JSON object per line works: kubectl logs --output=json, tail -f app.jsonl, journalctl -o json -f.",
      "features": [
        "Table of each log entry projected to ts, level, and msg",
        "Bar chart of entry counts grouped by level, from the same stream",
        "Error and fatal lines flash the table red; warnings flash it yellow",
        "Both widgets read the same incoming JSON-lines stream",
        "Retarget to different keys by editing the pick list, the table columns, and the count_by field",
        "Free / OSS — MIT licensed"
      ]
    },
    "arb-envbrowser": {
      "overview": "An interactive arb dashboard that turns the env command into a live, fuzzy-searchable browser for your environment variables. It runs env as its own data source, so nothing needs to be piped in, and it doubles as an interactive filter when used mid-pipe.",
      "features": [
        "Self-sourcing — spawn env makes env's stdout the shared line stream",
        "Every KEY=value row lands in an fzf-style select widget: type to narrow, Enter to emit",
        "Variables sorted by name so the list is stable and scannable",
        "Typing matches the variable name only, while each row still displays the full KEY=value",
        "A filter control shapes the downstream passthrough, forwarding only matching variables",
        "Free / OSS — MIT licensed"
      ]
    },
    "zshrs-forgit": {
      "overview": "forgit — the interactive git + fzf utility — ported to a native zshrs plugin. The commands are compiled Rust builtins in a cdylib loaded through zshrs's stable plugin ABI with zmodload -R, instead of shell functions parsed on every startup.",
      "features": [
        "Nine native builtins — ga (add), grh (reset HEAD), glo (log), gd (diff), gcf (checkout file), gclean, gss (stash viewer), gcp (cherry-pick), gi (.gitignore)",
        "Loaded through zshrs's stable plugin ABI with zmodload -R",
        "Orchestration and sequencing in Rust; git and fzf run as subprocesses as upstream",
        "delta / diff-so-fancy used for diff rendering when present",
        "Installed with znative load MenkeTechnologies/zshrs-forgit"
      ]
    },
    "zshrs-git-fuzzy": {
      "overview": "git-fuzzy — the full-screen fzf-driven git interface — ported to a native zshrs plugin; this port covers the status command end-to-end. The self-reentrant helpers run as builtins, so there is no per-keystroke library sourcing.",
      "features": [
        "Full-screen fzf git UI (status command) as a native plugin",
        "Self-reentrant preview/keybinding helpers as builtins — no per-keystroke re-sourcing",
        "Requires git and fzf (>= 0.71) on PATH",
        "delta / diff-so-fancy used for diff rendering when present",
        "Installed with znative load MenkeTechnologies/zshrs-git-fuzzy"
      ]
    },
    "zshrs-git-repos": {
      "overview": "zsh-git-repo-cache ported to a native zshrs plugin: scan the filesystem for every git repository, cache the list, and fzf-pick one to cd into, with clean/dirty filtering. The native version walks in-process and classifies clean/dirty in parallel across threads.",
      "features": [
        "In-process filesystem walk instead of sudo find / -name .git",
        "Parallel clean/dirty classification across threads",
        "fzf-pick a repo to cd into, with clean/dirty filtering",
        "Clean = git diff-index --quiet HEAD and no untracked files (same test as the original)",
        "Installed with znative load MenkeTechnologies/zshrs-git-repos"
      ]
    },
    "zshrs-revolver": {
      "overview": "revolver — a progress spinner for the shell — ported to a native zshrs plugin. Instead of a shell script that forks a background process and coordinates through a statefile, the spinner is a compiled Rust builtin whose animator runs on an in-process thread.",
      "features": [
        "Start, update the message while work runs, and stop a spinner",
        "55 spinner styles (dots, line, arc, bouncingBall, pong, shark, …); revolver demo previews them",
        "Animator runs on an in-process thread — no fork, no statefile",
        "Options: -h/--help, -v/--version, -s/--style &lt;name&gt;",
        "Installed with znative load MenkeTechnologies/zshrs-revolver"
      ]
    },
    "zshrs-kubectl-completion": {
      "overview": "kubectl completion as a native zshrs plugin. Instead of a large static, version-pinned _kubectl function, it delegates to cobra's built-in completion protocol — kubectl __complete — so candidates always match the kubectl version actually installed.",
      "features": [
        "Delegates to cobra's kubectl __complete protocol",
        "Candidates always in sync with the installed kubectl — nothing to regenerate",
        "Completes subcommands, resources, and flags",
        "Native zshrs plugin, no static _kubectl function to maintain",
        "Installed with znative load MenkeTechnologies/zshrs-kubectl-completion"
      ]
    },
    "zshrs-zsh-z": {
      "overview": "zsh-z — the frecency directory jumper (z &lt;partial&gt; cd's to the directory you visit most, weighted by recency and frequency) — ported to a native zshrs plugin. A faithful Rust reimplementation of the ~/.z datafile, frecency formula, aging rule, matching, and z options.",
      "features": [
        "z &lt;partial&gt; jumps to the highest-frecency matching directory",
        "Faithful reimplementation of the ~/.z datafile format and frecency formula",
        "Aging rule, matching, and z options reproduced from upstream",
        "z -l lists matches with scores",
        "Installed with znative load MenkeTechnologies/zshrs-zsh-z"
      ]
    },
    "zshrs-fasd": {
      "overview": "fasd — frecency for files AND directories — ported to a native zshrs plugin. Where zsh-z tracks only the directories you cd into, fasd tracks every file and directory argument of every command via a preexec hook, and a/s/d/f/j/v query them by frecency. A faithful Rust reimplementation of the ~/.fasd datafile, the add/aging rule, the regex + fuzzy matching, and the frecency scoring.",
      "features": [
        "d &lt;part&gt; jumps to the best directory, f &lt;part&gt; the best file, a either, v opens the best file in $EDITOR",
        "preexec hook records every command's path arguments (plus $PWD)",
        "Regex → case-insensitive → fuzzy matching, last term in the basename",
        "Frecency scoring reproduced from fasd; -r rank / -t recency ordering",
        "Installed with znative load MenkeTechnologies/zshrs-fasd"
      ]
    },
    "zshrs-reveal": {
      "overview": "reveal — open the current git repository's GitHub (and Heroku) pages in the browser — ported to a native zshrs plugin. A faithful Rust reimplementation of gh_reveal: platform opener detection, git remote -v parsing, and SSH/HTTPS URL normalization.",
      "features": [
        "reveal opens the current repo's GitHub page(s); arguments filter the remotes by substring",
        "Outside a repo, opens your GitHub repositories page (or reveals directory arguments)",
        "Normalizes each SSH/HTTPS remote to host/user/repo (drops scheme, userinfo, port, .git)",
        "Heroku remotes open their dashboard + herokuapp.com URLs",
        "Installed with znative load MenkeTechnologies/zshrs-reveal"
      ]
    },
    "zmax-native-wc": {
      "overview": "wc for the editor buffer — :wc reports the current buffer's line / word / char / byte counts on the status line, the editor analog of the wc tool. A native zmax plugin: a compiled Rust cdylib loaded at runtime over zmax's stable C ABI, no editor recompile.",
      "features": [
        ":wc → line / word / char / byte counts of the buffer on the status line",
        "Compiled Rust cdylib loaded over zmax's stable C ABI — no editor recompile",
        "Installed into the content-addressed store under ~/.zmax/pkg/, SHA-256 pinned, dlopen'd by mmap",
        "Self-installs on first launch from one :zmax-native get line in ~/.zmax/init.vim, then loads zero-network",
        "Installed with :zmax-native add MenkeTechnologies/zmax-native-wc"
      ]
    },
    "zmax-native-uuid": {
      "overview": ":uuid inserts a random RFC 4122 version-4 UUID at the cursor; :uuid-upper inserts the uppercase form. Entropy is read from /dev/urandom, so the crate has zero dependencies. A native zmax plugin: a compiled Rust cdylib loaded at runtime over zmax's stable C ABI, no editor recompile.",
      "features": [
        ":uuid inserts a random v4 UUID at the cursor; :uuid-upper inserts the uppercase form",
        "RFC 4122 version-4; entropy read from /dev/urandom — zero dependencies",
        "Compiled Rust cdylib loaded over zmax's stable C ABI — no editor recompile",
        "Installed into the content-addressed store under ~/.zmax/pkg/, SHA-256 pinned, dlopen'd by mmap",
        "Installed with :zmax-native add MenkeTechnologies/zmax-native-uuid"
      ]
    },
    "zmax-native-toc": {
      "overview": ":toc scans the current buffer's Markdown ATX headings and inserts a nested table of contents at the cursor. Zero dependencies. A native zmax plugin: a compiled Rust cdylib loaded at runtime over zmax's stable C ABI, no editor recompile.",
      "features": [
        ":toc inserts a nested Markdown table of contents built from the buffer's ATX headings",
        "Nesting follows heading depth; anchor slugs follow the standard heading-to-anchor rules",
        "Zero dependencies; compiled Rust cdylib loaded over zmax's stable C ABI",
        "Installed into the content-addressed store under ~/.zmax/pkg/, SHA-256 pinned, dlopen'd by mmap",
        "Installed with :zmax-native add MenkeTechnologies/zmax-native-toc"
      ]
    },
    "zmax-native-lorem": {
      "overview": ":lorem [n] inserts n paragraphs of lorem-ipsum placeholder text at the cursor (one paragraph when n is omitted), blank-line separated. Zero dependencies. A native zmax plugin: a compiled Rust cdylib loaded at runtime over zmax's stable C ABI, no editor recompile.",
      "features": [
        ":lorem inserts one paragraph; :lorem n inserts n paragraphs, blank-line separated",
        "Zero dependencies; compiled Rust cdylib loaded over zmax's stable C ABI",
        "No editor recompile — loaded at runtime through the zmax-native package manager",
        "Installed into the content-addressed store under ~/.zmax/pkg/, SHA-256 pinned, dlopen'd by mmap",
        "Installed with :zmax-native add MenkeTechnologies/zmax-native-lorem"
      ]
    },
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
    "zmax-book": {
      "overview": "The companion book to zmax — the modal IDE with vim, emacs, and Spacemacs keymaps over a multiple-selection core, and the first IDE ever to embed ten complete programming languages — elisp, vimscript, stryke, AWK, and Zsh — compiled into one binary on a single shared bytecode VM, with no subprocess and no FFI.",
      "features": ["zmax, end to end — the modal IDE wearing a vim default keymap", "Vim, emacs, and Spacemacs bindings on one multiple-selection engine", "World-first: ten languages embedded in the core — elisp, vimscript, stryke, AWK, zsh, Ruby, PHP, Python, JavaScript, arb", "The engine underneath: rope, tree-sitter, fusevm, the AOT/JIT split", "Pandoc + LaTeX typeset, 102 pages, DRM-free PDF"]
    },
    "zmax-native-book": {
      "overview": "The plugin guide for zmax — writing a native, compiled Rust plugin for the editor over its frozen C ABI. Helix, which zmax forks, ships no plugin system at all; zmax publishes a versioned binary interface a stranger can compile against, plus a package manager that installs the result from owner/repo into a content-addressed store and maps it into the process. The book covers the boundary and why it is a C ABI, the declare_plugin! macro read as its expansion, the six host callbacks and the context window that governs them, the five SDK examples line by line, shipping and the package manager, and the rules of the road — closing on an honest inventory of where the API stops.",
      "features": ["The frozen C ABI: #[repr(C)] tables, extern \"C\" fn pointers, ABI_VERSION checked from both sides at load", "declare_plugin! read as its expansion — the static PluginInfo, the #[no_mangle] init, one trampoline per handler", "The six host callbacks (message, error, eval, buffer_text, insert_text, register_command) and the context window that makes them legal", "The five SDK examples line by line: hello, insert-date, buffer-stats, trim-trailing, banner", "Shipping: zmax-native.toml, the package manager, the ~/.zmax/pkg store, publishing an owner/repo plugin", "Rules of the road: TUI safety, panics that abort across FFI, ABI versioning, testing — and where the API stops", "Pandoc + LaTeX typeset, 61 pages, DRM-free PDF"]
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
    "rubyrs-book": {
      "overview": "The companion book to rubyrs — a compiled Ruby runtime hosted on the shared fusevm bytecode VM. MRI walks an AST in C; rubyrs lexes and parses Ruby to an AST, lowers it to fusevm bytecode, and runs it on a compiled VM with a three-tier Cranelift JIT. Arithmetic and comparison lower to native VM ops so the JIT can trace hot loops, while Ruby-specific behaviour — method dispatch, blocks, object construction, yield — is served by a thread-local RubyHost runtime. rubyrs carries no VM or JIT of its own.",
      "features": ["rubyrs, end to end — Ruby on the shared fusevm machine", "The pipeline: Ruby source → lexer → parser (AST) → fusevm bytecode → VM + JIT", "Native arithmetic/comparison ops vs the RubyHost runtime (dispatch, blocks, yield)", "Classes, modules/include, super, exceptions, splat/default params, &:sym block-pass", "The differential parity harness against real Ruby", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "arb-registry-book": {
      "overview": "The companion book to arb-registry — the community package index for arb. A registry is usually a server: an HTTP API, a database, an auth layer, uptime. arb-registry is none of that. It borrows the model Cargo and Homebrew use for their indexes: the index is a JSON file in a git repo, every package is an ordinary git repo, resolution is a git pull, and publishing is a commit. The book covers that model end to end.",
      "features": [
        "The index.json format — name, description, repo URL, and version per package",
        "The arb client commands: update, search, install, and publish",
        "The import resolution chain, from package name to cloned repo to loaded module",
        "Package anatomy — the arb.toml manifest and the .arb spec modules beside it",
        "The trust model of a shared JSON index living in a git repo",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "pythonrs-book": {
      "overview": "The companion book to pythonrs — Python as a fusevm frontend, and the first compiled standalone Python runtime. CPython interprets a bytecode it re-dispatches every run; pythonrs lexes and parses Python with an indentation-aware front end, lowers it to fusevm bytecode, caches that bytecode with rkyv, and runs it on the shared VM with a Cranelift JIT — with AOT-native compilation of your scripts as the end of the same pipeline.",
      "features": [
        "pythonrs, end to end — Python on the shared fusevm machine",
        "The indentation-aware lexer and parser, and the lowering of Python to fusevm bytecode",
        "Native arithmetic ops for the JIT vs the PyHost runtime that serves dispatch, comprehensions, and object construction",
        "rkyv-cached bytecode and AOT-native compilation of your scripts",
        "The differential parity harness against CPython",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "rlang-book": {
      "overview": "The companion book to rlang — R as a fusevm frontend, a compiled R runtime. GNU R walks a parse tree in C; rlang lexes and parses R to an AST, lowers it to fusevm bytecode, and runs it on the shared VM with a three-tier Cranelift JIT — carrying no VM or JIT of its own. for/while/repeat/if/&&/|| lower to native fusevm jumps with native integer loop counters, so the tracing JIT sees ordinary loops.",
      "features": [
        "rlang, end to end — R on the shared fusevm machine",
        "The vector value model — no scalars, attributes (names/dim/class), recycling and NA propagation, three-valued logic",
        "Copy-on-modify semantics and the way complex assignment targets rebuild and re-bind",
        "S3 dispatch, AOP before/after/around intercepts, the AOT native-executable and inline-Rust FFI paths, and the wasm build",
        "The differential parity harness against GNU R",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "zvcs-book": {
      "overview": "The companion book to zvcs — a git-shadowing superset VCS built for many-writer, submodule-heavy automated workflows. A single binary named git shadows stock git on PATH (porcelain served by vendored gitoxide); on top, a coordination layer replaces git's index.lock flock with a per-repo FIFO zdaemon so concurrent writers serialize fairly instead of racing.",
      "features": [
        "zvcs, end to end — a git superset for lock-free automated VCS",
        "The shadow git binary and the superset-verb vs git-compat dispatch",
        "zdaemon: the per-repo FIFO coordinator (mpsc + VecDeque, ACQUIRE/GRANTED/RELEASE, auto-release on EOF)",
        "RepoLock: the RAII client that serializes index writers fairly",
        "zsync and zbump: ff-only submodule reconcile and forward-only gitlink bumps",
        "The vendored gitoxide engine, and the coordination test proving occupancy is exactly one",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "phplang-book": {
      "overview": "The companion book to phplang — PHP as a fusevm frontend, the first compiled standalone PHP runtime with no Zend engine. It lexes and parses PHP in both inline-HTML and PHP modes, lowers it to fusevm bytecode with native arithmetic ops for the JIT, and serves PHP semantics — arrays, coercion, the builtin library — from a PhpHost runtime.",
      "features": [
        "phplang, end to end — PHP on the shared fusevm machine",
        "The dual-mode lexer (inline HTML + PHP) and the recursive-descent parser",
        "Lowering PHP to fusevm bytecode; native arithmetic vs the PhpHost runtime",
        "The PHP array object model (ordered map, key coercion) and value semantics",
        "The builtin library and the aspect-oriented intercept substrate",
        "The differential parity harness against PHP (and a Drupal-7 procedural corpus)",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "phplang-reference": {
      "overview": "The complete phplang reference — the PHP keyword set, language constructs, casts, and the builtin library surface of phplang, generated from the language server's own corpus so every function and construct matches the shipping php binary, each with a runnable example.",
      "features": [
        "Every keyword, construct, cast, and library function the build recognizes",
        "Grouped by chapter: Keyword, Construct, Cast, String, Array, Math, Type, Output",
        "Generated from the src/lsp.rs corpus that also drives editor completion",
        "A runnable PHP example for every entry",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "node-js-book": {
      "overview": "The companion book to node-js — JavaScript as a fusevm frontend and a compiled standalone JS runtime. It lexes JS with automatic semicolon insertion, Pratt-parses it, lowers it to fusevm bytecode (native arithmetic for the JIT, a dedicated DIV builtin for JS division semantics), and serves objects, arrays, and the standard library from a JsHost object heap.",
      "features": [
        "node-js, end to end — JavaScript on the shared fusevm machine",
        "The ASI-aware lexer and the Pratt expression parser",
        "Lowering JS to fusevm bytecode; native arithmetic vs the JsHost object heap",
        "The object model (ordered property maps) and the builtin standard library",
        "The differential parity harness against Node (byte-for-byte on its corpus)",
        "Honest boundaries: no event loop, classes, or regex yet",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "node-js-reference": {
      "overview": "The complete node-js reference — the JavaScript keyword set, globals, and the array / string / number / Math / JSON method surface of node-js, generated from the language server's own corpus so every name matches the shipping node binary, each with a runnable example.",
      "features": [
        "Every keyword, global, and method the build recognizes",
        "Grouped by chapter: keywords, globals, and per-type method sets",
        "Generated from the src/lsp.rs corpus that also drives editor completion",
        "A runnable JavaScript example for every entry",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "javars-book": {
      "overview": "The companion book to javars — Java as a fusevm frontend and a compiled standalone Java runtime with no JVM. It lexes and parses Java with a hand-written recursive-descent parser, models the single-class main entry point, lowers Java to fusevm bytecode, and serves Java semantics from a JavaHost runtime, with a DAP debugger over the same pipeline.",
      "features": [
        "javars, end to end — Java on the shared fusevm machine",
        "The hand-written lexer and recursive-descent parser; the single-class main-entry model",
        "Lowering Java to fusevm bytecode; the JavaHost runtime and builtin set",
        "The DAP debug adapter and the LSP language server",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "javars-reference": {
      "overview": "The complete javars reference — every Java keyword, type, operator, and builtin the current javars build recognizes, generated from the language server's own corpus so every entry matches the shipping javars binary, each with a runnable example.",
      "features": [
        "Every keyword, type, operator, and builtin the build recognizes",
        "Grouped by chapter for the Java surface",
        "Generated from the src/lsp.rs corpus that also drives editor completion",
        "A runnable Java example for every entry",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "kotlinrs-book": {
      "overview": "The companion book to kotlinrs — Kotlin as a fusevm frontend and a compiled standalone Kotlin runtime with no JVM. It tokenizes and parses Kotlin, models the top-level fun entry point, lowers Kotlin to fusevm bytecode (the Int/Double split and integer-division ops), compiles inline Rust FFI via rust { } blocks to a cached cdylib, and ships a DAP debugger over the same pipeline.",
      "features": [
        "kotlinrs, end to end — Kotlin on the shared fusevm machine",
        "The tokenizer and parser; the top-level fun model",
        "Lowering Kotlin to fusevm bytecode; the Int/Double split and integer-division ops",
        "Inline Rust FFI via rust { } blocks compiled to a cached cdylib",
        "The DAP debug adapter and the LSP language server",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "kotlinrs-reference": {
      "overview": "The complete kotlinrs reference — every Kotlin keyword, operator, and builtin the current kotlinrs build recognizes, generated from the language server's own corpus so every entry matches the shipping kotlinrs binary, each with a runnable example.",
      "features": [
        "Every keyword, operator, and builtin the build recognizes",
        "Grouped by chapter for the Kotlin surface",
        "Generated from the src/lsp.rs corpus that also drives editor completion",
        "A runnable Kotlin example for every entry",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "scalars-book": {
      "overview": "The companion book to scalars — Scala as a fusevm frontend and a compiled standalone Scala runtime with no JVM. It lexes Scala with a newline-inferring lexer, parses it, lowers Scala to fusevm bytecode (the SDIV integer-division op vs native float arithmetic), serves Scala semantics from a ScalaHost runtime, and is validated by a differential parity-fuzz harness against real scala.",
      "features": [
        "scalars, end to end — Scala on the shared fusevm machine",
        "The newline-inferring lexer and the parser",
        "Lowering Scala to fusevm bytecode; the SDIV integer-division op vs native float arithmetic",
        "The differential parity-fuzz harness byte-diffed against real scala",
        "The LSP language server for editor completion",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "scalars-reference": {
      "overview": "The complete scalars reference — every Scala keyword, operator, and builtin the current scalars build recognizes, generated from the language server's own corpus so every entry matches the shipping scalars binary, each with a runnable example.",
      "features": [
        "Every keyword, operator, and builtin the build recognizes",
        "Grouped by chapter for the Scala surface",
        "Generated from the src/lsp.rs corpus that also drives editor completion",
        "A runnable Scala example for every entry",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "groovyrs-book": {
      "overview": "The companion book to groovyrs — Groovy as a fusevm frontend and a compiled standalone Groovy runtime with no JVM. It lexes Groovy with a newline-significant lexer, parses it with a script-model parser, lowers Groovy to fusevm bytecode (the GDIV division op and for-in range desugaring), serves Groovy semantics from a GroovyHost runtime, and is validated by a differential parity harness against real groovy.",
      "features": [
        "groovyrs, end to end — Groovy on the shared fusevm machine",
        "The newline-significant lexer and the script-model parser",
        "Lowering Groovy to fusevm bytecode; the GDIV division op and for-in range desugaring",
        "The differential parity harness against real groovy",
        "The LSP language server for editor completion",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "groovyrs-reference": {
      "overview": "The complete groovyrs reference — every Groovy keyword, operator, and builtin the current groovyrs build recognizes, generated from the language server's own corpus so every entry matches the shipping groovyrs binary, each with a runnable example.",
      "features": [
        "Every keyword, operator, and builtin the build recognizes",
        "Grouped by chapter for the Groovy surface",
        "Generated from the src/lsp.rs corpus that also drives editor completion",
        "A runnable Groovy example for every entry",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "pythonrs-reference": {
      "overview": "The dense reference companion to The pythonrs Book — the complete Python surface of the compiled Python runtime on fusevm. Generated from the live implementation rather than written by hand, so the builtin, type, and CLI listings track what the binary actually ships. DRM-free PDF.",
      "features": [
        "Every builtin exposed by the pythonrs runtime",
        "The core type surface and the methods implemented on each",
        "The full command-line interface — running a file, a one-liner, and the REPL",
        "Generated from the live implementation, so it does not drift from the binary",
        "The dense companion to The pythonrs Book",
        "DRM-free PDF"
      ]
    },
    "rlang-reference": {
      "overview": "The dense reference companion to The rlang Book — the complete R surface of the compiled R runtime on fusevm. Generated from the live implementation rather than written by hand, so the primitive, builtin, and CLI listings track what the binary actually ships. DRM-free PDF.",
      "features": [
        "Every primitive and builtin exposed by the rlang runtime",
        "The core vector/attribute surface and the operations implemented on each",
        "The full command-line interface — Rscript on a file, a -e one-liner, and the REPL",
        "Generated from the live implementation, so it does not drift from the binary",
        "The dense companion to The rlang Book",
        "DRM-free PDF"
      ]
    },
    "arb-book": {
      "overview": "The companion book to arb — the pipeline-to-TUI language on fusevm. Pipe any Unix stream into arb and it spawns a dynamic full-screen TUI (and, later, a web page) built from a declarative, Tcl/Tk-flavored spec. The book covers the spec language and its widget/source model, the jq/xpath/css/yq query superset over the live stream, the interactive megafilter/map that shapes the passthrough in place, and the fusevm bytecode VM + Cranelift JIT it runs on — from the zero-config live-tail of Milestone 0 outward.",
      "features": ["arb, end to end — a TUI for every pipeline", "The declarative, Tcl/Tk-flavored spec and its widget/source model", "The jq / xpath / css / yq query superset over the live stream", "The interactive megafilter/map that shapes the passthrough in place", "Running on the fusevm bytecode VM + Cranelift JIT", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "zterminal-book": {
      "overview": "The companion book to zterminal — the GPU-accelerated, cross-platform terminal emulator in Rust. The OpenGL ES glyph-atlas renderer, xterm-compatible VT parsing, native i3-style tiling with one PTY per pane, native tmux control over the wire protocol (no subprocess), the embedded-WebView control panel, and the command-palette-driven workflow — across BSD, Linux, macOS, and Windows.",
      "features": ["zterminal, end to end — the GPU terminal emulator", "The OpenGL ES 2.0 glyph-atlas renderer and xterm-compatible VT parser", "Native i3-style tiling: one shell + PTY per pane, GL-scissored", "Native tmux control via the wire protocol; exposé, broadcast, cross-pane search, session save/restore", "The embedded-WebView control panel, command palette, and TOML configuration", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "powerliners-book": {
      "overview": "The companion book to powerliners — a Rust port of Python's powerline-status statusline/prompt renderer, shipping as a multi-binary suite with zero Python runtime and sub-millisecond render. The segment model and the built-in segment library, the UNIX-socket daemon that speaks the upstream powerline wire protocol, the JSON theme and colorscheme format, and the shell, tmux, vim, and ipython bindings.",
      "features": ["powerliners, end to end — the powerline prompt/statusline system in Rust", "The segment model and adapters — git_status, ci_status, kubecontext, and the net-new segments", "The UNIX-socket daemon and the upstream powerline wire protocol", "Drop-in JSON theme/colorscheme compatibility; tmux, zsh, bash, vim, ipython bindings", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "desktop-in-rust-book": {
      "overview": "Rewriting the Desktop in Rust — the cross-cutting book on the MenkeTechnologies desktop-app fleet and the architecture that ties it together. Ten from-scratch Rust ports — zreq (Postman), zcite (Zotero), ztunnel (Tunnelblick), zgo (Alfred), zftp (Cyberduck), zcontainer (Docker Desktop / Lens), zoffice, zemail, zpdf (Acrobat / Preview), and zphoto (GIMP / Photoshop) — each a thin Tauri v2 shell over a pure-Rust *-core engine that exposes a native Rust API and a C ABI, so the same engine embeds inside every other app, all behind the shared zgui-core toolkit.",
      "features": ["The 'engine core, thin shell' thesis: WebView shell, Tauri command bridge, GUI-free *-core engine", "The *-core pattern and its C ABI embedding contract — ten engines, one shape", "One app per chapter: zreq, zcite, ztunnel, zgo, zftp, zcontainer, zoffice, zemail, zpdf, zphoto", "zcontainer: the first compiled-native desktop GUI for both Docker and Kubernetes, against an all-Electron field", "The embed matrix — how one engine bump reaches every shell that vendors it", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "the-operator-book": {
      "overview": "The Operator \u2014 a working guide to writing software with coding agents, for someone who will be accountable for code they did not type. The premise is that agents do not make programming faster so much as move the bottleneck: production becomes nearly free, review becomes the entire cost, and it gets harder because you did not write the code and get no signal about which parts the model was unsure of. Everything in the book follows from that inversion \u2014 the context file exists to prevent defects that would otherwise need catching, decomposition exists to keep diffs inside what a person will read, and the verification discipline exists because plausibility stopped being evidence. Six parts: Method, Failure, The Fight, Tools and Operations, Verification, and What Does Not Change.",
      "features": ["The context file as the highest-leverage artifact \u2014 what goes in it, section by section, and what its absence produces", "Parallel sessions: what concurrency buys, what it costs, and why review capacity is the real ceiling", "A failure taxonomy: context failure, convergent reinvention, confident wrongness, fabrication, and the audit-tool problem", "The audit-tool rule \u2014 never let anything modify the instrument that measures correctness, with the incident that produced it", "The Fight: the adversarial stance, sycophancy and how it is suppressed, the verification war, and what sustained vigilance costs", "A ledger of rules, each with the failure that produced it, recorded when it happened rather than reconstructed", "Verification without reading every line: mechanical oracles, differential testing, property tests, targeted sampling", "Test theater \u2014 why an agent writing both the code and its tests produces correlated blind spots", "Why the method amplifies expertise rather than substituting for it, and why that widens the gap rather than closing it", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "studio-book": {
      "overview": "The Studio — the cross-cutting book on the MenkeTechnologies audio stack and the two shared C++ cores it stands on. zdsp-core is the shared DSP substrate (the channel strip, the overlap-add time stretcher, the spectrogram analyzer, the lock-free streaming file source, and the playback orchestrator that composes them) and zpwr-patch-core is the signal-agnostic modular patch graph — one templated engine, PatchEngineT&lt;S&gt;, instantiated three ways: float for the mono audio graph, a stereo sample carrying L and R on one cable, and a note-event stream for MIDI. On those two cores sit the four plugins (zpwr-synth, zpwr-fx, zpwr-midi-fx, zpwr-daw), the desktop app Audio-Haxor, and zwire, whose browser-wide equalizer source-ports the same zdsp-core chain into Chromium's audio service so one EQ shapes every sound the browser makes. The book is the continuous account of how one DSP implementation and one graph engine serve a whole product family without any of them re-deriving the work.",
      "features": ["The two shared cores: zdsp-core (the DSP substrate) and zpwr-patch-core (the signal-agnostic patch graph)", "One templated engine, three instantiations: mono float, stereo L/R on one cable, and the note-event MIDI stream", "Mono-to-stereo reuse: the ~3,500 mono blocks wrapped once per channel instead of hand-written stereo copies", "The plugin-host adapter, mono vs stereo: the dual-mono insert vs the native stereo block that doubles as an instrument", "The voice, layer, MIDI, and WebEditor engines that all ride the one graph", "The shared clip engine: a pure-C++ C-ABI core linked native by the DAW and loaded over Rust FFI by the Tauri apps", "The three manifestations of one DSP core: native JUCE, ported into Chromium's audio service, and a JS mirror", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "cli-fleet-book": {
      "overview": "The CLI Fleet — the cross-cutting compendium of every command-line tool in the MenkeTechnologies stack, and the CLI-side twin of 'Rewriting the Desktop in Rust'. Part I is an index: the seven tools that already carry their own book (zshrs, strykelang, awkrs, vimlrs, elisprs, powerliners, ztmux) are situated in the fleet and pointed at their volumes, not re-documented. Part II gives a full, source-grounded chapter to each tool that had none — the Unix reimplementations lsofrs (lsof), nmaprs (nmap), iftoprs (iftop) and htoprs (htop), the shell temporary-file stack manager temprs, the disk-usage TUI storageshower, the two colourisers zcolorizer (its own theme grammar) and grcrs (a port of grc), and the two browser-adjacent native-messaging host binaries zpwrchrome-host (a Rust port of browserpass-native plus extension actions) and zwire-host (the universal local host). An opening chapter, 'The shape of the fleet', frames the shared architecture — the ratatui TUI stack, the CLI/capture layers, the uniform MIT licensing, and the port method.",
      "features": ["Part I: a cross-reference index to the seven CLI tools with their own books", "Part II: a full grounded chapter for each of the ten tools that had none (eight CLI/TUI tools plus the two native hosts zpwrchrome-host and zwire-host)", "A shared-architecture chapter: the ratatui TUI stack, clap/pcap/procfs, the uniform MIT licensing, and the port-parity method", "Port-honest — every reimplementation names its upstream; the original work is the Rust engineering", "The Unix ports: lsofrs, nmaprs, iftoprs, htoprs — architecture, CLI surface, parity vs upstream", "The originals: zcolorizer's theme grammar, storageshower's scanner, the two native hosts' JSON protocols", "The CLI-side twin of 'Rewriting the Desktop in Rust' (the GUI fleet)", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "editor-plugins-book": {
      "overview": "Editor Plugins — the build guide for the editor tooling every fusevm language ships: a VS Code extension, an Emacs major mode, and a Vim/Neovim plugin, three per language. Every code sample is taken verbatim from the shipped arb plugins (vscode-arb, emacs-arb, vim-arb), the most complete member of the matrix. The book works in construction order: first the contract the language binary exposes (--lsp Language Server on stdio, --dap Debug Adapter on stdio, --check static check, and the fixed diagnostic line format), then the GUI-PATH problem — an editor launched from the Dock does not inherit the shell PATH, so the binary resolver hands the client an absolute path or refuses to start — then each editor from filetype detection through syntax highlighting to the language server and debugger. The recurring lesson: the wiring (server spawn, DAP launch, binary resolution) is language-agnostic and copied unchanged; only the grammar (keywords, widgets, verbs) is rewritten per language.",
      "features": ["The shared language-binary contract: --lsp, --dap, --check, and the fixed diagnostic line format the plugins parse", "The GUI-PATH resolver — why a Dock-launched editor can't find /opt/homebrew/bin or ~/.cargo/bin, and the copy-verbatim fix", "The vscode-languageclient --stdio trap: transport: TransportKind.stdio appends --stdio and breaks the handshake — omit it", "VS Code: the package.json manifest, TextMate grammar + language-configuration, activation, the LSP client, and DAP run/debug via DebugAdapterExecutable", "Emacs: define-derived-mode, font-lock + syntax table + syntax-propertize for /regex/, indentation, eldoc/completion from a stdlib data file, and eglot + lsp-mode registration", "Vim/Neovim: ftdetect/ftplugin/syntax/indent/compiler/plugin, the :make --check compiler, and ALE / vim-lsp / coc / nvim-dap wiring", "The one indentation rule expressed three ways — indentationRules regex, arb-indent-line, GetArbIndent — kept in sync", "A copy-vs-rewrite checklist for a new language, and the three invariants: never append a transport arg, resolve against the GUI PATH, degrade to syntax highlighting", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "stryke-ecosystem-book": {
      "overview": "The Stryke Ecosystem — the batteries. The strykelang core ships small and fast; the connection to the outside world lives in a fleet of opt-in packages, one per external system, kept out of the core binary so the daily-driver install stays slim. This book maps that fleet and gives a full, source-grounded chapter to each of its 29 packages, grounded in each package's own README, Cargo.toml, stryke.toml, and examples/. An opening chapter, 'The shape of the fleet', pulls out the shared package model: a thin stryke library plus a Rust cdylib (libstryke_&lt;name&gt;), dlopened in-process on first `use &lt;Namespace&gt;`, calls crossing a uniform JSON FFI boundary, and a connection cache scoped to the whole process run, keyed by URL so repeated calls skip the TCP+TLS+auth handshake.",
      "features": ["An opening chapter on the shared package model — cdylib + [ffi] namespace, JSON boundary, OnceCell connection cache, s pkg install", "Part I Databases: postgres, mysql, mssql, mongo, redis, neo4j, scylla, clickhouse, search", "Part II Data & analytics: arrow, parquet, polars, duckdb, spark", "Part III Messaging & RPC: kafka, zmq, grpc", "Part IV Cloud & infrastructure: aws, gcp, azure, k8s, docker", "Part V Web & automation: scrape, selenium, mcpd, email", "Part VI Documents (office) and Part VII Foundation (utils, gui) — the packages that are not external-system clients, framed honestly as such", "Each chapter names the wrapped crate and the exported verbs from source — no invented APIs, one real example per package", "The connector-fleet companion to the strykelang language reference. Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "zpwr-encyclopedia": {
      "overview": "The complete reference to zpwr — the most advanced UNIX terminal environment, with 500+ subcommands and 2000+ aliases. Every verb, alias, and subsystem, LaTeX-typeset into one volume.",
      "features": ["Every zpwr verb and subcommand (500+)", "2000+ aliases, 47k completions, vim + tmux integration", "Generated from the live zpwr source", "LaTeX-typeset encyclopedia, DRM-free PDF"]
    },
    "ztmux-book": {
      "overview": "The companion book to ztmux — the world's first 100%-functional tmux in Rust. Not a wrapper around the tmux binary and not a control-mode client: it reimplements the whole program — server, client, grid/screen model, input parser, layouts, command language, formats, and terminal back end — in memory-safe Rust, seeded from the tmux-rs port and validated module-by-module against the vendored upstream tmux C source of truth. The book walks that architecture and the port methodology: a parity suite that runs identical inputs through the real tmux and ztmux and diffs them byte-for-byte (1194/1194 cases passing) and an anti-drift gate that fails the build on any Rust function with no tmux C counterpart.",
      "features": ["ztmux, end to end — the whole tmux program reimplemented in Rust", "The client/server split, the libevent loop, and the session/window/pane state tree", "The grid/screen + scrollback model, the VT input parser, and the layout engine", "The lalrpop command language, one file per command mirroring tmux's cmd-*.c", "The port methodology: byte-for-byte parity vs the vendored tmux C source, 1194/1194 cases passing", "The anti-drift gate: no Rust function survives without a tmux C counterpart", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "zwire-book": {
      "overview": "The companion book to zwire — a Chromium/Blink browser forked into the strykelang cyberpunk HUD. Not a WebView wrapper (WebKit, no MV3) and not a fresh engine: a real Blink base, patched and extended, on a dedicated profile that never touches system Chrome. The book walks the full stack the project is built on — the HUD extension workspace (the ztmux tiling overlay, the ⌘K palette, sessions, the internal-page skin) and, under it, the 25 authored C++ patches that compile the native chrome an extension cannot reach (tab geometry, UI fonts, the neon toolbar, native menus and dialogs, the 8 schemes in the color mixer + DevTools, and a browser-wide DSP engine inside Chromium's audio service) against a pinned Chromium tag.",
      "features": ["Why a real Blink base is required — zpwrchrome's Manifest V3 surface (userScripts, declarativeNetRequestWithHostAccess, nativeMessaging, webRequest, service-worker background)", "The unbranded fork build that still carries --load-extension (removed from branded Chrome in v137)", "The 25 HUD patches that restyle the native chrome — tabs, UI font, neon toolbar, omnibox, native menus, the 8 schemes in the color mixer + DevTools — and compile the browser-wide audio engine, written against a pinned Chromium tag", "The ztmux tiling overlay, the ⌘K palette, the new-tab HUD, the internal-page scheme picker, its eight schemes, and the native host", "The automation layer, chapter by chapter: stryke lifecycle hooks (53 catalogued browser events), output triggers on rendered page text, and pane pipelines — reactive dataflow edges between tiled webviews, with the cycle check that refuses a loop", "The audio dashboard over the browser-wide DSP engine: the spec-on-disk control loop, the live meters back-channel, and why it never uses tabCapture", "The dedicated profile and per-user staged extensions — never collides with system Chrome", "The CDP overlay layer and the cross-platform / updating operations matrix", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "inventions-book": {
      "overview": "Firsts — the narrative edition of the MenkeTechnologies invention ledger (INVENTIONS.md). It walks the 268 candidate 'world's first' capabilities across the stack, grouped by subsystem, and holds each to the same falsifiable bar: a genuinely novel capability plus a real in-repo implementation. Every claim carries its basis (files, functions, build artifacts) and an honest caveat — 'no prior art found' is recorded as exactly that, never as proof — plus a high/med/low confidence tag. The six marquee claims get an appendix of adversarial prior-art analyses.",
      "features": ["268 candidate firsts, each as claim + in-repo basis + honest caveat + confidence tag", "The execution engine: a solo from-scratch JIT VM hosting seventeen language frontends on one bytecode", "The compiled Unix shell, the Perl-5 superset, and the fully modular patch-graph DAW", "zcontainer: the first compiled-native desktop GUI for both Docker and Kubernetes", "Appendix: adversarial prior-art analyses for five of the eight marquee (★) claims", "The methodology: how to claim — and how to refute — a first honestly", "Pandoc + LaTeX typeset, DRM-free PDF"]
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
    "vscode-arb": {
      "overview": "A VS Code / VSCodium extension for arb — the pipeline-visualization language — with both an LSP and a DAP.",
      "features": ["*.arb filetype detection", "Hand-written source.arb TextMate grammar (widgets, ~130 query verbs, input sources, /regex/, durations/sizes, dotted widget paths, -flags)", "arb.run command (arb &lt;file&gt;)", "LSP via arb --lsp", "DAP debugging via arb --dap — step the stream, regex breakpoints"]
    },
    "vim-arb": {
      "overview": "Vim / Neovim support for arb — syntax, indent, run, lint, and LSP.",
      "features": ["*.arb filetype detection", "arb syntax + brace-aware indent", "Run / :make via arb --check", "ALE lint via arb --check", "LSP via arb --lsp"]
    },
    "emacs-arb": {
      "overview": "arb-mode for Emacs — a major mode for the arb pipeline language.",
      "features": ["Font-lock for arb keywords, widgets, query verbs, /regex/, widget paths", "Brace indentation + run via arb", "eldoc + completion for query verbs", "LSP via arb --lsp (eglot + lsp-mode)"]
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
    "vscode-elisp": {
      "overview": "A VS Code / VSCodium extension for Emacs Lisp on the elisprs runtime — syntax, running, LSP, and full DAP debugging.",
      "features": ["*.el, .emacs / _emacs, and elisp-shebang filetype detection", "Standalone source.elisp TextMate grammar (special forms, built-in functions, keyword symbols, char literals, quoting)", "elisp.run command (elisp &lt;file&gt;)", "LSP via elisp --lsp", "DAP debugging via elisp --dap — breakpoints, stepping, variables"]
    },
    "vim-elisp": {
      "overview": "Vim / Neovim support for Emacs Lisp (elisprs) — syntax, indent, run, LSP, and DAP.",
      "features": ["*.el / .emacs filetype detection", "Standalone Emacs Lisp syntax grammar + brace-aware indent", "Run / :make via elisp", "LSP (vim-lsp / coc.nvim) via elisp --lsp", "nvim-dap debugging via elisp --dap"]
    },
    "emacs-elisp": {
      "overview": "elisprs-mode for Emacs — a major mode for Emacs Lisp that derives from the built-in emacs-lisp-mode and adds the elisprs toolchain.",
      "features": ["Derives from emacs-lisp-mode (inherits syntax table, indentation, paren handling, font-lock)", "Extra font-lock layer for the elisprs subrs", "Run a buffer through elisp; eldoc + completion over the builtin surface", "LSP via elisp --lsp (eglot + lsp-mode)", "DAP via elisp --dap"]
    },
    "zpwr-theme": {
      "overview": "A cyberpunk editor theme spanning VS Code and JetBrains, generated from one palette.",
      "features": ["VS Code: 8 color schemes × dark/light = 16 themes", "JetBrains: 16 matching UI themes + 16 editor color-scheme XMLs", "Generated from a single palette/schemes.json", "Palette shared with the MenkeTechnologies app-stack HUD"]
    },
    "tmux-fzf-url": {
      "overview": "A tmux key-binding that fzf-pickers every URL visible in the current pane.",
      "features": ["Scans the visible tmux pane for URLs", "fzf picker to select one", "Opens the selection in your default browser", "Zero-config tmux plugin"]
    },
    "gh_reveal": {
      "overview": "Open the current git repository's GitHub page in your browser from the terminal.",
      "features": ["Resolves the repo's GitHub URL from the git remote", "Opens it in the default browser", "One-command reveal", "Heroku remotes open both dashboard.heroku.com/apps/&lt;app&gt; and &lt;app&gt;.herokuapp.com"]
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
    "zmusic": {
      "overview": "A Melodics superset in Rust (Tauri v2 desktop app) behind a cyberpunk HUD — a play-along trainer for keys, pads, and drums that grades your playing against 142 bundled lessons and against your own MIDI and audio files, rather than a closed subscription content library. Every bundled lesson is a committed .mid imported through the same Chart::from_smf a dropped file uses — there is no second content path — and its backing track is rendered from the same chart at the same tempo from t=0. A chart is a zpwr-clip-engine ClipSeq pattern, so the trainer reuses the grid and sequencer engine already behind zpwr-daw instead of inventing a second note format, and a JUCE audio sidecar keeps MIDI input and the playhead in one process — hit-vs-target timing is a subtraction, never an IPC round trip. Its pure-Rust zmusic-core engine is extracted so the same trainer embeds across the GUI stack. In development.",
      "features": [
        "142 bundled lessons plus your own MIDI + audio files — keys, pads, and drums, no closed content library",
        "Charts are zpwr-clip-engine ClipSeq patterns — the same grid/sequencer engine as zpwr-daw, one note format",
        "Scrolling highway play surface: light-guide 88-key keyboard, MPC pad grid, and GM drum lanes",
        "Chord drills — a rep-counting drill engine that records what is played, with kit and pad drills in the kit's own lane order",
        "Dynamic difficulty, practice speed and Wait Mode — the grader's windows derive from the speed you set",
        "Star paths and take history — unstarred lessons ordered easiest-first, exams gated on stars, every take kept",
        "JUCE audio sidecar owns the scoring clock — MIDI-in and the playhead share one process, so grading never crosses IPC",
        "Cyberpunk HUD interface from the shared zgui-core chrome",
        "Embeddable zmusic-core engine (rlib + staticlib + cdylib)",
        "In development — the app and its core are being built out"
      ],
      "screenshots": [
        { "src": "assets/zmusic.webp", "cap": "PLAY tab — a keys lesson on the ClipSeq note grid with draw/paint/slice tools and 1/4–1/32 grid, practice-speed and backing-track controls, the score / accuracy / streak / perfect / miss / extra / mean-err readouts, and the light-guide 88-key keyboard in the cyberpunk HUD" }
      ]
    },
    "ztorrent": {
      "overview": "A from-scratch BitTorrent client in Rust (Tauri v2 desktop app) modeled on Transmission, behind a cyberpunk HUD. The engine carries the session model — torrents, files, peers, trackers, labels — and the policy Transmission applies above the wire: the download/seed queue, ratio and idle seeding limits, the alt-speed (turtle) scheduler, blocklists, and watch folders. Two hand-assessed reports track it — 97.4% of Transmission's 114-feature surface, and 76.7% of an 86-feature surface taken from qBittorrent, Deluge, uTorrent, BiglyBT and Tixati. Formats are handled byte-exactly, and a Transmission RPC translation over HTTP or HTTPS lets existing remotes drive it. Its pure-Rust ztorrent-core engine is extracted so the same client embeds across the GUI stack. In development.",
      "features": [
        "Session model — torrents, queue order, labels, per-torrent limits, per-file wanted/priority flags, with atomic JSON persistence",
        "Download / seed queue — slot limits, stalled detection, and priority",
        "Seeding policy — ratio and idle limits decide when a seed stops",
        "Alt-speed (turtle) scheduler — time window plus weekday bitfield, overnight windows included",
        "Blocklists — P2P plaintext, CIDR, eMule ipfilter.dat and PeerGuardian .p2b binary, sniffed by magic rather than file name, merged into sorted ranges with binary-search lookup",
        "Watch directories — polled, reporting only files whose size has settled",
        "Byte-exact bencode — the info-hash is SHA-1 of the ORIGINAL info bytes; .torrent read/write and magnet parse/build (hex + Base32)",
        "BitTorrent wire via a vendored librqbit fork — peers over TCP and µTP, HTTP/UDP trackers, DHT, local discovery, peer exchange, magnet metadata, UPnP; patched where upstream exposed no knob (queue order, live file priorities, super-seeding)",
        "RSS — RSS 2.0 and Atom feeds, auto-download rules in word or regex mode, season/episode ranges, and a seen-list so a refresh takes nothing twice",
        ".torrent creation — tracker tiers, comment, source, private flag and web seeds; magnet build/parse",
        "Super-seeding (BEP 16) on the wire — one rarest piece per peer at a time, also selectable as a share-limit action",
        "Categories, subcategories and saved views — a category is a save path plus its own share and speed limits, and changing it moves the payload",
        "Disk preallocation and content layout for new torrents — off, sparse, or a real block reservation",
        "Play a torrent while it is still downloading — first and last pieces first, files queued in order",
        "Transmission RPC compatibility over HTTP or HTTPS — transmission-remote and the phone apps speak to this engine unchanged; email notification on completion",
        "Client view from zgui-core — status-filter sidebar with live counts, a sortable/resizable table with fuzzy filtering, and an Info / Files / Peers / Trackers / Options details pane",
        "Embeddable ztorrent-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps",
        "In development — the app and its core are being built out"
      ],
      "screenshots": [
        { "src": "assets/ztorrent.webp", "cap": "Client view — status-filter sidebar with live counts, the sortable torrent table (size, done, status, up/down, ratio, ETA, peers), add/magnet/start/pause/remove and turtle-mode actions, and the Info / Files / Peers / Trackers / Pieces / Options details pane in the cyberpunk HUD" }
      ]
    },
    "zlatex": {
      "overview": "A from-scratch LaTeX editor in Rust (Tauri v2 desktop app) behind a cyberpunk HUD: source on the left, live-typeset pages on the right. There is no external TeX distribution and no subprocess — no pdflatex, no MacTeX, no tectonic; TeX's own pipeline is implemented in the crate, text mode included (preamble, sectioning, cross-references, Knuth–Plass line breaking, page building), with math layout parameters sourced from the loaded face's OpenType MATH table instead of hardcoded constants. Its pure-Rust zlatex-core engine is extracted so the same typesetter embeds across the GUI stack. In development.",
      "features": [
        "TeX's pipeline in Rust — category codes, macro expansion (\\def / \\newcommand / \\let), the math grammar, and box-and-glue layout (mlist_to_hlist) with the 8×8 inter-atom spacing table",
        "Layout parameters read from the font's OpenType MATH constants, so the engine's measurements and the painted result cannot drift",
        "No TeX distribution, no subprocess, nothing to install",
        "Structure — the \\frac family, \\sqrt with an optional index, \\left…\\right delimiter growth, scripts, primes, accents, \\overline / \\underline",
        "Environments — matrix, pmatrix, bmatrix, Bmatrix, vmatrix, Vmatrix, cases, aligned, and array with a column spec",
        "Alphabets mapped to real Unicode math code points — \\mathbb{R} is U+211D, not a styled R",
        "Live preview mapped both ways — every glyph run carries the byte span of the source that produced it, so a click on the ink selects the source",
        "Export — SVG, PNG, and PDF drawn from glyph outlines; an exported PDF carries its LaTeX source and re-opens as an editable equation",
        "Equation library (bundled SQLite) and symbol palettes generated from the control-sequence table",
        "One JSON command bus — app, CLI, and the automation bus all enter through it, so every GUI feature is scriptable",
        "Text mode as well as math — documents typeset to real pages via Knuth–Plass line breaking, TeX's own hyphenation patterns, footnotes at the foot of their page, floats with captions, and page building, not single-formula previews",
        "Books, not just files — \\input and \\include resolve against the open document, so a book split across chapter files previews as one book with one outline",
        "The reference fixed point, proved or refuted — a document is finished only when a pass reads exactly the numbers and pages it wrote, so the layout iterates in memory and reports either the pass it converged on or the cycle and its period, naming every entry that alternates and every \\ref / \\pageref site that read one, at a source line and column, with what it printed on each pass",
        "TeX Live package manager in the editor — Updates / Packages / This document tabs, status joined from the local texlive.tlpdb against the mirror, installs unpacked into ~/.zlatex/texmf with no tlmgr, no perl and no root; Ingest macros mines a .sty and reports what it could not honour",
        "Editor pane with syntax highlighting, minimap, Vim and Emacs keymaps, and 50–200% preview zoom",
        "Embeddable zlatex-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps",
        "In development — the app and its core are being built out"
      ],
      "screenshots": [
        { "src": "assets/zlatex.webp", "cap": "Split editor — LaTeX source with syntax highlighting and a minimap on the left, the typeset page (title, section, inline math, numbered display equation) on the right, plus display/inline mode, Vim and Emacs keymaps, zoom, and SVG / PNG / PDF export in the cyberpunk HUD" }
      ]
    },
    "zpdf": {
      "overview": "A from-scratch PDF editor in Rust (Tauri v2 desktop app) that replaces Adobe Acrobat and macOS Preview — full document editing, annotation, forms, and signatures behind a cyberpunk HUD, with a scriptable CLI on the same engine. The port report catalogs 293 features across the Acrobat Pro + Preview surface and all 293 are implemented and cited to real code. zpdf-core parses and writes the PDF object model directly, so linearization, font subsetting and redaction that truly removes content are first-class rather than bolt-ons, and the same pure-Rust engine embeds inside the other apps.",
      "features": [
        "Full PDF editing — text, images, and objects on parsed content streams",
        "Annotation & markup — highlight, notes, shapes, freehand ink, stamps, measure",
        "AcroForms — create, fill, and flatten form fields",
        "Digital & certificate signatures — sign and validate",
        "OCR — recognize text into a searchable layer",
        "Redaction that truly removes content, plus sanitize hidden data",
        "Page management — insert / delete / extract / merge / split / rotate / crop",
        "Convert & export — Office formats, images, text, PDF/A",
        "Review & compare — diff two PDFs at line, word and structural level, comment summary, review tracking",
        "Accessibility — tags, reading order, alt text, accessibility check, PDF/A and PDF/UA preflight validation",
        "Optimize & print production — reduce size, lossless stream recompression, downsample, embed/subset fonts, linearize, color separations, per-page ink coverage (TAC)",
        "Automation — Action Wizard batch, a CLI on the same engine, and a document JavaScript console",
        "Document tabs and 2 / 3 / 4-up split-view panes — many PDFs open at once, each pane with its own document, scroll and zoom; Page Organizer (⌘⇧P) reassembles a new PDF from any pages of any open document",
        "Beyond every competitor — an in-file content-addressed Merkle version-control DAG (log / diff / blame / bisect / time-travel checkout, plus branching and three-way merge) stored in the .pdf's own trailer, a PII scanner with one-shot privacy-sweep redaction, a machine-checkable verifiable-redaction guarantee, deterministic byte-stable export, and live recalculable page tables with per-number provenance",
        "Embeddable zpdf-core engine (rlib + staticlib + cdylib) — embeds into traderview and the other GUI apps"
      ],
      "screenshots": [
        { "src": "assets/zpdf.webp", "cap": "Two-page spread view — page thumbnails, the PAGE / TEXT / FIELDS / METADATA / BOOKMARKS / TIMELINE / INSIGHTS / COMPARE tabs, and open/merge/extract/export actions in the cyberpunk HUD" }
      ]
    },
    "zphoto": {
      "overview": "A from-scratch image editor in Rust (Tauri v2 desktop app) that replaces GIMP, Photoshop and Illustrator, behind a cyberpunk HUD. Two engines behind one command surface: a raster engine at 97.7% of a 302-feature Photoshop checklist, and a separate vector engine at 69.7% of a 66-feature Illustrator checklist that rasterizes into the same layer stack — SVG is the interchange format, and AI files route through the zpdf-core PDF engine. 477 tests. Its pure-Rust zphoto-core engine is extracted so the same imaging engine embeds inside the other apps.",
      "features": [
        "Layer-based raster editing with blend modes, masks, groups and adjustment layers — 8, 16 and 32-bit pixels with an editable indexed colour table",
        "Selections, masks, brushes, and paint tools",
        "Filters and non-destructive adjustments — destructive point ops (Exposure, Temperature, Colour Balance, …) preview live on-canvas while you drag and only commit on OK, through the engine undo stack",
        "Open / edit / export common image formats, plus layered PSD and XCF read and write",
        "Vector mode — an Illustrator port: Bézier paths, fills and strokes, compound paths, expand, path editing (simplify / join / average / add-remove anchors), scissors and knife, transform-each, radial / grid / mirror Repeat, Select-Same",
        "Vector effects — Warp envelopes, Tweak / Free Distort / Convert-to-Shape, 2.5-D Extrude and Revolve, 3D rotate, linear / radial / mesh / freeform gradients, Live Paint bucket, Flare and Symbol Sprayer",
        "Photoshop-style chrome — menu bar, context-sensitive Tool Options Bar, and right-dock Layers / Channels / Paths / Swatches / Adjustments / Styles / Color panels, on the Photoshop default keyboard map",
        "Cyberpunk HUD interface from the shared zgui-core chrome",
        "Embeddable zphoto-core engine (rlib + staticlib + cdylib) — embeds into the other GUI apps"
      ],
      "screenshots": [
        { "src": "assets/zphoto.webp", "cap": "Raster editing workspace — layers panel, tool palette, brushes and selections, and non-destructive adjustments in the cyberpunk HUD" }
      ]
    },
    "zemail": {
      "overview": "A from-scratch desktop email client in Rust (Tauri v2) behind a cyberpunk HUD — 100% coverage of the Thunderbird feature surface (69 features) plus a 76-feature cross-client layer ported from Gmail, Apple Mail, Outlook, ProtonMail, Hey, Spark and Superhuman. IMAP (IDLE push, UID-incremental sync), POP3 and SMTP with browser OAuth2 / XOAUTH2 sign-in; OpenPGP message crypto and CardDAV contact sync; seven engine consoles (Mail Tools, Lab, Workbench, Ops, Forensics, Crypto, Settings) drive the raw command surface with no stubs. Its pure-Rust zemail-core engine is extracted so the same mail engine embeds across the GUI stack.",
      "features": [
        "100% Thunderbird port coverage (69 features) + 76 cross-client features",
        "IMAP with IDLE push and UID-incremental sync, POP3 download, SMTP send",
        "Browser OAuth2 / XOAUTH2 sign-in for Google, Microsoft 365 and Outlook.com",
        "OpenPGP sign / verify / encrypt via rPGP; CardDAV vCard sync; S/MIME in the engine",
        "RFC 5322 / MIME parsing, RFC 2047 + quoted-printable + format=flowed encoders",
        "JWZ conversation threading, Sieve (RFC 5228) export, JMAP Email/query model",
        "Snooze, send-later, undo-send, screener, VIP, vacation responder, templates",
        "Explainable phishing, triage-importance and tracking-pixel scoring — offline, no model",
        "Sender Identity Firewall — per-sender behavioural baselines flag impersonation and takeover",
        "Revision Ledger — BLAKE3 attachment identity plus content-delta drift across the archive",
        "Cyberpunk HUD interface",
        "Embeddable zemail-core engine (rlib + staticlib + cdylib) with a C ABI + C++ wrapper",
        "Owned, no-subscription desktop mail"
      ],
      "screenshots": [
        { "src": "assets/zemail.webp", "cap": "Mail client — folder sidebar, message list, and reading pane over the IMAP/SMTP zemail-core engine in the cyberpunk HUD" }
      ]
    },
    "zstation": {
      "overview": "A workspace of isolated web apps in Rust (Tauri v2) behind a cyberpunk HUD — a from-scratch port of the defunct station.app. Named dashboards arrange your web apps as Trello-like draggable, resizable tiles, each running in its OWN native, session-isolated webview (per-partition WKWebView data store on macOS / WebView2 data directory on Windows) so logging into one never spills cookies or storage into another; any dashboard pops out into its own OS window for multi-monitor use. A tile is not only a site — 70 native widget kinds render in the tile body, and the whole workspace is one SQLite database with an FTS5 index across every tile and note. Its pure-Rust zstation-core engine is extracted so the same station board embeds across the GUI stack.",
      "features": [
        "Workspace of web apps in Rust + Tauri v2, ported from station.app",
        "Per-service session isolation via native child webviews (WKWebView / WebView2), not iframes",
        "143-service built-in catalog plus arbitrary custom URLs, each in its own partition",
        "70 native widget-tile kinds — notes, todos, kanban, charts, timers, PTY terminal, MIDI-style control surfaces",
        "Named dashboards with ⌘1–9 switching; pop a dashboard into its own OS window, one per monitor",
        "Station Wiring — a local Source → Transform → Sink bus that drives one logged-in app from another, no OAuth, no cloud",
        "Session Lens — fire one path at N authenticated tiles and field-wise diff what each account sees",
        "Session Branching — copy-on-write snapshot and restore of a whole board's sessions plus layout",
        "SQLite workspace with an FTS5 index over every tile and note; durable toast history",
        "ztranslator-core embedded: cron / knob / slider / pad widgets inject System Events into translator presets",
        "Cyberpunk HUD interface",
        "Embeddable zstation-core engine (rlib + staticlib + cdylib)"
      ],
      "screenshots": [
        { "src": "assets/zstation.webp", "cap": "One board of session-isolated web apps — Trello-like draggable, resizable tiles, each its own native webview, in the cyberpunk HUD" }
      ]
    },
    "zoffice": {
      "overview": "A from-scratch office suite in Rust (Tauri v2 desktop app) that replaces Microsoft Office and LibreOffice — documents, spreadsheets, presentations, drawings, formulas and databases behind a cyberpunk HUD. 236 of 245 catalogued LibreOffice / MS Office features are implemented (96%, 0 stubbed): read and write ODF + OOXML plus legacy .doc/.xls/.ppt and .rtf, evaluate formulas, render page layout, and export PDF. Its pure-Rust zoffice-core engine is extracted so the same office engine embeds inside the other apps.",
      "features": [
        "245 LibreOffice / MS Office features catalogued; 236 implemented (96%), 0 stubbed",
        "Rust office engine — Writer 49/49, Calc 67/69, Impress 29/29, Draw 11/11, Math 5/6, Base 9/11",
        "Reads and writes ODF + OOXML (.odt/.docx, .ods/.xlsx, .odp/.pptx) plus legacy .doc/.xls/.ppt, .rtf, .csv",
        "Formula evaluation, page-layout rendering, and PDF export for Writer, Calc and Impress",
        "Encrypted ODF/OOXML packages, XML digital signatures, OLE2 compound-file parsing",
        "zmerge — a git merge driver that reconciles parsed .docx/.odt models instead of failing on the blob",
        "zblame — structural git-blame attributing each paragraph to the revision that last changed it",
        "Calc recalculation critical path and dependency blast radius (keystone cell) — graph analyses no spreadsheet ships",
        "Cyberpunk HUD interface",
        "Embeddable zoffice-core engine (rlib + staticlib + cdylib)",
        "Owned, no-subscription office suite"
      ],
      "screenshots": [
        { "src": "assets/zoffice.webp", "cap": "Office suite — Writer / Calc / Impress editing over the ODF/OOXML zoffice-core engine in the cyberpunk HUD" }
      ]
    },
    "zshrs": {
      "overview": "A drop-in zsh replacement written in Rust that compiles shell commands to bytecode and runs them on a virtual machine instead of forking, with a persistent worker thread pool replacing fork+exec. Framed as the first compiled Unix shell.",
      "features": [
        "854k lines, 824 source files across a 3-crate workspace — zshrs runtime + zshrs-daemon + znative",
        "Compiles commands to fusevm bytecode with Cranelift JIT",
        "Persistent worker thread pool (2–18 threads) replaces fork+exec",
        "53 coreutils commands run in-process, zero fork",
        "100× warm-start speedup (717ms cold to 7ms warm)",
        "rkyv-backed bytecode image cache, mmap hot path",
        "193 ZLE widgets, 47 fish-ported builtins",
        "248 builtins — 157 in the zsh port table plus 91 extension builtins; zsh and bash compatibility",
        "Built-in LSP server, DAP debug adapter, JetBrains plugin",
        "234-opcode fusevm 0.17 bytecode, AOP intercepts, parallel primitives (pmap/pgrep/peach)"
      ]
    },
    "elisprs": {
      "overview": "Emacs Lisp in Rust — run .el files outside Emacs. A Lisp-2 interpreter with a separate-value/function-cell obarray, dynamic binding, and an elisp-correct reader built on its own ElispHost value model, lowered onto the fusevm bytecode VM that already backs stryke, zshrs, awkrs, and vimlrs. Ships as a standalone elisp binary with a REPL. Free and open source.",
      "features": [
        "Elisp interpreter in Rust — runs .el files standalone, no Emacs required",
        "Lisp-2 obarray with separate value and function cells",
        "Dynamic binding and an elisp-correct reader on its own ElispHost value model",
        "Lowering onto the fusevm bytecode VM (the engine behind stryke, zshrs, awkrs, vimlrs)",
        "22 special forms and 252 subrs, plus an 889-name elisp prelude porting subr.el, cl-lib, seq.el, map.el, ring.el, nadvice and text-property-search",
        "Standalone elisp binary with an interactive REPL and an rkyv bytecode cache",
        "LSP language server, DAP debugger, and AOT native compilation",
        "Free / OSS — MIT licensed"
      ]
    },
    "zmax": {
      "overview": "A zero-configuration modal IDE in Rust: install the binary, open a project, and get LSP, a DAP debugger, tree-sitter, a fuzzy file picker, a project tree, a real PTY terminal, magit-style git, and run configs — no init.el, no plugin manager, no setup ritual. It is a Vim / Emacs / Spacemacs / JetBrains superset with 5 keymap presets (spacemacs by default, plus vim, helix, emacs and cua), switchable at runtime. The generated port report measures it against cited Neovim, GNU Emacs, Spacemacs, JetBrains, Cursor and fzf.vim inventories: 5973 of 6847 items ported (87.2%), and 185 of 186 deduplicated capabilities (99.5%). This is the terminal editor; the windowed GUI front-end ships separately as zmax-gui. Free and open source.",
      "features": [
        "Zero configuration — LSP, DAP debugger, tree-sitter, fuzzy picker, project tree, PTY terminal, magit-style git and run configs all work on first launch, from one static binary",
        "12 embedded scripting interpreters — elisp, vimscript, awk, zsh, stryke, ruby, php, python, node, arb, tcl and R, each a pure-Rust crate sharing one host API with no FFI between them",
        ":xpipe — filter a selection through a chain of those languages in-process; an N-stage chain is N function calls, no fork and no execve, landing as one undo step",
        "5 keymap presets — spacemacs (default), vim, helix, emacs and cua; switchable at runtime with :keymap",
        "Native plugins — an ordinary Rust cdylib loaded at runtime over a frozen, versioned C ABI, registering typable : commands with no editor recompile",
        "Built-in TUIs — snippet library, hex editor, 3-pane merge resolver, org-mode with a date-aware agenda, IDE workbench, comint shell and a searchable help browser",
        "2268 static commands, 2585 typable : commands and 4227 default keybindings, re-derived from source by the port report on every run",
        "Terminal IDE; the windowed GUI build is zmax-gui",
        "Free / OSS — MPL-2.0 licensed"
      ],
      "screenshots": [
        { "src": "assets/zmax/editor.webp", "cap": "zmax in NOR mode — file-tree, split editors over stryke source, the IDE action menu (Find Usages, Refactor, Run/Debug, Git), and an embedded terminal, all running in the terminal" }
      ]
    },
    "zmax-gui": {
      "overview": "A native desktop GUI for the zmax IDE. It wraps the zmax modal-editing core in a windowed front-end, the way MacVim wraps the Vim CLI editor: a Tauri v2 shell running the editor in an embedded PTY under a full menu bar, toolbar, ⌘K palette and native file dialogs, with an IDE project workbench and in-process office/PDF document search and blame layered on top. Free and open source.",
      "features": [
        "GUI front-end over the zmax terminal IDE — same modal core, native window",
        "A 21-menu menu bar, a toolbar, a ⌘K palette over every action, and a right-click context menu â each bridged into the editor as an ex-command",
        "Native open/save dialogs and drag-and-drop",
        "Modal editing, tree-sitter syntax, and LSP inherited from the zmax core",
        "Cross-platform",
        "Free / OSS — MPL-2.0 licensed"
      ],
      "screenshots": [
        { "src": "assets/zmax-gui.webp", "cap": "zmax-gui — the windowed front-end over the zmax modal IDE core: native tabs, menu bar, GUI font rendering, and split editors" }
      ]
    },
    "zwire": {
      "overview": "A Chromium/Blink browser forked into a cyberpunk HUD — not a theme and not a wrapper, but a real engine compiled from a 27-patch C++ source fork of Chromium and running a full keyboard-driven, tiling workspace on top. The fork restyles the native chrome the extension layer can't reach — sharp 2px tab shapes, the Share Tech Mono UI font, a neon under-toolbar line, a sharp omnibox, native Views menus and dialogs bound to the HUD palette, and the 8 HUD schemes wired into the color mixer + DevTools — and compiles a browser-wide DSP engine into Chromium's audio service so one chain shapes every sound the browser makes. Layered over it, the HUD (extensions/hud-internal) adds a tmux-style tiling overlay, a ⌘K command palette, vim-style motions, a find bar, a powerline status bar, durable session management, stryke lifecycle hooks, page-content triggers, reactive pane pipelines, and 23 HUD pages that reimplement Chrome's own internal pages — all against a dedicated profile so it never touches your system Chrome. Free and open source.",
      "features": [
        "27-patch C++ source fork of Chromium (pinned tag) that restyles the native chrome: sharp 2px tabs, Share Tech Mono UI font, neon under-toolbar line, sharp omnibox, the 8 HUD schemes in the color mixer + DevTools, native menu/dialog colors bound to the HUD palette, plus allow-framing so ztmux can iframe any site",
        "Browser-wide audio engine compiled into Chromium's audio service — an always-on zdsp-core chain (EQ cascade, channel strip, saturation/dynamics, modulation, delay + reverb, spatial, brickwall limiter) on every output stream (media element, MSE/YouTube, Web Audio, WebRTC), live-reconfigurable with nothing open and no relaunch, with real post-DSP spectrum and meters pumped back to the Audio HUD page",
        "ztmux — a tmux server in the browser: recursive binary pane splits, unlimited windows, every pane a live webview of any URL, driven by a rebindable prefix with 49 remappable actions (panes, layouts, windows, partial synchronize-panes, copy mode, marks, clock)",
        "⌘K command palette (zpalette), vim-style motions (zkeys/zvim), a find bar (zfind), and a powerline status bar (zpowerline)",
        "Durable named sessions saved to chrome.storage — full CRUD page (create / rename / duplicate / delete / load / import-export) with per-pane URL editing and a live SVG preview of each window's tiling",
        "stryke lifecycle hooks — bind scripts to 53 catalogued browser events (tab / window / navigation / download / bookmark / terminal / scheme / audio / ⌘K-command, plus an action catch-all), run by zwire-host with the event JSON on stdin",
        "Output triggers — bind a regex to page text as it renders and streams, then run a chain of typed steps (shell / stryke / JS / AppleScript / batch / browser-action / scheme / host) with the matched line as {q}; per-trigger cooldown, once-per-page mode, URL filter",
        "Pane pipelines — a persisted, reactive dataflow edge between tiled webviews: extract from a source pane (selector / regex / selection / URL), transform it (a stryke |> op chain, JS, or passthrough), deliver it to a sink pane (navigate / fill / replace / append / batch-open), with a graph cycle-check that refuses an A→B→A loop",
        "One namespaced browser.* automation verb bus — tab / group / window ops, edge snapping, navigation, downloads, browsing-data clearing, bookmarks, reading list, extensions, power, screenshot, notify, tmux toggle — driven by the palette, shortcuts, and hooks through a single service-worker executor and published as a typed, introspectable manifest",
        "23 HUD pages reimplementing chrome://{extensions,settings,history,bookmarks,downloads,version} plus Audio, Hooks, Triggers, Pipelines, Terminal, Notes, Feeds, Translate, Reading list, a dashboard, a Keyboard remapper, Commands, Sessions, CI, a Host console, and an in-browser App Store tab",
        "8 color schemes (cyberpunk, midnight, matrix, ember, arctic, crimson, toxic, vapor), each with a light variant, driving the browser chrome natively with a light/dark toggle synced across the HUD, new-tab page, and zpwrchrome",
        "Built on zgui-core — the shared ZGui cyberpunk web-component toolkit (260 webui modules), loaded straight from the submodule path so no copy can go stale",
        "zpwrchrome MV3 power-tool preloaded as a submodule (reuse, not copy) against a dedicated profile — needs a real Blink engine for userScripts, declarativeNetRequestWithHostAccess, nativeMessaging, webRequest, and a service-worker background",
        "Free / OSS — MIT licensed"
      ],
      "screenshots": [
        { "src": "assets/zwire/tmux.webp", "cap": "ztmux — the tmux-style tiling overlay running in the forked Chromium HUD: recursive pane splits, each pane a live webview, driven by a rebindable prefix and the powerline status bar" },
        { "src": "assets/zwire/audio.webp", "cap": "The Audio HUD page — a browser-wide C++ audio engine applied live to every tab: the full signal chain, an always-on preamp + compressor, an 8-band draggable parametric EQ, and a metering column (peak/LUFS, stereo goniometer, phase correlation, VU)" },
        { "src": "assets/zwire/audio2.webp", "cap": "The Audio HUD engine strip — gain/pan/mono/drive, space & glue (width/delay/reverb/limiter), and the two FX racks (gate·crush·exciter·Haas·cross-feed·chorus·flanger·phaser, then waveshaper·ring-mod·tremolo·auto-pan·auto-wah), over a live spectrum analyzer and scrolling spectrogram" }
      ]
    },
    "zwire-host": {
      "overview": "A single self-contained Rust binary (~500 KB, no Python, no psutil) that exposes the local machine to any app over one JSON message protocol. It began as the Chrome native-messaging host for zwire's HUD and is now a universal local endpoint — reachable from a browser extension and, as a newline-delimited-JSON local-socket daemon, from tmux, emacs, desktop apps, plugins, shell scripts, and any language. Both transports feed the same dispatcher, so every command works over either one. Free and open source.",
      "features": [
        "One static Rust binary, zero runtime dependencies — no system Python, no pip install psutil, nothing to break on a fresh machine",
        "Two transports, one dispatcher — Chrome native messaging (u32-length + JSON) and a local-socket daemon (Unix domain socket / Windows named pipe, newline-delimited JSON)",
        "Streams live system stats (sysinfo), runs PTY terminals (portable-pty), crawls and watches/tails the filesystem, and execs commands",
        "Background jobs that notify on completion, process list/kill, clipboard / notify / open, and a per-app key/value store",
        "A pub/sub event bus that federates across a mesh of peered hosts",
        "Also a Rust library — sibling hosts (e.g. zpwrchrome-host) embed it as a dependency",
        "Free / OSS — MIT licensed"
      ],
      "screenshots": [
        { "src": "assets/zwire/host.webp", "cap": "zwire-host — the single self-contained Rust binary exposing live system stats, PTY terminals, filesystem crawl/watch, background jobs, and the pub/sub event bus over one JSON protocol" }
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
        "10,488 stdlib primaries (11,266 keys in %all including 688 aliases and 90 keywords)",
        "48.5 MiB single static binary, sub-10ms cold start",
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
        "441 documented builtins; the 106 that need a live editor are flagged as standalone stubs rather than faked",
        "AOP :Intercept advice on user-function calls — before/after/around, no Vim counterpart",
        "Inline rust { } FFI blocks callable as VimL functions",
        "163 self-testing examples/*.vim run in CI, plus a differential fuzzer against Vim 9.2 and Neovim 0.12",
        "Standalone binary, REPL, LSP language server, DAP debugger, and AOT native compiler",
        "Free / OSS — MIT licensed"
      ]
    },
    "rubyrs": {
      "overview": "Ruby in Rust — a compiled Ruby runtime. MRI runs Ruby by walking an AST in C; rubyrs lexes and parses Ruby to an AST, lowers it to fusevm bytecode, and runs it on a compiled VM with a three-tier Cranelift JIT — the same engine behind zshrs, stryke, awkrs, and elisprs. Arithmetic and comparison operators lower to native VM ops so the JIT can trace hot loops, while Ruby-specific behaviour (method dispatch, blocks, object construction, yield) is served by a thread-local runtime host. rubyrs carries no VM or JIT of its own. Free and open source.",
      "features": [
        "Compiled Ruby runtime — Ruby source → lexer → parser (AST) → fusevm bytecode → VM + Cranelift JIT",
        "Arithmetic and comparison lower to native VM ops so the JIT traces hot loops",
        "RubyHost heap serves method dispatch, blocks, object construction, and yield",
        "Classes, exceptions, modules/include, super, class methods, parallel assignment, default + splat params, &:sym block-pass",
        "Runs a file, a one-liner (ruby -e), or an interactive REPL (ruby --repl)",
        "Real OS threads under a GVL, exactly like MRI — Thread#join/#value, Mutex, Queue/SizedQueue, and ConditionVariable, with a blocking pop releasing the GVL",
        "Requireable stdlib built into the binary — json, set, date/time, securerandom, digest, base64, ostruct, socket, sqlite3, fiddle, plus bundled pure-Ruby uri, csv, optparse and yaml",
        "A real on-disk SQLite3::Database backed by an in-tree SQLite (no gem, no FFI), and a pure-Ruby ActiveRecord subset over it — relations, finders, validations, callbacks, associations",
        "Genuine C calls through Fiddle — dlopen, symbol resolution, and libffi-marshalled Fiddle::Function invocation",
        "AOT — ruby --build bundles an app and every file it requires into one cached program; ruby --build --native emits a standalone executable that needs no interpreter and no .rb sources",
        "AOP method intercepts, an LSP server, a DAP debugger with in-method breakpoints, and an irb-style REPL",
        "Differential parity harness: a 398-snippet corpus diffed against real Ruby 4.0.6, frozen and replayed in CI",
        "Free / OSS — MIT licensed"
      ]
    },
    "arb": {
      "overview": "Visualize and modify Unix pipelines. Pipe a stream into arb and it spawns a dynamic full-screen TUI (and, later, a web page) built from a declarative, Tcl/Tk-flavored spec. It is a jq / xpath / css / yq superset, an interactive megafilter/map over the live passthrough, and it runs on the fusevm bytecode VM + Cranelift JIT. Milestone 0 ships zero-config live-tail — pipe any stream in and watch it in a full-screen TUI; with no controlling terminal it prints a headless summary instead. Free and open source.",
      "features": [
        "A TUI for every pipeline — pipe any Unix stream in, get a dynamic full-screen TUI",
        "Declarative, Tcl/Tk-flavored spec drives widgets, layout, and sources",
        "A jq / xpath / css / yq query superset over the live stream",
        "Interactive megafilter/map that shapes the passthrough in place",
        "Runs on the fusevm bytecode VM + Cranelift JIT",
        "Zero-config live-tail (Milestone 0); headless summary when there is no TTY",
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
        "13 broker importers plus a Generic CSV column-mapping wizard",
        "17 reports plus R-multiple, Monte Carlo, fill-quality TCA, tax-lot tracker",
        "139 stateless financial calculators under /calc",
        "Asset classes: stocks, options, futures, forex",
        "On-device receipt OCR with 20-bucket Schedule C taxonomy",
        "stryke-JIT backtest engine, walk-forward sweeper, strategy alerts",
        "Schema: 125 tables, 179 indexes, 25 enum types; money is NUMERIC(20,8)"
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
        "65 superset extensions beyond BOME — response curves, musical scale snap, LFO/ADSR generators, swing + groove, strum, note-repeat, velocity compression, SMF/SysEx builders, offline rules-VM debugger"
      ],
      "screenshots": [
        { "src": "assets/ztranslator.webp", "cap": "Translator table mapping incoming MIDI/OSC/DMX triggers to outgoing actions" }
      ]
    },
    "zcite": {
      "overview": "A from-scratch reference manager in Rust (Tauri v2 desktop app) that replaces Zotero — library, citations, and bibliographies behind a cyberpunk HUD. Its pure-Rust zcite-core engine is extracted so the same reference engine embeds inside the other apps.",
      "features": [
        "Library — all 37 Zotero item types, nested collections, colored tags, saved searches, related items, notes + annotations, trash/restore, group libraries",
        "Citations & bibliographies — APA, MLA, Chicago (author-date + notes), IEEE, Vancouver, Harvard, AMA, Nature, or any loaded .csl via the built-in CSL processor",
        "Import / export — BibTeX, BibLaTeX, RIS, CSL-JSON, CSL-YAML, EndNote XML + tagged, MODS, MARCXML, Zotero RDF, PubMed/DataCite/CrossRef JSON, JSON-LD, COinS, RTF, HTML, CSV/TSV, Markdown",
        "Identifier lookup — DOI (CrossRef), ISBN (Open Library), PMID (NCBI), arXiv, plus metadata retrieval from a PDF's text and /Info block",
        "Duplicate detection + merge — exact DOI/ISBN/title bucketing plus a fuzzy near-duplicate tier with a non-destructive per-field merge preview",
        "Serverless conflict-free sync — Lamport-stamped op log over any folder or WebDAV, field-level CRDT merge, no account and no conflict dialog",
        "Citation-aware 3-way .docx merge — installs as a git merge driver for co-authored manuscripts",
        "Quote & locator attestation — checks quoted spans against the cited PDF page with typed verdicts, fully offline",
        "zcite-lsp — a citation Language Server for .tex / .md / .qmd / .typ with live diagnostics, quick-fixes and cite-key completion",
        "Style-inverse decompiler — recovers structured items from a plain reference list, then restyles A to B",
        "Embeddable zcite-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps"
      ],
      "screenshots": [
        { "src": "assets/zcite.webp", "cap": "Reference library — collections, tags, and per-item metadata with citation/bibliography styles in the cyberpunk HUD" }
      ]
    },
    "zreq": {
      "overview": "A from-scratch API client in Rust (Tauri v2 desktop app) that replaces Postman — build, send, and organize HTTP requests behind a cyberpunk HUD. Its pure-Rust zreq-core engine is extracted so the same request engine embeds inside the other apps.",
      "features": [
        "Workspaces, collections, and saved requests",
        "Environments, variables, and token expansion",
        "Auth — basic, bearer, api-key, OAuth 2.0 (attach + token acquisition), Digest, OAuth 1.0, AWS Signature v4 and Hawk, inherited request to folder to collection",
        "HTTP execution with full request/response history",
        "Code generation to 16 targets — curl, wget, http, fetch, Node, Python, HTTPie, Go, Java, C#, PHP, Ruby, Rust, Swift, Kotlin, PowerShell",
        "Import curl / Postman v2.1 / OpenAPI 3 / HAR / Insomnia / Bruno / HTTPie; export Postman v2.1, HAR, OpenAPI and Bruno; .env import/export on environments",
        "Collection runner — depth-first request plan with CSV/JSON data-file iterations",
        "Native pm.* test assertions (status / time / body / header) and variable writes — no JS sandbox",
        "GraphQL Explorer with schema introspection, an OAuth 2.0 token manager, and a structural response-diff panel",
        "Tools workbench — JWT, hash/HMAC, encoding, JSONPath/JMESPath, JSON-Schema, secret scan, PKCE, fuzz, HAR analyze, OpenAPI diff/mock, SLA, collection lint + diff",
        "Embeddable zreq-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps"
      ],
      "screenshots": [
        { "src": "assets/zreq.webp", "cap": "API client — collection sidebar, request builder, and response viewer with environments and history in the cyberpunk HUD" }
      ]
    },
    "ztunnel": {
      "overview": "A from-scratch VPN tunnel manager in Rust (Tauri v2 desktop app) that replaces Tunnelblick — manage OpenVPN and WireGuard tunnels from one owned, cross-platform desktop app behind a cyberpunk HUD. Its pure-Rust ztunnel-core engine is extracted so the same VPN engine embeds across the GUI stack.",
      "features": [
        "OpenVPN + WireGuard connections and configurations",
        "Connection manager with OpenVPN-process control",
        "WireGuard tunnel management",
        "Logs, stats, stored credentials (optional OS keychain), and a connection scheduler",
        "Kill switch, split tunneling, split DNS and leak protection",
        "Multi-hop chaining, obfuscation transports, and a server catalog with quality ranking",
        "Interface-less WireGuard handshake probe — one real Noise_IKpsk2 initiation validates endpoint, keys and PSK with no tun and no privilege",
        "Network benches — diagnostics (public IP, default route, leak check), TLS/DoH/MTU/speedtest/header tools, LAN scan (subnet math, ping sweep, ARP, RDAP), live monitor (netstat, firewall, HTTP bench, TLS scan, DNS dump/AXFR)",
        "SSH port-forward manager — local/remote/dynamic forwards, jump hosts, key generation, ~/.ssh/config import",
        "Connect / disconnect with live status",
        "macOS + Linux behind a platform abstraction (utun / /dev/net/tun, routing, DNS) — bring-up needs root and reports needs_privilege rather than faking a live tunnel",
        "Embeddable ztunnel-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps"
      ],
      "screenshots": [
        { "src": "assets/ztunnel.webp", "cap": "VPN manager — OpenVPN/WireGuard tunnel list with live connection status, logs, and stats in the cyberpunk HUD" }
      ]
    },
    "zthrottle": {
      "overview": "A from-scratch system stress + benchmark tool AND full system monitor in Rust (Tauri v2 desktop app), behind a cyberpunk HUD. Four real single-axis benchmarks plus a world-first contention profiler that drives every subsystem at once, going beyond single-axis tools like Blackmagic Disk Speed Test. Around the benchmarks sits a live monitor: processes, network, and a persistent storage tree. Its pure-Rust zthrottle-core engine is extracted so the same engine embeds across the GUI stack.",
      "features": [
        "Disk throughput + random 4 KiB IOPS, uncached via F_NOCACHE / O_DIRECT",
        "Network throughput (loopback or a host:port peer) — TCP, UDP, and RTT",
        "CPU integer + f64 matmul kernels with multi-thread scaling",
        "Memory STREAM Copy/Scale/Add/Triad bandwidth + pointer-chase latency",
        "World-first contention profiler — every axis driven at once, with an interaction matrix and bottleneck-migration timeline",
        "System monitor — processes with signal control (TERM/KILL/STOP/CONT/HUP…), CPU-history graph, per-interface network history + live flows",
        "Storage tree — a persistent SQLite directory index built by ONE full scan, then kept live by filesystem-watch hooks (targeted updates, no re-walk); instant reads, no loading screen",
        "\"What can I free?\" — junk detection with a user-editable pattern list, per-owner filter, and multi-select bulk delete (.git internals never flagged)",
        "Cross-platform — macOS, Linux, and Windows",
        "Embeddable zthrottle-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps"
      ],
      "screenshots": [
        { "src": "assets/zthrottle.webp", "cap": "Stress-bench + system monitor — multi-axis benchmarks, the contention profiler, and live process/network/storage panels in the cyberpunk HUD" }
      ]
    },
    "zgo": {
      "overview": "A from-scratch launcher in Rust (Tauri v2 desktop app) that replaces Alfred — fuzzy launching, workflows, and snippets behind a cyberpunk HUD. Its pure-Rust zgo-core engine is extracted so the same launcher engine embeds inside the other apps.",
      "features": [
        "Workflows — objects + connections with Script Filter feedback (JSON + legacy XML)",
        "Fuzzy matching across launchable items",
        "Variable / token expansion in actions",
        "Web searches from the launch bar",
        "Clipboard history — a background pasteboard daemon, browsed newest-first via the clip / cb keyword, with paste-to-front-app",
        "Inline tool keywords in the launch bar — hashes / HMAC, Base64, UUID / ULID, JWT decode, cron describe, unit / base / IP math, regex match & replace, JSON / CSV / YAML conversion, QR payloads, screenshot capture, process kill, each mapped to a zgo-core command",
        "Smart query router — a keyword-free result row for colors, unit conversions, number bases, IPs and Unix timestamps, resolved through query.classify",
        "Matcher introspection — Keystroke Optimizer, Typo Robustness, Prefix Trajectory and Catalog Drift, each replayed through the live matcher",
        "Snippets with auto-expansion",
        "Embeddable zgo-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps"
      ],
      "screenshots": [
        { "src": "assets/zgo.webp", "cap": "Launcher — fuzzy launch bar, workflows, clipboard history, and snippets in the cyberpunk HUD" }
      ]
    },
    "zftp": {
      "overview": "A from-scratch file-transfer client in Rust (Tauri v2 desktop app) that replaces Cyberduck — bookmarks, sessions, and a transfer queue behind a cyberpunk HUD. Its pure-Rust zftp-core engine is extracted so the same transfer engine embeds across the GUI stack.",
      "features": [
        "Protocols — FTP, FTPS, SFTP, SCP/SSH (pure-Rust russh, no libssh2/OpenSSL C build), WebDAV/WebDAVS",
        "Hydra Swarm Fetch — one file mirrored on endpoints across different protocols, pulled as disjoint byte-ranges concurrently, scheduled by each source's live-measured throughput, then reassembled and proved",
        "Swarm Replicate — broadcast one local file to N heterogeneous targets at once, read every replica back, prove it with a Merkle root, and succeed on a tunable W-of-N quorum",
        "Swarm Consensus Audit — per-block majority vote across replicas to pick canonical truth, flag corrupt copies, and emit a minimal block-level heal plan instead of a whole re-upload",
        "Erasure Dispersal — self-contained GF(256) Reed-Solomon: k data + m parity shards scattered one per endpoint, rebuildable from any k, at (k+m)/k× storage instead of N×",
        "Bonjour / mDNS LAN discovery of file-transfer services",
        "Cloud stores — S3 (+ S3-compatible), Google Cloud Storage, Azure, Backblaze B2, Swift, Google Drive, Dropbox, OneDrive, Box",
        "Bookmark model with .duck, FileZilla sitemanager.xml and WinSCP .ini import",
        "Session-lifecycle manager",
        "Download / upload / sync transfer queue",
        "Per-session logs and throughput stats",
        "OS-keychain credential storage (on by default) plus PBKDF2 + AEAD profile encryption",
        "Embeddable zftp-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps"
      ],
      "screenshots": [
        { "src": "assets/zftp.webp", "cap": "File-transfer client — bookmarks, remote browser, and the download/upload/sync transfer queue across FTP/SFTP/WebDAV/cloud stores in the cyberpunk HUD" }
      ]
    },
    "zcontainer": {
      "overview": "A from-scratch container & Kubernetes desktop in Rust (Tauri v2 desktop app) that replaces Docker Desktop and Lens — the first compiled-native desktop GUI for both Docker and Kubernetes (every other tool is Electron or a TUI), behind a cyberpunk HUD. Its pure-Rust zcontainer-core engine is extracted so the same engine embeds across the GUI stack.",
      "features": [
        "Containers, images, volumes, networks, and Compose stacks",
        "Managed dockerd — a Virtualization.framework Linux guest on macOS (kernel + rootfs bundled), native on Linux, WSL2 on Windows; a pre-existing Docker Desktop / Colima daemon is detected and left alone",
        "Swarm — services (mode / replicas / scale / live logs / remove), cluster info, nodes, per-service tasks, and a secrets & configs manager",
        "Pre-flight blast-radius simulation — a node drain predicts every evicted pod's landing node or the exact Pending reason against surviving-node headroom, plus endpoint loss and PDB stalls; a resource delete shows the ownerReference GC cascade",
        "Offline analyzer suite, no daemon and no cluster — Dockerfile lint + optimize, SLSA provenance, buildx bake, registry auth, Compose lint / topology / convert-to-manifests, RBAC, Pod Security admission, admission webhooks, Ingress routes, CRD invariants, PV/PVC bind, kubeconfig",
        "Offline predictors — build-cache invalidation, health-gated Compose startup schedule, whole-cluster Deploy Dry-Run, OOM-kill order, request-based cost model",
        "Multi-cluster Kubernetes contexts — pods, workloads, services, CRDs, Helm releases",
        "Live log streaming, in-pod exec, and port-forwarding",
        "YAML editing and resource inspection",
        "Compiled-native (not Electron / not a TUI)",
        "Cross-platform — macOS, Linux, and Windows",
        "Embeddable zcontainer-core engine (rlib + staticlib + cdylib) — mounts into the other GUI apps"
      ],
      "screenshots": [
        { "src": "assets/zcontainer/dashboard.webp", "cap": "Overview — engine status, workload donut, live CPU chart, disk usage, and recent activity" },
        { "src": "assets/zcontainer/containers.webp", "cap": "Containers — per-container CPU/memory sparklines, net & block I/O, PIDs, and port mappings" }
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
      ],
      "screenshots": [
        { "src": "assets/zterminal/dashboard.webp", "cap": "Dashboard — live tmux server stats, session/window/pane gauges, PTY throughput, and the zgui-core widget showcase" },
        { "src": "assets/zterminal/settings.webp", "cap": "Settings — color-scheme presets, custom palette, CRT/vignette/neon effects, and live TOML config reload" }
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
        "1.0–31.7× faster than BSD awk, gawk, and mawk across 30 benchmark comparisons",
        "LSP language server, DAP debug adapter, and a reedline REPL with a live stats banner",
        "AOP command-intercept engine on awk function calls, ported from zshrs",
        "Inline Rust FFI (rust { } blocks) plus --disasm / --dump-tokens / --dump-ast / --dump-bytecode introspection",
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
        "Modes: --tui, --top, --summary, --watch, --stale, --ports, --tree, --net-map, --follow, --monitor, --delta, --pipe-chain, --stall",
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
        "Native flow-to-process attribution — libproc on macOS, /proc on Linux, no external tools",
        "31 cyberpunk themes with live chooser and config persistence",
        "Per-flow sparklines, mouse support, hover/right-click tooltips",
        "Headless --json NDJSON streaming to stdout",
        "Bandwidth threshold alerts: border flash, bell, status message",
        "macOS and Linux (requires libpcap)",
        "Completions for zsh, bash, fish, elvish, powershell"
      ]
    },
    "htoprs": {
      "overview": "A from-source Rust port of htop 3.5.1 — the interactive process viewer ported against the vendored htop C source rather than wrapping the htop binary. Coverage is generated from source at report time, not asserted: 1069 of 1093 C functions (97.8%) across 130 of the 131 C files, with 1 stub remaining. The process model, container/util layer, the full meter set, the UI panels and main loop, key dispatch, the CRT terminal layer and the per-OS backends are ported end-to-end; the TUI assembles and runs on macOS and Linux. On top sits a 21-module src/extensions/ layer, exempt from the port-purity gate, holding htoprs-original monitoring and theming. Crate v0.5.12, MIT.",
      "features": [
        "1069 of 1093 htop 3.5.1 C functions ported (97.8%), 130 of 131 C files, 1 stub — number generated from source by scripts/gen_port_report.py, nothing hardcoded",
        "Every fn under src/ported/ carries a /// Port of &lt;File&gt;.c:&lt;line&gt; citation; an anti-drift gate fails the build on a Rust fn with no C counterpart",
        "Interactive process viewer: live table and tree, per-core CPU / memory / swap / load / battery / network / DiskIO / GPU / ZFS meters, dynamic meters",
        "Sort, filter, search, tag; signal sending and renice; the setup / columns / colors / display-options screens",
        "Per-OS machine and process-table backends ported: darwin, linux, freebsd, netbsd, openbsd, dragonflybsd, solaris",
        "21-module src/extensions/ layer on top of the port: 31 color schemes with live chooser and editor, themed help overlay",
        "Original monitoring suite on free htop keys: fuzzy finder (f), saved regex filters (r), snapshot diffs (d), per-PID history rings, threshold alerts, braille CPU graphs, memory-exhaustion forecast",
        "TUI assembles and runs on macOS and Linux; v0.5.12, MIT — original Rust reimplementation of htop"
      ]
    },
    "zdbview": {
      "overview": "A terminal store editor for the two file formats a Rust cache layer actually uses: rkyv archives and SQLite databases, in one binary. SQLite is self-describing, so it gets full generic CRUD on any database. rkyv is not — the format stores layout and relative pointers, no field names and no type tags — so zdbview carries a format registry instead: faithful copies of the producer's archive types, detected by magic header (or a validated try-decode for the header-less ones) and checked with rkyv::check_archived_root. Registered archives are not just readable but editable: each change deserializes the shard, mutates it, and re-serializes the whole archive byte-identically to the producing host, written back atomically. Anything unregistered degrades to a read-only structural view rather than a guess.",
      "features": [
        "rkyv CRUD write-back — add, edit, rename and delete records in a recognized archive; deserialize, mutate, re-serialize, atomic temp+rename",
        "Byte-identical re-serialization — the producing host reads the edited shard normally, verified by round-tripping every real cache",
        "Ten registered formats — zshrs script / autoload / canonical shard / system shard, strykelang (native v4 + compat), awkrs, vimlrs, elisprs heap image, plus header-less pythonrs and rubylang/arb shards keyed by content hash",
        "rkyv Records view — key/value table for a recognized archive: keys left, the selected value's decoded scalar fields plus a hex pane right, searchable by key",
        "Format registry — magic-detected, validated decode; a version or feature drift fails validation and falls back, never decodes garbage silently",
        "Structural fallback for unknown archives — printable-string runs with byte offsets, plus an xxd-style hex/ascii dump",
        "Full generic SQLite CRUD — tables with row counts, paginated rows, in-place cell edit, insert with column defaults, rowid delete, arbitrary SQL",
        "Backend chosen by header magic, not filename — a .db whose bytes are not a SQLite header opens as an archive",
        "No-arg launch opens an MRU picker of recently opened files; SQLite is compiled in (no system library)",
        "MIT — original Rust, ratatui + crossterm"
      ]
    },
    "zdbview-book": {
      "overview": "The companion book to zdbview — the terminal inspector and CRUD editor for rkyv archives and SQLite databases. It follows the tool from the sixteen bytes that decide which backend opens a file, through the generic CRUD surface a self-describing database allows, to the format registry that makes a non-self-describing rkyv archive readable and writable at all — and states plainly where recognition stops.",
      "features": [
        "Detection: the SQLite header magic as sole authority, with the extension only as a tie-breaker for files too short to carry a header",
        "The SQLite half: rowid addressing, identifier and LIKE escaping, whole-table SQL-backed search, and the WITHOUT ROWID limit",
        "The rkyv problem: no field names, no type tags — what a structural inspector can and cannot recover",
        "The format registry: three archive families, the magic pre-filter, rkyv validation gates, and the structural fallback",
        "Write-back: one generic deserialize-mutate-reserialize path, stable record identity, and the temp-file-plus-rename write",
        "The TUI state model, the disasm feature's linked-fusevm tradeoff, and the tests that hold the backend contract",
        "Pandoc + LaTeX typeset, DRM-free PDF"
      ]
    },
    "grcrs": {
      "overview": "A from-source Rust port of grc, the Generic Colouriser (1.13) — the two-binary grc/grcat suite reimplemented against the upstream grc sources rather than wrapping them, so any command's output can be colourised by config-driven regexp rules.",
      "features": [
        "Two binaries: grc (the wrapper) and grcat (the colouriser filter)",
        "grc parses options, matches the command against grc.conf, runs it, and pipes stdout/stderr through grcat",
        "grcat drives per-command config rules — regexp-matched colour, count, and skip directives",
        "--pty mode so colour-suppressing commands still emit colourable output",
        "Ported against the upstream grc source of truth, not a shell wrapper",
        "MIT — original Rust reimplementation of grc"
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
        "134/137 upstream files ported (97.8%), 2529 lib tests",
        "462 parity tests byte-compared against live upstream Python",
        "5 binaries: powerline, -daemon, -config, -render, -lint",
        "UNIX-socket daemon speaks the upstream powerline wire format",
        "58 segment adapters (59 registry keys) including git_status, ci_status, kubecontext",
        "Drop-in compatible with existing powerline JSON theme files",
        "Targets tmux, zsh, bash, vim, ipython prompts",
        "Bundled vim plugin via include_str!, no +python3 needed",
        "Net-new segments: gpu_usage, thermal, aws/gcp context"
      ]
    },
    "ztmux": {
      "overview": "The world's first 100%-functional tmux in Rust — a from-source port of the whole program, not a wrapper around the tmux binary and not a control-mode client. The server, client, grid/screen model, input parser, layouts, command language, formats, and terminal back end, reimplemented in memory-safe Rust. Correctness is measured, not claimed: a parity suite runs identical inputs through the real tmux and ztmux and diffs them byte-for-byte — 1194/1194 cases passing against the vendored tmux next-3.7, zero known divergences. MIT-licensed.",
      "features": [
        "The whole tmux program in Rust: server + client, not a wrapper",
        "1194/1194 parity cases passing — byte-for-byte against the vendored tmux next-3.7",
        "Validated module-by-module against the vendored upstream tmux C source of truth",
        "Grid/screen + scrollback model, VT input parser, and the layout engine",
        "lalrpop command grammar; one file per command mirroring tmux's cmd-*.c",
        "libevent event loop and the tmux client/server socket protocol",
        "Anti-drift gate: build fails on any Rust function with no tmux C counterpart",
        "MIT-licensed, self-contained (vendors tmux C + tmux-rs as references)"
      ],
      "screenshots": [
        { "src": "assets/ztmux.webp", "cap": "ztmux — the from-source Rust tmux: recursive pane splits, windows, and the status bar, byte-for-byte parity with system tmux" }
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
      "overview": "A Chrome MV3 extension bundling fourteen daily-driver browser tools into one toolbar icon, with a vendored Rust native-messaging host and 55 keyboard commands.",
      "features": [
        "UNIX pass integration: fill, copy, OTP, full CRUD manager",
        "Profile + credit-card autofill from pass entries",
        "Segmented multi-connection download manager via Range GETs",
        "JetBrains-style tab switcher with MRU, scenes, minimap",
        "fzf-fuzzy search over up to 5000 history entries",
        "Tampermonkey-equivalent userscript engine with GM_* shim",
        "Wappalyzer-compatible detection, 3,993-fingerprint corpus",
        "Full-page screenshot capture with OffscreenCanvas stitching",
        "55 commands; 3109 node:test + 132 cargo test cases, all passing"
      ],
      "screenshots": [
        { "src": "assets/zpwrchrome.webp", "cap": "zpwrchrome — the MV3 toolbar popup: pass integration, download manager, tab switcher, history search, and userscript engine in one icon" }
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
      "overview": "A fully modular patch-graph synthesizer on the shared zpwr-patch-core engine: each voice is a free patch graph of 309 voice modules (VA/wavetable/FM/additive/supersaw/Karplus oscillators, filters, ADSR/LFO/S&H modulators, VCA/mixer) plus the shared 3,366-block audio pack merged into the same graph, unlimited stacked layers, with a per-param mod matrix and a master + unlimited-aux FX-bus rack. 3,675 blocks in all, 194 of them component-level analog-circuit models. Not a fixed voice path.",
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
        "Master-FX bus: the shared 3,366-block patch-core audio pack (incl. 189 component-level analog-circuit models) runs once on the summed output",
        "300 factory presets — 256 general (two 128-voice banks) plus Trance (20), Hard Techno (13) and Schranz (11) genre banks"
      ],
      "screenshots": [
        { "src": "assets/zsynth-synth.webp", "cap": "Synth view: per-voice oscillator, filter, and envelope panel" },
        { "src": "assets/zsynth-patch.webp", "cap": "Patch view: modular patch-graph wiring of the 309-module voice" },
        { "src": "assets/zsynth-peform.webp", "cap": "Perform view: macros, mod matrix, and layer controls" }
      ]
    },
    "zpwr-fx": {
      "overview": "A modular patch-graph effects plugin — not a fixed slot rack. Wire 3,366 DSP module types freely (fan-out and feedback allowed) into your own algorithms, with a per-param mod matrix, unlimited layers, and an EZ-wire mode that auto-routes the signal path. Built on the shared zpwr-patch-core engine.",
      "features": [
        "World first: part of the first fully-modular patch-graph audio plugin quartet (with zpwr-daw) to pair patch-graph wiring with a no-cable knob panel, EZ auto-wiring, and stereo mirror + offset-preserving stereo link",
        "3,366 audio module types across every effect family",
        "Free patch graph: any node to any node, feedback with one-sample delay",
        "189 component-level analog-circuit models across the Amp / Analog / Distortion / Filter / Oscillator families — per-sample nodal and Newton device solves, no IR or sample clones",
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
      "overview": "A MIDI-effects plugin that transforms the note stream before it reaches an instrument — turning single keys into voiced chords, scale-locking for intelligent harmony, and running notes through a polymetric step arpeggiator with Euclidean rhythm generation. The same free-routed patch graph as zpwr-fx, instantiated on the note stream (563 MIDI module types across 11 categories), not a fixed slot rack.",
      "features": [
        "World first: part of the first fully-modular patch-graph audio plugin quartet (with zpwr-daw) to pair patch-graph wiring with a no-cable knob panel, EZ auto-wiring, and stereo mirror + offset-preserving stereo link",
        "563 note-stream module types in a free patch graph (not a fixed rack) — harmony, sequencing, probability, routing, control sources, dynamics, expression, tuning, MPE/voicing",
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
    "stryke-app": {
      "overview": "App automation for stryke — call a MenkeTechnologies GUI app's verbs by name, read its state, and subscribe to its events over the GUI Automation Bus. Semantic, not pixel: where stryke-gui moves the mouse, stryke-app calls library.search and gets rows back. Shipped as a cdylib that stryke dlopens in-process on the first use App; the client keeps a per-app connection in a process-wide pool, so there is no fork per call — a Unix domain socket on macOS and Linux, a named pipe on Windows.",
      "features": [
        "Eight exports — App::here / open / list / verbs / call / get / sub / poll",
        "App::call(name, verb, args) invokes a typed verb on a running app and returns its value",
        "App::verbs(name) returns the app's typed surface manifest, so the API is discoverable at runtime",
        "App::get(name, state) reads a state query; App::sub + App::poll buffer and drain events",
        "App::here() opens the app the script is running inside, via ZGUI_APP",
        "Process-wide connection pool over a Unix domain socket (macOS / Linux) or named pipe (Windows) — no fork per call",
        "Host side is zgui-bridge; the contract is GUI_AUTOMATION_BUS.md §6 (the App module) and §7 (transport)"
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
      "overview": "Full pandas DataFrame plus numpy ndarray/linalg/FFT/random surface for stryke in one cdylib — 1,547 wrapper fns across 43 export families.",
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
    "stryke-terminal": {
      "overview": "Headless VTXXX terminal emulator for stryke — a faithful port of pyte. Feed it the raw byte stream a program writes and it maintains a full VT100 / VT220 / TERM=linux screen model; then read the rendered screen instead of escape-laden bytes. Shipped as a precompiled cdylib stryke dlopens in-process on first `use Terminal`, with emulator sessions that persist across calls.",
      "features": [
        "Faithful pyte port: VT100 / VT220 / TERM=linux screen model",
        "Feed raw bytes — colors, cursor moves, erases, scroll regions, insert/delete, charsets, titles",
        "Maintains grid, cursor, per-cell colors/attributes, modes, scroll margins, tab stops",
        "Scrollback history and rendered-screen reads via Terminal::display",
        "Per-cell inspection via Terminal::cell (character plus SGR attributes)",
        "Backs strykelang's pty_* builtins — drive htop/vim/etc. fully headless",
        "In-process cdylib, dlopened on first use Terminal; sessions persist across calls"
      ]
    },
    "stryke-utils": {
      "overview": "Pure-stryke boundary helper library of 149 long-tail composites not in core, across six sublibraries (String, List, Hash, Num, Time, Path) with no cdylib or FFI.",
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
        "Recipes: 49 login chains (ssh, sudo, psql, vault, kinit, docker_login)",
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
        "234 opcodes across 22 sections, 11 fused superinstructions",
        "AOT compilation of a whole program to a native object file via cranelift-object (aot feature)",
        "Inline Rust FFI — rust { } blocks compiled to a cdylib and marshalled against fusevm::Value (ffi feature)",
        "Cooperative goroutine scheduler and channels (sched module, Go/Chan ops, interpreter-only)",
        "Compiles to wasm32-unknown-unknown for web-worker execution",
        "Three-tier Cranelift JIT: linear, block, and tracing",
        "Tracing JIT records hot loops, deopts on guard miss",
        "29 first-class shell ops, 61 first-class AWK ops",
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
        "504 zpwr subcommands with colorized zsh menucompletion",
        "2000+ aliases plus 360+ git aliases",
        "47,441 zsh tab completions for predictive input (47,393 from zsh-more-completions + 48 in-tree)",
        "177 centralized ZPWR-namespace environment variables",
        "1,277 centralized files in ~/.zpwr for clean uninstall",
        "77 neovim plugins; 48 zinit plugins (33 custom)",
        "224k lines of code across 1,229 text files",
        "Evolved from Hashrocket's Dotmatrix into a full cyberdeck"
      ]
    },
    "zsh-more-completions": {
      "overview": "The largest curated zsh completion corpus in existence, wiring over 47k command completions into compsys — auto-generated from --help, man pages, and web research, then cleaned and verified.",
      "features": [
        "The largest curated zsh completion corpus: 47,393 files",
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
        "11,688 zunit @test blocks across 79 files; sub-millisecond pure-zsh hot path"
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
        "cargo add/install &lt;TAB&gt; queries crates.io live",
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
        "gem install &lt;TAB&gt; completes remote gems",
        "Includes all Oh My Zsh gem completion",
        "Installs via zinit, oh-my-zsh, or manual sourcing",
        "Add to oh-my-zsh plugins array",
        "MIT licensed, with CI"
      ]
    },
    "zsh-nginx": {
      "overview": "nginx vhost management from zsh — en / dis enable and disable sites by symlink, vhost scaffolds a new server block from a template (plain_php, symfony2), each with its own compsys completion.",
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
        "pip install &lt;TAB&gt; completes remote packages",
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
    },
    "awkrs-reference": {
      "overview": "The complete awkrs reference — the AWK language surface, builtins, and command-line interface of awkrs, the parallel Rust AWK, generated from the live implementation so every function and flag matches the shipping binary.",
      "features": ["Every AWK builtin and language construct, generated from the live awkrs source", "The command-line surface: options, field and record separators, program invocation", "Parallel-execution notes specific to the Rust implementation", "The dense companion to The awkrs Book", "DRM-free PDF"]
    },
    "elisprs-reference": {
      "overview": "The complete elisprs reference — the Emacs Lisp subroutines and special forms implemented as a fusevm frontend, generated from the live implementation.",
      "features": ["Every implemented Emacs Lisp subroutine and special form", "The fusevm-frontend model: Emacs Lisp lowered to the shared bytecode VM", "Generated from the live elisprs source", "The dense companion to The elisprs Book", "DRM-free PDF"]
    },
    "gui-automation-bus-book": {
      "overview": "The companion book to the GUI automation bus — the cross-app event-routing layer that wires the MenkeTechnologies desktop suite together, letting one app drive another over a shared message bus.",
      "features": ["The cross-app event-routing architecture", "The message model: how apps subscribe and publish", "Per-app endpoints across the desktop suite", "Worked automation flows spanning multiple apps", "Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "gui-automation-bus-reference": {
      "overview": "The dense reference for the GUI automation bus — its message types, routing model, and per-app endpoints, for scripting the desktop suite.",
      "features": ["Every message type on the bus", "The routing model: addressing, fan-out, and delivery", "The per-app endpoint catalog", "The companion reference to The GUI Automation Bus", "Free, DRM-free PDF"]
    },
    "rubyrs-reference": {
      "overview": "The complete rubyrs reference — the Ruby language surface of the compiled Ruby runtime on fusevm: builtins, core classes (String / Array / Hash), and the CLI, generated from the live implementation so every method and flag matches the shipping binary.",
      "features": ["The Ruby surface implemented by rubyrs, generated from the live source", "Core classes and their methods: String, Array, Hash, and friends", "The CLI: run a file, a -e one-liner, or the REPL", "The runtime model: native VM ops vs the RubyHost (dispatch, blocks, yield)", "The dense companion to The rubyrs Book", "DRM-free PDF"]
    },
    "strykelang-reference": {
      "overview": "The complete strykelang language reference — every builtin, operator, sigil, and pipeline form of the parallel Perl 5 superset, generated from the live implementation. The dense companion to The strykelang Book.",
      "features": ["Every strykelang builtin, generated from the live implementation", "Operators, sigils, and the pipe-forward pipeline forms", "The parallel-execution and Cranelift-JIT model", "The dense companion to The strykelang Book", "DRM-free PDF"]
    },
    "vimlrs-reference": {
      "overview": "The complete vimlrs reference — the VimL builtin functions, commands, and options implemented as a fusevm frontend, generated from the live implementation.",
      "features": ["Every implemented VimL builtin function", "Ex commands and options coverage", "The fusevm-frontend model: VimL lowered to the shared bytecode VM", "The dense companion to The vimlrs Book", "DRM-free PDF"]
    },
    "zgui-core-component-catalog": {
      "overview": "The zgui-core component catalog — every UI component in the shared GUI toolkit behind the MenkeTechnologies desktop apps, the one library each app builds its interface from.",
      "features": ["Every component in the shared zgui-core toolkit", "The window, panel, knob, file-browser, and HUD chrome shared across apps", "How one component implementation serves the whole desktop fleet", "The UI-side analog of zdsp-core and zpwr-patch-core", "Free, DRM-free PDF"]
    },
    "zmax-reference": {
      "overview": "The complete zmax reference — every command, keymap, and embedded-language entry point of the modal IDE. The dense companion to The zmax Book.",
      "features": ["Every zmax command and default keymap", "The embedded-language entry points", "The modal editing model", "The dense companion to The zmax Book", "DRM-free PDF"]
    },
    "znative-book": {
      "overview": "The companion book to znative — the zshrs package manager, and the first shell package manager whose unit of installation can be native compiled code rather than shell text. It walks the published, versioned ABI that makes a native plugin safe to install, the eight-command surface, source auto-classification with @ref pinning, the content-addressed store, and the worked plugin ports.",
      "features": ["The published, versioned plugin ABI (the znative crate on crates.io; the repr(C) boundary and ABI_VERSION checked at load)", "The eight-command surface: load / add / remove / list / info / update, plus gc / clean", "Source auto-classification (owner/repo, github:, git+URL, path:) with @ref pinning and shallow clone", "The content-addressed store at $ZSHRS_HOME/pkg/ with its installed.toml index and sha256 integrity", "The worked plugin ports: forgit, git-fuzzy, revolver, kubectl, zsh-z", "Global-only, no lockfile, by design. Pandoc + LaTeX typeset, DRM-free PDF"]
    },
    "zpwr-clip-engine-reference": {
      "overview": "The zpwr-daw clip-engine reference — the timeline, clip, and playback model behind the DAW's arrangement and session views.",
      "features": ["The pattern, clip, and event model", "The step, transport, and scheduling core", "MIDI export and project serialization", "The pure-C++ C-ABI engine shared by the DAW and the Tauri apps", "Free, DRM-free PDF"]
    },
    "zpwr-daw-reference": {
      "overview": "The zpwr-daw manual — a shared-engine architecture overview plus a per-module node and parameter reference for the note-stream blocks every track wires, generated from the live registry.",
      "features": ["Shared-engine architecture overview", "Per-module node and parameter reference, generated from the live registry", "The note-stream blocks every track wires", "The stereo-graph track model", "Free, DRM-free PDF"]
    },
    "zpwr-fx-block-catalog": {
      "overview": "Every DSP block zpwr-fx ships — the full 3,366-block audio patch-graph pack across 18 categories, including 189 component-level analog-circuit models, each with its parameters.",
      "features": ["All 3,366 audio DSP blocks in the zpwr-fx pack, across 18 categories", "189 component-level analog-circuit models", "Per-block parameter reference", "Built on the shared zpwr-patch-core graph and zdsp-core substrate", "Free, DRM-free PDF"]
    },
    "zpwr-fx-reference": {
      "overview": "The zpwr-fx manual — a shared-engine architecture overview plus a per-module node and parameter reference, generated from the live registry.",
      "features": ["Shared-engine architecture overview", "Per-module node and parameter reference, generated from the live registry", "The single-graph, stereo-locked effects model", "Built on zpwr-patch-core and zdsp-core", "Free, DRM-free PDF"]
    },
    "zpwr-midi-fx-block-catalog": {
      "overview": "Every block zpwr-midi-fx ships — its note-stream module pack: arpeggiators, chord generators, scale quantizers, Euclidean and generative sequencers, humanize, and remap.",
      "features": ["Every note-stream block in the zpwr-midi-fx pack", "Arp, chord, scale, Euclidean and generative sequencing, humanize, remap", "Per-block parameter reference", "Runs on the note-stream instantiation of the shared graph", "Free, DRM-free PDF"]
    },
    "zpwr-midi-fx-reference": {
      "overview": "The zpwr-midi-fx manual — a shared-engine architecture overview plus a per-module node and parameter reference, generated from the live registry.",
      "features": ["Shared-engine architecture overview", "Per-module node and parameter reference, generated from the live registry", "The note-event stream signal model", "Built on zpwr-patch-core", "Free, DRM-free PDF"]
    },
    "zpwr-patch-core-block-catalog": {
      "overview": "The complete shared patch-graph reference — every block across all four plugins (zpwr-synth, zpwr-fx, zpwr-midi-fx, zpwr-daw), with an alphabetical index.",
      "features": ["Every block across all four plugins in one volume", "An alphabetical cross-plugin index", "The shared zpwr-patch-core graph model", "Per-block parameters and categories", "Free, DRM-free PDF"]
    },
    "zpwr-synth-block-catalog": {
      "overview": "Every DSP block zpwr-synth ships — 3,675 blocks across 18 categories: 309 voice modules plus the shared 3,366-block audio pack that also runs on the master and aux FX bus, 194 of them component-level analog-circuit models.",
      "features": ["309 voice modules", "The shared 3,366-block audio pack, merged into the voice graph and on the master/aux FX bus", "194 component-level analog-circuit models", "Per-block parameter reference", "Runs across the polyphonic voice pool (PolyEngine)", "Free, DRM-free PDF"]
    },
    "zpwr-synth-reference": {
      "overview": "The zpwr-synth manual — a per-module node and parameter reference for the modular voice engine, generated from the live registry.",
      "features": ["Per-module node and parameter reference, generated from the live registry", "The modular voice-engine model (PolyEngine)", "Oscillators, filters, envelopes, LFOs, and effects", "Built on zpwr-patch-core and zdsp-core", "Free, DRM-free PDF"]
    },
    "zshrs-reference": {
      "overview": "The complete zshrs reference — every builtin, option, parameter flag, and completion primitive of the first compiled Unix shell. The dense companion to The zshrs Book.",
      "features": ["Every zshrs builtin and option", "Parameter flags and completion primitives", "Generated from the live zshrs source", "The dense companion to The zshrs Book", "DRM-free PDF"]
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
    'api-rest-generator', 'arb', 'awkrs', 'fusevm', 'htoprs', 'iftoprs', 'lsofrs', 'nmaprs',
    'powerliners', 'storageshower', 'temprs', 'strykelang', 'zdbview', 'zshrs', 'ztmux', 'zpwr',
    'zpwrchrome', 'stryke-arrow', 'stryke-aws', 'stryke-azure',
    'stryke-clickhouse', 'stryke-demo', 'stryke-docker', 'stryke-duckdb',
    'stryke-email', 'stryke-fleet', 'stryke-gcp', 'stryke-grpc', 'stryke-gui',
    'stryke-k8s', 'stryke-kafka', 'stryke-mcpd', 'stryke-mongo', 'stryke-mssql',
    'stryke-mysql', 'stryke-neo4j', 'stryke-office', 'stryke-parquet',
    'stryke-polars', 'stryke-postgres', 'stryke-redis', 'stryke-scrape',
    'stryke-scylla', 'stryke-search', 'stryke-selenium', 'stryke-spark',
    'stryke-terminal', 'stryke-utils', 'stryke-zmq', 'zsh-cargo-completion', 'zsh-cpan-completion',
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

  // The ruby-on-fusevm product keeps the store id 'rubyrs' (matching its books
  // and reference PDF), but the repo was renamed to 'rubylang' (crate name;
  // 'rubyrs' is taken on crates.io), so its Pages live at github.io/rubylang/,
  // not github.io/rubyrs/ (renamed-repo Pages URLs do not redirect). Wire the
  // doc-site links to the real path. Verified live (HTTP 200).
  (function () {
    var p = byId('rubyrs');
    if (!p) return;
    var base = 'https://menketechnologies.github.io/rubylang/';
    p.docsite = [
      { label: 'Documentation', desc: 'Project documentation site', url: base },
      { label: 'API Reference', desc: 'Full API / block reference', url: base + 'reference.html' },
      { label: 'Engineering Report', desc: 'Architecture & engineering report', url: base + 'report.html' },
    ];
  })();

  // ---- Helpers --------------------------------------------------------
  var CART_KEY = 'appstore-cart';

  // Contact form target. The store is a static site with no backend, so the
  // contact form POSTs to the Web3Forms relay (see renderContactPage), which
  // forwards the message to the inbox registered to this public access key.
  var WEB3FORMS_KEY = '7937cf02-fe17-4a96-8869-98165c3a1f73';

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

  // ---- Billing model ---------------------------------------------------
  // Desktop apps and audio plugins are monthly subscriptions; the publications
  // are one-time purchases; anything priced at zero is free whatever its
  // category says. The same rule drives zpwr-account's catalog export, so the
  // storefront and the billing tables cannot drift apart.
  var SUBSCRIPTION_CATEGORIES = [
    'Desktop Apps',
    'Audio Plugins',
    'Developer Tools',
    'CLI Tools',
    'stryke Packages',
    'arb Packages',
  ];

  // Where subscriptions are managed. Subscribing does not go through this
  // cart: a recurring charge and a one-time purchase are different PayPal
  // flows, and mixing them in one basket produces a checkout that can only be
  // half right.
  var ACCOUNT_URL = 'https://accounts.menketechnologies.com';

  function isSubscription(p) {
    if (isFree(p)) return false;
    return SUBSCRIPTION_CATEGORIES.indexOf(p.category) !== -1;
  }

  // Monthly price in whole dollars, derived from the perpetual price.
  //
  // Anchored on the two set by hand — zftp at $20 perpetual is $5/month,
  // zpwr-synth at $149 is $30 — so one fifth clamped to that $5-$30 band
  // reproduces both exactly and interpolates the rest.
  function monthlyOf(p) {
    var tier = (p.tiers && p.tiers[0]) || { price: p.price };
    return Math.min(30, Math.max(5, Math.round((tier.price || 0) / 5)));
  }

  function fmtMonthly(p) {
    return '$' + monthlyOf(p);
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
    var product = byId(productId);
    if (product && isSubscription(product)) {
      // A subscription is billed by PayPal on its own schedule and is granted
      // by the account server, not by this checkout. Sending someone here with
      // one in the basket would charge them once for something that renews.
      window.location.href = ACCOUNT_URL + '/#/apps';
      return;
    }
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
          (isSubscription(p)
            ? '<span class="price"><span class="amt">' + fmtMonthly(p) + '</span>' +
                '<span class="per">per month</span></span>'
            : '<span class="price"><span class="amt' + priceCls + '">' + fmtPrice(tier.price) + '</span>' +
                (tier.price ? '<span class="per">one-time</span>' : '') + '</span>') +
          (isFree(p)
            ? '<button type="button" class="btn btn-buy" data-download="' + (p.download || p.repo) + '">Download ↗</button>'
            : isSubscription(p)
              ? '<button type="button" class="btn btn-buy" data-subscribe="' + p.id + '">Subscribe</button>'
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

  // ---- Branch marks ---------------------------------------------------
  // Every product belongs to one of the four MenkeTechnologies branches. The
  // mark is the corporate hex + MT monogram (identical in all four -- that is
  // the family DNA) plus a branch glyph in the four corner voids the hexagon
  // leaves empty. Source of truth: branding/branches/*.svg in the meta repo.
  var BRANCH_CORE =
    '<g fill="none" stroke="currentColor" stroke-width="4" stroke-linejoin="round">' +
      '<path d="M32 6 L55 19 V45 L32 58 L9 45 V19 Z"/></g>' +
    '<g fill="none" stroke="var(--neon)" stroke-width="3.5" stroke-linejoin="miter" stroke-linecap="butt">' +
      '<path d="M19 40 V26 L25 32 L31 26 V40"/><path d="M35 26 H45 M40 26 V40"/></g>';

  // The glyph is authored once in the top-left void and mirrored into the other
  // three, so the corners cannot drift out of symmetry when one is edited.
  function branchCorners(glyph) {
    return ['', ' transform="translate(64,0) scale(-1,1)"',
                ' transform="translate(0,64) scale(1,-1)"',
                ' transform="translate(64,64) scale(-1,-1)"']
      .map(function (t) { return '<g' + t + '>' + glyph + '</g>'; }).join('');
  }

  var BRANCHES = {
    audio: { name: 'MTAudio',
      glyph: '<path d="M2 18 A8 8 0 0 1 10 10" fill="none" stroke="currentColor" stroke-width="3.5" stroke-linecap="butt"/>' },
    publishing: { name: 'MTPublishing',
      glyph: '<path d="M2 9 H11 L2 18 Z" fill="currentColor"/>' },
    app: { name: 'MTApp',
      glyph: '<path d="M2 18 V10 H10" fill="none" stroke="currentColor" stroke-width="3.5" stroke-linecap="butt"/>' },
    oss: { name: 'MTOpensource',
      glyph: '<g fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="butt"><path d="M3 8 V20 M9 11 V17"/></g>' },
  };

  // Category is the signal for everything except three products: zpwr-daw,
  // audio-haxor and zmusic are audio products that happen to ship as desktop
  // apps, so category alone would file them under MTApp. Named explicitly
  // rather than inferred.
  var BRANCH_BY_CATEGORY = {
    'Audio Plugins': 'audio',
    'Publications': 'publishing',
    'Desktop Apps': 'app',
    'Developer Tools': 'oss',
    'CLI Tools': 'oss',
    'stryke Packages': 'oss',
    'arb Packages': 'oss',
  };
  var BRANCH_BY_ID = { 'zpwr-daw': 'audio', 'audio-haxor': 'audio', zmusic: 'audio' };

  function branchOf(p) { return BRANCH_BY_ID[p.id] || BRANCH_BY_CATEGORY[p.category] || 'oss'; }

  function branchBadge(p) {
    var key = branchOf(p), b = BRANCHES[key];
    return '<span class="p-branch b-' + key + '">' +
      '<svg class="p-branch-mark" viewBox="0 0 64 64" aria-hidden="true" focusable="false">' +
        BRANCH_CORE + branchCorners(b.glyph) +
      '</svg>' + b.name + '</span>';
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

    // Three shapes: free downloads from GitHub, subscriptions are billed monthly
    // by the account server, one-time products pick a licence tier and go in the
    // cart. The tier picker is deliberately absent for a subscription — there is
    // one monthly price and the seat count comes with the plan.
    var subscription = isSubscription(p);
    var pricingHtml;
    if (free) {
      pricingHtml = '<div class="price detail-price"><span class="amt free">Free</span><span class="per">open source</span></div>';
    } else if (subscription) {
      pricingHtml =
        '<div class="price detail-price"><span class="amt">' + fmtMonthly(p) + '</span><span class="per">per month</span></div>' +
        '<p class="version-note">Billed monthly through your MenkeTechnologies account. Cancel whenever you like — access runs to the end of the period you have paid for. Updates are included for as long as you subscribe.</p>';
    } else {
      pricingHtml =
        '<div class="license-pick">' + tiersHtml + '</div>' +
        '<div class="price detail-price"><span class="amt" id="detailAmt">' + fmtPrice((p.tiers[0] || {}).price) + '</span><span class="per">one-time</span></div>' +
        '<p class="version-note">Each purchase licenses the current major version, including all minor &amp; patch updates within it. Future major versions are a separate purchase.</p>';
    }
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
    var actionsHtml;
    if (free) {
      actionsHtml = '<a class="btn btn-buy" href="' + (p.download || p.repo) + '" target="_blank" rel="noopener noreferrer">Download ↗</a>' + sourceBtn + docsBtn;
    } else if (subscription) {
      // Subscribing happens at the account server, which opens the plan and
      // grants access. This cart charges once and cannot do that.
      actionsHtml = '<a class="btn btn-buy" href="' + ACCOUNT_URL + '/#/apps">Subscribe</a>' + sourceBtn + docsBtn;
    } else {
      actionsHtml = '<button type="button" class="btn btn-buy" id="detailAdd">Add to cart</button>' + sourceBtn + docsBtn;
    }

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
          '<div class="p-branchrow">' + branchBadge(p) + '<span class="p-cat">' + p.category + '</span></div>' +
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

    // A subscription has no tier picker and no cart button — its action is a
    // link to the account server, which needs no wiring here.
    if (free || isSubscription(p)) return;

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

  // ---- PayPal Smart Buttons ------------------------------------------
  // Public client ID from a LIVE REST app at developer.paypal.com. This is a
  // PUBLIC credential — it ships in client-side JS and is safe to commit. The
  // API *secret* never appears here (client-side capture needs no secret).
  // Empty string => the PayPal method shows a "not configured" note instead of
  // attempting to load the SDK.
  var PAYPAL_CLIENT_ID = 'AZZQjvgmEJpt12iT7We_BGQ_HkVWMR2J_P3sOsqGihpRRWLagbI7S3A4w6uGnwNXyisFxw1czHRD0bZs';

  var paypalSdkState = 0;        // 0 unloaded · 1 loading · 2 ready · 3 failed
  var paypalWaiters = [];

  function loadPayPalSdk(onReady, onFail) {
    if (paypalSdkState === 2) { onReady(); return; }
    if (paypalSdkState === 3) { onFail(); return; }
    paypalWaiters.push({ ok: onReady, fail: onFail });
    if (paypalSdkState === 1) return;
    paypalSdkState = 1;
    var s = document.createElement('script');
    s.src = 'https://www.paypal.com/sdk/js?client-id=' + encodeURIComponent(PAYPAL_CLIENT_ID) +
            '&currency=USD&intent=capture&components=buttons';
    s.onload = function () { paypalSdkState = 2; flushPayPalWaiters(true); };
    s.onerror = function () { paypalSdkState = 3; flushPayPalWaiters(false); };
    document.head.appendChild(s);
  }
  function flushPayPalWaiters(ok) {
    var w = paypalWaiters; paypalWaiters = [];
    w.forEach(function (cb) { (ok ? cb.ok : cb.fail)(); });
  }

  // Single source of truth for the checkout money math — the summary panel and
  // the PayPal order both read from here so amounts can never diverge.
  function checkoutTotals() {
    var cart = readCart();
    var subtotal = cartTotal(cart);
    var disc = discountAmount(subtotal);
    return { cart: cart, subtotal: subtotal, disc: disc, total: subtotal - disc };
  }

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
    var t = checkoutTotals();
    var cart = t.cart, subtotal = t.subtotal, disc = t.disc, total = t.total;
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

  // Contact page: name / email / subject / message. On submit, POST to the
  // Web3Forms relay via fetch (15s timeout so a slow/down relay surfaces an
  // error instead of hanging) and show inline success/error.
  function renderContactPage() {
    var root = document.getElementById('contactRoot');
    if (!root) return;

    root.innerHTML = '' +
      '<div class="contact-wrap">' +
        '<p class="contact-intro">Questions about a product, a license, a bug, or a custom build? Fill this out and it sends straight to my inbox.</p>' +
        '<form id="contactForm" novalidate>' +
          '<div class="field"><label for="cfName">Your name</label>' +
            '<input id="cfName" type="text" autocomplete="name" placeholder="Name"></div>' +
          '<div class="field"><label for="cfEmail">Your email</label>' +
            '<input id="cfEmail" type="email" autocomplete="email" placeholder="you@example.com"></div>' +
          '<div class="field"><label for="cfSubject">Subject</label>' +
            '<input id="cfSubject" type="text" placeholder="What\'s this about?"></div>' +
          '<div class="field"><label for="cfMessage">Message</label>' +
            '<textarea id="cfMessage" placeholder="Type your message…"></textarea></div>' +
          // honeypot — hidden from humans, tempts bots; Web3Forms drops it if filled
          '<input type="checkbox" name="botcheck" style="display:none" tabindex="-1" autocomplete="off">' +
          '<div class="contact-err" id="cfErr" role="alert" aria-live="polite"></div>' +
          '<button type="submit" class="btn btn-buy pay-now-btn">Send message</button>' +
        '</form>' +
        '<div id="cfSent"></div>' +
      '</div>';

    var form = root.querySelector('#contactForm');
    if (!form) return;
    var btn = form.querySelector('button[type="submit"]');
    var btnText = btn ? btn.textContent : 'Send message';

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var name = (root.querySelector('#cfName').value || '').trim();
      var email = (root.querySelector('#cfEmail').value || '').trim();
      var subject = (root.querySelector('#cfSubject').value || '').trim();
      var message = (root.querySelector('#cfMessage').value || '').trim();
      var botcheck = form.querySelector('input[name="botcheck"]').checked;
      var errEl = root.querySelector('#cfErr');
      var sent = root.querySelector('#cfSent');

      var missing = [];
      if (!name) missing.push('name');
      if (!email || email.indexOf('@') < 1) missing.push('a valid email');
      if (!message) missing.push('a message');
      if (missing.length) {
        errEl.textContent = 'Please add ' + missing.join(', ') + '.';
        return;
      }
      errEl.textContent = '';
      if (sent) sent.innerHTML = '';

      btn.disabled = true;
      btn.textContent = 'Sending…';

      // Hard timeout so a dead backend surfaces an error instead of hanging.
      var controller = new AbortController();
      var timer = setTimeout(function () { controller.abort(); }, 15000);

      var payload = {
        access_key: WEB3FORMS_KEY,
        name: name,
        email: email,
        subject: subject || ('Contact from ' + name),
        message: message,
        botcheck: botcheck
      };

      fetch('https://api.web3forms.com/submit', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify(payload),
        signal: controller.signal
      }).then(function (res) {
        if (!res.ok) { throw new Error('HTTP ' + res.status); }
        return res.json();
      }).then(function (data) {
        if (!data || !data.success) { throw new Error('relay rejected'); }
        form.reset();
        if (sent) {
          sent.innerHTML = '<div class="contact-sent">Message sent — thanks. I\'ll get back to you at ' +
            email.replace(/&/g, '&amp;').replace(/</g, '&lt;') + '.</div>';
        }
      }).catch(function () {
        errEl.textContent = 'Could not send right now. Please try again shortly.';
      }).then(function () {
        clearTimeout(timer);
        btn.disabled = false;
        btn.textContent = btnText;
      });
    });
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
                '<div class="pay-method-body"><div id="paypalButtonContainer"><p class="checkout-note">Pay securely with your PayPal balance, bank, or card.</p></div></div>' +
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

    // Payment-method accordion (single open at a time). Selecting PayPal mounts
    // its Smart Buttons and hides the generic "Pay now".
    var methods = root.querySelector('#payMethods');
    if (methods) methods.addEventListener('click', function (e) {
      var head = e.target.closest('.pay-method-head');
      if (!head) return;
      activateMethod(root, head.parentElement.getAttribute('data-method'));
    });

    // Express wallet buttons route to the provider.
    //   paypal          -> select the PayPal method + render Smart Buttons (live)
    //   shop / gpay / venmo -> client-side placeholders (see README)
    function startWallet(name) {
      if (name === 'paypal') {
        activateMethod(root, 'paypal');
        var pm = root.querySelector('.pay-method[data-method="paypal"]');
        if (pm && pm.scrollIntoView) pm.scrollIntoView({ behavior: 'smooth', block: 'center' });
        return;
      }
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
      // PayPal is captured by its own buttons — the form submit is a no-op.
      if (method === 'paypal') return;
      completeOrder(root, method);
    });
  }

  function paypalNote(msg) {
    return '<p class="checkout-note">' + msg + '</p>';
  }

  // Mount PayPal Smart Buttons into #paypalButtonContainer. Idempotent: a second
  // call while already mounted is a no-op. The order is built live inside
  // createOrder, so discount changes are picked up without re-rendering.
  function renderPayPalButtons(root) {
    var container = root.querySelector('#paypalButtonContainer');
    if (!container) return;
    if (!PAYPAL_CLIENT_ID) {
      container.innerHTML = paypalNote('PayPal is not configured yet.');
      return;
    }
    if (container.getAttribute('data-rendered') === '1') return;
    container.innerHTML = paypalNote('Loading PayPal…');

    var fail = function () {
      container.removeAttribute('data-rendered');
      container.innerHTML = paypalNote('Could not reach PayPal — check your connection and try again.');
    };

    loadPayPalSdk(function () {
      if (!window.paypal || !window.paypal.Buttons) { fail(); return; }
      container.innerHTML = '';
      container.setAttribute('data-rendered', '1');

      window.paypal.Buttons({
        style: { layout: 'vertical', color: 'gold', shape: 'pill', label: 'paypal' },

        createOrder: function (data, actions) {
          var t = checkoutTotals();
          var unit = {
            amount: {
              currency_code: 'USD',
              value: t.total.toFixed(2),
              breakdown: {
                item_total: { currency_code: 'USD', value: t.subtotal.toFixed(2) },
              },
            },
            items: t.cart.map(function (i) {
              var p = byId(i.id) || { name: i.id };
              return {
                name: (p.name + ' — ' + i.tier + ' license').slice(0, 127),
                quantity: '1',
                category: 'DIGITAL_GOODS',
                unit_amount: { currency_code: 'USD', value: (i.price || 0).toFixed(2) },
              };
            }),
          };
          if (t.disc > 0) {
            unit.amount.breakdown.discount = { currency_code: 'USD', value: t.disc.toFixed(2) };
          }
          // Pack fulfillment data onto the order so the PayPal "payment received"
          // email / transaction record carries what's needed to send the app +
          // license: the buyer's delivery email (custom_id) and the apps + tiers
          // purchased (description). PayPal field caps are 127 chars.
          var deliveryEl = root.querySelector('#ckEmail');
          var deliveryEmail = (deliveryEl && deliveryEl.value || '').trim();
          if (deliveryEmail) unit.custom_id = deliveryEmail.slice(0, 127);
          unit.description = ('Deliver to ' + (deliveryEmail || 'PayPal email') + ' — ' +
            t.cart.map(function (i) {
              var p = byId(i.id) || { name: i.id };
              return p.name + ' (' + i.tier + ')';
            }).join(', ')).slice(0, 127);
          return actions.order.create({ intent: 'CAPTURE', purchase_units: [unit] });
        },

        onApprove: function (data, actions) {
          return actions.order.capture().then(function (details) {
            var payer = details && details.payer && details.payer.email_address;
            completeOrder(root, 'PayPal', payer);
          });
        },

        onError: fail,
      }).render(container).catch(fail);
    }, fail);
  }

  // Activate one payment method: sync the accordion, hide the generic "Pay now"
  // when PayPal is chosen (its own buttons submit), and mount those buttons.
  function activateMethod(root, method) {
    var methods = root.querySelector('#payMethods');
    if (methods) {
      var all = methods.querySelectorAll('.pay-method');
      for (var i = 0; i < all.length; i++) {
        all[i].classList.toggle('active', all[i].getAttribute('data-method') === method);
      }
    }
    var payNow = root.querySelector('#payNow');
    if (payNow) payNow.style.display = (method === 'paypal') ? 'none' : '';
    if (method === 'paypal') renderPayPalButtons(root);
  }

  function completeOrder(root, method, payerEmail) {
    // Card / Shop Pay / Google Pay / Venmo are still client-side placeholders —
    // no real charge. PayPal (Smart Buttons) is a live capture; `payerEmail`
    // comes back from the PayPal payer record for license delivery.
    var emailEl = root.querySelector('#ckEmail');
    var email = payerEmail || (emailEl && emailEl.value) || 'your inbox';
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
    renderContactPage();

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
      var sub = e.target.closest('[data-subscribe]');
      if (sub) {
        e.preventDefault();
        e.stopPropagation();
        // Subscriptions are opened, billed and granted by the account server.
        // The storefront's job ends at sending the customer there.
        window.location.href = ACCOUNT_URL + '/#/apps';
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
