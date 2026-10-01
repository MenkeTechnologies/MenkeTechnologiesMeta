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

## First terminal emulator to diff a command's output against its previous run

Because Zterminal anchors every **OSC 133** command block to absolute scrollback
lines (prompt / command / output / finish marks, plus the typed command text),
it already knows the exact output span of every command still in the buffer. On
top of that it can, retroactively and with no re-run, **diff the captured output
of any command against the previous run of the same command** — pulled straight
from your real shell history, compared line by line with a Myers (`git`-style)
diff and rendered as an inline unified hunk (`+` added / `−` removed).

`watch -d` highlights changes only across *future* re-runs you launch through it,
and Kitty's `diff` kitten is a file/git viewer you point at paths — neither knows
what your commands actually printed. Zterminal's diff is keyed on the terminal's
own command-output blocks: open the **Commands** tab (⌘K → *Commands*), press
**Diff** on any command, and it auto-selects that command's prior run and shows
what changed. No terminal emulator diffs command output from its own history.

## First terminal emulator to trend a number from a command's output across runs

The same absolute anchoring that powers the output diff means Zterminal knows the
exact output span of *every* run of a command still in scrollback — not just the
last two. On top of that it can **trend a numeric value across all of those
runs**: it lifts one number out of each run's output (a chosen "slot" — the k-th
numeric token in reading order) and renders the series as a sparkline with its
min / max / first / last / Δ / mean. Run `du -sh .`, a benchmark that prints a
time, or `wc -l log` repeatedly and the value's movement is charted retroactively
— no re-run, no piping through a plotting tool. A slot pager switches which
number in the output is tracked.

Terminal-side charting tools (`chart`, YouPlot) are separate programs you pipe a
data stream into; they know nothing about your command history. Warp's blocks
carry exit-code and duration metadata but never extract a value from the output
itself. This is orthogonal to Zterminal's own diff — the diff answers "what text
changed between two runs", the trend answers "how did this number move across N
runs". Open the **Commands** tab (⌘K → *Commands*) and press **Trend** on any
command. No terminal emulator extracts and charts a metric from a command's own
output history.

## First terminal emulator to sort a command's printed output by column

The same absolute anchoring that powers the diff and the trend also lets
Zterminal treat a single run's output as a **table** — and sort it. On the
command's already-printed OSC 133 output it detects the aligned column
boundaries by vertical whitespace alignment (a column separator is a character
position that is blank in every row), splits each row into cells, and then
**sorts the rows by any column you click** — numerically, and magnitude-aware
(so `4.0K` sorts below `2.0G`, and `93%` / `1,024` parse), when the whole column
is numeric; case-insensitively by text otherwise. The sort is stable, so ties
keep their printed order.

Sort `ps aux` by `%CPU` or `RSS`, `df -h` by `Use%`, `kubectl get pods` by
`RESTARTS`, `docker ps` by name — **retroactively, in place, on output that has
already scrolled past**, with no re-run and nothing piped through `sort`/`awk`.
Open the **Commands** tab (⌘K → *Commands*) and press **Sort** on any command.

Warp's block filter is a substring visibility filter — it hides non-matching
lines, it does not parse columns or reorder rows; `sort -k` / `awk` re-run the
command and cannot touch output already on screen. This is orthogonal to
Zterminal's own diff and trend: both of those compare a command against its own
*history* (across runs), whereas the sort reshapes a *single* run's output into
a sortable relational table. No terminal emulator sorts a command's printed
output by column.

## First terminal emulator to compare broadcast output across panes while the command runs

Broadcasting one command to many panes is old — Kitty's `broadcast` kitten,
iTerm2's "send input to all sessions", tmux `synchronize-panes`. All of them are
**unidirectional input**: they type into N panes and leave you to read N outputs
by eye. Zterminal closes the loop and compares what comes back.

Because every command block is anchored to **absolute** scrollback lines by its
OSC 133 marks, Zterminal has something no other emulator has: a stable key to
align N independent output streams on. Each output line a pane completes is
hashed and filed under its **ordinal within the `C`..`D` span** — its position
counting from the output mark, not from the prompt and not from a scroll
position. That is what makes the comparison hold when panes disagree about
everything except the output itself: a pane whose prompt wrapped onto three
lines, a pane nine lines further down the buffer, and a pane emitting at half
the rate all still compare line k against line k.

