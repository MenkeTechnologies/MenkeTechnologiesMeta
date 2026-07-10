# GUI Automation Bus — Rollout Checklist

Work list to bring every app onto the bus defined in [`GUI_AUTOMATION_BUS.md`](GUI_AUTOMATION_BUS.md)
(§4 surface · §5 bridge · §6 `stryke-app` · §7 transport · §11 rollout). Companion to
[`GUI_APP_ARCHITECTURE.md`](GUI_APP_ARCHITECTURE.md) (core/host ownership) and
[`GUI_POLISH_GATE_CHECKLIST.md`](GUI_POLISH_GATE_CHECKLIST.md).

**Status: nothing built.** Every cell starts ☐. The shared prerequisites (Phase 0) block all per-app
work; do not start an app row until Phase 0 for its track is ✅.

## Roster (21 apps, two tracks)

Derived from `app-store/store.js` — recompute, don't trust the literal:
```
# Desktop Apps (Track A):
perl -0777 -ne 'while(/name:\s*['"'"'"]([^'"'"'"]+)['"'"'"][^}]*?category:\s*['"'"'"]Desktop Apps['"'"'"]/gs){print "$1\n"}' app-store/store.js
# Audio Plugins (Track B):
perl -0777 -ne 'while(/name:\s*['"'"'"]([^'"'"'"]+)['"'"'"][^}]*?category:\s*['"'"'"]Audio Plugins['"'"'"]/gs){print "$1\n"}' app-store/store.js
```

- **Track A — Tauri / webview (18):** `zpdf`, `zphoto`, `zemail`, `zstation`, `zoffice`, `Audio-Haxor`,
  `traderview`, `ztranslator`, `zcite`, `zreq`, `ztunnel`, `zthrottle`, `zgo`, `zftp`, `zcontainer`,
  `zterminal`, `zwire`, `zpwr-daw`. Uses `ZGui.automation` (JS) + `zgui-bridge` (Rust socket) +
  `run_stryke_hook`.
- **Track B — JUCE (4):** `zpwr-daw`, `zpwr-synth`, `zpwr-fx`, `zpwr-midi-fx`. No webview, no Tauri
  `invoke` — the surface, socket host, and stryke embedding are **C++ / C-ABI**.
- **`zpwr-daw` is in both** — its Tauri shell rides Track A; its JUCE `ClipEngine` rides Track B. The two
  surfaces namespace under one bus name (`zpwr-daw.timeline.*` shell, `zpwr-daw.clip.*` engine).

`Audio-Haxor` is Tauri+JUCE but is driven through its Tauri shell → **Track A only**.

---

## Phase 0 — shared prerequisites (once, blocking)

### 0A — Track A substrate (`zgui-core` + `strykelang`)
- [ ] `zgui-core/webui/automation.js` — `ZGui.automation`: `register({app,verbs,state,events})`,
      `surface()`, `emit(id,payload)`, and the call/get/subscribe **dispatch** to registered handlers (§4).
- [ ] Upgrade the `event`-step editor (`user-commands.js:300`) to read the typed `surface()` instead of
      label-only `setActions`.
- [ ] `zgui-bridge` (new shared Rust crate) — Unix-socket host, newline-JSON frame codec, request router
      (§7.1). One entry point: `zgui_bridge::serve(app_name, surface)`.
- [ ] Port the request/response + subscribe substrate out of **zcontainer** into `zgui-bridge` (don't
      reinvent) — reference impl per §5.
- [ ] `stryke-app` package (sibling of `stryke-gui`) — `app__*` FFI, the `App` module
      (`here/open/list/verbs/call/get/on`), + `stryke.toml [ffi.exports]` entries (pkg-FFI-manifest rule).
