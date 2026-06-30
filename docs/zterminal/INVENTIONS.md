# Inventions

Firsts that Zterminal introduces to the terminal-emulator space. Each is, to our
knowledge, novel — no shipping terminal emulator did it before.

## First terminal emulator to modify tmux settings live

Zterminal speaks tmux's **native wire protocol** directly to the server socket
(`crates/ztmux-core`) — it is a first-class tmux client, with no `tmux`
subprocess and nothing typed into the shell line. On top of that it ships live
editors for the running server:

- **tmux server options** — read every `show-options` scope (server / session /
  window) and edit any of them in place (`set-option`), applied instantly.
- **tmux paste buffers** — list, view, edit, create, paste, and delete buffers.
- **tmux key bindings** — list every binding across the key tables and rebind /
  unbind them live (`bind-key` / `unbind-key`), with the command re-tokenized for
  the wire.

No other terminal emulator edits a live tmux server's options, buffers, and
keybindings from its own UI.

## First terminal emulator to store tmux state in switchable profiles

Zterminal's **profiles** are named snapshots of the *entire* configuration that
you switch between in one click — and they capture far more than the terminal
config:

- the full terminal config (`zterminal.toml`),
- the GUI look (color scheme, light/dark, custom scheme, effects),
- and the **tmux server state** — options, buffers, and key bindings.

Switching a profile restores the whole set, including reconfiguring the live tmux
server over the wire. No emulator has profile-switchable tmux configuration.

## First terminal emulator with a custom, live telemetry dashboard

Zterminal ships an in-app **dashboard** — a live, polling telemetry surface built
from a real component library (`zgui-core`): PTY throughput, render timing,
scrollback, the full tmux summary (clients, sessions, windows, panes, server
identity), and system metrics, rendered with gauges, sparklines, donuts, meters,
tables, and stat strips. It doubles as a showcase of the component library. No
terminal emulator ships a custom dashboard of this kind.
