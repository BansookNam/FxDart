#!/usr/bin/env bash
# Builds the docs site and serves it locally for preview.
#
#   ./run.sh              # build, serve, print URLs
#   ./run.sh -s           # skip the build, just serve what's in docs/
#   ./run.sh -p 4000      # use a specific port
#   ./run.sh -o           # open the browser once it's up
#
# The switcher, nav, and asset links are all relative, so what you see here is
# what ships — no rewriting for the /FxDart/ subpath GitHub Pages serves from.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

PORT=8000
SKIP_BUILD=0
OPEN_BROWSER=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--skip-build) SKIP_BUILD=1; shift ;;
    -p|--port) PORT="${2:-}"; shift 2 ;;
    -o|--open) OPEN_BROWSER=1; shift ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown flag: $1" >&2; exit 1 ;;
  esac
done

step() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }
dim()  { printf '\033[2m%s\033[0m\n' "$1"; }

command -v python3 >/dev/null 2>&1 || {
  echo "python3 is required to serve the preview" >&2; exit 1; }

# ---------------------------------------------------------------- build
if [[ $SKIP_BUILD -eq 0 ]]; then
  step "Rendering docs/ from content/ + i18n/"
  dart run tool/build_docs.dart

  step "Translation coverage"
  dart run tool/build_docs.dart --status
else
  step "Skipping build (-s)"
  # Warn but don't block: previewing stale output is a legitimate thing to do,
  # you just want to know that's what you're looking at.
  dart run tool/build_docs.dart --check || \
    dim "(previewing stale output — drop -s to regenerate)"
fi

[[ -f docs/index.html ]] || { echo "docs/index.html missing — run without -s" >&2; exit 1; }

# ---------------------------------------------------------------- port
# Walk forward if the port is taken rather than dying on a stale server.
for _ in $(seq 0 20); do
  if python3 -c "
import socket,sys
s=socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
try: s.bind(('127.0.0.1', $PORT)); s.close()
except OSError: sys.exit(1)
" 2>/dev/null; then
    break
  fi
  dim "port $PORT busy, trying $((PORT + 1))"
  PORT=$((PORT + 1))
done

# ---------------------------------------------------------------- serve
BASE="http://localhost:$PORT"

step "Serving docs/ at $BASE"
echo
python3 - "$BASE" <<'PY'
import json, sys, unicodedata

base = sys.argv[1]

def width(s):
    # CJK endonyms are double-width glyphs; padding by len() misaligns them.
    return sum(2 if unicodedata.east_asian_width(c) in 'WF' else 1 for c in s)

def row(name, url):
    print(f"  \033[1m{name}{' ' * (20 - width(name))}\033[0m {url}")

row('English', f'{base}/')
for loc in json.load(open('content/locales.json')):
    if not loc.get('path'):
        continue  # English is the root, printed above
    row(loc['name'], f"{base}/{loc['path']}/")
PY
echo
dim "  101 course        $BASE/101/index.html"
dim "  sample tutorial   $BASE/tutorials/map.html"
dim "  sitemap           $BASE/sitemap.xml"
echo
dim "  Ctrl-C to stop."
echo

if [[ $OPEN_BROWSER -eq 1 ]]; then
  ( sleep 1; command -v open >/dev/null 2>&1 && open "$BASE/" ) &
fi

# Serve from docs/ so paths match production exactly.
cd docs
exec python3 -m http.server "$PORT" --bind 127.0.0.1
