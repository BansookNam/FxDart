#!/usr/bin/env bash
# Builds the GitHub Pages resources under docs/ and commits + pushes them.
#
#   ./deploy.sh                     # build, commit with a default message, push
#   ./deploy.sh "tweak 101 intro"   # build, commit with your message, push
#   ./deploy.sh -n                  # dry run: build + show what would be committed
#   ./deploy.sh -s "msg"            # skip the build step, just commit + push
#
# GitHub Pages for this repo serves the docs/ folder on the default branch, so
# "deploying" is just pushing docs/ — no separate build artifact branch.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

DRY_RUN=0
SKIP_BUILD=0
MESSAGE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1; shift ;;
    -s|--skip-build) SKIP_BUILD=1; shift ;;
    -m|--message) MESSAGE="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "unknown flag: $1" >&2; exit 1 ;;
    *) MESSAGE="$1"; shift ;;
  esac
done

BRANCH="$(git rev-parse --abbrev-ref HEAD)"

step() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }

# ---------------------------------------------------------------- build
if [[ $SKIP_BUILD -eq 0 ]]; then
  step "Building playground bundle (docs/assets/fxdart_single.dart)"
  bash tools/build_single_file.sh

  step "Analyzing library sources"
  dart analyze lib

  step "Rendering docs/ from content/ + i18n/"
  dart run tool/build_docs.dart
else
  step "Skipping build (-s)"

  step "Verifying docs/ is current"
  dart run tool/build_docs.dart --check
fi

# ---------------------------------------------------------------- sanity
step "Checking docs/ layout"
for required in docs/index.html docs/101/index.html docs/css/site.css \
                docs/js/playground.js docs/assets/fxdart_single.dart; do
  [[ -f "$required" ]] || { echo "missing required page resource: $required" >&2; exit 1; }
done
echo "ok — $(find docs -type f | wc -l | tr -d ' ') files under docs/"

step "Translation coverage"
dart run tool/build_docs.dart --status

# ---------------------------------------------------------------- stage
# Staged by path, deliberately. A docs deploy must not sweep up unrelated
# work-in-progress in lib/ or test/ — if you want source changes in the same
# push, commit them yourself first. This also leaves the untracked
# example/_snip_*.dart scratch files alone.
step "Staging changes"
git add docs content i18n tool tools deploy.sh DEPLOY.md

if git diff --cached --quiet; then
  echo "nothing to deploy — docs/ is already up to date."
  exit 0
fi

git diff --cached --stat

if [[ $DRY_RUN -eq 1 ]]; then
  step "Dry run — stopping before commit"
  echo "run without -n to commit and push to origin/$BRANCH"
  exit 0
fi

# ---------------------------------------------------------------- ship
if [[ -z "$MESSAGE" ]]; then
  MESSAGE="docs: update GitHub Pages site"
fi

step "Committing"
git commit -m "$MESSAGE"

step "Pushing to origin/$BRANCH"
git push origin "$BRANCH"

step "Deployed"
echo "https://bansooknam.github.io/FxDart/"
echo "(Pages usually takes ~1 minute to rebuild.)"
