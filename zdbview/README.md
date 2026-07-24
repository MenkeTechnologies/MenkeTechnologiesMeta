# zdbview

Terminal inspector and CRUD editor for **rkyv archives** and **SQLite databases**.

One binary opens either kind of file. The file type is detected from the SQLite
header magic (authoritative — a `.db` name whose bytes are not a SQLite header is
treated as binary), falling back to the extension only for files too short to
carry a header.

```
zdbview                        # no args → pick from recently opened files
zdbview path/to/file.db        # SQLite → full CRUD
zdbview path/to/archive.rkyv   # rkyv   → structural inspection
zdbview --sqlite file          # force SQLite
zdbview --rkyv   file          # force rkyv/binary
```

## Recent files (no args)

Every opened file is recorded to `$XDG_CACHE_HOME/zdbview/recent` (or
`~/.cache/zdbview/recent`), most-recent-first. Running `zdbview` with no argument
shows that list as a picker — `j`/`k` to move, `Enter` to open, `q` to quit.

## SQLite — full generic CRUD

SQLite files are self-describing, so every operation works on any database:

- Browse tables (with row counts) and paginated rows.
- `e` — edit the selected cell in place.
- `a` — insert a row using column defaults.
- `d` — delete the selected row (confirm with `y`).
- `:` — run an arbitrary SQL statement.

Rows are addressed by `rowid`; `WITHOUT ROWID` tables are listed read-only.

## rkyv — structural inspection

rkyv archives are **not self-describing**: the format stores no field names or
type tags (https://rkyv.org/format.html), so the schema cannot be recovered from
an arbitrary archive. Without the originating Rust type, zdbview shows the raw
structure instead:

- `1` **Info** — size and summary.
- `2` **Strings** — every run of printable text embedded in the archive, with
  byte offsets (keys, interned identifiers, string fields).
- `3` **Hex** — `xxd`-style hex/ascii dump of the raw bytes.

Typed field-name CRUD over a rkyv archive requires a supplied schema descriptor
and is planned separately.

## Keys

| Key | Action |
|-----|--------|
| `Tab` | switch focus (table list ↔ rows) |
| arrows / `hjkl` | move |
| `gg` / `G` | jump to top / bottom |
| `n` / `p` | next / previous page (SQLite) |
| `e` `a` `d` `:` | edit / add / delete / SQL (SQLite) |
| `1` `2` `3` | Info / Strings / Hex (rkyv) |
| `q` / `Esc` | quit |

## Build

```
cargo build
cargo test
```
