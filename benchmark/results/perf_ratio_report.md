# DartComparison: slowest to fastest ratio

Machine: Apple M1 Max, 32GB RAM, Dart 3.12.2, macos Version 26.3 (Build 25D125) (AOT (dart compile exe), enforced per result line)
Date: 2026-08-23 · Scale: `full` (headline N per case)

Ordered by FxDart/native, slowest first — so the rows worth acting on are at the top and the ordering does not change direction partway down. The Ratio column states each row's own verdict.

| Case | Path | N | Native (µs) | FxDart (µs) | Ratio |
|---|---|---:|---:|---:|---|
| Recent error messages, deduped | `benchmark/cases/recent-errors` | 1,000,000 | 10,350 | 13,705 | Native 1.32x faster |
| Monthly category report, sorted by spend | `benchmark/cases/monthly-category-report` | 1,000,000 | 11,298 | 14,495 | Native 1.28x faster |
| Live search over a keystroke stream | `benchmark/cases/live-search` | 100,000 | 45,186 | 56,022 | Native 1.24x faster |
| Rate-limited batch import | `benchmark/cases/rate-limited-import` | 100,000 | 130,963 | 157,739 | Native 1.20x faster |
| Enrich top merchants concurrently | `benchmark/cases/concurrent-enrichment` | 100,000 | 194,966 | 232,989 | Native 1.20x faster |
| Three consecutive readings over the limit | `benchmark/cases/consecutive-over-limit` | 1,000,000 | 17,065 | 20,315 | Native 1.19x faster |
| Diff two ledger snapshots | `benchmark/cases/ledger-diff` | 500,000 | 223,406 | 260,993 | Native 1.17x faster |
| Running account balance | `benchmark/cases/running-balance` | 1,000,000 | 237,775 | 275,067 | Native 1.16x faster |
| Poll a flaky API until first success | `benchmark/cases/flaky-api-retry` | 100,000 | 495,525 | 571,710 | Native 1.15x faster |
| Revalue the stock, three lookups at a time | `benchmark/cases/stock-revaluation` | 100,000 | 310,871 | 352,923 | Native 1.14x faster |
| Parallel downloads, results in order | `benchmark/cases/parallel-downloads` | 100,000 | 338,767 | 380,499 | Native 1.12x faster |
| Windowed alerts from a sensor stream | `benchmark/cases/stream-windowed-alerts` | 100,000 | 32,801 | 36,580 | Native 1.12x faster |
| Fetch profiles, two at a time | `benchmark/cases/bounded-concurrency` | 100,000 | 305,945 | 339,218 | Native 1.11x faster |
| Paginated product listing | `benchmark/cases/paginated-products` | 1,000,000 | 101,254 | 111,942 | Native 1.11x faster |
| Merchants in first-visit order | `benchmark/cases/first-visit-merchants` | 1,000,000 | 23,752 | 26,194 | Native 1.10x faster |
| Compound interest table | `benchmark/cases/compound-interest` | 1,000,000 | 221,723 | 244,461 | Native 1.10x faster |
| Two paged feeds, concatenated and deduped | `benchmark/cases/paged-feeds-dedupe` | 100,000 | 78,495 | 85,678 | Native 1.09x faster |
| Pair sensors with readings, keep anomalies | `benchmark/cases/sensor-anomalies` | 1,000,000 | 62,546 | 68,163 | Native 1.09x faster |
| Category with highest average expense | `benchmark/cases/top-category-average` | 1,000,000 | 60,453 | 64,596 | Native 1.07x faster |
| First sensor reading over the limit | `benchmark/cases/first-over-limit` | 1,000,000 | 4,952 | 5,224 | ~tie |
| Rank labels for a leaderboard | `benchmark/cases/rank-labels` | 1,000,000 | 200,130 | 210,735 | Native 1.05x faster |
| p50/p95 latency per endpoint | `benchmark/cases/latency-percentiles` | 1,000,000 | 204,682 | 209,743 | ~tie |
| Fetch 10 profiles, 3 at a time | `benchmark/cases/concurrent-profile-fetch` | 100,000 | 301,340 | 307,916 | ~tie |
| Load three remote configs in order | `benchmark/cases/sequential-configs` | 100,000 | 323,546 | 329,816 | ~tie |
| Finale — DailyLedger monthly close | `benchmark/cases/daily-ledger-close` | 20,000 | 1,179,092 | 1,192,216 | ~tie |
| Cohort retention table | `benchmark/cases/cohort-retention` | 1,000,000 | 717,631 | 722,793 | ~tie |
| Longest streak of no-spend days | `benchmark/cases/no-spend-streak` | 1,000,000 | 23,832 | 24,002 | ~tie |
| Concurrent price lookup with fallback | `benchmark/cases/price-lookup-fallback` | 100,000 | 351,267 | 353,207 | ~tie |
| Log alert digest by service and severity | `benchmark/cases/alert-digest` | 1,000,000 | 174,148 | 174,416 | ~tie |
| Detect duplicated transactions | `benchmark/cases/duplicate-transactions` | 1,000,000 | 977,438 | 966,122 | ~tie |
| Weekly averages from daily readings | `benchmark/cases/weekly-sensor-averages` | 999,999 | 49,117 | 48,450 | ~tie |
| Rank the month by category | `benchmark/cases/category-rank` | 1,000,000 | 33,166 | 32,126 | ~tie |
| Smoothed zone changes | `benchmark/cases/smoothed-zone-changes` | 1,000,000 | 39,409 | 37,410 | FxDart 1.05x faster |
| Refunds vs charges, both formatted | `benchmark/cases/refunds-vs-charges` | 1,000,000 | 253,321 | 235,918 | FxDart 1.07x faster |
| First 5 valid emails, normalized | `benchmark/cases/valid-emails` | 1,000,000 | 72,451 | 67,110 | FxDart 1.08x faster |
| Food spending this month | `benchmark/cases/food-spending` | 1,000,000 | 12,554 | 11,435 | FxDart 1.10x faster |
| Batch users into pages of 10 | `benchmark/cases/paginate-users` | 1,000,000 | 82,083 | 73,711 | FxDart 1.11x faster |
| Fill gaps in a sparse time series | `benchmark/cases/sparse-timeseries` | 1,000,000 | 57,304 | 51,161 | FxDart 1.12x faster |
| Leaderboard with tied ranks | `benchmark/cases/leaderboard-ties` | 1,000,000 | 533,811 | 470,687 | FxDart 1.13x faster |
| Anomalies with surrounding context | `benchmark/cases/anomaly-context` | 1,000,000 | 11,932 | 10,443 | FxDart 1.14x faster |
| Multi-currency expense report | `benchmark/cases/multi-currency-report` | 1,000,000 | 123,300 | 104,392 | FxDart 1.18x faster |
| Spending inside a date window | `benchmark/cases/date-window-spend` | 1,000,000 | 14,852 | 11,441 | FxDart 1.30x faster |
| All tags across posts, sorted | `benchmark/cases/unique-tags` | 1,000,000 | 106,922 | 77,818 | FxDart 1.37x faster |
| End-of-day settlement pipeline | `benchmark/cases/settlement-pipeline` | 100,000 | 48,934 | 30,701 | FxDart 1.59x faster |
| Categories over their monthly budget | `benchmark/cases/budget-alerts` | 1,000,000 | 21,518 | 12,954 | FxDart 1.66x faster |
| Price drops between two snapshots | `benchmark/cases/price-drop-detection` | 1,000,000 | 1,160,477 | 640,680 | FxDart 1.81x faster |
| Top 5 merchants by total spend | `benchmark/cases/top-merchants` | 1,000,000 | 116,769 | 63,374 | FxDart 1.84x faster |
| Line items to invoice summary | `benchmark/cases/invoice-summary` | 1,000,000 | 25,325 | 13,623 | FxDart 1.86x faster |
| Average order value over $100 | `benchmark/cases/average-basket` | 1,000,000 | 17,331 | 8,790 | FxDart 1.97x faster |
| Most frequent log level | `benchmark/cases/top-log-level` | 1,000,000 | 44,788 | 19,704 | FxDart 2.27x faster |
| Top 3 largest expenses | `benchmark/cases/top-expenses` | 1,000,000 | 503,939 | 189,687 | FxDart 2.66x faster |
| Full monthly ledger report | `benchmark/cases/monthly-ledger-report` | 1,000,000 | 135,112 | 47,285 | FxDart 2.86x faster |
| Inventory restock plan | `benchmark/cases/restock-plan` | 1,000,000 | 216,181 | 51,924 | FxDart 4.16x faster |
