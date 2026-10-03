# Daily Ledger — an fxdart showcase (Flutter web)

A budget book + planner in one app. One `Entry` model covers expenses,
income, bills, and tasks — so every screen is a data-aggregation problem,
and **every aggregation is an [fxdart](../../) pipeline**. Each card's
subtitle names the operators it runs, and the **?** beside any formula
opens a dialog that walks the pipeline step by step **with the live
numbers on screen**.

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
  `fxRange` → `flatMap`, seeded `fxShuffle`.
- `lib/ui/widgets.dart` — the pipeline explainer (`PipelineExplanation` /
  `showPipelineDialog`): the "?" dialogs are built from closures over the
  same pipeline outputs the cards render, so their numbers can never drift.
- `plan.md` — the build plan plus nine evaluate → suggest → strategize →
  implement iteration rounds, including the operator coverage table. Rounds
  5–8 each **added an operator to fxdart itself** (`maxBy`/`minBy`,
  `sumBy`, `averageBy`) when the app exposed a gap.

## Operator tour (highlights)

| Where | Pipeline |
| ----- | -------- |
| Running balance sparkline | `sortBy(date)` → `scan(sum)` |
| Cashflow forecast | `fxConcat(actual, projected)` → `sortBy` → `scan` — history and future through one pipeline |
| Calendar grid | `fxRange(42)` → `map` → `chunk(7)` |
| Due & overdue panel | `filter` → `sortBy` → `partition` |
| Budgets | `groupBy` → `sumBy`; suggestions via `fxEvolve` |
| Heatmap | one `filter` source, two `fxFork()`s → `groupBy`/`sumBy` + `sumBy` |
| Weekday profile | `groupBy(day)` → `sumBy`, then `groupBy(weekday)` → `averageBy` |
| Quick stats | `fxJuxt` over the month slice; biggest expense via `maxBy` |
| Duplicates | `uniqBy` + `difference` |
| Tag explorer | `intersection` / `difference`; `fxCompact(fxPluck(...))` → `sum` |
| CSV export | `sortBy` → `map` → `fxPick` → `join`, header `prepend`ed |
| CSV import | `fxSplit` → `zipWithIndex` → `map(parse)` → `fxCompact` ×2; per row `zip(header, cells)` → `fxFromEntries` |
| Search / reset / import preview | `debounce` / `throttle` / `debounce` |
| Caching | nested `fxMemoize` keyed by list identity (+ month, + rules, + `(month, today)` records) |
| About dialog | the dynamic `pipe` (FxTS parity), run live |
