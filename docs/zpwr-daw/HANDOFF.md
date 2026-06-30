# zpwr-clip-engine — Handoff Plan

Status: planning. No implementation in this document — this is the execution spec
for turning `zpwr-clip-engine` into the canonical, embeddable **FL-Studio-style
clip / timeline / arranger / sequencer** used across the whole stack.

## 1. Vision (what this repo becomes)

`zpwr-clip-engine` is a **reusable component with two halves**:

- **Frontend** — a host-agnostic web UI (the FL-Studio-style canvas grid:
  clip / timeline / arranger / sequencer). One renderer + one interaction model,
  bound to different *domains* by configuration.
- **Backend** — the C++ engine (pattern model, transport, step clock glue),
  exposed to native hosts directly and to Rust hosts over a **C ABI (FFI)**.

It is imported into C++ **and** Rust apps that have a web frontend. The backend
is reached via FFI from Rust; via direct linkage + the JUCE `WebBrowserComponent`
native-fn bridge from C++.

### Consumers (all share one frontend + one engine)

| Consumer | Stack | Uses the clip engine as |
| --- | --- | --- |
| zpwr-synth | C++/JUCE | CLIP tab (per-layer note patterns feeding voices) |
| zpwr-midi-fx | C++/JUCE | CLIP tab (note patterns → MIDI out) |
| zpwr-fx | C++/JUCE | CLIP tab |
| audio_haxor | Rust/Tauri + JS | ALS generator (section-override timeline) |
| ztranslator | Rust/Tauri | trigger source (sequencer fires triggers/actions) |

## 2. Current state (verified)

### Frontend — two *separate, hardwired* grids exist; neither is general
- `webui/clip/clip.js` (293 lines): a **DOM** piano-roll. Domain = notes:
  rows are pitches `CLIP_LO=36..CLIP_HI=96`, columns are steps, cell value =
  note length. Has per-layer patterns, scales/random/presets, swing, divisions,
  native-clock + JS-timeout fallback. Already host-agnostic via dependency
  injection: `initClip({ el, nf, getCAT, getActiveLayer })` returns
  `{ buildClip, clipStop, clipManualKey, isPlaying }`. **This is the right
  portability shape — keep the `deps`/`nf` pattern.**
- `audio_haxor/frontend/js/als-timeline.js` (1216 lines): a **canvas** grid with
  the full FL gesture set we want. Domain = ALS macro automation: lanes =
  `['chaos','glitch','density','variation','parallelism','scatter']`, cells =
  8-bar blocks, value = float 0..1. **This is the GUI to port** — it has the
  renderer + interactions; it is just bound to the wrong domain and lives in the
  wrong repo.

The two share the same conceptual structure (**lanes × cells, each cell holds a
value**) and must collapse into one engine.

### als-timeline.js interaction inventory (the spec to preserve)
All of these are domain-independent and must survive the port:
- **paint** (left click-drag): stamp a value across cells, cross-lane sweep
  (`onMouseDown` paint branch, `onWindowMouseMove` paint branch).
- **erase** (right click-drag): clear cells, cross-lane sweep; native context
  menu suppressed at capture phase (`onContext`).
- **value-by-height drag** (top-band of a cell): `_drag.mode==='value'`.
- **scroll fine-tune** (`onWheel`, ±0.05).
- **shift-click range-select** within a lane (`onMouseDown` shift branch).
- **cmd/ctrl-click ramp** anchor→clicked, linear-interpolated, y = end value
  (`onMouseDown` ctrl/meta branch) + ramp cursor affordance (`_ctrlHeld`).
- **multi-select + popover** that bulk-edits the whole selection
  (`_selection`, `openPopover`, `onPopoverInput`, `onDeleteClick`).
- **boundary drag to resize sections** with frozen pixel↔bar mapping + ghost
  preview (`hitBoundary`, `_drag.mode==='boundary'`). This is ALS-arrangement
  specific; generalizes to "resize a region/section length" — keep behind a
  capability flag (see §4).
- **DPR-correct canvas layout + ResizeObserver reflow** (`layout`, `init`).
- **custom SVG cursors** (paintbrush / eraser / ramp).

