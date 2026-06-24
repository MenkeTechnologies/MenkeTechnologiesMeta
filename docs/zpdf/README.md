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
![status](https://img.shields.io/badge/status-planning-39ff14?style=flat-square)
![MenkeTechnologies](https://img.shields.io/badge/MenkeTechnologies-stack-d300c5?style=flat-square)

### `[THE FROM-SCRATCH PDF EDITOR]`

> *"Every feature in Acrobat and Preview, in one Rust binary."*

**zpdf** is a from-scratch PDF editor written in Rust, aiming to be the most capable PDF editor — porting the full feature set of Adobe Acrobat (Pro) and macOS Preview into a single tool. Created by MenkeTechnologies.

### [`Read the Docs`](https://menketechnologies.github.io/zpdf/) &middot; [`Engineering Report`](https://menketechnologies.github.io/zpdf/report.html) · [`Feature Port Report`](https://menketechnologies.github.io/zpdf/zpdf_port_report.html)

---

## Table of Contents

- [\[0x00\] Status](#0x00-status)
- [\[0x01\] What zpdf Is](#0x01-what-zpdf-is)
- [\[0x02\] Source Apps](#0x02-source-apps)
- [\[0x03\] Feature Areas](#0x03-feature-areas)
- [\[0x04\] Planned Architecture](#0x04-planned-architecture)
- [\[0x05\] Roadmap](#0x05-roadmap)
- [\[0xFF\] License](#0xff-license)

---

## [0x00] STATUS

**Day 1 — planning.** This repository currently holds the documentation set (roadmap + feature spec) and **no source code yet**. The docs describe what zpdf *will* do, not what works today. Nothing here is a claim that a feature is implemented. The centerpiece is the [feature port report](https://menketechnologies.github.io/zpdf/zpdf_port_report.html): a comprehensive catalog of Acrobat (Pro) + Preview features to port, every row marked `planned`.

---

## [0x01] WHAT ZPDF IS

A from-scratch PDF editor in Rust. The goal is breadth: cover the union of what Adobe Acrobat Pro and macOS Preview can do — viewing, page management, text/object editing, annotation/markup, forms, signatures and security, redaction, OCR, convert/export, review/compare, optimization, accessibility, and batch automation — in one tool with a CLI and a GUI front end.

zpdf parses and writes the PDF object model directly (no shelling out to a third-party PDF engine for the core), so editing, optimization, and structure-level operations (linearization, font subsetting, redaction that truly removes content) are first-class rather than bolt-ons.

This is a roadmap document. Feature status lives in the port report; everything is `planned` until there is verifiable code behind it.

---

## [0x02] SOURCE APPS

zpdf ports its feature set from two reference applications:

- **Adobe Acrobat (Pro)** — the full professional feature surface: AcroForms, digital signatures and certificates, redaction, OCR, PDF/A & PDF/X archival export, Action Wizard batch automation, accessibility tagging, compare, optimization.
- **macOS Preview** — the lightweight markup surface: annotation toolbar, signature capture, drag-to-combine PDFs, image editing, slideshow.

Each row in the port report names which app the feature comes from (Acrobat, Preview, or both).

---

## [0x03] FEATURE AREAS

The catalog is grouped into these areas (see the port report for the per-feature breakdown):

- **Viewing / navigation** — zoom, page layout (single / continuous / two-up), thumbnails, bookmarks/outline, full-screen, read mode, rotate view.
- **Page management** — insert, delete, extract, replace, split, merge/combine, reorder, rotate, crop, resize, headers/footers, backgrounds, watermarks, Bates numbering.
- **Text / object editing** — edit text, edit images, add/remove objects, font handling, reflow, find & replace.
- **Annotations / markup** — highlight, underline, strikethrough, sticky notes, text boxes, callouts, shapes, freehand ink, stamps, file attachments, measure tools.
- **Forms** — AcroForms create/fill/flatten, all field types, calculations, FDF/XFDF import/export, form JavaScript.
- **Signatures & security** — digital and certificate signing, validation, certify, password/permission encryption, redaction, sanitize/remove hidden data.
- **OCR** — text recognition, searchable PDF output, multi-language.
- **Convert / export** — to/from Office formats, HTML, images, text; scan to PDF; print to PDF; PDF/A & PDF/X.
- **Review / compare** — diff two PDFs, comment summary, review tracking.
- **Optimize** — reduce file size, downsample images, embed/subset fonts, linearize (fast web view).
- **Accessibility** — tags, reading order, alt text, accessibility check.
- **Preview-specific** — markup toolbar, signature capture (trackpad/camera), drag-to-combine, image/GIF editing, slideshow.
- **Automation** — Action Wizard / batch, CLI, scripting.

---

## [0x04] PLANNED ARCHITECTURE

Planned, not built. Subject to change as implementation starts.

- **Core PDF model** — direct parse/serialize of the PDF object model (objects, xref, streams, content streams). Owns linearization, incremental update, and object-level edits.
- **Render** — a page rasterizer for the viewer and for raster export (image export, OCR input, thumbnails).
- **Editing engine** — text and object editing on parsed content streams; page-tree operations for insert/delete/extract/reorder/merge.
- **Forms / signatures** — AcroForm field model, FDF/XFDF, and the cryptographic path for signing/validation and encryption.
- **OCR pipeline** — rasterize → recognize → inject a searchable text layer.
- **CLI + GUI** — a scriptable command-line front end for batch/automation, and a desktop GUI for interactive editing and markup.

---

## [0x05] ROADMAP

The port report is the roadmap. It enumerates the Acrobat + Preview feature set and tracks status per feature. Implementation will proceed area by area; the report's `planned` rows become cited as code lands. No feature is marked done without verifiable code.

---

## [0xFF] LICENSE

MIT &middot; [MenkeTechnologies](https://github.com/MenkeTechnologies) &middot; [zpdf](https://github.com/MenkeTechnologies/zpdf) &middot; [MenkeTechnologiesMeta](https://github.com/MenkeTechnologies/MenkeTechnologiesMeta)
