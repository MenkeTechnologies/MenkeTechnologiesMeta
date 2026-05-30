#!/usr/bin/env bash
# For every Rust Cargo.toml, pin that every `path = "..."` entry
# inside `[lib]`, `[[example]]`, `[[bench]]`, or `[[test]]` table
# headers references a file that actually exists on disk.
#
# Iter-59 covered the `[[bin]]` case. This gate extends to the
# four other Cargo target kinds that accept the same `path = "..."`
# field: library crates, example programs, benchmarks, integration
# tests. Same failure mode: `cargo build` (or `cargo bench`,
# `cargo test`, `cargo run --example foo`) errors with "could not
# find source file" only when the relevant subcommand runs — and
# benchmarks/examples are often invoked rarely, so the broken
# path can sit dormant for weeks before anyone notices.
#
# Resolution rule (Cargo's own): paths are relative to the
# directory containing Cargo.toml. For Tauri apps with
# src-tauri/Cargo.toml, paths resolve relative to src-tauri/.
#
# Coverage at iter-60 add:
#   - [lib] paths:      8 entries (all resolved)
#   - [[example]]:      0 entries
#   - [[bench]]:        0 entries
#   - [[test]]:         0 entries
#
# Pure regression floor for [[example]]/[[bench]]/[[test]] —
# nothing to catch yet but locks the rule when any submodule
# starts adding examples or benches.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

init_count=0
for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] && init_count=$((init_count + 1))
done
if [[ $init_count -eq 0 ]]; then
    echo "SKIP  no submodules initialized"
    exit 0
fi

checked=0
missing=0

# Extract `path = "..."` entries within a specific section header.
# Inlined per-kind because awk's `-v` parameter strips one level of
# backslash escapes — `'^\[lib\]'` arrives as `^[lib]` (a useless
# character class), so the header regex MUST be literal inside the
# awk program, not a parameter.

extract_lib_paths() {
    awk '
        /^\[lib\]/   { in_sec = 1; next }
        /^\[/        { if (in_sec) in_sec = 0 }
        in_sec && /^path *= *"/ {
            match($0, /"[^"]+"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
        }
    ' "$1"
}

extract_example_paths() {
    awk '
        /^\[\[example\]\]/                          { in_sec = 1; next }
        /^\[/ && !/^\[\[example\]\]/                { if (in_sec) in_sec = 0 }
        in_sec && /^path *= *"/ {
            match($0, /"[^"]+"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
        }
    ' "$1"
}

extract_bench_paths() {
    awk '
        /^\[\[bench\]\]/                            { in_sec = 1; next }
        /^\[/ && !/^\[\[bench\]\]/                  { if (in_sec) in_sec = 0 }
        in_sec && /^path *= *"/ {
            match($0, /"[^"]+"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
        }
    ' "$1"
}

extract_test_paths() {
    awk '
        /^\[\[test\]\]/                             { in_sec = 1; next }
        /^\[/ && !/^\[\[test\]\]/                   { if (in_sec) in_sec = 0 }
        in_sec && /^path *= *"/ {
            match($0, /"[^"]+"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
        }
    ' "$1"
}

check_paths() {
    local cargo="$1"
    local pkg_dir="$2"
    local kind="$3"
    shift 3
    local tp
    for tp in "$@"; do
        [[ -n "$tp" ]] || continue
        checked=$((checked + 1))
        local full="$pkg_dir/$tp"
        if [[ ! -f "$full" ]]; then
            echo "FAIL  $cargo: [$kind] path=\"$tp\" → $full does not exist"
            missing=$((missing + 1))
            ok=0
        else
            echo "PASS  $cargo: [$kind] path=\"$tp\""
        fi
    done
}

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    pkg_dir=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"; pkg_dir="$p"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"; pkg_dir="$p/src-tauri"
    fi
    [[ -n "$cargo" ]] || continue

    # Read each kind's paths into an array then check.
    IFS=$'\n' read -r -d '' -a lib_paths < <(extract_lib_paths "$cargo" && printf '\0')
    IFS=$'\n' read -r -d '' -a ex_paths  < <(extract_example_paths "$cargo" && printf '\0')
    IFS=$'\n' read -r -d '' -a bn_paths  < <(extract_bench_paths "$cargo" && printf '\0')
    IFS=$'\n' read -r -d '' -a ts_paths  < <(extract_test_paths "$cargo" && printf '\0')
    check_paths "$cargo" "$pkg_dir" "lib"     "${lib_paths[@]}"
    check_paths "$cargo" "$pkg_dir" "example" "${ex_paths[@]}"
    check_paths "$cargo" "$pkg_dir" "bench"   "${bn_paths[@]}"
    check_paths "$cargo" "$pkg_dir" "test"    "${ts_paths[@]}"
done

echo "---"
echo "Summary: $checked Cargo target path entries checked, $missing pointing at missing files"

[[ $ok -eq 1 ]] && exit 0 || exit 1
