#!/usr/bin/env bash
# Builds the Daily Ledger Flutter web app and publishes it to GitHub Pages at
#
#   https://bansooknam.github.io/FxDart/DailyLedger/
#
# Pages serves the repo's docs/ folder on the default branch, so "deploying"
# is: flutter build web → copy into docs/DailyLedger/ → commit + push.
# This script touches ONLY docs/DailyLedger/ (plus itself) — the docs site,
# library sources, and app sources are never swept up. Commit app changes
# under example/daily_ledger/ separately, like lib/ and test/.
#
#   ./deploy.sh                     # build, copy, commit with default message, push
#   ./deploy.sh "tweak dashboard"   # same, custom commit message
#   ./deploy.sh -n                  # dry run: build + copy + show what would be committed
#   ./deploy.sh -s "msg"            # skip the flutter build, just copy + commit + push
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$APP_DIR/../.." && pwd)"
BASE_HREF="/FxDart/DailyLedger/"
OUT_DIR="$ROOT/docs/DailyLedger"

DRY_RUN=0
SKIP_BUILD=0
MESSAGE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1; shift ;;
    -s|--skip-build) SKIP_BUILD=1; shift ;;
    -m|--message) MESSAGE="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "unknown flag: $1" >&2; exit 1 ;;
    *) MESSAGE="$1"; shift ;;
  esac
done

BRANCH="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD)"

step() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }

# ---------------------------------------------------------------- build
cd "$APP_DIR"

if [[ $SKIP_BUILD -eq 0 ]]; then
  step "Analyzing app"
  flutter analyze

  step "Running logic tests"
  flutter test

  step "Building web release (base-href $BASE_HREF)"
  # --pwa-strategy none: no service worker, so Pages visitors never get a
  # stale cached build after a deploy.
  flutter build web --release --base-href "$BASE_HREF" --pwa-strategy none
else
  step "Skipping build (-s)"
fi

[[ -f "$APP_DIR/build/web/index.html" ]] || {
  echo "no build output at build/web — run without -s first" >&2; exit 1;
}

# ---------------------------------------------------------------- copy
step "Syncing build/web → docs/DailyLedger/"
mkdir -p "$OUT_DIR"
# --delete keeps the target exactly equal to the build, but only INSIDE
# docs/DailyLedger/ — the rest of docs/ is never touched.
rsync -a --delete "$APP_DIR/build/web/" "$OUT_DIR/"

# ---------------------------------------------------------------- sanity
step "Checking deployed layout"
for required in "$OUT_DIR/index.html" "$OUT_DIR/flutter.js" \
                "$OUT_DIR/main.dart.js" "$OUT_DIR/flutter_bootstrap.js"; do
  [[ -f "$required" ]] || { echo "missing required file: $required" >&2; exit 1; }
done
grep -q "base href=\"$BASE_HREF\"" "$OUT_DIR/index.html" || {
  echo "index.html base href is not $BASE_HREF — wrong build flags?" >&2; exit 1;
}
echo "ok — $(find "$OUT_DIR" -type f | wc -l | tr -d ' ') files under docs/DailyLedger/"

# ---------------------------------------------------------------- stage
step "Staging changes"
cd "$ROOT"
git add docs/DailyLedger example/daily_ledger/deploy.sh

if git diff --cached --quiet; then
  echo "nothing to deploy — docs/DailyLedger/ is already up to date."
  exit 0
fi

git diff --cached --stat | tail -5

if [[ $DRY_RUN -eq 1 ]]; then
  step "Dry run — stopping before commit"
  echo "run without -n to commit and push to origin/$BRANCH"
  exit 0
fi

# ---------------------------------------------------------------- ship
if [[ -z "$MESSAGE" ]]; then
  MESSAGE="docs: deploy Daily Ledger app to Pages"
fi

step "Committing"
git commit -m "$MESSAGE"

step "Pushing to origin/$BRANCH"
git push origin "$BRANCH"

step "Deployed"
echo "https://bansooknam.github.io/FxDart/DailyLedger/"
echo "(Pages usually takes ~1 minute to rebuild.)"
