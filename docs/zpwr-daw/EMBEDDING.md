# Embedding zpwr-daw

zpwr-daw is a host-agnostic **timeline / clip / automation engine**. It emits
events; **the host decides what an event does.** The same arrangement drives
MIDI in the synth plugins, **trades** in traderview, **translations** in
ztranslator, and **stryke transforms** in Audio-Haxor — nothing in the engine
knows which.

It ships three ways from one codebase:

| Mode | Host | Transport |
| --- | --- | --- |
| **Plugin** | synth / fx / midi-fx (JUCE) | JUCE `WebBrowserComponent` native fns |
| **Embedded** | traderview, ztranslator, Audio-Haxor, any Tauri/JUCE app | the host's bridge (`nf`) |
| **Standalone** | the engine alone (sellable) | JS-clock fallback, no host needed |

## The four seams

Everything a host touches goes through one of these.

### 1. Transport bridge — `nf(name)(...args)`
The frontend never knows its host. It calls `nf("clipSeqStep")()`, `nf("clipAutoValue")(...)`, etc. You supply `nf`:

```js
import { createTauriBridge } from "./grid/transport/tauri-bridge.js";   // or createJuceBridge
const { nf } = createTauriBridge({ prefix: "myapp" });   // nf → tauri invoke
```

A bare stub works too (standalone): `const nf = (name) => (...a) => Promise.resolve();`

### 2. Clip data — `model.serialize()`
Every clip, note, automation point and arrangement is plain JSON:
```js
model.serialize();          // notes: [{ s, l, n, len, v }] ; arrangement: { trackId: { bar: {clipId,len} } } ; automation: { laneId: [{t,v}] }
```
This is the read seam. **Audio-Haxor reads a clip's notes, runs stryke on them, writes them back** with `model.deserialize(...)`. Any host can transform clips this way.

### 3. Hook contracts (host implements what it needs)
- **`zpc::ClipSeqHooks`** (`include/zpc/ClipSeq.h`) — the audio-thread note clock. Optional; null = JS-clock fallback.
- **`zpc::ClipAudioHooks`** (`include/zpc/ClipAudio.h`) — audio clips → `zpc::AudioClipPlayer` (`include/zpc/AudioClip.h`). *(C++ side; unverified pending a JUCE build.)*

### 4. The trigger surface — clips + automation fire host actions
This is the generic, non-audio path, and the point of the engine:

- **Clips** fire events when the arrangement clock reaches them.
- **Automation lanes** fire their value live every step: `nf("clipAutoValue")(cc, byte0..127, laneId, value0..1)`.
- The **`triggers` domain** (`webui/grid/domains/triggers.js`) is bool action lanes — one cell = one host action.

The host binds the meaning:

```js
// traderview: an automation lane drives position size; a trigger clip places the trade.
const nf = (name) => {
  if (name === "clipAutoValue") return (cc, byte, lane, v) => { if (lane === "size") positionSize = v; };
  if (name === "clipSeqStep")   return () => -1;            // JS clock
  return () => Promise.resolve();
};
// when a trigger clip fires (your sequencer callback): placeTrade(side, positionSize);
```

```js
// ztranslator: each trigger cell → an output; automation picks the variant.
//   clip trigger → emit(currentOutput);   clipAutoValue("variant", v) → currentOutput = pickVariant(v);
```

## Minimal embed

```js
import { initClipSeq } from "./clip/clip-seq.js";
const api = initClipSeq({ el, nf, getCAT: () => ({ hasKeyboard: true }), getActiveLayer: () => 0 });
api.buildClip();   // renders the arranger into #clip-grid; wire your toolbar ids (see clip-seq-demo.html)
```

Serve over **http://** (ES modules are CORS-blocked over `file://`). See
`webui/clip/clip-seq-demo.html` for a complete standalone wiring, and the
[port report](arranger_port_report.html) for the full feature coverage.