### Backend — C++ static lib, host-contract via JUCE native fns
- `include/zpc/ClipSeq.h`: `ClipSeqHooks` (host-side contract: `pattern`,
  `transport`, `play`, `step`, `wired()`) + `registerClipSeqFns(builder, hooks,
  prefix)` which appends `clipSeq*` native fns onto a JUCE
  `WebBrowserComponent` options builder. Pattern JSON shape is already defined:
  `[{ s:step, l:layer, n:note, len:steps, v:velocity }, ...]`.
- `include/zpc/midi/NoteGraphHost.h`: `runNoteGraphLayers` — note-stream graph
  driver (the synth feeds graph output straight into voices; midi-fx emits MIDI).
- `CMakeLists.txt`: builds `zpwr_clip_engine` **STATIC**, `juce::juce_core` only,
  PIC on, alias `zpwr::clip_engine`. No C ABI / no Rust bindings yet.
- Consumed by the 3 plugins as a git submodule under `libs/zpwr-clip-engine`
  (they `add_subdirectory` it and link `zpwr::clip_engine`). Only zpwr-synth
  currently wires the native sequencer.

### Gaps to close
1. No generalized grid engine — two hardwired copies (clip.js DOM, als-timeline.js canvas).
2. The canvas grid (the good GUI) lives in audio_haxor, not here.
3. No C ABI / FFI surface → Rust hosts (haxor, ztranslator) cannot use the backend.
4. No host-agnostic JS transport adapter (JUCE native-fn vs Tauri `invoke`).

## 3. Target architecture

```
zpwr-clip-engine/
  webui/
    grid/                      # NEW: the generalized canvas grid engine (from als-timeline.js)
      grid-core.js            #   renderer + hit-testing + layout (DPR, ResizeObserver)
      grid-interactions.js    #   paint/erase/value/scroll/range/ramp/boundary + popover
      grid-model.js           #   lanes × cells value model + (de)serialization
      domains/
        notes.js              #   pitch lanes × step cells, value = velocity/length (replaces clip.js domain)
        automation.js         #   macro lanes × bar-blocks, value = 0..1 (the ALS domain)
        triggers.js           #   action lanes × time slots, value = trigger (ztranslator)
      transport/
        juce-bridge.js        #   nf() -> JUCE WebBrowserComponent native fns (existing registerClipSeqFns)
        tauri-bridge.js       #   nf() -> Tauri invoke(...) for Rust hosts
    clip/                     # existing tab markup/styles; migrate to grid/ domain=notes
  include/zpc/
    ClipSeq.h                 # existing JUCE native-fn contract (keep for plugins)
    ClipEngine.h              # NEW: pure C++ engine (pattern model + step clock), no JUCE in the core path
    capi/clip_engine.h        # NEW: C ABI (extern "C") for FFI
  src/capi/clip_engine.cpp    # NEW: C ABI implementation wrapping ClipEngine
  bindings/rust/              # NEW: Rust crate wrapping the C ABI (cbindgen header + -sys + safe wrapper)
  CMakeLists.txt              # add capi static + optional cdylib targets
```

Principle: **one renderer, one interaction model, N domain bindings, 2 transport
bridges.** The frontend never knows whether it is inside JUCE or Tauri — it calls
an injected `nf`/transport object (the pattern `clip.js` already uses).

## 4. Generalization model (collapse both grids into one)

A **domain** supplies everything that differs; the grid engine supplies
everything that is shared (render loop, hit-test, all gestures, popover, persist).

```
Domain = {
  lanes(),                 // [{ id, label, color }]  (pitches | macro params | triggers)
  cells(),                 // [{ key, x-extent }] over the time axis (steps | 8-bar blocks | slots)
  value: { type: 'unit'|'length'|'bool', min, max, step },  // how a cell value is interpreted/drawn
  capabilities: {          // which gestures apply
    paint, erase, valueDrag, scroll, rangeSelect, ramp,
    resizableRegions,      // ALS boundary-drag (off for notes/triggers by default)
  },
  serialize(model)         // -> JSON payload for the backend (per-domain shape)
  deserialize(json)        // -> model
  labels: { laneAxis, timeAxis, hint }
}
```

