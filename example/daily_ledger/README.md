# Daily Ledger — an fxdart showcase (Flutter web)

A budget book + planner in one app. One `Entry` model covers expenses,
income, bills, and tasks — so every screen is a data-aggregation problem,
and **every aggregation is an [fxdart](../../) pipeline**. Each card's
subtitle names the operators it runs.

```bash
flutter run -d chrome     # from example/daily_ledger/
flutter test              # pure-Dart tests for the logic/ pipelines
```

## Where to look

- `lib/logic/` — the point of the example: pure functions from `List<Entry>`
  to view data, each one an fxdart pipeline, each unit-tested. The UI never
  computes.
- `lib/data/ledger_repository.dart` — hive_ce (IndexedDB on web) as a "dumb
  shelf"; startup loads 4 boxes through `toAsync().map(read).concurrent(3)`.
- `lib/data/seed.dart` — deterministic fixtures via `createSeededRandom`,
  `range` → `flatMap`, seeded `shuffle`.
- `plan.md` — the build plan plus the four evaluate → suggest → strategize →
  implement iteration rounds, including the operator coverage table.

## Operator tour (highlights)

| Where | Pipeline |
| ----- | -------- |
| Running balance sparkline | `sortBy(date)` → `scan(sum)` |
| Calendar grid | `range(42)` → `map` → `chunk(7)` |
| Due & overdue panel | `filter` → `sortBy` → `partition` |
| Budgets | `groupBy` → `fold`; suggestions via `evolve` |
| Heatmap | one `filter` source, two `fork()`s → `groupBy`/`fold` + `sum` |
| Quick stats | `juxt` over the month slice |
| Duplicates | `uniqBy` + `difference` |
| Tag explorer | `intersection` / `difference`; `compact(pluck(...))` → `sum` |
| CSV export | `sortBy` → `map` → `pick` → `join`, header `prepend`ed |
| Search / reset | `debounce` / `throttle` |
| Caching | nested `memoize` keyed by list identity + month |
| About dialog | the dynamic `pipe` (FxTS parity), run live |
