#!/usr/bin/env bash
# One entry point for the benchmark suites, with the traps already handled.
#
#   ./benchmark.sh                        # sweep every case, then regenerate the report
#   ./benchmark.sh ledger-diff top-merchants
#   ./benchmark.sh --rx                   # the RxDart-vs-FxDart family instead
#   ./benchmark.sh --docs                 # sweep, regenerate, and rebuild docs/
#
#   ./benchmark.sh --ab ledger-diff       # paired A/B: did MY change move this?
#   ./benchmark.sh --ab --all             # …across every case
#   ./benchmark.sh --ab --ref v0.8.5 ledger-diff
#
#   ./benchmark.sh --verify               # are results.json and the report in step?
#   ./benchmark.sh --check                # faithfulness + example checks, no measuring
#   ./benchmark.sh --report-only          # re-derive verdicts, no measuring
#   ./benchmark.sh --smoke ledger-diff    # does it still run? (results are restored)
#
# WHY THIS EXISTS, rather than calling the four tools by hand
# ----------------------------------------------------------
# Each of these steps has a way of going wrong quietly, and every one of them
# has actually happened in this repo:
#
#   * A sweep writes results.json, which build_docs renders the bar charts
#     from — but the ratio report is a SEPARATE script. Update one and not the
#     other and the two disagree, silently, until someone regenerates the
#     report months later and it looks like a regression landed. A sweep here
#     always regenerates the report.
#   * `--smoke` runs one un-warmed iteration and writes the result to
#     results.json like any other run. Those numbers are not measurements.
#     Smoke mode here restores results.json and SUMMARY.md when it finishes.
#   * A sweep cannot resolve a change smaller than ~5%: the native side links
#     no fxdart code, so a lib-only change must leave it identical, and it
#     measures at a median -2.1% with a -27%..+4% range across runs. Use --ab
#     for "did my change do anything", which runs both variants interleaved in
#     one session so drift lands on both.
#   * ab_bench rejects a run whose control drifted, but a clean control is not
#     enough on its own: at its default 12 rounds, four readings in the 0.8.6
#     pass looked like solid ±3-4% results against clean controls and were all
#     gone at 20. --ab runs 20 here, and fails the run when ab_bench's own
#     gate fires (a pipeline hides its exit code, so PIPESTATUS is read).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

MODE=sweep
FAMILY=()          # empty = the Dart family; ("--rx") = the RxDart one
BUILD_DOCS=0
ROUNDS=""
REF=()
SLUGS=()
AB_ALL=0

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
warn() { printf '\033[33m%s\033[0m\n' "$*" >&2; }
die()  { printf '\033[31m%s\033[0m\n' "$*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ab)          MODE=ab; shift ;;
    --all)         AB_ALL=1; shift ;;
    --verify)      MODE=verify; shift ;;
    --check)       MODE=check; shift ;;
    --report-only) MODE=report; shift ;;
    --smoke)       MODE=smoke; shift ;;
    --rx)          FAMILY=(--rx); shift ;;
    --docs)        BUILD_DOCS=1; shift ;;
    --rounds)      ROUNDS="${2:-}"; shift 2 ;;
    --ref)         REF=(--ref "${2:-}"); shift 2 ;;
    -h|--help)     sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)            die "unknown flag: $1  (try --help)" ;;
    *)             SLUGS+=("$1"); shift ;;
  esac
done

