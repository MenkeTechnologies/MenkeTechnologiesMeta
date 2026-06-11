# BUGS

Defects surfaced by the two `coverage` audit workflows (read-the-code findings, each with a `file:line` and a quoted evidence snippet). Reported, not auto-fixed — per the project rule that bug fixes are reviewed individually. These live in the submodule worktrees; the path in each entry is relative to that submodule.

**Counts:** 3 high · 19 medium · 23 low open · 3 fixed.

**2×** marks a defect found independently by both audit passes (higher confidence).

---

## Fixed

- **storageshower** `src/columns.rs:37` (high) — fixed in `de40ef3105`. mount_col_width panics (process abort) when a custom mount width is configured (prefs.col_mount_w > 0) and the inner terminal width is below 28. clamp(8, inner_w.saturating_sub(20)) yields clamp(min=8, max<8) which violates Rust's min<=max precondition and panics. inner_w comes from the live terminal width minus borders (ui.rs:388 `inner_w = w.saturating_sub(lm+rm)`), and mount_col_width is called every frame in the render path (ui.rs:547, ui.rs:616) and in mouse hit-testing (mouse.rs:82). Any user with col_mount_w set in prefs who renders in a sub-28-column pane (narrow tmux split, side panel) crashes the TUI. Reproduced: `cargo test --test columns_mount_width_narrow_custom_no_panic_integration` -> panic at src/columns.rs:37:45 'min > max. min = 8, max = 7' (inner_w=27) and 'min = 8, max = 0' (inner_w=1).
- **stryke-duckdb** `src/lib.rs:373` (high) — fixed in `fa74d31e1a`. duckdb__dump interpolates the caller-controlled `source` field raw into `SELECT * FROM {source}` with NO validate_identifier() guard, unlike duckdb__import (line 387) and duckdb__export (line 447) which both validate their `table` param. A `source` value like `t; DROP TABLE t; SELECT * FROM t` reaches run_query -> conn.prepare. prepare() typically executes one statement so the blast radius is narrower than execute_batch, but the asymmetry is the bug: dump is the one FROM-clause interpolation site left unvalidated, so any stryke caller routing untrusted input through dump's `source` gets a different (weaker) safety contract than import/export. Same module already documents (lines 414-419) that raw identifier interpolation is the exact injection class validate_identifier exists to close.
- **traderview** `crates/traderview-ocr/src/parse.rs:1098` (medium) — fixed in `a3737cdc20`. guess_category over-matches via the 2-character keyword "ad" (and "ads") in the first-declared 'advertising' category. Keyword matching is substring-based (n.contains(kw)), so "ad" matches any item name containing the bigram 'ad' — e.g. 'Unleaded' (fuel), 'Gatorade', 'lemonade', 'avocado', 'bread'-adjacent tokens. Combined with tie-to-first resolution, real fuel/grocery items get tagged 'advertising' (a Schedule C deduction line), producing wrong tax-category defaults.

---


## HIGH

### zsh-git-repo-cache `autoload/zsh-git-repo-searchGitCommon:9`

cd-emission to selected repo is built with naive double-quoting and then eval'd, so repo paths containing $, backtick, or an embedded double-quote are expanded or mangled at eval time -> wrong directory or failed cd. The emission lives in all 5 zsh-git-repo-goThere callbacks; searchGitCommon line 9 evals it. A directory whose name contains $USER cds to the expanded value instead of the literal path; a directory name containing " breaks the quoting; a name containing $(...) or backticks would execute under eval (command injection on attacker-controlled / oddly-named paths). Correct fix is single-quote-safe emission (e.g. perl quotemeta or print the path NUL-delimited and cd via a variable, not eval of a double-quoted string).

```
autoload/zsh-git-repo-searchAllGitRepos:10  perl -ne 'chomp; print "cd \"$_\""'   (same in searchClean/Dirty/CleanCache/DirtyCache goThere) ; autoload/zsh-git-repo-searchGitCommon:9  eval "$out"  . Empirical: target '/.../$USER/repo' emits  cd "/.../$USER/repo"  which under eval expands $USER and the cd misses (PWD empty).
```

### zshrs `src/ported/builtins/sched.rs:961`

