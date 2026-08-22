#!/usr/bin/env bash
# Builds the GitHub Pages site under docs/ exactly as CI does, so it can be
# inspected before it ships.
#
#   ./deploy.sh        # build the site, then say how to publish it
#   ./deploy.sh -n     # dry run: build only
#   ./deploy.sh -s     # skip the build, just verify what is already in docs/
#
# It does NOT commit. docs/ is untracked generated output, published by
# .github/workflows/pages.yml on a push to main. Serve the local build with
# `./run.sh -s`.
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

  # Must run before build_docs: the generator stamps data-pg only on snippets
  # that already have an artifact on disk. Rebuilding the bundle above changes
  # every fxdart snippet's id, so --prune clears the superseded ones.
  # A compile failure here means a demo on the site is broken — let it stop
  # the deploy. Use --scope=all to cover every playground, --scope=none to
  # skip precompiling entirely.
  step "Precompiling playgrounds (docs/pg/)"
  dart run tool/precompile_playgrounds.dart --scope="${PG_SCOPE:-first}" --prune

  step "Rendering docs/ from content/ + i18n/"
  dart run tool/build_docs.dart
else
  step "Skipping build (-s)"

  step "Verifying docs/ is current"
  dart run tool/build_docs.dart --check
fi

# ---------------------------------------------------------------- sanity
# css/, js/ and frame.html are copied out of web/ by build_docs, so this
# also checks that the copy ran — without it every page renders unstyled.
step "Checking docs/ layout"
for required in docs/index.html docs/101/index.html docs/css/site.css \
                docs/js/playground.js docs/frame.html \
                docs/assets/fxdart_single.dart; do
  [[ -f "$required" ]] || { echo "missing required page resource: $required" >&2; exit 1; }
done
echo "ok — $(find docs -type f | wc -l | tr -d ' ') files under docs/"

step "Translation coverage"
dart run tool/build_docs.dart --status

# ---------------------------------------------------------------- ship
# docs/ is not tracked any more, so there is nothing here to commit. The site
# is published by .github/workflows/pages.yml, which runs on a push to main
# and uploads docs/ straight to GitHub Pages. What this script is now for is
# building the exact same output locally and looking at it before it ships —
# `./run.sh -s` serves what the build above just produced.
#
# Sources still have to be committed the ordinary way. They are listed here
# only so a build that changed them does not look clean by accident.
step "Source changes that would trigger a publish"
if git diff --quiet -- web content i18n lib tool tools benchmark; then
  echo "none — the working tree matches HEAD."
else
  git diff --stat -- web content i18n lib tool tools benchmark
  echo
  echo "Commit and push these to main; pages.yml publishes on arrival."
fi

if [[ $DRY_RUN -eq 1 ]]; then
  step "Dry run — stopping"
  exit 0
fi

step "Publishing"
if [[ -n "$MESSAGE" ]]; then
  echo "note: -m/--message no longer applies — this script does not commit." >&2
fi
if command -v gh >/dev/null 2>&1; then
  echo "To publish what is on main right now:"
  echo "  gh workflow run pages.yml"
  echo "To publish every playground artifact rather than the default scope:"
  echo "  gh workflow run pages.yml -f pg_scope=all"
else
  echo "Push to main, or run the \"pages\" workflow from the Actions tab."
fi

step "Site"
echo "https://bansooknam.github.io/FxDart/"
