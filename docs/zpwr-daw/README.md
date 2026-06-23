```
███████╗██████╗ ██╗    ██╗██████╗       ██████╗  █████╗ ██╗    ██╗
╚══███╔╝██╔══██╗██║    ██║██╔══██╗      ██╔══██╗██╔══██╗██║    ██║
  ███╔╝ ██████╔╝██║ █╗ ██║██████╔╝█████╗██║  ██║███████║██║ █╗ ██║
 ███╔╝  ██╔═══╝ ██║███╗██║██╔══██╗╚════╝██║  ██║██╔══██║██║███╗██║
███████╗██║     ╚███╔███╔╝██║  ██║      ██████╔╝██║  ██║╚███╔███╔╝
╚══════╝╚═╝      ╚══╝╚══╝ ╚═╝  ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚══╝╚══╝ 
```

![C++](https://img.shields.io/badge/C%2B%2B-20-05d9e8?style=flat-square)
![JavaScript](https://img.shields.io/badge/JavaScript-grid%20engine-ff2a6d?style=flat-square)
![Rust](https://img.shields.io/badge/Rust-bindings-39ff14?style=flat-square)
![Role](https://img.shields.io/badge/role-DAW%20arranger%20engine-d300c5?style=flat-square)
![C ABI](https://img.shields.io/badge/C%20ABI-FFI-05d9e8?style=flat-square)
![Export](https://img.shields.io/badge/export-Type--0%20MIDI-ff2a6d?style=flat-square)
![MenkeTechnologies](https://img.shields.io/badge/MenkeTechnologies-audio%20stack-d300c5?style=flat-square)

### `[ONE GRID ENGINE, N DOMAINS, TWO TRANSPORT BRIDGES]`

> *"One renderer + one interaction model + one value model, bound to a domain."*

A standalone **DAW arranger engine** — a generalized canvas grid (notes / arranger /
automation / triggers domains), a pure C++ `ClipEngine` with a swung audio-thread step
clock, a C ABI for Rust hosts, and byte-identical C++/JS MIDI export. Shared across the
MenkeTechnologies audio stack. Created by MenkeTechnologies. See the
[Engineering Report](docs/report.html) and the
[DAW Arranger Port Report](docs/arranger_port_report.html).

# zpwr-daw

A full DAW arranger engine — extracted as a standalone library (formerly
`zpwr-clip-engine`). It started as a per-layer piano-roll pattern sequencer and
grew into a two-view DAW: an **Arrangement** timeline (tracks, clips, sections,
tempo/meter maps, markers, breakpoint automation) and a **Session** clip launcher
(scenes, follow actions), plus MIDI/JSON export and an in-progress JUCE audio-clip
layer. Playback runs on a native audio-thread step clock when the host wires it
(minimise-proof) and falls back to a JS timer otherwise. See the live coverage
audit in [`docs/arranger_port_report.html`](docs/arranger_port_report.html).

It carries these pieces:

| Piece | Path | Role |
| --- | --- | --- |
| Generalized grid engine | `webui/grid/` | One canvas renderer + one interaction model + a value model, bound to a `domain` (notes / automation / triggers). The FL-Studio-style clip / timeline / arranger grid, host-agnostic. |
| Grid domains | `webui/grid/domains/` | `notes.js` (pitch lanes × step cells, value = note length → the CLIP piano-roll), `arranger.js` (tracks × bars, cells = clip ids → the DAW arrangement; double-click a clip drills into its notes), `automation.js` (macro lanes × 8-bar blocks, value 0..1 → the ALS section-overrides timeline), `triggers.js` (action lanes × time slots, value = bool → ztranslator). |
| Transport bridges | `webui/grid/transport/` | `juce-bridge.js` (`nf` → JUCE `WebBrowserComponent` native fns) and `tauri-bridge.js` (`nf` → Tauri `invoke`). The frontend never knows which host it runs in. |
| Slot sequencer | `webui/grid/sequencer.js` | A JS step clock that walks the time axis and fires every set cell per slot (swing-aware). Drives the triggers domain and is the JS-fallback clock for any host without a native engine. |
| Pure C++ engine | `include/zpc/ClipEngine.h` | JUCE-free pattern model + swung step clock + event queue. Timing/length semantics ported verbatim from the clip.js fallback sequencer. |
| MIDI File export | `include/zpc/MidiFile.h`, `webui/grid/export/midi.js` | Renders a pattern to a Type-0 Standard MIDI File — import the sequencer into any compatible DAW (Ableton, FL, Logic, Reaper). Byte-identical C++ and JS exporters. |
| C ABI (FFI) | `include/zpc/capi/clip_engine.h`, `src/capi/clip_engine.cpp` | `extern "C"` surface over `ClipEngine` so Rust hosts drive the same engine the JUCE plugins drive. |
| Rust bindings | `bindings/rust/` | `zpwr-clip-engine-sys` (raw decls, compiles the C ABI via `cc`) + `zpwr-clip-engine` (safe wrapper). |
| Note-stream module pack | `include/zpc/midi/`, `src/midi/` | Chord / Arp / Scale / Euclidean / Game-of-Life / Brian-Brain / Langton + the chord & scale engines, all as `ModuleInfoT<NoteStream>` modules. The MIDI counterpart to the header-only audio pack. |
| Native sequencer glue | `include/zpc/ClipSeq.h` | The `clipSeq*` host contract (`ClipSeqHooks`) + a templated helper that registers the matching native functions on a JUCE `WebBrowserComponent` options builder. |
| CLIP web UI (legacy) | `webui/clip/` | The original DOM piano-roll as an ES module (`clip.js` exporting `initClip`). Stays live until consumers cut over to the grid engine (notes domain). |

## Dependencies

The note pack is templated on the signal-agnostic graph core
(`ModuleRegistryT` / `RuntimeGraphT` / `SignalTraits`) from
[zpwr-patch-core](https://github.com/MenkeTechnologies/zpwr-patch-core), vendored
as a submodule under `libs/zpwr-patch-core`. Only `juce_core` beyond that.

```sh
git clone --recurse-submodules https://github.com/MenkeTechnologies/zpwr-daw.git
```

## Build (standalone test)

Point `ZPC_JUCE_DIR` at a JUCE checkout. Standalone builds compile the two graph-core
translation units from the submodule directly, so no separate `zpwr_patch_core` lib is
required; when embedded in a host that already defines `zpwr_patch_core`, this links that
target instead.

```sh
cmake -S . -B build -DZPC_JUCE_DIR=/path/to/JUCE
cmake --build build --target MidiModulesTest
./build/MidiModulesTest_artefacts/*/MidiModulesTest
```

## Embedding in a host

CMake — add this repo as a submodule and link the alias. If the host already adds
`zpwr-patch-core`, add it **before** this so the core lib is reused rather than recompiled:

```cmake
add_subdirectory(libs/zpwr-patch-core)   # the host's own core submodule (optional)
add_subdirectory(libs/zpwr-clip-engine)
target_link_libraries(MyPlugin PRIVATE zpwr::clip_engine)
```

Native sequencer — wire the audio-thread clock and register the JS bridge:

```cpp
#include <zpc/ClipSeq.h>

zpc::ClipSeqHooks clip;
clip.pattern   = [this] (const juce::String& json) { /* parse + stage pattern */ };
clip.transport = [this] (int steps, double bpm, double perBeat, float swing,
                         int swingUnit, bool loop, bool perLayer, int target) { /* … */ };
clip.play      = [this] (bool on) { /* start / stop the processBlock step clock */ };
clip.step      = [this] { return currentStep; };

rootObject->setProperty ("hasClipSeq", clip.wired());        // advertise availability to the page
options = zpc::registerClipSeqFns (std::move (options), clip, pfx);
```

Web UI — load the styles and module, then wire it with the host's helpers:

```js
import { initClip } from "./clip/clip.js";
const clip = initClip({ el, nf, getCAT, getActiveLayer });
clip.buildClip();                       // (re)render the roll, e.g. on tab switch
// keyboard handlers call clip.clipManualKey(true|false); transport calls clip.clipStop()
```

Open `webui/clip/demo.html` in a browser to see the legacy roll render against stub host deps.

## Generalized grid engine (`webui/grid/`)

One renderer + one interaction model + one value model, bound to a `domain`.
The domain supplies everything that differs (lanes, time-axis cells, value type,
which gestures apply, serialize shape); the engine supplies everything shared
(render loop, hit-test, all gestures, popover bulk-edit, persistence). The merge
detail that matters: `value.type` selects the edit-drag axis — `'length'` →
horizontal right-edge note resize (notes), `'unit'` → vertical top-band value
height (automation), `'bool'` → click toggle (triggers).

```js
import { createGrid } from "./grid/index.js";
import { createNotesDomain } from "./grid/domains/notes.js";
import { createJuceBridge } from "./grid/transport/juce-bridge.js";

const { nf } = createJuceBridge({ prefix: uiPrefix });   // or createTauriBridge()
const grid = createGrid({
    canvas: document.getElementById("clip-grid"),
    domain: createNotesDomain({ getSteps, getPerBeat, layer: 0 }),
    store: localStorage,
    storageKey: "zfx_clip_notes_L0",
    onChange: (model) => nf("clipSeqPattern")(JSON.stringify(model.serialize())),
});
grid.setPlayhead(currentStep);   // drive the playhead column from the transport
```

Domains: `createNotesDomain` (piano-roll, serializes to the `[{s,l,n,len,v}]`
ClipSeq shape), `createAutomationDomain` (ALS lanes, serializes to the Rust
`{param:{bar:value}}` shape, resizable sections), `createTriggersDomain`
(provisional trigger shape, pending the ztranslator contract).

Pure-logic tests (model, domains, layout/hit math) run headless:

```sh
node --test webui/grid/tests/grid.test.mjs
```

## C ABI + Rust bindings (for Rust hosts)

The pure C++ `ClipEngine` advances a swung step clock and queues note on/off
events; the C ABI (`include/zpc/capi/clip_engine.h`) exposes it to Rust so
Audio-Haxor / ztranslator drive the same engine the JUCE plugins drive. The
`-sys` crate compiles the JUCE-free `clip_engine.cpp` directly with `cc` — no
CMake or JUCE needed for the Rust path.

```rust
use zpwr_clip_engine::ClipEngine;
let mut e = ClipEngine::new();
e.set_pattern(r#"[{"s":0,"l":0,"n":60,"len":2,"v":100}]"#);
e.set_transport(4, 120.0, 4.0, 0.0, 1, /*loop*/ true, /*per_layer*/ false, /*target*/ 0);
e.play(true);
e.advance(0.125);                       // one step at 120 bpm / 1/16
for ev in e.poll_events() { /* route note on/off to the synth */ }
```

```sh
cargo test --manifest-path bindings/rust/zpwr-clip-engine/Cargo.toml
```

C/C++ consumers can instead link the CMake target `zpwr::clip_engine_capi`
(static) or build `-DZPC_BUILD_CAPI_SHARED=ON` for a shared library.

## Export to MIDI (import into a compatible DAW)

Any pattern renders to a Type-0 Standard MIDI File — the universal DAW
interchange format — so the sequencer's output drops straight into Ableton, FL,
Logic, Reaper, etc. One step = one grid cell; `perBeat` is steps-per-quarter
(the clip.js note division); layer → MIDI channel; `repeats` renders the pattern
back-to-back N times. The C++ (`include/zpc/MidiFile.h`) and JS
(`webui/grid/export/midi.js`) writers emit byte-identical files.

Rust / native:

```rust
let mut e = ClipEngine::new();
e.set_pattern(r#"[{"s":0,"l":0,"n":60,"len":2,"v":100}]"#);
e.set_transport(4, 120.0, 4.0, 0.0, 1, true, false, 0);
e.write_midi_file("clip.mid", /*repeats*/ 4)?;     // or e.render_midi(4) -> Vec<u8>
```

Web (grid frontend):

```js
import { patternToMidi, downloadMidi } from "./grid/export/midi.js";
downloadMidi(patternToMidi(grid.serialize(), { bpm, perBeat, steps, repeats: 4 }), "clip.mid");
```

C ABI: `zpc_clip_render_midi(engine, repeats, &data, &len)` (free with
`zpc_bytes_free`). The exporters are verified by round-trip parsing in the test
suites (`cargo test`, `node --test webui/grid/tests/midi.test.mjs`).

## Interaction parity checklist (regression contract, HANDOFF §2)

The grid engine must preserve every gesture from the ALS timeline it was lifted
from. Verify against this list when touching `grid-interactions.js`:

- paint (left click-drag), cross-lane sweep
- erase (right click-drag), cross-lane sweep; native context menu suppressed
- value-by-height drag (unit) / right-edge length drag (notes)
- scroll fine-tune (±`value.step`)
- shift-click range-select within a lane
- cmd/ctrl-click ramp (anchor → clicked, linear, y = end value)
- multi-select + popover bulk-edit of the whole selection
- boundary-drag region resize with frozen pixel↔unit mapping + ghost preview (automation)
- DPR-correct canvas layout + ResizeObserver reflow; custom cursors