Domain mappings:
- **notes** (clip): lanes = pitches C2..C7 (scrollable), cells = steps, value =
  `length` (drag right edge = note length; keeps clip.js semantics). Serialize to
  the existing `[{s,l,n,len,v}]` ClipSeq pattern shape.
- **automation** (ALS): lanes = the 6 macro params, cells = 8-bar blocks, value =
  `unit` 0..1, `resizableRegions` on. Serialize to the ALS
  `{param:{bar:value}}` shape.
- **triggers** (ztranslator): lanes = actions/outputs, cells = time slots, value =
  `bool`. Serialize to a trigger-list shape (TBD with ztranslator owner).

Note: clip.js drags the **right edge** for note *length* (horizontal); als drags
the **top edge** for *value* (vertical). The unified engine must support **both
edge-drag axes**, chosen by `value.type` (`length` → horizontal resize handle,
`unit`/`bool` → vertical height). This is the single most important merge detail.

## 5. Transport / backend bridge (host-agnostic frontend)

The frontend already isolates host calls behind `nf(name)(...args)` in clip.js.
Keep that. Provide two adapters that produce an `nf`:
- **JUCE** (`transport/juce-bridge.js`): `nf` resolves to `Juce.getNativeFunction
  (prefix + name)` — i.e. the existing `clipSeq*` fns from `registerClipSeqFns`.
  No backend change for plugins.
- **Tauri** (`transport/tauri-bridge.js`): `nf` resolves to a wrapper over
  `window.__TAURI__.invoke('clip_seq_' + name, {...})`. The Rust command handler
  forwards to the C ABI (§6).

Pattern/transport JSON stays identical across both bridges (already defined in
`ClipSeq.h`). Playhead readback: JUCE = `clipSeqStep` poll (rAF); Tauri = an
`invoke('clip_seq_step')` poll or a Tauri event emitted from Rust.

## 6. FFI / C ABI design (for Rust hosts)

Add a C ABI so Rust (haxor, ztranslator) can drive the same engine the plugins
use. Core engine logic must be split out of JUCE-coupled code first.

1. **`include/zpc/ClipEngine.h`** — pure C++ engine: holds the pattern + transport,
   advances a step clock, exposes `currentStep()`, fires per-step note/trigger
   callbacks. No `WebBrowserComponent` dependency; `juce_core` is acceptable but
   prefer plain types at the boundary.
2. **`include/zpc/capi/clip_engine.h`** — `extern "C"` surface, opaque handle:
   ```c
   typedef struct ZpcClipEngine ZpcClipEngine;
   ZpcClipEngine* zpc_clip_new(void);
   void  zpc_clip_free(ZpcClipEngine*);
   void  zpc_clip_set_pattern(ZpcClipEngine*, const char* json);     // [{s,l,n,len,v}]
   void  zpc_clip_set_transport(ZpcClipEngine*, int steps, double bpm, double per_beat,
                                float swing, int swing_unit, int loop, int per_layer, int target);
   void  zpc_clip_play(ZpcClipEngine*, int playing);
   int   zpc_clip_step(const ZpcClipEngine*);                        // -1 stopped
   // pull events produced since last poll (note/trigger), for hosts without an audio callback:
   int   zpc_clip_poll_events(ZpcClipEngine*, ZpcClipEvent* out, int max);
   ```
3. **`src/capi/clip_engine.cpp`** — implement over `ClipEngine`.
4. **CMake**: add `zpwr_clip_engine_capi` (STATIC + optional `cdylib`/SHARED for
   Rust `dylib` linking). Keep `zpwr::clip_engine` (JUCE) intact for plugins.
5. **`bindings/rust/`**: a `-sys` crate (cbindgen-generated header + `bindgen` or
   hand-written `extern "C"` decls) + a safe wrapper crate. haxor/ztranslator add
   it as a path/git dependency and expose Tauri commands that call it.

Threading: the C ABI engine must be drivable either from an audio callback
(plugins already do this via `ClipSeqHooks`) or from a Rust-side timer/audio
thread (Tauri hosts). `zpc_clip_poll_events` covers hosts that pull on a timer.

## 7. Execution phases

Each phase is independently shippable; the plugins must keep working at every step
(the CLIP tab is live in zpwr-synth).

