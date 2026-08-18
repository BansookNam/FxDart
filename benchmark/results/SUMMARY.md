# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-18
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 19 µs | 5.9 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.4 µs | 1.9 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 3 | sequential-configs (async) | 100 | 334 µs | 314 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 4 | average-basket | 100 | 1.9 µs | 774 ns | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 5 | paginate-users | 100 | 7.3 µs | 6.4 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 6 | rank-labels | 100 | 14 µs | 14 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 7 | running-balance | 100 | 20 µs | 22 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 8 | food-spending | 100 | 1.1 µs | 792 ns | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.4 µs | 1.6 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 10 | first-over-limit | 100 | 919 ns | 950 ns | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 11 | top-merchants | 100 | 23 µs | 136 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 12 | unique-tags | 100 | 55 µs | 49 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 22 µs | 20 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 14 | valid-emails | 100 | 4.9 µs | 4.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100 | 322 µs | 400 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 16 | compound-interest | 100 | 19 µs | 20 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 17 | top-category-average | 100 | 6.9 µs | 6.8 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 18 | date-window-spend | 100 | 1.7 µs | 1.4 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 19 | sensor-anomalies | 100 | 5.6 µs | 6.9 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 20 | recent-errors | 100 | 1.0 µs | 1.3 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 21 | duplicate-transactions | 100 | 38 µs | 40 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 3.7 µs | 5.0 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 192 µs | 233 µs | **tie** | 16.6 MB | 16.8 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 21 µs | 29 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 25 | weekly-sensor-averages | 98 | 3.7 µs | 4.4 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 26 | paginated-products | 100 | 5.9 µs | 7.2 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 27 | invoice-summary | 100 | 3.9 µs | 8.4 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.2 µs | 3.3 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.1 µs | 5.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 100 | 1.7 µs | 2.8 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 10 µs | 11 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 32 | restock-plan | 100 | 11 µs | 9.7 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 33 | price-lookup-fallback (async) | 100 | 356 µs | 380 µs | **tie** | 16.5 MB | 16.9 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 20 µs | 29 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 27 µs | 29 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 349 µs | 433 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 37 | ledger-diff | 100 | 20 µs | 24 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 487 µs | 650 µs | **tie** | 16.8 MB | 17.1 MB | tie | 3 |
| 39 | alert-digest | 100 | 20 µs | 24 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 16 µs | 18 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 79 µs | 93 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.4 µs | 1.5 µs | **tie** | 17.1 MB | 16.6 MB | tie | 3 |
| 43 | smoothed-zone-changes | 100 | 1.8 µs | 4.3 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 31 µs | 38 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 45 | live-search (async) | 100 | 50 µs | 71 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 143 µs | 169 µs | **tie** | 16.5 MB | 16.8 MB | tie | 3 |
| 47 | category-rank | 100 | 3.6 µs | 12 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 321 µs | 398 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 274 µs | 326 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 50 | cohort-retention | 100 | 39 µs | 35 µs | **tie** | 17.0 MB | 16.6 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 100 | 347 µs | 455 µs | **tie** | 16.7 MB | 17.2 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 28 µs | 33 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 49 µs | 36 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.43 ms | 961 µs | **fxdart** | 23.2 MB | 22.0 MB | fxdart | 3 |
| 2 | top-log-level | 10000 | 339 µs | 192 µs | **tie** | 20.0 MB | 14.2 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 31.2 ms | 31.2 ms | **tie** | 50.6 MB | 50.8 MB | tie | 3 |
| 4 | average-basket | 10000 | 181 µs | 83 µs | **tie** | 19.1 MB | 15.3 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 751 µs | 663 µs | **tie** | 22.8 MB | 23.4 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.67 ms | 1.74 ms | **tie** | 34.7 MB | 37.8 MB | native | 3 |
| 7 | running-balance | 10000 | 1.99 ms | 2.23 ms | **tie** | 24.0 MB | 23.6 MB | tie | 3 |
| 8 | food-spending | 10000 | 123 µs | 95 µs | **tie** | 16.9 MB | 15.6 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 147 µs | 173 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 10 | first-over-limit | 10000 | 53 µs | 57 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 11 | top-merchants | 10000 | 676 µs | 579 µs | **tie** | 23.0 MB | 23.6 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.27 ms | 990 µs | **tie** | 20.7 MB | 23.3 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.24 ms | 2.03 ms | **tie** | 23.4 MB | 22.9 MB | tie | 3 |
| 14 | valid-emails | 10000 | 556 µs | 520 µs | **tie** | 20.0 MB | 20.1 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 10000 | 31.1 ms | 35.7 ms | **native** | 26.2 MB | 22.3 MB | fxdart | 3 |
| 16 | compound-interest | 10000 | 1.90 ms | 2.15 ms | **tie** | 22.7 MB | 22.9 MB | tie | 3 |
| 17 | top-category-average | 10000 | 356 µs | 355 µs | **tie** | 23.0 MB | 22.9 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 150 µs | 112 µs | **tie** | 20.9 MB | 15.6 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 532 µs | 623 µs | **tie** | 22.7 MB | 23.7 MB | tie | 3 |
| 20 | recent-errors | 10000 | 88 µs | 121 µs | **tie** | 15.8 MB | 15.9 MB | tie | 3 |
| 21 | duplicate-transactions | 10000 | 4.04 ms | 3.97 ms | **tie** | 40.3 MB | 36.1 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 265 µs | 262 µs | **tie** | 19.7 MB | 19.6 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 18.0 ms | 20.9 ms | **native** | 49.3 MB | 50.0 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.32 ms | 2.87 ms | **tie** | 23.4 MB | 25.3 MB | native | 3 |
| 25 | weekly-sensor-averages | 9996 | 398 µs | 448 µs | **tie** | 22.7 MB | 22.7 MB | tie | 3 |
| 26 | paginated-products | 10000 | 865 µs | 857 µs | **tie** | 17.6 MB | 20.8 MB | native | 3 |
| 27 | invoice-summary | 10000 | 239 µs | 111 µs | **tie** | 22.4 MB | 15.7 MB | fxdart | 3 |
| 28 | budget-alerts | 10000 | 178 µs | 87 µs | **tie** | 21.7 MB | 15.7 MB | fxdart | 3 |
| 29 | monthly-category-report | 10000 | 107 µs | 138 µs | **tie** | 17.0 MB | 15.9 MB | fxdart | 3 |
| 30 | consecutive-over-limit | 10000 | 113 µs | 202 µs | **tie** | 20.9 MB | 23.5 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 726 µs | 709 µs | **tie** | 23.5 MB | 22.9 MB | tie | 3 |
| 32 | restock-plan | 10000 | 1.32 ms | 1.18 ms | **tie** | 17.6 MB | 20.2 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 36.8 ms | 35.9 ms | **tie** | 49.0 MB | 30.8 MB | fxdart | 5 |
| 34 | monthly-ledger-report | 10000 | 895 µs | 413 µs | **tie** | 22.9 MB | 17.2 MB | fxdart | 3 |
| 35 | sparse-timeseries | 10000 | 474 µs | 452 µs | **tie** | 23.0 MB | 20.2 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 33.3 ms | 38.8 ms | **native** | 50.8 MB | 33.1 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.46 ms | 3.24 ms | **native** | 26.1 MB | 31.2 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 49.9 ms | 62.4 ms | **native** | 29.2 MB | 24.7 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.37 ms | 1.40 ms | **tie** | 17.9 MB | 18.0 MB | tie | 3 |
| 40 | latency-percentiles | 10000 | 1.86 ms | 1.74 ms | **tie** | 18.1 MB | 17.2 MB | fxdart | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 8.16 ms | 8.62 ms | **tie** | 43.0 MB | 24.2 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 98 µs | 92 µs | **tie** | 18.4 MB | 19.0 MB | tie | 3 |
| 43 | smoothed-zone-changes | 10000 | 186 µs | 414 µs | **tie** | 22.0 MB | 22.8 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.07 ms | 3.53 ms | **tie** | 23.6 MB | 24.9 MB | native | 3 |
| 45 | live-search (async) | 10000 | 4.40 ms | 5.75 ms | **native** | 23.0 MB | 23.8 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 13.1 ms | 15.4 ms | **native** | 23.6 MB | 27.9 MB | native | 3 |
| 47 | category-rank | 10000 | 288 µs | 289 µs | **tie** | 17.4 MB | 17.9 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 32.5 ms | 35.4 ms | **native** | 49.0 MB | 31.3 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 28.2 ms | 30.2 ms | **native** | 50.8 MB | 31.9 MB | fxdart | 3 |
| 50 | cohort-retention | 10000 | 2.31 ms | 2.09 ms | **tie** | 18.0 MB | 17.7 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 10000 | 324.1 ms | 329.8 ms | **tie** | 49.9 MB | 50.3 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 4.17 ms | 3.03 ms | **fxdart** | 23.1 MB | 23.9 MB | tie | 3 |
| 53 | price-drop-detection | 10000 | 6.99 ms | 3.77 ms | **fxdart** | 37.1 MB | 34.5 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 519.2 ms | 216.0 ms | **fxdart** | 123.9 MB | 139.0 MB | native | 3 |
| 2 | top-log-level | 1000000 | 46.6 ms | 20.0 ms | **fxdart** | 89.2 MB | 44.9 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 330.3 ms | 326.7 ms | **tie** | 83.0 MB | 82.1 MB | tie | 5 |
| 4 | average-basket | 1000000 | 17.3 ms | 8.72 ms | **fxdart** | 75.2 MB | 72.9 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 84.0 ms | 79.9 ms | **fxdart** | 123.2 MB | 125.1 MB | tie | 4 |
| 6 | rank-labels | 1000000 | 214.3 ms | 240.9 ms | **native** | 241.2 MB | 223.1 MB | fxdart | 3 |
| 7 | running-balance | 1000000 | 240.7 ms | 271.9 ms | **native** | 186.4 MB | 185.6 MB | tie | 3 |
| 8 | food-spending | 1000000 | 12.3 ms | 11.2 ms | **fxdart** | 90.8 MB | 85.0 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 25.4 ms | 27.1 ms | **native** | 116.2 MB | 115.9 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 4.97 ms | 5.25 ms | **tie** | 117.2 MB | 117.5 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 122.8 ms | 63.9 ms | **fxdart** | 137.9 MB | 118.6 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 112.1 ms | 80.0 ms | **fxdart** | 161.2 MB | 161.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 270.5 ms | 238.2 ms | **fxdart** | 180.9 MB | 179.2 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 70.0 ms | 66.6 ms | **fxdart** | 175.7 MB | 174.8 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100000 | 325.6 ms | 370.6 ms | **native** | 49.3 MB | 50.4 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 221.9 ms | 244.3 ms | **native** | 129.0 MB | 126.6 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 61.5 ms | 62.4 ms | **tie** | 133.3 MB | 131.6 MB | tie | 5 |
| 18 | date-window-spend | 1000000 | 14.9 ms | 11.5 ms | **fxdart** | 123.3 MB | 119.8 MB | tie | 3 |
| 19 | sensor-anomalies | 1000000 | 67.3 ms | 76.2 ms | **native** | 170.0 MB | 156.5 MB | fxdart | 3 |
| 20 | recent-errors | 1000000 | 10.6 ms | 14.4 ms | **native** | 113.9 MB | 113.8 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 1015.5 ms | 986.1 ms | **tie** | 323.3 MB | 332.5 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 23.7 ms | 24.3 ms | **tie** | 105.3 MB | 106.3 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100000 | 203.7 ms | 237.4 ms | **native** | 81.6 MB | 81.5 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 536.3 ms | 653.9 ms | **native** | 234.7 MB | 293.2 MB | native | 3 |
| 25 | weekly-sensor-averages | 999999 | 48.4 ms | 54.1 ms | **native** | 99.2 MB | 107.3 MB | native | 3 |
| 26 | paginated-products | 1000000 | 102.7 ms | 131.9 ms | **native** | 177.8 MB | 207.0 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 24.9 ms | 13.7 ms | **fxdart** | 89.5 MB | 88.4 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.6 ms | 13.0 ms | **fxdart** | 90.1 MB | 82.7 MB | fxdart | 3 |
| 29 | monthly-category-report | 1000000 | 11.4 ms | 14.6 ms | **native** | 119.5 MB | 119.4 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 16.7 ms | 22.5 ms | **native** | 150.2 MB | 149.3 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 128.4 ms | 118.0 ms | **fxdart** | 203.7 MB | 214.3 MB | native | 3 |
| 32 | restock-plan | 1000000 | 214.9 ms | 208.9 ms | **tie** | 173.5 MB | 189.7 MB | native | 5 |
| 33 | price-lookup-fallback (async) | 100000 | 361.9 ms | 366.8 ms | **tie** | 81.0 MB | 80.9 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 142.2 ms | 47.3 ms | **fxdart** | 167.4 MB | 127.1 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 51.0 ms | 54.0 ms | **native** | 125.0 MB | 144.4 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 343.2 ms | 403.2 ms | **native** | 80.7 MB | 123.4 MB | native | 3 |
| 37 | ledger-diff | 500000 | 224.4 ms | 276.2 ms | **native** | 176.7 MB | 171.8 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100000 | 494.8 ms | 628.3 ms | **native** | 56.2 MB | 50.3 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 168.6 ms | 168.7 ms | **tie** | 126.0 MB | 239.5 MB | native | 3 |
| 40 | latency-percentiles | 1000000 | 197.5 ms | 200.9 ms | **tie** | 138.4 MB | 192.0 MB | native | 5 |
| 41 | paged-feeds-dedupe (async) | 100000 | 80.8 ms | 89.2 ms | **native** | 74.0 MB | 73.9 MB | tie | 3 |
| 42 | anomaly-context | 1000000 | 11.4 ms | 10.3 ms | **fxdart** | 132.3 MB | 131.8 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 39.7 ms | 37.8 ms | **fxdart** | 232.8 MB | 82.0 MB | fxdart | 3 |
| 44 | stream-windowed-alerts (async) | 100000 | 32.0 ms | 35.9 ms | **native** | 74.9 MB | 74.6 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 45.1 ms | 61.0 ms | **native** | 53.1 MB | 57.8 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 132.4 ms | 159.5 ms | **native** | 76.3 MB | 79.7 MB | tie | 3 |
| 47 | category-rank | 1000000 | 34.2 ms | 33.0 ms | **tie** | 147.1 MB | 147.9 MB | tie | 5 |
| 48 | stock-revaluation (async) | 100000 | 312.3 ms | 348.8 ms | **native** | 80.8 MB | 80.6 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 302.2 ms | 318.0 ms | **native** | 80.0 MB | 80.1 MB | tie | 3 |
| 50 | cohort-retention | 1000000 | 609.6 ms | 649.5 ms | **native** | 238.6 MB | 239.4 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 20000 | 1190.6 ms | 1201.0 ms | **tie** | 53.1 MB | 54.6 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 51.9 ms | 31.6 ms | **fxdart** | 56.1 MB | 58.2 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1161.7 ms | 652.3 ms | **fxdart** | 393.8 MB | 445.2 MB | native | 3 |