The comparison runs **mid-command**, on the same per-wakeup pass that already
scans for triggers. A line where one value is held by strictly more than half of
the panes that have reached that ordinal marks the remainder divergent — in the
overlay (`⌃⌘G`) and in each terminal's own left gutter, amber, while the command
is still running. Three rules keep the signal honest: a pane that has not
reached an ordinal yet is *behind*, not wrong, so uneven output rates produce no
noise; a two-pane disagreement is a *tie*, not a majority, so neither pane is
accused and both variants are shown; and only panes running the same command
text are compared at all.

The prior art is post-execution and outside the emulator. ClusterShell's `clush`
gathers identical output across a nodeset (`-b`) and can show a unified diff
between nodesets (`--diff`), but it waits for the command to complete before
displaying gathered results; pdsh's `dshbak` is a formatter you pipe finished
output through. Neither is live, and neither is a terminal emulator with a
grid to mark. What is new here is the streaming, mid-command, per-ordinal
divergence with live in-pane marking — not the idea of collapsing identical
output, which ClusterShell already ships.

Scope is stated rather than implied: this covers Zterminal's own split panes.
tmux panes are not in-process, so their output never reaches the emulator's
grid and they are not compared. Tracking is armed by a broadcast and costs an
unarmed window a single boolean per wakeup; each scan is bounded by the same
line budget the trigger scanner accepts and each block caps how many ordinals it
will hash, so neither a flood of output nor a long-running command can stall a
frame or grow the per-block state without bound.

## First terminal emulator to keep a command's output queryable after it leaves the buffer

Zterminal's output diff, metric trend, and column sort all read a command block's
captured output — and all three were hard-bounded by scrollback residency. The
marks are anchored to absolute grid lines and are evicted with them, so "diff
this against its previous run" stopped working the moment the previous run
scrolled away. The **command-block ledger** removes that bound: a finished
block's output is stored, and the same three features read from the store when
the buffer no longer has the block.

What that buys is retroactive analysis over a horizon the terminal never had.
Diff a run from weeks ago against today's, in a different window. Trend a
benchmark's printed time across every run ever recorded rather than the handful
still on screen — which matters because the evicted runs are usually where the
peak and the trough are, so a resident-only series is not merely shorter, its
statistics are wrong. Sort a table that scrolled off long ago. And query the
store by **stored output**, not just by command text.

Two claims are deliberately *not* made. Persistent search over command metadata
is prior art: Atuin queries shell history by text, directory, exit code,
duration, and host, and does it well. What is stored here that a history database
does not keep is the output bytes, keyed by command block — that is the residual
first, and the retroactive diff/trend/sort and output-regex predicates are what
fall out of it. Second, the stored output is **not ANSI-faithful**. It is the
grid-reconstructed text, the same `Vec<String>` those three consumers already
take, so escape sequences are gone before capture. Preserving them would require
teeing raw PTY bytes on the read path — a per-byte cost paid by every session
whether or not anyone ever queries the store. One append per finished command is
the entire ingest cost, and it runs on the app thread rather than the PTY thread
so a large block cannot stall the parser.

The rivals discard the data rather than out-query it, which is a structural
ceiling and not a tuning gap. Ghostty's `scrollback-limit` is in-session and its
`window-save-state` covers position, size, tabs, and splits — not scrollback.
WezTerm has no persistent output store and no diff action. Warp's session
restoration reads a SQLite database that is overwritten with the latest session
data — single-generation, with no query surface. iTerm2's session logging is
unindexed text and its Instant Replay is in-memory and current-session. No query
speed recovers bytes that were never written.

Reads are shaped to match. Every segment's fixed-stride index is resident in
memory and carries every metadata predicate, so a query is a flat scan; the
payloads are mmap'd and touched only for records the metadata scan already
selected, which is what keeps an output-regex query off the corpus. The store is
opt-in and off by default — persisting output that was previously ephemeral is a
real change in what a terminal keeps — with a per-block cap, a total-store cap
that evicts whole segments, and a version byte that makes an unreadable segment a
skipped one rather than a crash.

