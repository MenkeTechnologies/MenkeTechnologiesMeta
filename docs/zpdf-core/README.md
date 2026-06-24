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
pure-Rust PDF engine with no GUI and no platform dependencies. It is the unit that
gets embedded: the desktop editor is one host, and the same engine (and its GUI
component) mounts into the other MenkeTechnologies apps — **traderview** renders and
marks up PDFs in-window without launching a separate program. Same shared-component
pattern as [`zpwr-clip-engine`](https://github.com/MenkeTechnologies/zpwr-clip-engine)
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
- **No GUI, no platform deps** — just the document model and operations. Hosts bring
  their own UI; the desktop app and every embed share this exact crate.
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

The GUI embed (webview component the host Tauri app mounts) layers on top of this
crate, mirroring how `zpwr-clip-engine` mounts its sequencer into each app.

## [0x03] MODULES

| Module | Responsibility |
| --- | --- |
| `doc` | open/save, in-memory I/O, version, document properties (`/Info`), merge |
| `page` | page count, rotate, delete, reorder, extract |
| `text` | text extraction (real), in-place edit + OCR (planned) |
| `annot` | sticky notes (real), markup family (highlight/ink/stamp — planned) |
| `form` | AcroForm detection + field enumeration (real), fill/flatten (planned) |
| `sign` | signature detection (real), certificate signing/verify (planned) |
| `security` | encryption detection (real), encrypt/decrypt/redact/sanitize (planned) |

## [0x04] PORT REPORT

Coverage of the Adobe-Acrobat / Apple-Preview surface is audited honestly:
`scripts/feature_map.json` lists every target capability, and
`scripts/gen_port_report.py` **derives** each feature's status from `src/` — a
feature is `DONE` only when its cited symbol exists and is not a `NotImplemented`
stub. Status cannot be faked in the manifest; only by writing engine code.

```sh
python3 scripts/gen_port_report.py   # → docs/port_report.html
```

## [0x05] BUILD & TEST

```sh
cargo build      # local dev (never --release per house rule)
cargo test       # self-contained: builds PDFs in memory, no external fixtures
```

## [0xFF] LICENSE

Commercial. © MenkeTechnologies. All rights reserved.
