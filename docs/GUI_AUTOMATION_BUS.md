# GUI Automation Bus — Design Doc (RFC)

Status: proposed. Defines how **stryke scripts drive every MenkeTechnologies GUI app** — semantically,
in-process and from the shell, with cross-app orchestration. Extends the existing user-programmable
command palette (`zgui-core/webui/user-commands.js`) from a fire-and-forget step runner into a
bidirectional automation surface. Companion to `GUI_APP_ARCHITECTURE.md` (shell/view boundary) and
`GUI_APP_REQUIREMENTS.md`. The live surface every app exposes is catalogued in
[`GUI_SCRIPT_ACTIONS.md`](GUI_SCRIPT_ACTIONS.md) (generated from each app's verb source).

---

## 1. Problem

The apps already ship a user-programmable command palette. `ZGui.userCommands`
(`app-store/zgui-core/webui/user-commands.js`) stores a shared, cross-app JSON list of command entries,
each a chain of typed steps: `url | js | scheme | event | stryke | bash`. Two steps matter here:

- **`event`** (`user-commands.js:171`) dispatches **one** app action id. Apps publish their action
  vocabulary via `setActions([{id,label}])` — **id + label only**. No params, no return, no state.
- **`stryke`** (`user-commands.js:174`) runs a script via `invoke("run_stryke_hook", {script, ctx:{arg}})`
  on the backend.

The `stryke` step is a **dead end**. The script runs on the backend, receives `ctx.arg`, returns — and
has **no handle back into the app**. It cannot:

- call an app action and get its **return value**,
- read app **state** (current selection, open document, list contents),
- **subscribe** to app events,
- reach a **different** app.

And `event` fires exactly one action with no args and no result. So today you get *either* a blind
script *or* one fire-and-forget action. Never **stryke driving the app**. That is the entire gap this
RFC closes.

## 2. Goals / Non-goals

**Goals**
- A running stryke script can enumerate an app's verbs, **call** them with typed args and receive the
  **return value**, **read** state, and **subscribe** to events.
- Same API whether the script runs **in-process** (palette step, hooks) or **out-of-process** (a `.stk`
  file in zshrs driving a *running* app).
- **Cross-app**: one script in one terminal orchestrates zcite + zemail + zreq + zcontainer together.
- Semantic, not pixel — driving named verbs, not screen coordinates.
- One shared implementation in `zgui-core` + one stryke package; per-app cost is only *declaring verbs*.

**Non-goals**
- Not a replacement for `stryke-gui` (OS-level mouse/keyboard/pixel) — that stays as the fallback for
  non-owned apps and for input synthesis. This bus is for the **owned suite**, driven semantically.
- Not a network protocol. Local socket only, single user, single machine.
- Not a new language. stryke is the language; this is an `App` module for it.

## 3. Model — five layers

| Layer | What | Extends / reference impl |
| --- | --- | --- |
| **1. Automation surface** | Each app declares a typed verb dictionary + state queries + events. Introspectable. | formalizes `setActions` |
| **2. Bridge** | Request/response RPC so a stryke `call` returns a value from the app. | zcontainer "sync invoke + streaming subscribe substrate" |
| **3. stryke `App` module** | `use App`; open/list apps; `call`/`get`/`on`/`verbs`. | mirrors `stryke-gui` / `stryke-aws` package shape |
| **4. Transport** | In-proc = direct callback; out-of-proc = per-app Unix socket + JSON-RPC wire. | zterminal→tmux imsg socket protocol |
| **5. Front-ends** | Palette `stryke` step, hooks runtime, standalone `.stk` — all get `App` in scope. | palette becomes one client |

Governing rule (consistent with `GUI_APP_ARCHITECTURE.md`): the automation surface is **owned by the
core** (a core knows its own verbs), the **socket host is owned by the top-level app** (one socket per
running app process, like one `⌘K` per app). An embedded core contributes verbs into the host's surface;
it does not open its own socket.

## 4. Layer 1 — the automation surface (the "sdef")

Today `setActions([{id,label}])` gives id + label. Replace it with a typed manifest registered once per
app on boot. New `zgui-core` module `automation.js` → `window.ZGui.automation`.

```js
ZGui.automation.register({
  app: "zcite",                          // this app's bus name
  verbs: [
    { id: "library.search",
      label: "Search library",
      params: [{ name: "q", type: "string", required: true },
               { name: "collection", type: "string", required: false }],
      returns: "list<item>",
      run: (a) => zcite.searchLibrary(a.q, a.collection) },   // returns a value (may be a Promise)
    { id: "item.add",
      label: "Add item",
      params: [{ name: "doi", type: "string", required: true }],
      returns: "item",
      run: (a) => zcite.addByDoi(a.doi) },
  ],
  state: [
    { id: "selection", returns: "list<item>", get: () => zcite.currentSelection() },
    { id: "activeCollection", returns: "string", get: () => zcite.activeCollection() },
  ],
  events: [
    { id: "itemAdded", payload: "item" },   // emitted via ZGui.automation.emit("itemAdded", item)
  ],
});
```

- **verbs** — callable, typed, return a value. `run(args)` may be async; the bridge awaits it.
- **state** — read-only queries. `get()` returns a value.
- **events** — the app calls `ZGui.automation.emit(id, payload)`; subscribers receive it.

`ZGui.automation.surface()` returns the manifest (verbs/state/events, types only, no functions) —
this is what `App::verbs()` reports to a script. The palette's `event`-step editor also reads it, so the
existing action dropdown (`user-commands.js:300`) upgrades from label-only to typed verbs for free.

## 5. Layer 2 — the bridge (stryke ⇆ app, request/response)

Today `run_stryke_hook` is fire-and-forget. The bridge makes an in-flight stryke script able to call
back into the app **and get the value back into the VM**.

Flow of `App::call("zcite.library.search", { q => "graphene" })` running **in-process**:

```
stryke VM (App::call)
  → host callback  app_call(verb, args_json)          [stryke FFI → app backend]
  → backend routes to the webview: dispatch to ZGui.automation registered verb
  → verb.run(args) resolves (await if Promise)
  → JSON result travels back over the response channel
  → host callback returns the JSON to the stryke VM
  → App::call returns the decoded value
```

The one new backend primitive: a **synchronous-looking request/response** between the stryke host and
the webview surface. zcontainer already implements exactly this shape ("sync invoke + streaming
subscribe substrate") — that is the reference to port into the shared bridge, not to reinvent per app.

`get` is the same path against the `state` table; `on(event, fn)` registers on the **subscribe** channel
(the streaming half of the same substrate) and the app's `emit` pushes frames to subscribers.

## 6. Layer 3 — the stryke `App` module

A new connector package **`stryke-app`** — sibling of `stryke-gui` / `stryke-aws`, same cdylib+FFI shape
(`extern "C" fn app__*` in `src/lib.rs`, `*const c_char -> *const c_char`). Semantic, not pixel; the two
are complementary (use `stryke-gui` to poke a foreign app, `stryke-app` to drive an owned one).

Real stryke syntax (matching `stryke-gui/examples/*.stk`): `use App`, `val $x`, `Module::fn(...)`,
`$handle->method(...)`, `p`, `"${x}"` interpolation.

```stryke
#!/usr/bin/env stryke
use App

# ── in-process: the script is running inside the app (palette step / hook) ──
val $me = App::here()                          # the host app
val @hits = @{ $me->call("library.search", %{ q => "graphene" }) }
p "found ${\ scalar @hits} items"

# ── out-of-process: drive a running app by name, from zshrs ──
val $cite = App::open("zcite")                 # dials the app's socket; dies if not running
val $req  = App::open("zreq")

# cross-app orchestration: every DOI in the zcite selection → fire a metadata request in zreq
for val $it (@{ $cite->get("selection") }) {
    $req->call("request.send", %{ url => "https://api.crossref.org/works/${ $it->{doi} }" })
}

# subscribe: when zcite adds an item, log it
$cite->on("itemAdded", fn ($item) {
    p "added: ${ $item->{title} }"
})

App::list()                                    # -> ["zcite","zreq","zcontainer", ...] running apps
$cite->verbs()                                 # -> the typed surface manifest (introspection)
```

Surface:

| Call | Returns | Notes |
| --- | --- | --- |
| `App::here()` | handle | the app the script runs inside (in-proc only) |
| `App::open($name)` | handle | dial a running app's socket; dies if absent |
| `App::list()` | list | bus names of running apps |
| `$h->verbs()` | manifest | typed verbs/state/events (introspection) |
| `$h->call($verb, %args)` | value | invoke a verb, await result, decode |
| `$h->get($state)` | value | read a state query |
| `$h->on($event, $fn)` | subscription | callback per emitted event |

## 7. Layer 4 — transport

Two modes, one API.

**In-process** — the script runs inside the app (palette `stryke` step or a hook). `App::here()` binds
directly to the local `ZGui.automation` surface via the host callback. No socket. Lowest latency.

**Out-of-process** — a `.stk` script in zshrs/terminal drives a *running* app. Each app process, on
boot, opens a **Unix domain socket**:

```
$XDG_RUNTIME_DIR/zgui/<app>.sock          # Linux
$TMPDIR/zgui/<app>.sock                    # macOS (XDG_RUNTIME_DIR usually unset)
```

`App::open("zcite")` dials `zgui/zcite.sock`. The socket host is a **shared Rust helper** (new crate
`zgui-bridge`, or a module reused by every app backend) so per-app cost is `bridge::serve(app_name,
surface)` in `main` — one line. Precedent: you already talk a raw wire protocol straight to a socket in
zterminal (tmux imsg, no subprocess); this is the same discipline.

### 7.1 Wire protocol

Newline-delimited JSON frames, request/response + a subscription stream. Deliberately small.

```
→ {"t":"call","id":1,"verb":"library.search","args":{"q":"graphene"}}
← {"t":"reply","id":1,"ok":true,"value":[ {...}, {...} ]}

→ {"t":"get","id":2,"state":"selection"}
← {"t":"reply","id":2,"ok":true,"value":[ {...} ]}

→ {"t":"verbs","id":3}
← {"t":"reply","id":3,"ok":true,"value":{ "verbs":[...],"state":[...],"events":[...] }}

→ {"t":"sub","id":4,"event":"itemAdded"}
← {"t":"reply","id":4,"ok":true}
← {"t":"event","sub":4,"event":"itemAdded","payload":{...}}     # pushed, N times
← {"t":"event","sub":4,"event":"itemAdded","payload":{...}}

← {"t":"reply","id":N,"ok":false,"error":"no such verb: foo.bar"}
```

`id` correlates reply to request; `sub` correlates pushed events to the subscription. The in-process
transport speaks the same frames over the host callback (no socket), so `stryke-app` has one codec.

## 8. Layer 5 — front-ends onto the bus

All three surfaces get `App` in scope and use the **same** module — no per-surface logic:

1. **Palette `stryke` step** — `user-commands.js:174` today passes only `ctx.arg`. Extend `run_stryke_hook`
   so the script has `App::here()` bound to the current app. A palette command becomes a real
   orchestration, not a single `event` fire. The step chain (`url|js|scheme|event|stryke|bash`) is
   unchanged; the `stryke` step just gets more powerful.
2. **Hooks runtime** (`zgui-core/webui/hooks-runtime.js`) — same binding, so app hooks can react to
   events and call verbs.
3. **Standalone `.stk`** — run from zshrs; uses `App::open(name)` over the socket. This is the
   cross-app bus.

## 9. Security

- Socket lives in the per-user runtime dir, mode **0600**; no network listener, ever.
- Out-of-process `call` requires the target app to be **running** (dial fails → `die`); no launch-on-demand
  in v1.
- Verbs are an **allow-list**: only what an app registered in `ZGui.automation.register` is reachable.
  There is no generic "eval JS in the app" verb — that would defeat the typed surface. (`js`/`bash` stay
  where they are: explicit user-authored palette steps, not remotely callable verbs.)

## 10. Relationship to the existing stryke automation packages

| Package | Level | Target | Keep for |
| --- | --- | --- | --- |
| `stryke-gui` | OS input / pixel | any app on screen | foreign apps, input synthesis, screenshots |
| `stryke-selenium` | WebDriver / DOM | browsers | web automation |
| **`stryke-app`** (new) | **semantic verbs** | **owned MenkeTechnologies suite** | **driving your own apps by name** |

No overlap: `stryke-gui` moves the mouse; `stryke-app` calls `library.search` and gets rows back.

## 11. Rollout

Shared, once:
1. `zgui-core`: `automation.js` (surface registry + JS bridge dispatch + `emit`), and upgrade the
   `event`-step editor to read the typed surface.
2. `zgui-bridge` (new shared Rust crate): the Unix-socket host + frame codec + request router; port the
   request/response + subscribe substrate out of zcontainer.
3. `strykelang`: the `stryke-app` cdylib package (`app__*` FFI, `App` module), + `stryke.toml`
   `[ffi.exports]` entries (per the pkg-FFI-manifest rule).
4. `run_stryke_hook` in the app backends: bind `App::here()` into the script's host env.

Per app (one session each, your 16-pane workflow):
5. Frontend: `ZGui.automation.register({ app, verbs, state, events })` — declare the surface. This is the
   only real per-app work; most verbs already exist as palette actions, now typed.
6. Backend: `zgui_bridge::serve(app_name, surface)` in `main`.
7. Verify: a `.stk` script drives the app **in-proc** (palette step) and **out-of-proc** (from zshrs).

**Pilot apps first** — highest existing action count, prove the loop before fan-out:
- **zcite** (85 cmds) — library/collection/citation verbs, rich state (selection, active collection).
- **zreq** (75 cmds) — request.send/save, environments; natural cross-app partner (fire requests for
  zcite DOIs, drive zcontainer service endpoints).

Then fan out to zemail, zcontainer, zftp, zstation, zterminal, the rest.

## 12. Novelty — honest prior-art analysis

This is a **combination** first, not a single new capability. Embedding a language in an app, scripting
across apps, and a vendor-authored automation language each **predate this separately**. The claim is the
*conjunction*, under constraints. Prior-art absence below is **non-exhaustive** and the bus is
**unbuilt** — every claim here is true only once §11 ships, not today (0 apps expose the surface now).

The four nearest prior arts, and why each fails a load-bearing leg:

| Prior art | Matches | Fails on |
| --- | --- | --- |
| **AppleScript / OSA** (Apple, 1993) — 20+ first-party apps scriptable | app count, vendor language | **macOS-only**; apps are Apple-Event **targets**, interpreter is external (`osascript`/`NSAppleScript`) — **not embedded** in the app |
| **VBA** (Microsoft) — runtime hosted in-process in Word/Excel/… | **in-process embedding**, vendor language, cross-app (COM/OLE) | **not cross-platform** (Windows-first, Mac subset, no Linux); single domain (office) |
| **LibreOffice + Basic/UNO** — cross-platform, embedded scripting, scriptable across apps | cross-platform, embedding, cross-app | single domain (office; ~6 apps); interpreted Basic, **no JIT**; component model, **not shared embeddable cores**; not solo |
| **KDE + Kross/D-Bus** — domain-diverse apps, scriptable across them | **domain diversity**, cross-app | Kross **"is not a scripting language"** — it **bridges Python/Ruby/JS/Falcon**; **no owner-authored language**, no JIT, not solo, IPC/component not shared cores |

**What survives — the constrained combination, none found:** a **domain-diverse** (Docker, PDF, email,
VPN, DAW, browser…), **cross-platform**, **solo-authored** GUI suite driven by the author's own
**from-scratch Cranelift-JIT language** (stryke), **embedded in-process** across **shared embeddable
cores**. No single prior art holds all of those at once — AppleScript is macOS-only + external, VBA is
Windows + single-domain, LibreOffice is single-domain + no JIT, KDE has no owner language. Recorded per
`INVENTIONS.md` methodology as **"none found," low confidence**, a combination/packaging novelty — **not**
a proven categorical single-capability first.

**Speed leg:** stryke is a Cranelift-JIT VM; in-proc calls are a host callback, not a fork; out-of-proc
is a Unix socket, not HTTP. No subprocess per call (same discipline as `stryke-gui`'s persistent `Enigo`
handle).

## 13. Open questions

1. **Handle lifetime out-of-proc** — does `App::open` hold the socket for the script's life, or dial per
   call? Proposal: hold; reconnect on `EPIPE`.
2. **Type coercion** — stryke hash/array ⇄ JSON is clean; how strict is param typing at the boundary?
   Proposal: validate against the manifest in the bridge, `die` with the verb signature on mismatch.
3. **Blocking vs async `on`** — does `$h->on` run the callback on a stryke event loop, or drain a queue
   the script polls? Proposal: drain on an explicit `App::pump()` / end-of-script block, to stay in
   stryke's execution model.
4. **`zgui-bridge` crate vs per-app module** — one shared crate is cleaner but adds a dependency to every
   app backend; confirm that fits the vendorable/durable constraint.
5. **Launch-on-demand** — v1 requires the app running. Worth an `App::open($name, %{ launch => 1 })`
   later?
```