## First terminal emulator to run a relational query — including a cross-command JOIN — over its own captured output

The column sort proved a command block is a table. This makes it an **addressable
relation**, and then joins two of them. A table operand is the command text in
backticks plus which run to reach — `` `ps aux` `` is the latest, `` `ps aux` @-1 ``
the one before — and a small frozen SQL subset runs over it: `SELECT`, `WHERE`
with `AND`/`OR`/`NOT`/parens/`LIKE`, `ORDER BY`, `LIMIT`, and exactly one
`INNER JOIN`.

The join is the residual first. Filtering and sorting one block is a single-run
operation the column sort already covers. Correlating **two different commands'
already-printed output on a shared key** is a different question: `ps aux` knows
a process's RSS but not which port it listens on; `lsof -i` knows the port but
not the memory. Joining them on PID answers "what is the largest process actually
listening on something" from output that was printed by a plain `zsh`, at two
different times, with neither command re-run and neither emitting structured
data. `kubectl get pods` joined to `kubectl top pods` on NAME, or today's `df -h`
joined to last week's on `Filesystem`, are the same shape. With the command-block
ledger on, neither run has to still be on screen.

Comparisons reuse the column sort's magnitude parsing, so `WHERE rss > 500M` is a
size comparison and not a lexical one — the same definition of "this cell is a
number" serves both features, which is what keeps them from disagreeing about the
same output.

## First tool to join the plain-text output of one command across N hosts

An operand can name a pane — `` `df -h` @pane 3 `` — and a pane, under broadcast, is
a host. Broadcast sends one command to an arbitrary set of panes across windows and
sessions, each an SSH session to a different machine, and every one prints its own
answer. That much is old: `pdsh`, Ansible and `tmux synchronize-panes` all fan a
command out. What none of them do is **relate the answers** — they hand back N
unrelated blobs of text and leave the correlation to a human reading rows side by
side, or to installing something on every host that emits structured data.

Joining them here needs nothing installed on any host, no agent, no serialization
format both ends agree on and no network fan-in, because all N outputs are already
resident in one process's grids. It is an in-memory hash join over text the terminal
already had.

Naming the pane is the part that makes it expressible at all. A broadcast finishes
as N runs of the *same* command text, so the recency selector — the only handle the
query language previously had — cannot say which host is which; `@0` and `@-1` pick
two of the N arbitrarily. `@pane N` narrows the candidate runs to one pane and the
recency selector then indexes within it, so `@pane 3 @-1` is the previous run on
that host. Two pane-named operands of one command take their aliases from the panes,
so the query reads as the hosts it came from. A pane-qualified operand deliberately
does not fall back to the durable ledger: the ledger records command text but not
which pane printed a run, and a join that guessed which host a row came from would
be worse than one that refuses.

Two things are deliberately constrained. The grammar is frozen: `GROUP BY`,
aggregates, subqueries, `UNION`, outer joins and a second join are **rejected
with a parse error naming the word that stopped it**, because a half-supported
`GROUP BY` that silently returned ungrouped rows would be worse than a rejection.
And because column detection is whitespace-alignment based — a guess that ragged
or wrapped output can defeat — every result renders the **inferred schema** of
each source next to the rows, so a bad guess is visible rather than silently
answering a different question.

The rivals have no query surface over captured output at all, which is why this
is a first rather than a faster version of something. Warp's block actions are
copy, share, bookmark, search, and a substring output filter — no sort, no
structured query. Ghostty stores no command output; its scrollback work is text
search. Kitty's scrollback surface is a pager. WezTerm configures appearance,
keys and multiplexing and has no capture layer. iTerm2's Instant Replay is
in-memory and current-session, and its session logs are unindexed text.

The nearest prior art does not overlap. Nushell pipes structured data *forward*
and its SQLite history stores **commands**, not output, and only for commands run
as `nu` builtins. Atuin indexes history metadata. `q`, `textql`, `dsq` and Miller
all require re-running the command and piping the result through them. None can
answer a question about output that a plain shell printed last week, and none can
join two different commands' output at all.