**Phase 0 — lift the canvas grid into this repo (no behavior change).**
- Copy `als-timeline.js` → `webui/grid/` as the starting point. Keep it working
  in haxor by having haxor import from the submodule path (or keep haxor's copy
  until Phase 4). Success: file builds/lints here; haxor unchanged.

**Phase 1 — generalize: split renderer / interactions / model / domain.**
- Refactor the lifted file into `grid-core.js` + `grid-interactions.js` +
  `grid-model.js` with a `Domain` object (§4). Re-express the ALS behavior as
  `domains/automation.js`. Success: an `automation` grid renders + behaves
  byte-for-byte like today's als-timeline (verify against the gesture inventory
  in §2).

**Phase 2 — notes domain (replace clip.js piano-roll).**
- Implement `domains/notes.js`: pitch lanes, step cells, `value.type='length'`
  (horizontal edge-drag), scales/random/presets/swing/divisions carried over
  from clip.js, serialize to the `[{s,l,n,len,v}]` ClipSeq shape. Wire it through
  `transport/juce-bridge.js` to the existing `registerClipSeqFns`. Success: the
  synth CLIP tab runs on the new grid with parity to current clip.js (playback,
  per-layer, native clock, fallback).

**Phase 3 — backend split + C ABI + Rust bindings.**
- Extract `ClipEngine.h` from the JUCE-coupled glue; add `capi/` + CMake targets
  + `bindings/rust/`. Success: a Rust integration test drives a pattern and reads
  back steps/events via the safe wrapper; plugins still build against
  `zpwr::clip_engine` unchanged.

**Phase 4 — consumer cutover.**
- 3 plugins: point CLIP tab at `webui/grid` (domain=notes) via JUCE bridge; bump
  submodule pins. haxor: ALS generator uses `webui/grid` (domain=automation) via
  Tauri bridge + Rust bindings; delete haxor's local `als-timeline.js`.
  ztranslator: `domains/triggers.js` + Tauri bridge as a trigger source. Success:
  all five consumers run the single shared engine; haxor's duplicate is gone.

**Phase 5 — docs + invariants.**
- README for embedding (C++ submodule path + Rust crate path), per-domain usage,
  and a pinned interaction-parity checklist (the §2 inventory) as the regression
  contract.

## 8. Success criteria
- One grid renderer + interaction model; zero duplicated gesture code.
- The synth CLIP tab has full parity with current `clip.js` (playback, per-layer,
  swing, divisions, native clock + JS fallback, key-trigger).
- haxor ALS timeline behaves identically to today on the shared grid; its local
  `als-timeline.js` is deleted.
- Rust hosts drive the engine through the safe FFI wrapper (integration-tested).
- Plugins build against `zpwr::clip_engine` with no API break at any phase.

## 9. Rollback
- Phases 0–3 are additive; the live `clip.js` path stays until Phase 4 flips each
  consumer. Roll back a consumer by reverting its submodule pin + the one-line
  frontend wiring. The C++ `zpwr::clip_engine` target and `ClipSeq.h` contract are
  never removed, so plugins can always fall back to the current clip.js.

## 10. Open questions (decide before Phase 2/3)
1. **Notes value axis**: keep clip.js's horizontal length-drag *and* add a vertical
   velocity-drag (top-band) per the ALS model? (Recommend yes — `value.type`
   supports both; velocity is currently fixed at 100 in `clipSeqPatternJson`.)
2. **Time axis for notes**: fixed step grid (current) vs. resizable regions like
   ALS sections? Default: notes off `resizableRegions`; revisit for an arranger view.
3. **ztranslator trigger schema**: what does a "trigger" cell emit (action id +
   payload)? Needs the ztranslator owner's contract before `domains/triggers.js`.
4. **Tauri playhead**: poll `invoke('clip_seq_step')` vs. Rust-emitted Tauri event?
   Event is lower-latency; poll is simpler. Default poll, revisit if jittery.
5. **cdylib vs staticlib** for Rust linkage on macOS universal + Linux: default
   staticlib for plugins-adjacent builds, cdylib only if a host needs dynamic load.
6. **Persistence keys**: clip.js uses `localStorage zfx_clip_layers`;
   als-timeline uses `prefs alsSectionOverrides`. Unify under a domain-scoped key
   provided by the host via `deps`.
