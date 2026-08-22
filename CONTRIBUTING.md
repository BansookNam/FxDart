# Contributing to fxdart

Everything here is a rule someone learned the hard way. Where a check exists
because a specific bug shipped, the bug is named — the point is that you can
tell when a rule stops applying.

- [Branching](#branching)
- [Long-running features](#long-running-features)
- [Pull requests](#pull-requests)
- [The gates](#the-gates)
- [What each kind of change touches](#what-each-kind-of-change-touches)
- [Performance claims](#performance-claims)
- [Releasing](#releasing)

## Branching

`main` is always deployable: GitHub Pages serves `docs/` straight off it, so a
broken `main` is a broken public site, not just a red build. Never commit to it
directly.

| prefix | for | example |
|---|---|---|
| `feat/` | a new operator, chain method or entry point | `feat/fx_ext` |
| `perf/` | a change whose whole point is a measurement | `perf/fused-take-uniq` |
| `fix/` | a bug with a failing test written first | `fix/zip-shorter-side` |
| `docs/` | `content/`, `i18n/`, `README`, tutorials, the theory book | `docs/takeuniqby-tutorial` |
| `packaging/` | pubspec, archive contents, CI, tooling | `packaging/exclude-harness` |
| `release/` | version bump + CHANGELOG only | `release/0.8.7` |

Branch off the current `main`. Rebase rather than merge while the branch is
yours alone — the history reads as a sequence of releases, and a merge bubble
inside a feature branch buries the one commit a future bisect wants.

## Long-running features

A feature that takes weeks is the case the rest of this file is shaped around.
Three rules keep it from becoming a merge event.

**1. Land the pieces that stand alone.** A new operator is not one commit. The
implementation, its tests, its tutorial, its comparison example and its
benchmark case are five, and the first two are useful on `main` before the
other three exist. Open a PR when the library change is green, and follow it
with docs PRs. `deploy.sh` stages only docs paths for exactly this reason — the
two streams are designed not to block each other.

**2. Rebase onto `main` at least weekly, and always before review.** The files
most likely to collide are the ones every change touches:
`lib/fxdart.dart`'s export list, `CHANGELOG.md`'s top section,
`benchmark/results/results.json`, and `i18n/*/sources.json`. All four conflict
textually while being semantically trivial to merge, and all four get worse the
longer you wait. `results.json` and `sources.json` are generated — resolve them
by taking `main`'s version and re-running the generator, never by hand-editing
the JSON.

**3. Keep the branch green the whole way, not at the end.** Run
[the fast gate](#the-gates) before every push. A feature branch that has not
compiled in a week is a feature branch nobody can help you with.

If the work is genuinely one indivisible change, say so in the PR description
and keep the branch rebased. If it is exploratory and may not land, prefix it
`spike/` and do not expect review.

## Pull requests

Every change reaches `main` through a PR. One PR is one reviewable idea — a
refactor and the feature it enables are two PRs, in that order.

**Title** — the commit convention, which is also the branch prefix:
`feat:`, `perf:`, `fix:`, `docs:`, `packaging:`. Lowercase, no trailing period,
and it names what changed rather than what you did: `feat: takeUniqBy, and what
the lazy callback floor actually is`, not `add takeUniqBy operator`.

**Body** — answer the three questions a reviewer will otherwise ask:

1. *What breaks if this is wrong?* Name the failure, not the feature.
2. *What did you measure?* Any claim about speed needs a number and the shape
   of the run that produced it — see [Performance claims](#performance-claims).
3. *What did you deliberately not do?* Deferred work, rejected alternatives,
   and the reason. This is the part that survives into the CHANGELOG.

**Size** — under ~400 lines of non-generated diff. Generated output
(`docs/`, `docs/assets/fxdart_single.dart`, `docs/pg/`, `benchmark/results/`)
does not count against that, but it should be in its own commit inside the PR
so the reviewer can skip it in one click.

**Squash** the merge unless the individual commits each stand alone and are
each green. The default is squash.

**Before requesting review**, the full gate passes locally and the PR
description says so. CI is a backstop, not your test run — two of the gates
below (`build_docs --check`, `check_theory`) are not in CI at all.

## The gates

### Fast gate — before every push

```bash
dart analyze lib                     # must be clean; `lints/recommended`
dart analyze test tool benchmark     # tooling counts as code
dart test                            # 100% must pass — see below
```

**"100% pass" is literal.** There is no allowed-failure list and no flaky test
to retry. A test that cannot be made deterministic does not belong in the
suite; async tests that assert on concurrency assert on a *bound*
(`peak > 1`), never on an exact interleaving. If a test fails on your machine
and passes in CI, that is the bug — investigate it rather than pushing.

The suite carries exactly one `skip:`, in `test/lazy/fork_test.dart`, and it
documents a semantic difference from FxTS rather than a defect: JS iterators
are shared cursors, Dart iterables restart per iterator, so the FxTS behaviour
it names cannot exist here. A new `skip:` needs that kind of reason in the
string itself — "flaky" and "fix later" are not reasons.

Coverage is reported to Codecov but is not a merge gate, and deliberately so:
`fx(xs).join()` broke in 0.8.0 while coverage sat at 100%, because every test
passed a separator. `test/api_surface_test.dart` exists to call every public
member in its **bare** form. Add to it when you add a member.

### Full gate — before requesting review

Everything above, plus:

```bash
bash tools/build_single_file.sh                      # regenerate the playground bundle
git diff --exit-code -- docs/assets/fxdart_single.dart   # must leave no diff
dart run tool/check_benchmark_faithfulness.dart      # cases match their published examples
dart run coverage:test_with_coverage                 # what coverage CI runs
```

The bundle step is not optional busywork. `tools/build_single_file.sh` keeps a
hand-maintained `_$NAME` wrapper list, and it silently fell out of step with
`uniqStrict`/`uniqByStrict` from 0.8.1 — the bundle failed to analyze for two
releases, and only a manual `./deploy.sh` ever noticed. **If you added a
public top-level function, check whether the wrapper list needs it.**

It has a consequence that catches everyone once. Every playground artifact
under `docs/pg/` is keyed by the snippet *plus* the bundle it compiles
against, so **any change to `lib/` re-keys every fxdart snippet on the site**
— rebuilding the bundle for a four-line addition orphaned 333 of 448
artifacts. Nothing fails; those pages just fall back to the network compile
service and get ~2s slower on Run. So a `lib/` PR runs the deploy sequence in
order and commits the result:

```bash
bash tools/build_single_file.sh                     # 1. bundle
dart run tool/precompile_playgrounds.dart --prune   # 2. re-compile, drop the superseded
dart run tool/build_docs.dart                       # 3. restamp data-pg
dart run tool/precompile_playgrounds.dart --status  # 0 "in scope not built yet"
```

Step 2 compiles over the network and takes minutes. Never reorder these:
`build_docs` stamps `data-pg` only on snippets that already have an artifact
on disk, so building docs before precompiling silently produces unstamped
pages.

### Docs gate — if you touched `content/`, `i18n/`, or the theory book

```bash
dart run tool/build_docs.dart                        # regenerate docs/
dart run tool/build_docs.dart --record               # mark translations current
dart run tool/build_docs.dart                        # rebuild: --record changes the banners
dart run tool/build_docs.dart --check                # must say "up to date"
dart run tool/check_translation.dart ko <path>       # per locale you touched
dart run tool/check_comparison.dart --check          # if you touched comparison examples
dart run tool/check_theory.dart [NN …]               # if you touched content/theory/
```

Three traps, in the order people hit them:

- **`--record` and the edit belong in the same commit.** Staleness is a hash of
  the *English* file, so any edit to it — including a mechanical front-matter
  bump — marks every translation outdated and grows a "may be outdated" banner.
  But recording is also what silences a *genuine* staleness, so before
  recording in bulk, run `--status` first and confirm the count you are about
  to clear is only your own edit.
- **`--record` does not build.** It rewrites `i18n/*/sources.json`, which
  changes the banner, which changes the HTML. Build again afterwards or
  `--check` will fail.
- **Editing any playground snippet orphans its artifact.** The page falls back
  to the network compile service and gets ~2s slower on Run, silently.
  `dart run tool/rebuild_page.dart <page.html>` does the whole sequence for one
  page.

`docs/` is generated output that is **committed**. Never hand-edit a `*.html`
under it. The hand-maintained exceptions are `docs/css/site.css`,
`docs/js/*.js`, `docs/frame.html`, `docs/assets/logo*.png` and
`docs/css/theorybook.css` + `docs/js/theorybook.js`.

## What each kind of change touches

**A new operator** is not done until all six exist:

1. the top-level sync function in `lib/src/{lazy,strict}/`
2. its `Async` variant, parallel-safe — overlapping `next()` calls must start
   overlapping upstream pulls, or `concurrent` breaks
3. the chain method on `Fx` **and** `FxAsync` in `lib/src/fx.dart`
4. the export in `lib/fxdart.dart` (extensions need their *names* in the
   `show` list, not just their members)
5. `test/{lazy,strict,util}/<fn>_test.dart` — one file per function — plus a
   bare-form call in `test/api_surface_test.dart`
6. `content/tutorials/<fn>.md` + `content/code/<fn>/`

**A chain method on `Fx`** — remember it is an extension type, so a redeclared
member *replaces* the interface member rather than overriding it. Anything
`Iterable` provides a default for (`join`, `fold`, `followedBy`) loses that
default the moment you redeclare it. This is the 0.8.0 `join()` bug.

**A new entry point** (a function that wraps a value into an fxdart type) gets
a getter twin, and **its name carries `fx`**: `.fx`, `.fxAsync`, `.fxEvents`,
`.fxLive`, `.fxShuffle`, `.fxDebounce`. The prefix says which library the call
steps into, and it leaves the bare word free for whatever else a project puts
on that type. `fxShuffle` shows why the rule earns its keep: `List.shuffle`
exists in `dart:core` and shuffles in place returning void, an instance member
always beats an extension, so a getter named `shuffle` would silently call the
wrong one.

**Operators do not get extensions on `Iterable`.** Fifteen of them (`map`,
`where`, `take`, `fold`, `reduce`, `join`, `any`, `every`, `expand`,
`forEach`, `last`, `toList`, `takeWhile`, `skipWhile`, `skip`) share a name
with a member `Iterable` already has, so the call could never reach fxdart;
seven more (`average`, `chunk`, `count`, `elementAtOrNull`, `firstWhereOrNull`,
`sorted`, `whereNot`) collide with `package:collection` and would be a compile
error in code importing both. Operators live on the chain — `xs.fx.map(f)`.

**Anything in `lib/`** — zero runtime dependencies, and it stays that way.

**A translation** — code blocks are locale-invariant. `content/code/` and
`sig.txt` are shared and never translated; in the theory book a chapter whose
fenced blocks differ from English fails `check_theory.dart` outright.

## Performance claims

The benchmark harness has a **~5% cross-run noise floor**. A sweep cannot
resolve anything smaller, so a number from `./benchmark.sh` alone is not
evidence that a change did anything.

```bash
./benchmark.sh --ab <slug> | --ab --all   # paired interleaved A/B — the instrument
./benchmark.sh --verify                   # is the ratio report in step with results.json?
./benchmark.sh                            # full sweep + regenerate the report
```

`--ab` runs 20 rounds rather than `ab_bench`'s default 12 because at 12, four
readings in the 0.8.6 pass looked solid against clean controls and vanished at
20. If your PR claims a speedup, paste the paired A/B output into the
description. If the change is under 5% and you only ran a sweep, say that
instead of the number.

Both benchmark families are maintained separately —
`benchmark/results/results.json` (native Dart vs FxDart) and
`results-rx.json` (RxDart vs FxDart) — and both are build_docs *inputs*, so a
sweep that lands without regenerating the report leaves the site contradicting
itself. That is what `--verify` is for.

## Releasing

Version bumps and CHANGELOG sections are their own PR on a `release/` branch,
separate from the feature commits.

**pub.dev is the source of truth for what shipped** — not git tags (three of
them for twenty-three published versions), and not the CHANGELOG (`0.7.7` and
`0.7.8` have sections and never reached pub.dev; both shipped inside `0.7.9`).

```bash
curl -s -H "Accept: application/vnd.pub.v2+json" \
  https://pub.dev/api/packages/fxdart |
  python3 -c "import sys,json;print(json.load(sys.stdin)['latest']['version'])"
grep '^version:' pubspec.yaml
```

If local **equals** published, your work needs a new section and a bump. If
local is **ahead**, the top section is unreleased — add to it. If local is
**behind**, stop and ask.

A CHANGELOG section is prose, not a bullet list. It says what changed, what it
cost, what was measured, and what was deliberately left out — the same three
questions the PR body answered.

Docs deploy separately, via `./deploy.sh`, which stages only
`docs content i18n tool tools deploy.sh DEPLOY.md`. Commit `lib/` and `test/`
changes yourself first; the deploy will not sweep them up.