Execution matches the existing shape: the metadata scan selects candidate blocks
before any payload is touched, each operand is tabulated once, and the join is a
hash join — the right side is indexed in one pass and the left is streamed
against it, rather than a nested product.

## First terminal emulator with a pane that *is* a query

The query above answers a question once. Pinning it to a split makes a pane whose
**contents are the relation**: the statement is bound to the pane, and every time
an OSC 133 command block finishes anywhere in the window it is re-executed and the
pane repainted. A `ps aux ⋈ lsof -i` view sitting beside your shell updates itself
the moment the next `ps aux` returns.

The distinction from the multiplexer control surfaces is the one that makes this a
first rather than a convenience. `kitty @ send-text` and `wezterm cli send-text`
can write bytes into another pane, and `tmux` can run a command in one — but in
every case the pane receives **text something else computed**, because those
emulators have no relation to query. Here the pane holds a statement and the
emulator answers it. The nearest shaped thing outside a terminal is a
`watch`-wrapped command, which re-runs the program; nothing is re-run here,
because the answer is computed from output that was already captured.

It is also cheap in a way an external tool cannot be. Every operand is already in
this process's address space — resident blocks in a pane's scrollback, older runs
in the ledger's mapped segments — so a refresh is an in-memory scan hung off an
append that already happens, and a refresh whose result is unchanged writes
nothing at all. A window with no query pane pays one boolean per wakeup. The same
view built outside the emulator would have to shell out to `ps aux` again to
notice a new row, which is a different (and slower) thing than reading the row the
user already printed.

The pane stays an ordinary pane: same PTY, same shell, same input routing. Query
mode borrows the terminal's **alternate screen** the way `less` does, so the shell
session sits untouched underneath, selection, search and scrollback keep working
with no special case anywhere in the renderer, and releasing the pane pops
straight back to it. The statement is parsed before the screen is touched, so a
typo never costs the view; and a result taller than the pane states how many rows
are below the fold rather than quietly showing fewer, which is the one way a live
view of a changing result would otherwise lie.

## First terminal emulator whose output triggers fire on a typed column predicate

Every trigger system in the category matches a **regular expression against one
rendered line**: iTerm2's Triggers, WezTerm's, Terminator's watches. That is a
consequence of what those emulators know about their own output — a line is
characters, and nothing above it knows there is a table there.

Zterminal already has a column model of its output: it recovers aligned columns
from monospace alignment and compares cells with magnitude awareness (the same
machinery the retroactive column sort and the relational query engine use).
Joining the two lets a trigger carry a **predicate** instead of a pattern:

```
%CPU  > 90        fire when any process crosses 90% CPU
Use%  > 85        fire when a filesystem fills up
c2   >= 500M      fire on the second column, by size
```

The comparison is typed. `4.0K` is below `2.0G`, `93%` is ninety-three, and
`1,024` is a thousand — so `MEM > 500M` means what it says, rather than matching
the characters `500M`. A regex cannot express `> 90` at all; the closest it gets
is a pattern that happens to match the digits in the position the command prints
them, which also matches an unrelated column, and which breaks the moment the
column widens. A pattern and a predicate can also be combined — they are ANDed
against the same row — so a predicate can be scoped to the rows a regex selects
(`postgres` **and** `%CPU > 1`).

It costs no more than the regex trigger it replaces. The columns come from text
the emulator has already reconstructed into a grid, so there is no second parse
of the output, no tee of the raw PTY byte stream, and no `awk` subprocess in the
path. Column detection runs at most once per pane wakeup, and only when a
relational trigger is configured; a purely textual trigger set takes exactly the
path it always did.

The one thing streaming forces: a header row is printed once and rows arrive
forever after, so the column spans and labels that arrived with the header are
remembered and later wakeups are split by them. Re-detecting columns on a
header-less burst would silently re-map every label — the third column of a
five-row burst is not the third column of the table.

## First terminal emulator that can be told to *wait* on the pane you are watching

