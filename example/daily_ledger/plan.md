# Daily Ledger — fxdart Flutter Web Example

A budget book + planner combined. One `Entry` model covers expenses, income,
bills, and todos — so every screen is a data-aggregation problem, and every
aggregation is an fxdart pipeline. This app is a **showcase for fxdart**:
storage stays dumb (hive_ce hands back plain lists), fxdart does all the
data work in memory.

- **Target:** Flutter **web only** (for now). Later compiled and hosted on
  GitHub Pages next to FxDart 101 (see [Deployment](#deployment)).
- **Location:** `example/daily_ledger/`

## Principles

1. **fxdart does the data work.** No SQL-style queries, no manual `for` loops
   for aggregation. If a screen needs grouping, summing, sorting, or
   windowing, it goes through `fx(...)` or a top-level operator.
2. **Storage is a dumb shelf.** hive_ce (IndexedDB on web) persists entries
   and returns `List<Entry>`. The repository never filters or aggregates.
3. **Readable over clever.** Each pipeline should read like the tutorial
   snippet for the operator it demonstrates. Code comments may name the
   operator being showcased — this app doubles as documentation.
4. **No heavy state management.** `ChangeNotifier` + `ValueListenableBuilder`.
   The star is the data layer, not the architecture.
5. **Deterministic demo data.** Seeded fixtures (fxdart's
   `createSeededRandom`) so the deployed demo looks identical for everyone.

## Tech stack

| Concern    | Choice                                  | Notes                                            |
| ---------- | --------------------------------------- | ------------------------------------------------ |
| Framework  | Flutter (web target only)               | `flutter create --platforms web`                 |
| Storage    | `hive_ce` + `hive_ce_flutter`           | IndexedDB backend on web; no native setup        |
| Data logic | `fxdart` (path dependency `../../`)     | The whole point                                  |
| State      | `ChangeNotifier` per feature            | Zero extra deps                                  |
| Routing    | Simple `IndexedStack` / `NavigationRail`| Dashboard · Calendar · Entries · Insights        |

## Data model

```dart
enum EntryType { expense, income, task, bill }
// bill = expense + dueDate; task = todo with optional dueDate

class Entry {
  final String id;
  final String title;
  final EntryType type;
  final double? amount;        // null for pure tasks
  final String categoryId;
  final List<String> tags;
  final DateTime date;         // when it happened / was created
  final DateTime? dueDate;     // bills & tasks
  final bool done;             // tasks: completed, bills: paid
  final String? recurringRuleId;
}

class Category { id, name, icon, colorSeed, kind (money | task) }

class RecurringRule { id, period (weekly | monthly), anchorDate }
```

Hive stores each as a box (`entries`, `categories`, `rules`) via generated
`TypeAdapter`s. That's the entire persistence story.

## Screens → fxdart usage map

| Screen / feature                          | fxdart operators                                   |
| ----------------------------------------- | -------------------------------------------------- |
| Dashboard: monthly income/expense totals  | `filter` → `groupBy` (month) → `sum` / `average`   |
| Dashboard: category breakdown (top 5)     | `groupBy` → `sortBy` → `take(5)`                   |
| Dashboard: running balance sparkline      | `sortBy` (date) → `scan` (cumulative sum)          |
| Dashboard: upcoming bills / overdue tasks | `filter` + `partition` (overdue vs upcoming)       |
| Calendar: month grid                      | `range` (day offsets) → `map` → `chunk(7)`         |
| Calendar: entries per day cell            | `indexBy` / `groupBy` (day key)                    |
| Entries list: grouped by day, filtered    | `filter` → `groupBy` → `sortBy`, `countBy` badges  |
| Entries list: search-as-you-type          | `debounce` on the query, `filter` on entries       |
| Insights: month-over-month comparison     | `zip` / `zipWithIndex` over consecutive months     |
| Insights: tag stats, duplicates cleanup   | `countBy`, `uniqBy`                                |
| Recurring rules → projected entries       | `cycle` / `range` → `map` → `takeWhile` (horizon)  |
| Repository load (entries+categories+rules)| `toAsync().map(...).concurrent(3)` + `delay`       |
| Seed fixtures                             | `createSeededRandom`, `range`, `map`, `shuffle`    |

The repository adds a small artificial `delay` per box read so the
`concurrent(3)` startup load is a visible, honest demo of the async story
without any network dependency.

## Architecture

```
example/daily_ledger/
  plan.md                  # this file
  lib/
    main.dart              # Hive init, seed-if-empty, app shell
    models/                # Entry, Category, RecurringRule (+ adapters)
    data/
      ledger_repository.dart   # dumb Hive access + fake latency
      seed.dart                # deterministic fixtures via fxdart
    state/                 # ChangeNotifiers (LedgerState, filters)
    logic/                 # pure fxdart pipelines (unit-testable!)
      summaries.dart       # monthly totals, category breakdown, balance
      calendar.dart        # month grid, per-day index
      recurrence.dart      # rule → projected entries
    ui/                    # screens + widgets
  test/                    # tests for logic/ (pure functions, no Flutter)
```

`logic/` is the showcase directory: pure functions from `List<Entry>` →
view data, each an fxdart pipeline, each unit-tested. UI never computes.

## Milestones (initial build)

- **M0 — Scaffold:** `flutter create` (web only), deps, Hive init, empty shell
  with `NavigationRail`. App runs in Chrome.
- **M1 — Model + data:** models, adapters, repository, seeded fixtures,
  `concurrent(3)` startup load.
- **M2 — Dashboard:** monthly summary, category top-5, running balance,
  upcoming/overdue panel.
- **M3 — Calendar:** `chunk(7)` month grid with per-day entries and
  amounts; tap a day → entries.
- **M4 — Entries:** filterable/grouped list, add/edit/delete form,
  debounced search, done-toggle for tasks/bills.
- **M5 — Insights + polish:** month comparison, tag stats, recurring
  projection; seed button; empty states; `dart analyze` clean; `logic/` tests
  pass.

## Deployment (later, after iteration rounds)

Like FxDart 101, the app will be served from `docs/` off `main`:

```bash
flutter build web --base-href /FxDart/ledger/ --pwa-strategy none
cp -r build/web docs/ledger
```

Open items to resolve at deploy time (deliberately deferred):

- `docs/` is generated by `tool/build_docs.dart` — confirm it won't clobber
  `docs/ledger/`, or teach the tool/`deploy.sh` a copy step.
- Decide renderer (`canvaskit` vs `skwasm`) and check bundle size for Pages.

## Iteration protocol — 4 rounds

After M5, run **4 rounds** of this loop. Each round is one commit series and
gets a log section appended at the bottom of this file.

1. **Evaluate — 10 feedbacks.** Play the deployed/local app end-to-end and
   write exactly 10 numbered feedback items. Rubric — each item is tagged:
   - `UX` — flow, clarity, visual polish
   - `CORRECT` — wrong numbers, date bugs, edge cases (empty month, tz)
   - `FX` — a place where fxdart is under-used, mis-used, or where an
     imperative loop survived
   - `PERF` — jank, rebuild storms, pipeline re-runs per frame
   - `DX` — code a tutorial reader would stumble on
2. **Suggest 3 new features.** Each with a one-line pitch and the fxdart
   operators it would exercise. Prefer features that cover operators the app
   doesn't demo yet (see coverage table below).
3. **Strategy.** Pick which feedbacks to fix (at minimum: all `CORRECT`,
   all `FX`) and which 1–3 features to build. For each, name the exact
   fxdart pipeline before writing code — pipeline-first design.
4. **Implement.** Build it, keep `logic/` pure + tested, `dart analyze`
   clean, update the operator coverage table.

**Round exit criteria:** all chosen items shipped, tests green, feedback log
recorded below, coverage table updated.

## Operator coverage table

Track which fxdart operators the app demonstrates; grow it every round.

| Status | Operators |
| ------ | --------- |
| ✅ initial build | filter, map, flatMap, groupBy, indexBy, countBy, sortBy, sum, average, scan, chunk, partition, take, drop, takeWhile, dropWhile, zip, zipWithIndex, range, uniq, uniqBy, debounce, delay, toAsync, concurrent, peek, createSeededRandom, shuffle, last |
| ✅ round 1 | fold, difference, evolve |
| ✅ round 2 | fork, pick, fromEntries, prepend, max |
| ✅ round 3 | memoize, juxt, throttle, takeRight, reverse, head |
| ✅ round 4 | intersection, difference (both directions), pluck, compact, pipe |
| ⏸ intentionally uncovered | omit, slice, cycle, tap, scan1, repeat — no natural fit in this app; forcing them would violate the "readable over clever" principle |

## Round log

### Round 1 — done

**Feedbacks (10):**
1. `CORRECT` — Insights "Month over month" was pinned to today and ignored the
   month selector, inconsistent with every other screen. → fixed: trend now
   follows `state.month`.
2. `CORRECT` — Calendar kept a stale day selection when switching months (the
   side panel showed a day not on the visible grid). → fixed: out-of-month
   selections are ignored; tapping a leading/trailing cell hops to that month.
3. `CORRECT` — `Entry.copyWith` couldn't *clear* nullable fields
   (`copyWith(dueDate: null)` was silently ignored) — a latent editing bug.
   → fixed with a sentinel-based copyWith.
4. `FX` — `possibleDuplicates` hand-rolled a set difference with
   `!firstSeen.contains(e)` inside a filter. → fixed: now literally
   `difference(firstSeen, money)`.
5. `FX` — `LedgerState.categoryById` was an imperative O(n) for-loop.
   → fixed: cached `indexBy`-built lookup map.
6. `PERF` — `dueCount()` scanned all entries once per calendar cell (42×N per
   frame). → fixed: one `countBy(due day)` index per build, cells do O(1) reads.
7. `PERF` — every `notifyListeners` rebuilds all four IndexedStack screens and
   recomputes summaries. Deferred → `memoize` candidate for a later round.
8. `UX` — Dashboard "Upcoming" silently truncated at 6 items. → fixed: shows
   "+N more in the Entries tab".
9. `UX` — Type-filter chip counts ignored the active search query, so badge
   numbers didn't match the visible list. → fixed: counts run over the
   searched list.
10. `DX` — Entry form's category dropdown could show a stale selection after
    switching entry type (initialValue is read once). → fixed: `ValueKey(_type)`
    forces a rebuild when the category list changes.

**Features suggested (3):**
- A. **Category budgets** — monthly budget per category with progress bars,
  over-budget flags, and auto-suggestions. Operators: `fold`, `evolve`,
  `groupBy`, `sortBy`. ← *chosen*
- B. **Weekly spending heatmap** — weekday×week intensity grid on Insights.
  Operators: `fork`, `countBy`, `chunk`.
- C. **Quick stats strip** — biggest expense / busiest day / daily average in
  one pass. Operators: `juxt`, `fork`.

**Strategy:** fix all CORRECT (1–3), all FX (4–5), plus PERF 6 and UX/DX 8–10;
defer PERF 7 to the memoize round. Build feature A pipeline-first:
`spentByCategory` = filter → groupBy → fold; `budgetStatuses` = map-join →
sortBy(-ratio); `suggestedBudgets` = range → map(spentByCategory) → per-key
average → **evolve** (+10% headroom, ceil to $10). Budgets persist in a
`Box<double>` (primitives need no adapter); startup now loads 4 boxes through
the same `concurrent(3)` pipeline.

**Implemented:** all of the above. New `logic/budgets.dart` + budgets card on
Dashboard with edit dialog and "Suggest from last 3 months" (evolve) action.
Tests: 34 passing (new `budgets_test.dart`; the float-noise test caught
`200 × 1.1` ceiling up a full $10 step — fixed by rounding to cents first).
`flutter analyze` clean.

### Round 2 — done

**Feedbacks (10):**
1. `FX` — `spentByCategory` rebuilt its result map with a raw map
   comprehension. → fixed: `fromEntries(fx(...).map(...))`.
2. `FX` — `suggestedBudgets` did the same for the averages map. → fixed with
   `fromEntries` too.
3. `UX` — the month-over-month table gave no hint that the newest row is a
   partial month, making the red "spending down" arrow misleading. → fixed:
   "· in progress" marker on the current month.
4. `UX` — no way to get data out of the demo. → fixed via CSV export feature.
5. `UX` — Insights had numbers but no at-a-glance shape of the month. → fixed
   via the heatmap feature.
6. `PERF` — summaries recompute on every rebuild (carried from R1). → still
   deferred; `memoize` is Round 3's headline.
7. `CORRECT` — verified `duePartition` uses *today* (not the viewed month) on
   purpose: due-ness is about now. Documented here as intended behavior.
8. `DX` — `heatmap` needed the calendar grid; reusing `monthGrid` keeps one
   source of truth for week layout (no second grid implementation).
9. `DX` — export columns are a single `csvColumns` const shared by header and
   `pick`, so the header can never drift from the row shape.
10. `UX` — heatmap cells needed hover tooltips with day + amount to be
    readable (added).

**Features suggested (3):**
- B. **Weekly spending heatmap** — `fork` (one filtered walk feeds two
  aggregations), `groupBy` → `fold`, grid reuse of `range` → `chunk(7)`.
  ← *chosen*
- D. **CSV export to clipboard** — `sortBy` → `map` → `pick` → `join`,
  `prepend` for the header row. ← *chosen*
- E. **Recent activity feed** — `takeRight` / `reverse` / `slice` over
  date-sorted entries. Deferred to Round 3/4.

**Strategy:** pipeline-first. Heatmap: one lazy `filter` source consumed via
two `fork()`s — per-day `groupBy`→`fold` and month `sum` — proving the source
is walked once; cells normalize against `max`. CSV: entry → full map, `pick`
keeps `csvColumns`, escape → `join(',')`, header `prepend`ed. Fix FX 1–2 with
`fromEntries`, UX 3 marker, tooltips.

**Implemented:** all of the above. New `logic/heatmap.dart`, `logic/export.dart`;
heatmap card on Insights, Export CSV button on Entries (copies the currently
filtered list). Tests: 40 passing (`heatmap_test.dart`, `export_test.dart`).
`flutter analyze` clean.

### Round 3 — done

**Feedbacks (10):**
1. `PERF` — (carried twice) summaries recomputed on every rebuild. → fixed:
   `logic/cached.dart` with **nested `memoize`** — outer keyed by the entries
   list *instance* (state swaps the list on every change, so identity is a
   correct key), inner keyed by month. Rebuild = cache hit, data change =
   natural miss.
2. `PERF` — the heatmap's fork pipelines re-ran per Insights rebuild. → fixed:
   `cachedHeatmap` same pattern.
3. `CORRECT` — double-clicking "Reset demo data" started two overlapping
   reseeds (racing `clear()`/`putAll()`). → fixed: fxdart `throttle` (leading
   edge only, 3s) around the button.
4. `CORRECT` — the entry form accepted `0` and negative amounts; a negative
   expense silently *flips into income* via `signedAmount`. → fixed:
   validator requires > 0.
5. `CORRECT` — "Export CSV" exported search+type-filtered entries from **all**
   months while the list shows only the viewed month — the copy didn't match
   the screen. → fixed: exports exactly the visible (month-scoped) rows.
6. `UX` — dashboard had no at-a-glance numbers. → fixed via quick-stats strip.
7. `UX` — no recent-activity view (deferred feature E). → fixed this round.
8. `UX` — sparkline had no scale context. → fixed: starts/ends balance labels
   under the chart.
9. `DX` — memoize caches are unbounded (superseded lists keep inner caches
   alive); acceptable for an app session, documented in `cached.dart` rather
   than hidden.
10. `FX` — quick stats were the textbook `juxt` shape (a list of stat
    functions over one input) — implemented that way instead of four separate
    walks of the widget code.

**Features suggested (3):**
- E. **Recent activity feed** — `sortBy` → `takeRight(8)` → `reverse`.
  ← *chosen*
- F. **Quick stats strip** — `juxt` over the month slice: biggest expense,
  busiest day (`countBy` → `sortBy` → `head`), avg daily spend, open due
  items. ← *chosen*
- G. **Tag explorer** — pick a tag, see spending overlap between months via
  `intersection` / `difference`, `pluck`. Deferred to Round 4.

**Strategy:** pipeline-first. Cache layer as composition (`memoize` ∘
`memoize`) rather than hand-rolled maps; `juxt` list where each stat is one
lambda; recent feed as a 3-operator chain; throttle wraps the existing reseed
without touching state code.

**Implemented:** all of the above. New `logic/cached.dart`, `logic/stats.dart`;
quick stats + recent activity cards on Dashboard; throttled reseed; amount
validation; WYSIWYG export. Tests: 45 passing (`stats_test.dart` includes an
`identical()` proof that the memoize cache hits). `flutter analyze` clean.

### Round 4 — done

**Feedbacks (10):**
1. `CORRECT` — the Tags card counted **all time** but sat next to
   month-scoped cards with no label, implying month scope. → fixed: titled
   "Tags (all time)".
2. `UX` — tag chips looked tappable but were dead UI. → fixed: chips now
   select a tag and open the Tag explorer.
3. `UX` — deleting an entry was instant and irreversible. → fixed: snackbar
   with Undo (re-upserts the held Entry object).
4. `FX` — the dynamic `pipe` — the FxTS-parity API the library keeps on
   purpose — was showcased nowhere. → fixed: the About dialog runs a live
   `pipe([filter, map, sum])` over the ledger and shows code + result.
5. `FX` — `pluck`/`compact` unused. → fixed: tag spend maps non-spending
   entries to a null amount, then `compact(pluck('amount'))` → `sum`.
6. `PERF` — `quickStats` was the one dashboard pipeline left uncached.
   → fixed: `cachedQuickStats` joins the nested-memoize family.
7. `DX` — the example's README was still the flutter-create boilerplate.
   → fixed: rewritten as an operator tour + pointers into `logic/`.
8. `UX` — no in-app explanation of what the demo *is*. → fixed: About dialog
   reachable from the top bar.
9. `CORRECT` — checked `intersection`/`difference` semantics on duplicate
   tags: both dedupe their output per the library contract, which is exactly
   right for tag *sets*. No change needed — noted so future rounds don't
   "fix" it.
10. `DX` — coverage table closed out: `omit`, `slice`, `cycle`, `tap`,
    `scan1`, `repeat` are declared intentionally uncovered — no natural fit
    in this app, and forcing them would violate principle #3 (readable over
    clever).

**Features suggested (3):**
- G. **Tag explorer** — month-over-month tag set algebra
  (`intersection` / `difference` both directions) + per-tag spend
  (`compact(pluck)` → `sum`). ← *chosen*
- H. **About dialog with a live `pipe`** — documentation-as-feature for the
  FxTS parity API. ← *chosen*
- I. **CSV import** — parse pasted CSV back into entries (`map`, `zip` with
  the header, `compact` for bad rows). Left on the table for a future round.

**Strategy:** pipeline-first as always: `compareTagMonths` is two
`flatMap` → `uniq` tag sets fed into `intersection` + both `difference`
directions; `tagSpend` is the `pluck`/`compact` chain; the About dialog uses
`pipe` verbatim so the displayed snippet is the code that ran.

**Implemented:** all of the above. New `logic/tags.dart`; Tag explorer card on
Insights; About dialog; Undo delete; `cachedQuickStats`; README rewrite.
Tests: 49 passing (`tags_test.dart`). `flutter analyze` clean;
`flutter build web` compiles.

## Final state (after 4 rounds)

- 4 screens · 12 pipeline-named cards · 8 `logic/` modules, all pure and
  unit-tested (49 tests) · zero state-management or data deps beyond
  `hive_ce` + `fxdart`.
- 45+ distinct fxdart operators demonstrated in context (see coverage table).
- Deployment to `docs/ledger/` on GitHub Pages remains the deliberately
  deferred next step (renderer choice + build_docs/deploy.sh clobber check).