# The results file this family writes, and the report built from it.
if [[ ${#FAMILY[@]} -gt 0 ]]; then
  RESULTS="benchmark/results/results-rx.json"
  SUMMARY="benchmark/results/SUMMARY-RX.md"
else
  RESULTS="benchmark/results/results.json"
  SUMMARY="benchmark/results/SUMMARY.md"
fi
REPORT="benchmark/results/perf_ratio_report.md"

regenerate_report() {
  # The ratio report only exists for the Dart family — the rx pages carry
  # their own bars and no ranking table.
  if [[ ${#FAMILY[@]} -gt 0 ]]; then
    return 0
  fi
  bold "→ regenerating $REPORT"
  python3 benchmark/results/perf_ratio_report.py
}

case "$MODE" in

  check)
    bold "→ benchmark cases match their published examples"
    dart run tool/check_benchmark_faithfulness.dart
    bold "→ both panels of every example print the same output"
    dart run tool/check_comparison.dart --check ${SLUGS[@]+"${SLUGS[@]}"}
    ;;

  verify)
    # Catches exactly the drift described at the top: results.json moved and
    # the report did not (or vice versa).
    if [[ ${#FAMILY[@]} -gt 0 ]]; then die "--verify covers the Dart family only"; fi
    tmp="$(mktemp -t perf_ratio_report.XXXXXX.md)"
    trap 'rm -f "$tmp"' EXIT
    python3 benchmark/results/perf_ratio_report.py -o "$tmp" >/dev/null
    if diff -q "$REPORT" "$tmp" >/dev/null 2>&1; then
      bold "✓ $REPORT is in step with $RESULTS"
    else
      warn "✗ $REPORT disagrees with $RESULTS — it was not regenerated after a sweep."
      warn "  Rows that differ:"
      diff "$REPORT" "$tmp" | grep '^[<>]' | sed 's/^/    /' >&2
      warn "  Fix with:  ./benchmark.sh --report-only"
      exit 1
    fi
    ;;

  report)
    bold "→ re-deriving verdicts from $RESULTS (no measuring)"
    dart run benchmark/run_benchmarks.dart ${FAMILY[@]+"${FAMILY[@]}"} --report-only
    regenerate_report
    ;;

  smoke)
    bold "→ smoke run (1 iteration, no warmup) — results will be restored"
    before="$(mktemp)"; beforeSum="$(mktemp)"
    cp "$RESULTS" "$before"; cp "$SUMMARY" "$beforeSum"
    trap 'cp "$before" "$RESULTS"; cp "$beforeSum" "$SUMMARY"; rm -f "$before" "$beforeSum"; \
          printf "\033[1m→ restored %s and %s\033[0m\n" "$RESULTS" "$SUMMARY"' EXIT
    dart run benchmark/run_benchmarks.dart ${FAMILY[@]+"${FAMILY[@]}"} --smoke ${SLUGS[@]+"${SLUGS[@]}"}
    warn "Smoke numbers are a liveness check, not a measurement."
    ;;

  ab)
    if [[ ${#SLUGS[@]} -eq 0 && $AB_ALL -eq 0 ]]; then
      die "--ab needs case slugs, or --all for every case"
    fi
    # 20, not ab_bench's default 12: see the note at the top of this file.
    rounds="${ROUNDS:-20}"
    scope="${#SLUGS[@]} case(s)"
    all=()
    if [[ $AB_ALL -eq 1 ]]; then all=(--all); scope="every case"; fi
    bold "→ paired A/B over $scope, $rounds rounds"
    out="$(mktemp)"
    trap 'rm -f "$out"' EXIT
    # ab_bench exits 1 when a control drifted past its limit, but a pipeline's
    # status is the last command's — so read PIPESTATUS rather than $?, and
    # keep the text check as a second net.
    set +e
    dart run tool/ab_bench.dart ${FAMILY[@]+"${FAMILY[@]}"} ${REF[@]+"${REF[@]}"} \
      "${all[@]+${all[@]}}" --rounds "$rounds" ${SLUGS[@]+"${SLUGS[@]}"} 2>&1 | tee "$out"
    ab_status=${PIPESTATUS[0]}
    set -e
    if [[ $ab_status -ne 0 ]] || grep -q '!!' "$out" || grep -q 'control drift' "$out"; then
      warn ""
      warn "A control moved past its limit — those rows mean nothing."
      warn "Re-run on an idle machine, or raise --rounds."
      exit 1
    fi
    ;;

  sweep)
    if [[ -n "$(git status --porcelain -- lib 2>/dev/null)" ]]; then
      warn "lib/ has uncommitted changes — these numbers will not match any commit."
      warn ""
    fi
    if [[ ${#SLUGS[@]} -eq 0 ]]; then
      warn "Sweeping every case. This takes a while, and a sweep cannot resolve"
      warn "a change under ~5% — use --ab for that."
      warn ""
    fi
    extra=()
    if [[ -n "$ROUNDS" ]]; then extra=(--rounds "$ROUNDS"); fi
    bold "→ measuring"
    dart run benchmark/run_benchmarks.dart ${FAMILY[@]+"${FAMILY[@]}"} ${extra[@]+"${extra[@]}"} ${SLUGS[@]+"${SLUGS[@]}"}
    regenerate_report
    if [[ $BUILD_DOCS -eq 1 ]]; then
      bold "→ rebuilding docs/ (the bar charts read $RESULTS)"
      dart run tool/build_docs.dart
    else
      bold "→ docs/ NOT rebuilt. The site's bars still show the old numbers."
      echo "   Run './benchmark.sh --docs …' next time, or 'dart run tool/build_docs.dart' now."
    fi
    ;;
esac