Automating a shell is two moves: put bytes in, then wait until something is true.
Every emulator in the category ships the first and none ships the second.
`kitten @ send-text`, `wezterm cli send-text`, `tmux send-keys` and iTerm2's
`async_send_text` all write into a live pane; nothing in any of them blocks on
what comes back. iTerm2's Python API is explicit about the shape of the gap — the
documented way to notice output is `get_screen_streamer()` inside `while
condition():`, i.e. poll the screen and re-parse it on every tick. WezTerm's pane
API is the same set of passive readers (`get_lines_as_text`,
`get_text_from_region`) with no condition to wait on. Kitty's remote-control
protocol matches windows by `field:regexp` and sends text; waiting for a window's
output is an open request against it, not a feature.

The wait exists outside the emulator instead, and it gets there by **taking the
PTY away from you**. `expect(1)` and `pexpect` spawn their own child, so what they
watch is a session nobody is looking at — you automate a second, invisible shell
and read the real one by eye. `tmux wait-for` is not output at all: it blocks on a
channel another client signals.

Zterminal makes the wait a verb on the pane the user already has open.
`pane_await` does not poll and does not answer: the automation bus already defers
a reply until the terminal produces one, so the socket simply holds until the
condition is satisfied. The scan hangs off the wakeup pass that already runs for
triggers, divergence, the ledger and query panes, over the same reconstructed
text, so a window with nothing armed pays one boolean per wakeup and an armed one
pays no second parse of the output.

**The condition is typed, which is the part that has no analogue anywhere.** A
wait can be a regex over freshly completed lines — that is `expect`, and it is the
floor, not the claim. It can instead be a **column predicate**: `%CPU > 90`,
`Use% > 85`, `c2 >= 500M`. That resolves a header label to a column and compares
that cell with the magnitude rules the retroactive column sort and the `WHERE`
engine already use, so `4.0K` is below `2.0G` and `93%` is ninety-three. A regex
cannot express `> 90` at all; the closest it reaches is a pattern matching the
digits in the position the command happens to print them, which also matches an
unrelated column and breaks the moment the column widens. Every prior-art trigger
system in the category is regex-over-one-rendered-line — iTerm2's documented
trigger actions are `Annotate, Bounce Dock Icon, Capture Output, … Run Command,
Run Coprocess, … Send Text, …`, with nothing that reads a column or compares a
number, and none of them block in any case. Third, a wait can be an **OSC 133
block**: "tell me when the command finishes, and with what exit code" — a
question about a *command*, which needs the emulator's block model and therefore
cannot be asked of a byte stream at all.

Two constraints are deliberate here. A timeout is an answer, not an error
(`{"ok":true,"matched":false,"timeout":true}`), because "the condition did not
happen" is a branch a script takes, not a failure it recovers from. And the
send/await pair is race-free by construction rather than by luck: `pane_send`
reports the pane's absolute cursor line *before* it wrote, and `pane_await` takes
that line as its floor, so a command that finished before the wait was armed is
still seen while one that finished before the *send* is correctly ignored. A wait
that guessed here would either hang on fast commands or answer immediately from
whatever the pane last ran, and both are worse than no wait.

## First tool that can block until N interactive shell sessions *agree*

The typed wait above asks a question about one pane. Under broadcast a pane is a
host, and the question a human actually has is never about one of them. A fleet
wait takes the same condition — a regex, a typed column predicate, or an OSC 133
block finishing — and decides it over a **set** of panes under a policy: `all`,
`any`, `quorum n`, or `agree`.

Three of those four are quantifiers over a per-host condition, and that shape is
prior art rather than a claim. `kubectl wait` "waits until the specified
condition is seen in the Status field of every given resource" and takes `--all`;
Ansible's `wait_for` blocks per host on a port, a file, or "a regex match a string
to be present in a file". Neither is being claimed, and neither is being beaten —
they are different tools operating on typed APIs and on files.

