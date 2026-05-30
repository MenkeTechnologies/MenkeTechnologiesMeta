#!/usr/bin/env bash
# For every workflow yml step `run:` block that invokes
# `curl` as a command (not as an apt-package name), pin
# that the invocation includes `-f` (or `--fail`).
#
# `curl` WITHOUT `-f`:
#
#   $ curl http://broken/endpoint > script.sh
#   $ echo "exit=$?"
#   exit=0
#   $ cat script.sh
#   <html><body><h1>500 Internal Server Error</h1></body></html>
#
# The HTTP error response body (HTML error page, JSON
# error envelope, default nginx 404 page, S3 access-
# denied XML) IS what gets written. Without `-f`, curl
# exits 0 because the TCP+TLS handshake succeeded — it
# treats any HTTP response, including 4xx/5xx, as
# success.
#
# Downstream failure modes:
#
#   1. Pipe to bash:
#        curl https://install.example/script | bash
#      The endpoint goes down; curl writes the error
#      HTML to stdout; bash tries to execute HTML as a
#      shell script. Garbage commands fire (might
#      include `<` characters that bash interprets as
#      redirection). Failure is non-obvious.
#
#   2. Download an install artifact:
#        curl https://release/v1.2.3/binary > /usr/local/bin/foo
#      Endpoint redirects to S3 (without -L the body
#      is empty) or returns 403 with denial XML. The
#      file is created, contains HTML/XML, then
#      chmod +x and an install step appear to
#      "succeed" — until the user invokes the tool.
#
#   3. Download a config artifact:
#        curl https://config/server.toml > config.toml
#      File contains error page; the next process to
#      load config.toml hits TOML parse errors with
#      cryptic messages. CI step succeeds; later step
#      fails with "expected key at line 1."
#
#   4. Conditional install:
#        if curl https://flag.example | grep -q enabled; then
#          install_thing
#        fi
#      Endpoint down; curl writes HTML; grep doesn't
#      find "enabled"; the if branch silently skips
#      the install. CI is green but the thing isn't
#      installed.
#
# `-f` (`--fail`) makes curl exit 22 on HTTP 4xx/5xx
# responses. Pipelines fail cleanly; downloaded files
# are not created with error content.
#
# Canonical curl-flag combination in CI scripts:
#   curl -fsSL ...
#     -f : fail on HTTP errors
#     -s : silent mode (no progress bar in logs)
#     -S : show errors even when silent
#     -L : follow redirects (GitHub raw → S3, etc.)
#
# This gate enforces `-f` (the safety flag). The
# others are conventional but not safety-critical.
# A health-check probe `curl -sf http://localhost/health`
# is acceptable: -f is present.
#
# Detection:
#   - find `curl ` as a command (followed by - or
#     URL, not as an apt-package name)
#   - exclude comment lines
#   - exclude lines that contain `apt-get install` /
#     `apt install` / `apt purge` (curl as package
#     name in those contexts)
#   - require `-f`, `--fail`, or `--fail-with-body`
#     anywhere in the same line
#
# Pairs with workflow security defense family +
# correctness (no-curl-pipe-sh, no-http-download,
# no-debug-env-vars). Adds anti-error-body-silent-
# success to the family.
#
# 32/32 curl command invocations use -f at iter-209
# add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
unsafe=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    while IFS= read -r match; do
        ln_num="${match%%:*}"
        text="${match#*:}"
        stripped=$(echo "$text" | sed -E 's/^[[:space:]]*//')
        case "$stripped" in
            \#*) continue ;;
        esac
        # Skip apt-package-list contexts (curl as package, not command)
        if echo "$stripped" | grep -qE 'apt(-get)?\s+(install|purge|remove)'; then
            continue
        fi
        # Require curl as a command (followed by - or URL)
        if ! echo "$stripped" | grep -qE '\bcurl\s+(-|http|"\$|\$\{)'; then
            continue
        fi
        checked=$((checked + 1))
        # Require -f / --fail / --fail-with-body somewhere in line
        if ! echo "$stripped" | grep -qE -- '(-[a-zA-Z]*f[a-zA-Z]*\b|--fail(-with-body)?\b)'; then
            echo "FAIL  $wf:$ln_num: curl missing -f / --fail — HTTP 4xx/5xx response body written silently. Line: $text"
            unsafe=$((unsafe + 1))
            ok=0
        fi
    done < <(grep -nE '\bcurl\s' "$wf" 2>/dev/null || true)
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked curl invocations checked, $unsafe without -f/--fail"

[[ $ok -eq 1 ]] && exit 0 || exit 1