Pre-existing build break: the lib test target does not compile. Test-side callers of schedgetfn (which takes *mut param) pass std::ptr::null() (= *const param), causing 9 E0308 *const/*mut mismatch errors at sched.rs:961,1077,1130,1144,1177,1253,1256,1301,1309. cargo test -p zshrs --lib fails with 11 errors total. This blocks running ANY lib unit test (verified: same 11 errors reproduce on a clean checkout with my change stashed).

```
line 585: `pub fn schedgetfn(_pm: *mut param) -> Vec<String> {`  ...  line 961: `let arr = schedgetfn(std::ptr::null());` (compiler: expected raw pointer `*mut param`, found `*const _`; suggests core::ptr::null_mut())
```

### zshrs `src/ported/params.rs:12973`

Pre-existing build break (same broken lib test target): argzerogetfn is declared `pub fn argzerogetfn(_pm: &param) -> String` at params.rs:8114, but two test callers invoke it with zero arguments, producing E0061 'takes 1 argument but 0 supplied' at params.rs:12973 and 12981.

```
line 8114: `pub fn argzerogetfn(_pm: &param) -> String {`  ...  line 12973: `argzerogetfn(),` and line 12981: `argzerogetfn(),` (no &param argument passed)
```


## MEDIUM

### awkrs `src/format.rs:1182`

%'d apostrophe (thousands-grouping) flag produces a misplaced separator next to the sign for exactly-3-digit numbers because apply_sign prepends the sign BEFORE insert_thousands_sep groups the string, so the grouping loop counts the sign char as a digit. awkrs prints +,123 where gawk prints +123.

```
src/format.rs:1182 `fn apply_sign(s: &mut String, pos: bool, sign: bool, space: bool)` mutates `s` (prepending '+'/' ') and runs before `insert_thousands_sep` (src/format.rs:490) which groups by counting from the right over the whole string including the prepended sign. Live: `awkrs 'BEGIN{printf "%+'\''d",123}'` => [+,123]; gawk => [+123].
```

### awkrs `src/format.rs:595`

format_hex_float mis-normalizes IEEE-754 subnormal doubles: the subnormal shift is `raw_mant.leading_zeros() - 12`, off by one. For 5e-324 (f64::from_bits(1), 2^-1074) it yields shift=51, placing the leading 1 at bit 51 instead of the implicit bit 52, so the result is 0x1.8p-1073 instead of 0x1p-1074. Every subnormal is affected.

```
src/format.rs:595 `let shift = raw_mant.leading_zeros() as i64 - 12; // 12 = 64 - 52` then line 596-598 `let normalized = raw_mant << shift; let exp = -1022 - shift; (exp, 1, normalized & 0x000F_FFFF_FFFF_FFFF)`. For raw_mant=1, leading_zeros=63, shift=51, normalized=1<<51 masks to 0x8000000000000 (bit 51) -> frac digit 8. Live: `awkrs 'BEGIN{x=5e-324;printf "%a",x}'` => [0x1.8p-1073]; gawk => [0x1p-1074].
```

### fasd-simple `bin/fasd:420`

In `fasd --query`, when an exact (case-sensitive then case-insensitive) match yields nothing AND `_FASD_FUZZY=0` (fuzzy matching disabled, a documented/supported config), `_fasd_data` is never cleared, so the no-match query returns the ENTIRE database instead of nothing. Only the fuzzy branch (line 430) has the `|| _fasd_data=` that clears on no-match; with fuzzy off the `elif` is skipped and the original full dataset falls through to the final awk and is printed. Reproduced: seed one row, set `_FASD_FUZZY=0`, query a non-matching string -> the seeded row (plus a spurious empty-path row) is returned. With the default `_FASD_FUZZY=2` the bug is masked because the fuzzy branch clears on no-match.

```
Lines 418-431:
        if [ "$_ret" ]; then
          _fasd_data="$_ret"
        elif [ "${_FASD_FUZZY:-0}" -gt 0 ]; then # fuzzy matching
          ...
          _ret="$(printf %s\\n "$_fasd_data" | grep -i "$fuzzy_bre")"
          [ "$_ret" ] && _ret=...
          [ "$_ret" ] && _fasd_data="$_ret" || _fasd_data=
        fi
      fi
-- the case-insensitive `else` block has no terminal `else _fasd_data=` when FUZZY is 0, so `_fasd_data` keeps the full dataset on a complete miss. Observed: `_FASD_DATA=$db _FASD_FUZZY=0 sh bin/fasd --query d aXbZ1` printed the seeded `a.b[1]` row despite no grep match.
```

### nmaprs `src/ftp_bounce.rs:36`

read_ftp_reply slices the first 3 bytes of an attacker-controlled FTP reply line with `first[..3]`, but the only length guard (`first.len() < 3` at line 33) checks BYTE length, not a UTF-8 char boundary. A reply line whose 3rd byte falls inside a multibyte UTF-8 codepoint (e.g. a banner starting with `x` followed by a 3-byte char like the euro sign) makes `first[..3]` panic with 'byte index 3 is not a char boundary'. In `-b` FTP-bounce mode the server (and thus its banner/replies) is untrusted, so a malicious or garbled FTP server can crash the scan. Same byte-slice hazard exists at line 48 inside the multiline continuation loop (`s[..3].parse()`).

```
let code: u16 = first[..3]
        .parse()
        .map_err(|_| anyhow!("FTP: bad code in {first:?}"));  // guarded only by `if first.len() < 3` (byte length, not char boundary). Reproduced: `&"x\u{20AC}"[..3]` panics: "end byte index 3 is not a char boundary; it is inside '€' (bytes 1..4 of string)".
```

### powerliners `src/ported/lib/overrides.rs:48`

parse_value() silently swallows JSON parse errors and falls back to a raw string, diverging from the upstream Python which raises JSONDecodeError. For inputs that start with a JSON-trigger char ('"{[0-9-') but are invalid JSON (e.g. "-", "[1,2", "\"unterminated", "12abc"), upstream json.loads(s) raises (verified: python3 -c via vendor/powerline shows all five RAISE JSONDecodeError), but the Rust port returns Value::String(s). A malformed --theme-option/--config-override value is accepted as a literal string instead of being rejected.

```
serde_json::from_str(s).unwrap_or_else(|_| Value::String(s.to_string()))
```

### powerliners `src/ported/lib/overrides.rs:184`

parse_override_var() silently drops malformed items via .filter_map(...).ok(), diverging from upstream Python whose generator raises on the first bad item. Items with a leading underscore (e.g. "_x=1") or missing '=' (e.g. "foo") raise ValueError/TypeError in upstream (keyvaluesplit py:38/40) but are silently filtered out here, so a typo'd override is dropped without any error rather than failing the CLI invocation.

```
.filter_map(|item| parsedotval_str(item).ok())
```

### revolver `bin/revolver:116`

Spinner message corruption: internal runs of whitespace (multiple spaces and tabs) in the user-supplied message are collapsed to single spaces before the spinner renders them. The state file written by _revolver_start (L250: echo "$! $msg" >! $statefile) and _revolver_update (L221: echo "$pid $msg" >! $statefile) is read back with state=($(cat $statefile)) (L116) which word-splits the whole line on IFS (space+tab+newline), discarding whitespace run-length and tab identity; msg="${(@)state:1}" (L118) then rejoins the message fields with a single space each. Result: revolver update 'step 3   of   8' displays 'step 3 of 8', and a tab-separated message displays space-separated. Caller-aligned/padded progress text and tab-delimited messages render differently than requested.

```
L116: `    state=($(cat $statefile))`  L118: `    msg="${(@)state:1}"`  (write side L221: `  echo "$pid $msg" >! $statefile`, L250: `  echo "$! $msg" >! $statefile`). Reproduced: input 'step 3   of   8' -> output 'step 3 of 8'; input $'col-a\tcol-b' -> output 'col-a col-b'.
```

### stryke-docker `src/lib.rs:345`

op_tag's target splitter has none of the guards op_pull's splitter got. It rsplit_once(':') with no registry-port guard and no digest guard, so a target like `localhost:5000/img` (registry+port, no tag) misparses to repo="localhost", tag=Some("5000/img"), producing a malformed tag_image request dockerd rejects with 'invalid reference format'. op_pull was fixed for exactly this (commit d1f743a627); op_tag was left with the old buggy pattern.

```
let (repo, tag) = match target.rsplit_once(':') {
    Some((r, t)) => (r.to_string(), Some(t.to_string())),
    None => (target.to_string(), None),
};
```

### stryke-docker `src/lib.rs:353`

op_tag substitutes empty string for a missing tag instead of docker's default 'latest'. For target="alpine" (no colon), tag=None then tag.unwrap_or_default() yields "", and bollard sends repo:"alpine", tag:"" to dockerd, rejected as 'invalid reference format'. The CLI defaults an omitted tag to 'latest'; this path does not.

```
tag: tag.unwrap_or_default(),
```

### stryke-gcp `src/lib.rs:346`

Binary-payload handling is inconsistent and lossy across the two read paths. op_gcs_get_object preserves non-UTF-8 bodies by base64-encoding them with a `base64:` prefix (lines 193-202), but op_pubsub_pull silently DROPS any message whose base64-decoded bytes are not valid UTF-8 via `.and_then(|b| String::from_utf8(b).ok()).unwrap_or_default()`, yielding an empty `data` string with no marker. A consumer pulling a binary Pub/Sub message receives "" indistinguishable from an empty message, losing the payload silently.

```
op_pubsub_pull: `.decode(data_b64).ok().and_then(|b| String::from_utf8(b).ok()).unwrap_or_default()` (lines 342-346) — non-UTF-8 -> empty string. Contrast op_gcs_get_object: `Err(_) => { ... Value::String(format!("base64:{}", ...encode(&bytes))) }` (lines 195-201) which preserves binary.
```

### stryke-gui `src/keyboard.rs:18` **2×** (also reported at `src/keyboard.rs:851`)

gui__key_keys returns the KEYBOARD_KEY_NAMES table to .stk scripts as the canonical list of names accepted by `gui key press/down/up`, but on macOS 50 of those advertised names are rejected by parse_key with 'unrecognized key name'. The names are only mapped in parse_key_platform arms gated to Windows/Linux (cfg(any(windows, all(unix, not(macos))))). A user reads a name from the public discovery list, passes it back, and gets an error: discovery-vs-execution mismatch. Symmetric gaps exist on Linux for the Windows-only and macOS-only names.

```
parse_key (src/keyboard.rs:175) -> parse_key_platform macOS arm (line 276) does not handle these; the in-flight test `every_public_table_entry_parses_on_current_platform` fails: 'KEYBOARD_KEY_NAMES advertises 50 name(s) that parse_key rejects on this platform; gui__key_keys lies to user scripts. Offenders: ["linefeed", "insert", "numlock", "scrolllock", "shiftlock", "pause", "printscreen", ... "browserhome", "hangul", "hanja", "kanji"]'. Table entries e.g. src/keyboard.rs:29 ("linefeed"), :63 ("insert"), :66 ("numlock") have no macOS parse_key mapping.
```

### stryke-gui `src/lib.rs:288`

region_from_value silently widens to full-screen capture on bad region input. as_i64() returns None for fractional (100.5) or string ("10") coordinates, collapsing the entire region Option to None; gui__screenshot (line 271-278) then treats None as 'no region' and captures the FULL display instead of erroring. A .stk caller that mis-types one of 4 coordinates gets a full-screen screenshot with no error.

```
`let w = arr[2].as_i64()?.max(0) as u32;` — the `?` short-circuits the whole fn to None on any non-i64 element; caller `Ok(serde_json::to_value(capture::screenshot_raw(region)?)?)` runs with region=None.
```

### stryke-mongo `src/lib.rs:361`

ffi_call_async silently substitutes Value::Null for any args bytes that fail JSON parsing (`unwrap_or(Value::Null)`). A stryke marshalling bug that hands the cdylib non-JSON bytes (truncated buffer, wrong encoding) is invisible: the handler runs as if no args were passed, and the user sees a misleading downstream error (e.g. 'missing target') instead of 'malformed args'. This is pinned (not fixed) by the existing `ffi_call_async_silently_substitutes_null_for_malformed_json_args` test; flagging as a design smell the boss may want to convert to an explicit error envelope.

```
Lines 360-362: `let cs = unsafe { CStr::from_ptr(args) }; serde_json::from_slice::<Value>(cs.to_bytes()).unwrap_or(Value::Null)` — parse failure is swallowed into Null rather than returned as `{"error":"malformed JSON args"}`.
```

### stryke-mysql `src/lib.rs:303` **2×** (also reported at `src/lib.rs:317`)

split_sql_statements reconstructs each statement byte-by-byte using `b as char`, which reinterprets every raw byte as a Unicode codepoint. For any multibyte UTF-8 in a SQL string literal (accented identifiers, CJK text, emoji), each continuation byte 0x80-0xFF becomes a Latin-1 codepoint, corrupting the statement that gets sent to query_drop. A statement like INSERT INTO t (name) VALUES ('Renée') is mangled because 'é' (0xC3 0xA9) is split into two garbage chars. The splitter advances over the input as `bytes` (line 254) but emits via `cur.push(bytes[i] as char)` at lines 303, 318 (and 263, 266-282 in the quote-scan loop), so non-ASCII payloads are corrupted before execution.

```
let bytes = sql.as_bytes(); ... _ => { cur.push(b as char); i += 1; }  // line 316-319: byte-as-codepoint, breaks multibyte UTF-8
```

### stryke-mysql `src/lib.rs:85`

json_to_my_value narrows every non-integral JSON number to f32 via `f as f32`, throwing away ~29 bits of f64 mantissa for every floating bind parameter — including DECIMAL, monetary, and coordinate values. A bound 0.1 is sent as the f32 approximation, not the f64. (Already pinned by the pre-existing j2mv_f64_zero_point_one_loses_precision_via_f32_cast test; surfaced here as the underlying defect — the obvious fix is MyValue::Double(f).)

```
lib.rs:84-85 `} else if let Some(f) = n.as_f64() { MyValue::Float(f as f32) }`.
```

### stryke-polars `src/extras.rs:444`

polars__roll_median returns the upper-middle element for even-sized windows instead of averaging the two central values, diverging from pandas DataFrame.rolling().median() and from this crate's own polars__stat_median. For window [1,2,3,4] it returns 3.0 instead of 2.5.

```
roll_op!(polars__roll_median, "rolling", |w: &[f64]| { let mut s: Vec<f64> = w.to_vec(); s.sort_by(...); s[s.len() / 2] }); — no even-length branch. Contrast polars__stat_median line 490-491: `} else if v.len() % 2 == 0 { (v[v.len() / 2 - 1] + v[v.len() / 2]) / 2.0 }` which DOES average. The rolling variant is internally inconsistent with the scalar variant.
```

### zsh-git-acp `autoload/zsh-gacp-NoCheck:11`

The Ctrl-S no-check commit-and-push widget reads its directory-blacklist opt-out from the wrong variable name. It uses $GACP_BLACKLISTED_DIRECTORIES (no ZSH_ prefix), but the documented variable (README.md:67, docs/index.html:97, docs/report.html:174) and the other two consumers (zsh-gacp-CheckDiff:11, zsh-gacp-CommitAndPush:25) use $ZSH_GACP_BLACKLISTED_DIRECTORIES. Result: a user who sets the documented variable gets NO blacklist protection on the fast Ctrl-S path — exactly the path where an unintended auto-push (e.g. in /etc or ~/.ssh) is most likely. Fix: rename to ZSH_GACP_BLACKLISTED_DIRECTORIES.

```
for dir in "${GACP_BLACKLISTED_DIRECTORIES[@]}" ; do   (autoload/zsh-gacp-NoCheck:11; contrast autoload/zsh-gacp-CheckDiff:11 and autoload/zsh-gacp-CommitAndPush:25 which both use "${ZSH_GACP_BLACKLISTED_DIRECTORIES[@]}")
```

### zsh-git-repo-cache `autoload/zsh-git-repo-regenAllGitRepos:11`

Trailing-.git strip uses an unescaped dot: s@/.git$@@ . The . matches ANY character, so a repo whose final path component is any-char followed by 'git' (e.g. /srv/agit, /code/dotgit -> last segment 'agit'/'tgit') gets its last 4 chars wrongly stripped, corrupting the cached repo root. The first-stage capture regex m{(/.*.git)/*$} has the same unescaped-dot flaw. Correct form is s@/\.git$@@ (and m{(/.*\.git)/*$}).

```
autoload/zsh-git-repo-regenAllGitRepos:11  perl -i -pe 's@/.git$@@' "$ZPWR_TEMPFILE3"  . Empirical: printf '/home/user/myrepo/agit' | perl -pe 's@/.git$@@'  ->  /home/user/myrepo  (the 'agit' segment is wrongly truncated, since /.git matches the literal '/agit').
```

### zsh-sed-sub `autoload/basicSedSub:61`

The replacement half is not escaped against sed's special replacement metacharacters & and \. The widget escapes only the @ delimiter (orig="${orig//@/\@}"; replace="${replace//@/\@}"), but sed treats an unescaped & in the replacement as 'the entire matched text' and \N as a backreference. A user typing `foo>X&Y` to insert a literal ampersand gets `Xfoo Y`-style output (& expands to the whole match) instead of the literal `X&Y`. Verified: `print -r -- 'say foo here' | sed -E -- 's@foo@X&Y@g'` yields 'say XfooY here', not 'say X&Y here'. No test covers &/backslash in the replacement.

```
orig="${orig//@/\@}"
    replace="${replace//@/\@}"
    sedArg="s@$orig@$replace@g"
```


## LOW

### api-rest-generator `src/bin/loco_gen.rs:367`

Hardcoded route-count literal in the CLI completion summary. The line prints both a derived product (entities.len() * 5) and a hardcoded prose count ('5 per entity'). It happens to be correct today because render_controller emits exactly 5 Routes::new().add(...) calls (src/loco.rs:415-419), but the literal 5 is not derived from the renderer, so adding/removing a CRUD route would make this summary silently lie. Violates the project rule against hardcoded counts that should be computed from the source of truth.

```
eprintln!("  Routes:     {} (5 per entity)", entities.len() * 5);
```

### gh_reveal `bin/reveal:70`

argValues regex-alternation builder uses bash single-replacement `/` instead of global `//`, so only the FIRST space between args is converted to a grep `|` alternation. With 3+ args, e.g. `reveal foo bar baz`, argValues=`foo bar baz` becomes `foo|bar baz` — `bar baz` is fed to `grep -E` as one literal-space alternative instead of two separate patterns, so the 3rd+ args silently never match any remote and their repos are not opened. Two-arg invocation works by luck (one space). Not fixed per instructions.

```
Line 70: `command git remote -v | command grep -E "$(echo ${argValues/ /|})" | ...` — `${argValues/ /|}` (single `/`) replaces only the first space. Verified in bash: argValues=`foo bar baz` -> `${argValues/ /|}` = `foo|bar baz` (only first space replaced). Same pattern repeats on lines 74 and 75.
```

### stryke-aws `src/lib.rs:246`

op_ddb_get_item key-value conversion diverges from op_ddb_put_item: it lacks the Value::Bool and Value::Null arms that op_ddb_put_item has (lines 219-220). A JSON key whose value is a bool or null falls through to `other => AttributeValue::S(other.to_string())`, producing the string AttributeValue "true"/"false"/"null" instead of AttributeValue::Bool / AttributeValue::Null. A get_item whose key was written by put_item with a Bool/Null attribute would query with the wrong AttributeValue type and fail to match.

```
line 245-246: `Value::Number(n) => AttributeValue::N(n.to_string()),\n            other => AttributeValue::S(other.to_string()),` — compare op_ddb_put_item lines 219-220 which explicitly handle `Value::Bool(b) => AttributeValue::Bool(b),` and `Value::Null => AttributeValue::Null(true),`.
```

### stryke-aws `src/lib.rs:387`

op_lambda_invoke serializes an absent payload as the 4-byte literal `null`. When opts has no `payload` key, opts["payload"] indexes to Value::Null, and `.to_string()` yields the string "null", which is sent as the Lambda invocation payload. A caller expecting an empty/absent payload instead delivers a JSON null literal to the function.

```
line 387: `let payload = opts["payload"].to_string();` — serde_json Value indexing returns Value::Null for a missing key, and Value::Null.to_string() is "null".
```

### stryke-docker `src/lib.rs:298`

op_pull's otherwise-fixed splitter still leaks an empty tag for the trailing-colon form `alpine:`. rsplit_once returns Some(("alpine","")), the guard passes (t="" has no '/'), so tag="" reaches bollard's CreateImageOptions, re-triggering the all-tags-pull behavior the 'latest' default was meant to prevent. The default only fires on the no-colon `_` arm.

```
let (from_image, tag) = match image.rsplit_once(':') {
    Some((repo, t)) if !repo.contains('@') && !t.contains('/') => {
        (repo.to_string(), t.to_string())
    }
    _ => (image.clone(), "latest".to_string()),
};
```

### stryke-gcp `src/lib.rs:316`

op_pubsub_pull parses maxMessages with `opts["max"].as_i64().unwrap_or(1)`. A non-integer JSON `max` (string "5", float 2.0) silently falls back to 1 instead of being honored or rejected, and a negative `max` (e.g. -1) is passed straight through into the `maxMessages` request body (line ~324) with no validation, producing a Pub/Sub 400 the caller cannot diagnose from the connector. No clamping/validation of the count.

```
`let max = opts["max"].as_i64().unwrap_or(1);` (line 316) then `let body = json!({ "maxMessages": max, "returnImmediately": false, });` (lines ~323-326) — `max` is forwarded unchecked, including negatives and silently-defaulted non-integers.
```

### stryke-gui `src/lib.rs:288`

region width/height clamp negatives via .max(0) before cast, but an i64 value above u32::MAX is silently truncated by `as u32` (e.g. 4_294_967_296 -> 0) with no error — request for a large region becomes a 0-width crop. Already pinned by the pre-existing region_from_value_silently_truncates_width_above_u32_max test as live behavior.

```
`let w = arr[2].as_i64()?.max(0) as u32;` and `let l = arr[0].as_i64()? as i32;` — no range validation before the lossy `as` casts; existing test asserts width comes back 0, left wraps to i32::MIN.
```

### stryke-kafka `src/lib.rs:65`

brokers_from_opts does not fall back to KAFKA_BROKERS or the 127.0.0.1:9092 default when `brokers` is present but an EMPTY string. `{"brokers": ""}` yields Some("") from as_str(), which map(String::from) turns into Some(""), so the .or_else(env)/.unwrap_or(default) chain is bypassed and an empty bootstrap.servers reaches librdkafka. This diverges from the missing-key path (correctly falls back) and the non-string path (the existing brokers_ignores_non_string_opts test confirms an integer falls back to default). An empty broker string produces a misconfigured client rather than the intended default. Did NOT add a test asserting this behavior since it pins a likely-defect; reporting instead.

```
fn brokers_from_opts(opts: &Value) -> String { opts.get("brokers").and_then(|v| v.as_str()).map(String::from).or_else(|| std::env::var("KAFKA_BROKERS").ok()).unwrap_or_else(|| "127.0.0.1:9092".to_string()) }  — as_str() on an empty JSON string returns Some(""), short-circuiting the fallback chain.
```

### stryke-mongo `src/lib.rs:73`

Doc/behavior mismatch in get_client timeout precedence. The comment claims server_selection_timeout_ms and connect_timeout_ms are 'both independently overridable via the opts hash', but the code only applies the opts values when `co.server_selection_timeout.is_none()` / `co.connect_timeout.is_none()`. If the connection URI specifies `?serverSelectionTimeoutMS=...` or `?connectTimeoutMS=...`, the opts values are silently ignored (URI wins). So opts is NOT independently overriding — it only fills gaps the URI left.

```
Lines 81-86: `if co.server_selection_timeout.is_none() { co.server_selection_timeout = Some(...from_millis(sst_ms)); }` — the opts-derived sst_ms/ct_ms are discarded whenever the URI already set the value, contradicting the comment at lines 68-72 stating both are 'independently overridable via the opts hash'.
```

### stryke-mongo `src/lib.rs:215`

op_count casts the driver's u64 count to i64 with `n as i64`. For a collection with more than i64::MAX (9.2e18) documents the cast wraps to a negative value. Practically unreachable (no mongo collection holds 9.2 quintillion docs), but it is an unchecked lossy cast that would silently emit a negative count rather than erroring. Same unchecked u64->i64 cast pattern appears in matched_count/modified_count/deleted_count/inserted_count.

```
Line 215: `Ok(json!({"value": n as i64}))` where `n` is the u64 returned by `count_documents`. No checked/try_into conversion; wraps silently on overflow.
```

### stryke-mysql `src/lib.rs:48`

url_from_opts performs no validation on `port` (read as i64) or on password/host containing URL-significant characters. Negative/zero/>65535 ports and passwords containing `@` or `/` are concatenated verbatim into the mysql:// URL, producing malformed URLs that fail at connect time with a low-level message rather than at config time. (Pinned by pre-existing url_port_* and url_password_with_slash tests.)

```
lib.rs:48 `let port = opts.get("port").and_then(|v| v.as_i64()).unwrap_or(3306);` and lib.rs:55 `format!("{}:{}", user, password)` with no percent-encoding.
```

### stryke-mysql `src/lib.rs:415`

op_dump interpolates `table` into `SELECT * FROM {}` WITHOUT calling validate_identifier (unlike op_schema at lib.rs:170 and op_insert_many at lib.rs:331). The `table` field flows raw from opts["table"].as_str() into format!, leaving an injection vector via the dump op (e.g. table = `t; DROP TABLE x`). `limit` is also interpolated as a raw i64 with no bound.

```
lib.rs:411-419: `let table = opts["table"].as_str().ok_or_else(...)?.to_string();` then `format!("SELECT * FROM {} LIMIT {}", table, n)` — no validate_identifier call, contrast lib.rs:170-175 in op_schema.
```

### stryke-postgres `src/lib.rs:877`

Pre-existing test-infra data race: two env-var tests bypass the ENV_LOCK mutex. `url_from_opts_assembled_form_uses_documented_defaults` (line 877) and `url_from_opts_explicit_url_wins_over_env_and_parts` (line 861) call `std::env::remove_var("DATABASE_URL"/"POSTGRES_URL")` directly instead of going through the `with_env` helper (line 619) which holds `ENV_LOCK`. Under parallel test execution they race with with_env-guarded tests that `set_var("DATABASE_URL", ...)`, causing intermittent failures. Reproduced 1/12 runs at --test-threads=8: failing test was `url_from_opts_assembled_form_uses_documented_defaults`. NOT caused by my change (all 5 new tests use with_env). Fix: wrap both in `with_env(|| { ... })`.

```
Line 879-880: `std::env::remove_var("DATABASE_URL"); std::env::remove_var("POSTGRES_URL");` with no ENV_LOCK held — vs the guarded `with_env` helper at line 620 `let _lock = ENV_LOCK.lock()...`.
```

### stryke-postgres `src/lib.rs:56`

url_from_opts reads `port` via `as_i64().unwrap_or(5432)` with no range clamp. A negative port (e.g. -1) or out-of-range value (e.g. 99999, exceeding u16 max 65535) is interpolated raw into the DSN (line 72-78), producing an unparseable connection string that surfaces as a confusing libpq error rather than an early arg-validation error. Already documented by the existing test `url_negative_port_is_passed_through_verbatim` (line 917) which pins the unclamped passthrough. Reporting per instructions, not fixing.

```
Line 56: `let port = opts.get("port").and_then(|v| v.as_i64()).unwrap_or(5432);` — no `1..=65535` clamp before `format!("postgresql://{}@{}:{}/{}", auth, host, port, ...)` at line 72.
```

### stryke-postgres `src/lib.rs:221`

json_to_param silently demotes a JSON integer above i64::MAX to f64, losing precision. The number branch tries as_i64() then as_f64(); a u64 value in (i64::MAX, u64::MAX] (legal per RFC 8259, accepted by serde_json) falls into the Float branch and loses low bits, then binds to a postgres BIGINT/NUMERIC column as a wrong value with no error. Already documented by existing test `jp_u64_above_i64_max_silently_demotes_to_float` (line 941). Reporting per instructions, not fixing. A lossless fix would route to PgParam::Str(n.to_string()).

```
Lines 221-228: `if let Some(i) = n.as_i64() { PgParam::Int(i) } else if let Some(f) = n.as_f64() { PgParam::Float(f) } else { PgParam::Str(n.to_string()) }` — the as_f64 branch catches u64>i64::MAX before the lossless Str fallback.
```

### stryke-selenium `src/lib.rs:116`

Doc/behavior divergence in selenium__quit. The comment says quit should NOT default to the active session ('defaulting to the active session is dangerous ... Require an explicit id'), but the code immediately does `arg_session(&v).or_else(get_active)`, so a stale script with no explicit id WILL quit whatever browser is active — exactly the footgun the comment warns against.

```
lib.rs:121-124 comment 'Require an explicit id' directly above `let id = arg_session(&v).or_else(get_active).ok_or_else(...)?;` which falls back to the active session.
```

### stryke-selenium `src/window.rs:36`

Lossy i64->u32 cast of window width/height. thirtyfour's Rect fields are i64 (types.rs:266 `pub width: i64`), but window_rect casts `r.width as u32` / `r.height as u32`. A negative or >u32::MAX dimension from a non-conformant WebDriver wraps to a huge u32 instead of erroring or clamping, silently corrupting the reported window size.

```
window.rs:36 `width: r.width as u32,` and line 37 `height: r.height as u32,` where r is thirtyfour Rect with `pub width: i64` / `pub height: i64` (types.rs:266-268). Same lossy cast pattern at window.rs:58-59 in set_window_rect (`cur.width as u32`).
```

### temprs `src/util/utils.rs:226`

util_transform_idx casts the stack length to i32 (`len as i32`) when computing a negative-index offset. For a usize len exceeding i32::MAX this truncates/sign-flips, producing a wrong (or negative) bound and either a bogus index or a spurious ERR_INVALID_IDX. Unreachable in practice (temp-file stacks are tiny), hence low severity, but it is a genuine lossy-cast correctness defect.

```
let bnd = idx + len as i32;
```

### temprs `src/util/utils.rs:236`

Same lossy `len as i32` truncation in the positive-index bound check; if len > i32::MAX the comparison `bnd >= len as i32` compares against a truncated/negative value, mis-validating indices. Implausible for this tool's stack sizes, so low severity.

```
if bnd >= len as i32 {
```

### tmux-fzf-url `fzf-url.sh:37`

IPv4 fallback regex matches any four 1-3 digit dotted groups, so out-of-range octets and 4-segment version strings are emitted as bogus URLs. 'upgraded to 1.2.3.4 today' yields http://1.2.3.4 and '999.999.999.999' yields http://999.999.999.999. Cosmetic in practice (picker shows a non-routable entry) but a real false-positive class. Reported per instructions; not fixed. Pinned by the new boundary test so any tightening is intentional.

```
push @m, "http://$1" while m{\b([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(?::[0-9]{1,5})?(?:/\S+)*)\b}g;
```

### traderview `crates/traderview-ocr/src/parse.rs:1490`

Tie-breaking in guess_category is purely by declaration order: `if score > best.0` keeps the EARLIEST category when two categories score equally. Because 'advertising' is declared first, any item that ties advertising against a more specific category (e.g. 'unleaded' tying advertising vs vehicle_fuel at score 1 each) is misclassified as advertising. There is no specificity or keyword-length weighting to break ties toward the more precise category.

```
line 1490: `if score > best.0 {` (strict greater-than, seeded `best: (i32, &str) = (0, "other")` at line 1484) — equal scores never replace the incumbent, so the first-declared category wins every tie.
```

### zsh-sed-sub `autoload/basicSedSub:59`

The orig/replace split cannot represent a literal `>` in either half. orig="${sedArg%%>*}" takes everything before the FIRST `>`; replace="${sedArg##*>}" takes everything after the LAST `>`. With input like `a>b>c`, the middle token `b` is silently dropped (orig=a, replace=c). This is documented single-separator behavior and is already pinned as an intentional contract by an existing test in tests/t-plugin.zsh ('multiple > in input - orig is everything BEFORE last >, replace is AFTER last'), so it is reported as a usability limitation rather than an unpinned defect. Verified: `a>b>c` produces sed expr s@a@c@g, dropping b.

```
orig="${sedArg%%>*}"
    replace="${sedArg##*>}"
```

### zsh-z `zsh-z.plugin.zsh:341`

_zshz_find_common_root treats a sibling path as a child due to an unanchored-suffix glob prefix check. The shortest match `$short` is accepted as the common root if every other match satisfies `[[ $x == $short* ]]`, but `$short*` lacks a trailing path separator, so a sibling like `/foobar` matches `/foo*` and `/foo` is wrongly emitted as the common root of {/foo, /foobar}. The correct common root is `/` (or none). Observable end-to-end: with matches `( /foo 10 /foobar 5 )`, `_zshz_find_common_root` + `read -rz` yields `/foo`. This can cause `z` to cd to a parent that is not actually a shared ancestor of all candidate matches.

```
for x in ${common_matches[@]}; do
    [[ $x != $short* ]] && return
  done

  print -z -- $short    # ($short* matches sibling /foobar against /foo*, no boundary)
```