- [ ] `run_stryke_hook` (app backends' shared handler) — bind `App::here()` into the script's host env so
      palette/hook scripts get the live surface (§8).

### 0B — Track B substrate (JUCE / C-ABI)
- [ ] C++ automation-surface API mirroring §4 (`registerVerb/registerState/emitEvent`) inside the JUCE
      shared layer — the plugins have no `window.ZGui`.
- [ ] Socket host reachable from C++ — either link `zgui-bridge` over the existing **C ABI** (`zpwr-daw`
      already ships "C ABI + Rust bindings") or a thin C++ server speaking the same §7.1 frames.
- [ ] **Plugin-instance addressing** — a VST3/AU/CLAP plugin runs *inside a DAW*, N instances at once.
      Decide the socket name scheme (`zgui/zpwr-synth.<pid>.<instance>.sock`) + a discovery list so
      `App::list()` / `App::open` can target one instance. **Standalone** builds are single-instance and
      use the plain `zgui/<app>.sock`.
- [ ] Embed stryke in the plugin via the shared fusevm C ABI (same VM as zpwr-daw) so in-process
      `App::here()` works inside the plugin.

> Track B has a real open question the RFC flags: an audio plugin is not a top-level process it fully
> controls, and the audio thread must never block on a socket call. **All bus I/O stays off the audio
> thread** (message thread only); verbs that touch DSP state marshal via the existing lock-free queue.

---

## Per-app recipe

### Track A (per app)
1. [ ] **Enumerate** the app's existing ⌘K actions → declare each as a typed **verb**
       (`id,label,params,returns,run`) in `ZGui.automation.register`. Promote, don't rewrite.
2. [ ] Declare **state** queries (selection, active doc/context/collection) with `get()`.
3. [ ] Declare **events** the app emits; call `ZGui.automation.emit(id,payload)` at each emit site.
4. [ ] Backend: add `zgui_bridge::serve("<app>", surface)` in `main` → opens the socket.
5. [ ] Register any **embedded cores'** verbs into the host surface, namespaced (`<core>.*`), per the
       core/host ownership rule — cores contribute verbs, the host owns the socket.
6. [ ] **Verify in-proc:** a palette `stryke` step calls a verb, reads a state, gets a value back.
7. [ ] **Verify out-of-proc:** from zshrs, `App::open("<app>")->call(...)`/`->get(...)` works over the socket.
8. [ ] Docs: list the app's verb surface in its README/docs (surface only — **no test names**, per rule).

### Track B (per JUCE app)
1. [ ] Declare verbs/state/events via the C++ surface API (transport, engine, DSP params where safe).
2. [ ] Stand up the socket host: **standalone** first (single instance), then plugin per-instance.
3. [ ] Embed stryke via the C ABI so `App::here()` runs inside the plugin (message thread).
4. [ ] **Verify standalone:** drive it from zshrs via `App::open`.
5. [ ] **Verify plugin:** load in a DAW, address the instance, drive one verb without an audio-thread stall.

**Done (per app)** = every box in its track's recipe is ✅ and both verify steps pass.

---

## Status matrix — Track A

Legend: ☐ not started · ◐ in progress · ✅ done · N/A.

| App | verbs | state | evt | sock | cores | in-proc | out-proc | docs |
| --- |:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| zcite ⭐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zreq ⭐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zcontainer | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zemail | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zftp | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zgo | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| ztunnel | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| ztranslator | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zpdf | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zphoto | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zoffice | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zstation | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zterminal | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zwire | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zthrottle | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| traderview | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| Audio-Haxor | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zpwr-daw (shell) | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |

## Status matrix — Track B (JUCE)

| App | surface | sock(standalone) | inst(plugin) | stryke-embed | verify-standalone | verify-plugin | docs |
| --- |:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| zpwr-daw (engine) | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zpwr-synth | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zpwr-fx | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| zpwr-midi-fx | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |

---

## Order

1. **Phase 0A** (Track A substrate) — nothing else can start until this lands.
2. **Pilots ⭐ `zcite` + `zreq`** — highest existing action counts (85 / 75), rich state, natural cross-app
   pair. Prove in-proc + out-of-proc + one cross-app script (`zcite` selection → `zreq` request) before
   fan-out.
3. **Fan out Track A** — remaining 16 apps, one session each (16-pane workflow).
4. **Phase 0B** (Track B substrate) — in parallel with Track A fan-out; the plugin-instance addressing is
   the gating unknown.
5. **Track B apps** — `zpwr-daw` engine first (already has the C ABI), then the three plugins.

## Acceptance

- [ ] Every app row in both matrices fully ✅.
- [ ] One end-to-end cross-app `.stk` in zshrs drives ≥3 apps from ≥2 domains in a single run.
- [ ] `App::list()` from zshrs enumerates every running app (Track A + Track B standalone).
- [ ] Only then does the §12 "20+ apps on the bus" claim become true (unbuilt until then).
