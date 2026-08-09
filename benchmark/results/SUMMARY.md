# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-09
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 19 µs | 6.4 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.8 µs | 3.2 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 3 | sequential-configs (async) | 100 | 375 µs | 343 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 4 | average-basket | 100 | 1.9 µs | 1.1 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 5 | paginate-users | 100 | 7.5 µs | 7.0 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 6 | rank-labels | 100 | 15 µs | 15 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 7 | running-balance | 100 | 20 µs | 23 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 8 | food-spending | 100 | 1.1 µs | 1.0 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.4 µs | 2.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 10 | first-over-limit | 100 | 961 ns | 972 ns | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 11 | top-merchants | 100 | 25 µs | 143 µs | **tie** | 17.0 MB | 17.2 MB | tie | 3 |
| 12 | unique-tags | 100 | 55 µs | 48 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 22 µs | 19 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 14 | valid-emails | 100 | 5.0 µs | 4.9 µs | **tie** | 16.3 MB | 16.4 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100 | 335 µs | 387 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 16 | compound-interest | 100 | 19 µs | 21 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 17 | top-category-average | 100 | 7.9 µs | 7.8 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 18 | date-window-spend | 100 | 1.8 µs | 1.5 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 19 | sensor-anomalies | 100 | 5.9 µs | 7.4 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 20 | recent-errors | 100 | 1.1 µs | 2.0 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 21 | duplicate-transactions | 100 | 41 µs | 42 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 4.3 µs | 5.4 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 201 µs | 246 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 21 µs | 30 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 25 | weekly-sensor-averages | 98 | 3.8 µs | 5.1 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 26 | paginated-products | 100 | 6.1 µs | 6.8 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 27 | invoice-summary | 100 | 4.1 µs | 9.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.4 µs | 4.9 µs | **tie** | 17.0 MB | 16.6 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.1 µs | 6.0 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 100 | 1.8 µs | 2.8 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 35 µs | 77 µs | **tie** | 16.7 MB | 16.2 MB | tie | 3 |
| 32 | restock-plan | 100 | 11 µs | 9.1 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 33 | price-lookup-fallback (async) | 100 | 452 µs | 409 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 22 µs | 31 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 30 µs | 32 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 393 µs | 463 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 37 | ledger-diff | 100 | 22 µs | 31 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 515 µs | 795 µs | **tie** | 16.4 MB | 17.0 MB | tie | 3 |
| 39 | alert-digest | 100 | 21 µs | 30 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 17 µs | 20 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 88 µs | 114 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.5 µs | 2.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 43 | smoothed-zone-changes | 100 | 1.9 µs | 4.1 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 35 µs | 57 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 45 | live-search (async) | 100 | 53 µs | 75 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 147 µs | 228 µs | **tie** | 16.4 MB | 17.3 MB | native | 3 |
| 47 | category-rank | 100 | 3.9 µs | 16 µs | **tie** | 16.4 MB | 16.0 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 336 µs | 403 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 314 µs | 328 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 50 | cohort-retention | 100 | 41 µs | 43 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 100 | 397 µs | 467 µs | **tie** | 16.6 MB | 17.1 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 32 µs | 34 µs | **tie** | 16.6 MB | 16.8 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 51 µs | 36 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.31 ms | 929 µs | **fxdart** | 23.1 MB | 22.0 MB | tie | 3 |
| 2 | top-log-level | 10000 | 351 µs | 316 µs | **tie** | 18.8 MB | 14.2 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 31.9 ms | 32.2 ms | **tie** | 50.6 MB | 50.4 MB | tie | 3 |
| 4 | average-basket | 10000 | 186 µs | 103 µs | **tie** | 19.1 MB | 15.3 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 770 µs | 663 µs | **tie** | 22.9 MB | 23.4 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.59 ms | 1.67 ms | **tie** | 34.8 MB | 37.7 MB | native | 3 |
| 7 | running-balance | 10000 | 1.91 ms | 2.06 ms | **tie** | 24.0 MB | 23.6 MB | tie | 3 |
| 8 | food-spending | 10000 | 128 µs | 129 µs | **tie** | 16.9 MB | 15.5 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 147 µs | 280 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 10 | first-over-limit | 10000 | 53 µs | 57 µs | **tie** | 15.3 MB | 15.4 MB | tie | 3 |
| 11 | top-merchants | 10000 | 707 µs | 605 µs | **tie** | 23.5 MB | 23.6 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.22 ms | 971 µs | **tie** | 20.6 MB | 23.2 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.14 ms | 1.85 ms | **tie** | 23.3 MB | 22.9 MB | tie | 3 |
| 14 | valid-emails | 10000 | 549 µs | 525 µs | **tie** | 19.9 MB | 20.0 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 10000 | 31.3 ms | 35.5 ms | **native** | 26.0 MB | 22.3 MB | fxdart | 3 |
| 16 | compound-interest | 10000 | 1.91 ms | 2.15 ms | **tie** | 22.6 MB | 22.8 MB | tie | 3 |
| 17 | top-category-average | 10000 | 350 µs | 355 µs | **tie** | 22.8 MB | 22.9 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 151 µs | 112 µs | **tie** | 20.8 MB | 15.6 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 532 µs | 629 µs | **tie** | 23.5 MB | 23.7 MB | tie | 3 |
| 20 | recent-errors | 10000 | 91 µs | 154 µs | **tie** | 15.8 MB | 15.8 MB | tie | 3 |
| 21 | duplicate-transactions | 10000 | 4.04 ms | 3.95 ms | **tie** | 40.2 MB | 36.0 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 258 µs | 265 µs | **tie** | 19.6 MB | 19.6 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 18.5 ms | 23.0 ms | **native** | 49.3 MB | 50.3 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.32 ms | 3.01 ms | **native** | 23.5 MB | 25.3 MB | native | 3 |
| 25 | weekly-sensor-averages | 9996 | 400 µs | 466 µs | **tie** | 22.7 MB | 22.7 MB | tie | 3 |
| 26 | paginated-products | 10000 | 817 µs | 829 µs | **tie** | 17.8 MB | 20.9 MB | native | 3 |
| 27 | invoice-summary | 10000 | 243 µs | 254 µs | **tie** | 22.4 MB | 19.0 MB | fxdart | 3 |
| 28 | budget-alerts | 10000 | 186 µs | 234 µs | **tie** | 21.8 MB | 19.6 MB | fxdart | 3 |
| 29 | monthly-category-report | 10000 | 106 µs | 172 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 30 | consecutive-over-limit | 10000 | 119 µs | 205 µs | **tie** | 20.6 MB | 23.6 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 2.66 ms | 6.14 ms | **native** | 22.0 MB | 19.1 MB | fxdart | 3 |
| 32 | restock-plan | 10000 | 1.24 ms | 1.10 ms | **tie** | 17.4 MB | 20.4 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 37.2 ms | 36.2 ms | **tie** | 49.1 MB | 30.9 MB | fxdart | 5 |
| 34 | monthly-ledger-report | 10000 | 913 µs | 673 µs | **tie** | 23.0 MB | 23.0 MB | tie | 3 |
| 35 | sparse-timeseries | 10000 | 470 µs | 446 µs | **tie** | 23.0 MB | 20.3 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 34.8 ms | 40.0 ms | **native** | 50.9 MB | 33.0 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.42 ms | 3.62 ms | **native** | 26.1 MB | 31.2 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 50.1 ms | 72.6 ms | **native** | 29.4 MB | 24.7 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.40 ms | 2.17 ms | **native** | 17.9 MB | 21.4 MB | native | 3 |
| 40 | latency-percentiles | 10000 | 1.85 ms | 2.13 ms | **tie** | 18.2 MB | 21.3 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 7.56 ms | 8.39 ms | **native** | 43.2 MB | 24.5 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 95 µs | 196 µs | **tie** | 18.3 MB | 23.0 MB | native | 3 |
| 43 | smoothed-zone-changes | 10000 | 173 µs | 410 µs | **tie** | 22.0 MB | 22.8 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.16 ms | 4.79 ms | **native** | 23.5 MB | 25.0 MB | native | 3 |
| 45 | live-search (async) | 10000 | 4.70 ms | 6.90 ms | **native** | 23.4 MB | 23.6 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 13.6 ms | 17.2 ms | **native** | 24.0 MB | 28.5 MB | native | 3 |
| 47 | category-rank | 10000 | 288 µs | 315 µs | **tie** | 17.2 MB | 17.9 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 31.0 ms | 36.7 ms | **native** | 48.9 MB | 30.8 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 29.9 ms | 31.9 ms | **native** | 51.8 MB | 32.0 MB | fxdart | 3 |
| 50 | cohort-retention | 10000 | 2.29 ms | 2.37 ms | **tie** | 17.9 MB | 18.1 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 10000 | 327.6 ms | 333.1 ms | **tie** | 49.9 MB | 50.3 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 4.78 ms | 3.37 ms | **fxdart** | 23.1 MB | 24.5 MB | native | 3 |
| 53 | price-drop-detection | 10000 | 7.14 ms | 3.82 ms | **fxdart** | 37.2 MB | 34.4 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 516.2 ms | 218.0 ms | **fxdart** | 125.4 MB | 136.2 MB | native | 3 |
| 2 | top-log-level | 1000000 | 46.8 ms | 31.7 ms | **fxdart** | 74.2 MB | 44.9 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 350.1 ms | 331.4 ms | **fxdart** | 83.2 MB | 82.0 MB | tie | 3 |
| 4 | average-basket | 1000000 | 17.4 ms | 10.2 ms | **fxdart** | 75.2 MB | 72.9 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 82.2 ms | 75.2 ms | **fxdart** | 122.7 MB | 126.7 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 208.5 ms | 215.4 ms | **tie** | 240.9 MB | 223.0 MB | fxdart | 5 |
| 7 | running-balance | 1000000 | 242.1 ms | 273.9 ms | **native** | 183.2 MB | 185.5 MB | tie | 3 |
| 8 | food-spending | 1000000 | 12.4 ms | 13.5 ms | **native** | 90.3 MB | 84.9 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 22.2 ms | 41.8 ms | **native** | 116.9 MB | 120.0 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 5.03 ms | 5.30 ms | **tie** | 117.0 MB | 117.3 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 125.6 ms | 61.2 ms | **fxdart** | 137.8 MB | 118.8 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 108.2 ms | 82.0 ms | **fxdart** | 161.7 MB | 161.9 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 252.8 ms | 229.4 ms | **fxdart** | 176.5 MB | 178.0 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 72.6 ms | 70.3 ms | **tie** | 174.4 MB | 175.1 MB | tie | 5 |
| 15 | bounded-concurrency (async) | 100000 | 312.4 ms | 356.3 ms | **native** | 49.2 MB | 50.4 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 222.6 ms | 247.2 ms | **native** | 127.9 MB | 127.8 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 66.2 ms | 65.9 ms | **tie** | 134.8 MB | 133.0 MB | tie | 4 |
| 18 | date-window-spend | 1000000 | 15.2 ms | 11.6 ms | **fxdart** | 125.8 MB | 119.7 MB | fxdart | 3 |
| 19 | sensor-anomalies | 1000000 | 64.5 ms | 73.9 ms | **native** | 162.8 MB | 155.3 MB | tie | 3 |
| 20 | recent-errors | 1000000 | 10.8 ms | 16.7 ms | **native** | 113.5 MB | 114.1 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 1012.8 ms | 1006.0 ms | **tie** | 323.4 MB | 332.6 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 24.1 ms | 24.8 ms | **tie** | 106.4 MB | 106.5 MB | tie | 5 |
| 23 | concurrent-enrichment (async) | 100000 | 204.1 ms | 261.4 ms | **native** | 81.4 MB | 81.5 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 555.0 ms | 666.8 ms | **native** | 232.5 MB | 235.9 MB | tie | 3 |
| 25 | weekly-sensor-averages | 999999 | 51.5 ms | 60.4 ms | **native** | 99.0 MB | 96.6 MB | tie | 3 |
| 26 | paginated-products | 1000000 | 103.0 ms | 128.4 ms | **native** | 177.8 MB | 208.1 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 25.1 ms | 27.4 ms | **native** | 89.2 MB | 90.1 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.7 ms | 27.7 ms | **native** | 90.3 MB | 90.1 MB | tie | 3 |
| 29 | monthly-category-report | 1000000 | 11.6 ms | 17.5 ms | **native** | 119.5 MB | 120.1 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 17.8 ms | 22.9 ms | **native** | 150.1 MB | 151.3 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 367.4 ms | 671.3 ms | **native** | 220.0 MB | 197.0 MB | fxdart | 3 |
| 32 | restock-plan | 1000000 | 221.9 ms | 208.4 ms | **fxdart** | 173.4 MB | 196.3 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 100000 | 387.9 ms | 372.3 ms | **tie** | 80.9 MB | 80.9 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 155.5 ms | 71.6 ms | **fxdart** | 166.4 MB | 120.1 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 59.1 ms | 49.0 ms | **fxdart** | 124.0 MB | 143.8 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 365.7 ms | 407.8 ms | **native** | 81.1 MB | 120.8 MB | native | 3 |
| 37 | ledger-diff | 500000 | 253.8 ms | 330.7 ms | **native** | 252.1 MB | 170.0 MB | fxdart | 3 |
| 38 | flaky-api-retry (async) | 100000 | 503.2 ms | 724.9 ms | **native** | 56.2 MB | 50.5 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 176.6 ms | 261.7 ms | **native** | 237.3 MB | 240.1 MB | tie | 3 |
| 40 | latency-percentiles | 1000000 | 211.1 ms | 281.8 ms | **native** | 189.8 MB | 209.9 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 100000 | 76.7 ms | 86.2 ms | **native** | 73.6 MB | 74.0 MB | tie | 3 |
| 42 | anomaly-context | 1000000 | 12.2 ms | 20.6 ms | **native** | 132.2 MB | 135.4 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 39.2 ms | 38.2 ms | **tie** | 245.0 MB | 82.0 MB | fxdart | 5 |
| 44 | stream-windowed-alerts (async) | 100000 | 32.4 ms | 48.5 ms | **native** | 74.7 MB | 75.7 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 48.4 ms | 70.5 ms | **native** | 52.8 MB | 59.1 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 134.7 ms | 176.4 ms | **native** | 76.3 MB | 80.6 MB | native | 3 |
| 47 | category-rank | 1000000 | 35.6 ms | 35.4 ms | **tie** | 146.8 MB | 147.7 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100000 | 314.1 ms | 364.6 ms | **native** | 80.9 MB | 80.6 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 333.0 ms | 335.7 ms | **tie** | 79.8 MB | 80.2 MB | tie | 5 |
| 50 | cohort-retention | 1000000 | 793.0 ms | 802.7 ms | **tie** | 238.6 MB | 238.7 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 20000 | 1206.0 ms | 1218.8 ms | **tie** | 53.1 MB | 54.8 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 52.4 ms | 33.9 ms | **fxdart** | 56.2 MB | 58.7 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1208.2 ms | 676.8 ms | **fxdart** | 393.7 MB | 445.4 MB | native | 3 |
