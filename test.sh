#!/usr/bin/env bash
# Runs the checks CI runs and prints one summary: analyzer, tests, and
# library line coverage (with any uncovered lines named, since the project
# holds lib/ at 100%).
#
#   ./test.sh              analyze + test + coverage
#   ./test.sh -q           tests only, no coverage (fast inner loop)
#   ./test.sh <path…>      pass paths/args through to `dart test`
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

QUICK=0
ARGS=()
for a in "$@"; do
  case "$a" in
    -q | --quick) QUICK=1 ;;
    *) ARGS+=("$a") ;;
  esac
done

bold() { printf '\033[1m%s\033[0m\n' "$1"; }
fail() { printf '\033[31m%s\033[0m\n' "$1"; }
ok() { printf '\033[32m%s\033[0m\n' "$1"; }

status=0

bold '── analyze ─────────────────────────────────────────────'
if dart analyze lib test; then
  ok 'analyzer clean'
else
  fail 'analyzer found issues'
  status=1
fi

echo
if [[ $QUICK -eq 1 || ${#ARGS[@]} -gt 0 ]]; then
  bold '── test ────────────────────────────────────────────────'
  # Reporter prints one line per failure plus a final tally.
  if dart test --reporter=compact "${ARGS[@]+"${ARGS[@]}"}"; then
    ok 'tests passed'
  else
    fail 'tests failed'
    status=1
  fi
  echo
  [[ $status -eq 0 ]] && ok 'OK (coverage skipped)' || fail 'FAILED'
  exit $status
fi

bold '── test + coverage ─────────────────────────────────────'
if dart run coverage:test_with_coverage; then
  ok 'tests passed'
else
  fail 'tests failed'
  status=1
fi

echo
bold '── library line coverage ───────────────────────────────'
python3 - <<'PY'
import os, sys

path = 'coverage/lcov.info'
if not os.path.exists(path):
    print('no coverage/lcov.info — coverage step did not produce a report')
    sys.exit(1)

files, cur = {}, None
for line in open(path):
    line = line.strip()
    if line.startswith('SF:'):
        cur = line[3:]
        files.setdefault(cur, {'hit': 0, 'found': 0, 'missing': []})
    elif line.startswith('DA:'):
        ln, hits = line[3:].split(',')
        files[cur]['found'] += 1
        if int(hits) > 0:
            files[cur]['hit'] += 1
        else:
            files[cur]['missing'].append(int(ln))

hit = sum(v['hit'] for v in files.values())
found = sum(v['found'] for v in files.values())
if not found:
    print('no lines recorded')
    sys.exit(1)

pct = hit / found * 100
print(f'{hit}/{found} lines = {pct:.2f}%')

root = os.getcwd() + '/'
incomplete = {f: v for f, v in files.items() if v['missing']}
for f, v in sorted(incomplete.items()):
    rel = f[len(root):] if f.startswith(root) else f
    lines = ', '.join(str(n) for n in v['missing'][:30])
    more = '' if len(v['missing']) <= 30 else f' (+{len(v["missing"]) - 30} more)'
    print(f"  {rel}  {v['hit']}/{v['found']}")
    print(f'    uncovered: {lines}{more}')

sys.exit(0 if pct == 100.0 else 2)
PY
cov=$?

echo
if [[ $cov -eq 2 ]]; then
  fail 'coverage is below 100%'
  status=1
elif [[ $cov -ne 0 ]]; then
  fail 'coverage report unavailable'
  status=1
else
  ok 'coverage 100%'
fi

if [[ $status -eq 0 ]]; then
  ok 'OK'
else
  fail 'FAILED'
fi
exit $status