**`agree` is the residual, and it is a different kind of predicate: the value is
not in the call.** "Wait until every host reports the same thing" cannot be
written as "wait for X", because nobody knows what X is until the fleet settles on
it — which is precisely the shape of the questions that matter during a rollout.
Are all the replicas at the same WAL position yet? Do all ten hosts hash the
config the same way now? Do all five control planes see the same node count? A
per-host waiter cannot express any of them however many hosts you run it on: the
condition is a comparison *between* hosts, and a per-host waiter has, by
construction, exactly one host's answer in scope. `agree` additionally accepts a
pinned value (`agree_on`), which collapses it back to the ordinary quantified
case — that direction is the prior art, and it is offered because it is useful,
not because it is new.

Reading a value, rather than only matching one, is what makes the comparison
possible. The `value` selector names a column of the matched row — resolved
through the same detector the retroactive column sort, the relational `WHERE` and
the typed triggers use, so a label means one thing everywhere — or capture group 1
of the pattern, or the whole line; for an `exit` condition it is the block's exit
code, so `agree` over exits answers "did this command end the same way
everywhere".

Two rules keep the answer honest, and both are inherited from the divergence
overlay's rather than invented here. A host that has not answered is **behind, not
concurring**: `agree` requires every member to have reported before it will call
the fleet agreed, because treating silence as assent is exactly how a rollout is
declared finished with two machines still on the old build. And a member's reading
is the **last** matching row of a wakeup, not the first: a replica catching up
prints every position it passes through, and only the one it stopped at is its
current answer.

The timeout is where a fleet wait earns its shape. It does not fail — it answers
with the full matrix: every pane's value, the `groups` of panes holding each
distinct value largest-first, and the `missing` panes that never spoke. An `agree`
that timed out is therefore not "it didn't work", it is "these two hosts are still
on 1.2.2", which is the thing you wanted to know.

Nothing in the category can be asked any of this, because nothing in the category
can be asked to wait at all. `wezterm cli`'s subcommands are spawn/activate/
resize/`send-text`/`get-text`; `kitten @`'s are the same shape plus kittens;
neither has a blocking verb. tmux's `wait-for` is not output: "When used without
options, prevents the client from exiting until woken using `wait-for -S` with the
same channel", and its `-E` form waits on hook and notification names. Its
monitoring is per-window and untyped — `monitor-silence` is "Monitor for silence
(no activity) in the window within `interval` seconds", which cannot distinguish a
host that is thinking from a host that is wrong.

The nearest fan-out tools are post-execution and outside the emulator, and they
compare rather than wait. ClusterShell's `clush -b` "waits for command completion
while displaying a progress indicator and then displays gathered output results",
and `--diff` "implies -b" — so its comparison happens after every node is done,
and there is no condition to block on. `pdsh`'s `dshbak` is a formatter you pipe
finished output through. What is new here is the *blocking* form of the question,
over interactive sessions a human already has open, with nothing installed on any
host and no connection re-owned: the fleet's answers are already resident in one
process's grids, so the comparison is an in-memory read hung off a wakeup pass
that already runs.

Bounds match the existing shape: at most 16 fleets, at most 64 panes each, every
one with a deadline; a duplicate pane is refused rather than counted twice (it
would let one host satisfy a two-pane quorum, and let a single host agree with
itself); an empty fleet is refused rather than making `all` and `agree` vacuously
true; and a pane is read once per wakeup for the fleet and single-pane registries
together, so the two features share one scan rather than each paying for it.

Scope is stated rather than implied, on the same terms as the divergence overlay:
this covers Zterminal's own panes, each of which is typically an SSH session to a
different machine. tmux panes are not in-process, so their output never reaches
the emulator's grid and they cannot be fleet members.

## First query engine whose data sources are unmodified interactive shells, and that establishes its own coherent instant

The relational query above joins two commands' already-printed output. What it
could never say is **when** the answer was taken. Pane 3 ran `df -h` yesterday and
pane 7 ran it a second ago; the join still succeeds, still produces rows, and the
rows are not a picture of any single moment. Reading a fleet-wide table, there was
no way to tell a real divergence from a stale half of one.

A trailing clause is where the statement names the moment it meant:

```sql
SELECT p3.Filesystem, p3.Use%, p7.Use%
  FROM `df -h` @pane 3 p3
  JOIN `df -h` @pane 7 p7 ON p3.Filesystem = p7.Filesystem
 FRESH WITHIN 5s REFRESH
```

`FRESH WITHIN 5s` **asserts** the bound; `REFRESH` **establishes** it — the
operands that are stale, or that were never run at all, are executed *where they
live*: the command is typed into the pane that is that operand's source, the wait
is on that pane's OSC 133 finish mark, and the join runs once every driven pane
has answered.

**Two things here are prior art and neither is claimed.** Bounding the staleness
of a query result is a shipped database product: Snowflake's dynamic tables take a
`TARGET_LAG`, documented as "Target lag tells Snowflake how fresh the data must
be", with the system dispatching refreshes to meet it — that is the same idea,
built by a database company, years earlier. Bounded-staleness consistency levels
are older still. And federated engines refreshing their remote sources is
ordinary: that is what a distributed query engine does.

**What is different is what a source is allowed to be.** Trino's concept page
defines a connector as the thing that "adapts Trino to a data source" and says
"you can think of a connector the same way you think of a driver for a database";
every federated engine, and every fleet-query tool, needs something on the far
side speaking a protocol it knows — a server, an HTTP API, or an agent like
`osqueryd`. Here the far side is a login shell a human already authenticated, the
connector is typing at its prompt, and the schema is whitespace recovered from
monospace output. Nothing is installed on any host, no port is opened, no
serialization format is agreed on, and the hosts never learn they were queried.

That substrate is only usable because an emulator sees two things a query engine
cannot. **Whether the shell is idle:** OSC 133 answers it exactly — a block with an
output mark and no finish mark is a command still running — so a pane sitting in
`vim`, `less` or a REPL is refused with that reason rather than typed into, and a
pane whose shell emits no OSC 133 is refused because a run there would have no
detectable end. **When the answer ended:** the refreshed reading is that block's
`C`..`D` span, so the join waits on a finished command rather than on a quiet
socket. Neither signal exists outside a terminal that parses the shell's own
semantic marks.

The honesty of the report is the rest of the work. A command is an interval, not
an instant, so two numbers come back: `skew_ms`, how far apart the readings were
taken (`max(start) − min(start)`), and `span_ms`, the widest instant the answer
could have been taken at (`max(finish) − min(start)`) — the error bar on the whole
table. Age is measured from the start mark, the conservative end, so a reading is
never certified fresher than it is. A run carrying no timestamp is `undated`,
which is neither "taken at the epoch" nor "taken now", and blocks coherence until
it is refreshed. Rows are still returned when the verdict is `coherent: false` —
the answer is labelled, never withheld, because withholding would hide the
divergence being chased — and a deadline answers with the pane that never came
back rather than failing.

`FRESH WITHIN` is rejected on an operand naming a run by position (`@-1`): running
a command again cannot make the run *before* the latest one any newer, so the two
halves of that statement contradict each other and it is refused at parse time.
And because a run that has happened cannot be un-run, a `REFRESH` statement is
refused inside an automation-bus transaction exactly as `pane_send` is — one
verb whose reversibility class is decided by its argument rather than its name —
while an ordinary query stays a read in the same transaction.

Cost matches the existing shape: only the stale operands are typed into, one run
per (pane, command) however many operands name it, and completion rides the same
per-wakeup pane read that already serves triggers, divergence, the ledger, query
panes and the two wait registries. A window with nothing settling pays one
`is_empty()`, and a query with no `FRESH WITHIN` clause never enters the path at
all.

Nothing in the emulator category can be asked any of this, because nothing in the
category has a relation to query. The documented `wezterm cli` subcommands are
spawn/activate/resize/`send-text`/`get-text`; `kitten @`'s are the same shape plus
kittens and `ls`, whose output the docs describe as "a tree of data in JSON
format" about windows and tabs, not about command output; Warp's block
documentation describes selecting, navigating and scrolling blocks and no data
operation across them; Ghostty documents an AppleScript dictionary for "windows,
tabs, terminals, layouts, and input events". Scope is stated on the same terms as
the divergence overlay and the fleet wait: this covers Zterminal's own panes, each
typically an SSH session to a different machine. tmux panes are not in-process, so
they cannot be operands.
