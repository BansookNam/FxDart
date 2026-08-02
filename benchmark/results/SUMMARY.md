# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-03
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 100 | 1.1 µs | 2.6 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 2 | running-balance | 100 | 20 µs | 24 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 3 | top-expenses | 100 | 19 µs | 11 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 4 | first-visit-merchants | 100 | 1.5 µs | 3.2 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 5 | average-basket | 100 | 2.0 µs | 2.6 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 6 | first-over-limit | 100 | 944 ns | 1.8 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 7 | top-log-level | 100 | 3.6 µs | 4.2 µs | **tie** | 16.5 MB | 16.2 MB | tie | 3 |
| 8 | paginate-users | 100 | 7.9 µs | 9.0 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 9 | rank-labels | 100 | 14 µs | 15 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 10 | sequential-configs (async) | 100 | 382 µs | 432 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 11 | top-merchants | 100 | 25 µs | 15 µs | **tie** | 17.1 MB | 17.1 MB | tie | 3 |
| 12 | recent-errors | 100 | 1.1 µs | 3.2 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 13 | date-window-spend | 100 | 1.8 µs | 2.8 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 14 | unique-tags | 100 | 52 µs | 46 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 15 | refunds-vs-charges | 100 | 23 µs | 22 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 16 | compound-interest | 100 | 19 µs | 20 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 17 | sensor-anomalies | 100 | 5.7 µs | 8.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 18 | top-category-average | 100 | 7.0 µs | 8.3 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 19 | valid-emails | 100 | 4.7 µs | 5.6 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 20 | bounded-concurrency (async) | 100 | 383 µs | 441 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 21 | monthly-category-report | 100 | 2.0 µs | 5.2 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 22 | paginated-products | 100 | 5.8 µs | 9.6 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 23 | weekly-sensor-averages | 98 | 4.0 µs | 6.5 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 24 | consecutive-over-limit | 100 | 1.8 µs | 9.1 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 25 | budget-alerts | 100 | 3.3 µs | 7.5 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 26 | leaderboard-ties | 100 | 22 µs | 32 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 27 | invoice-summary | 100 | 3.9 µs | 8.7 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 28 | no-spend-streak | 100 | 3.8 µs | 5.8 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 29 | duplicate-transactions | 100 | 41 µs | 41 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 30 | concurrent-enrichment (async) | 100 | 215 µs | 259 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 31 | monthly-ledger-report | 100 | 22 µs | 25 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 32 | cohort-retention | 100 | 41 µs | 46 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 33 | price-drop-detection | 100 | 51 µs | 37 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 34 | anomaly-context | 100 | 1.6 µs | 5.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 27 µs | 35 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 36 | multi-currency-report | 100 | 33 µs | 21 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 37 | restock-plan | 100 | 11 µs | 9.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 38 | alert-digest | 100 | 21 µs | 33 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 39 | latency-percentiles | 100 | 17 µs | 20 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 40 | ledger-diff | 100 | 21 µs | 30 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 41 | concurrent-profile-fetch (async) | 100 | 380 µs | 480 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 42 | flaky-api-retry (async) | 100 | 608 µs | 1.47 ms | **native** | 16.4 MB | 17.0 MB | tie | 3 |
| 43 | price-lookup-fallback (async) | 100 | 441 µs | 492 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 34 µs | 57 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 45 | rate-limited-import (async) | 100 | 188 µs | 285 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 46 | parallel-downloads (async) | 100 | 374 µs | 520 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 47 | paged-feeds-dedupe (async) | 100 | 94 µs | 176 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 48 | settlement-pipeline (async) | 100 | 33 µs | 45 µs | **tie** | 16.6 MB | 16.7 MB | tie | 3 |
| 49 | live-search (async) | 100 | 64 µs | 107 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 50 | daily-ledger-close (async) | 100 | 459 µs | 497 µs | **tie** | 16.7 MB | 17.3 MB | tie | 3 |
| 51 | category-rank | 100 | 3.7 µs | 9.2 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 52 | stock-revaluation (async) | 100 | 344 µs | 526 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 53 | smoothed-zone-changes | 100 | 2.1 µs | 6.9 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 10000 | 134 µs | 244 µs | **tie** | 16.8 MB | 16.9 MB | tie | 3 |
| 2 | running-balance | 10000 | 1.98 ms | 2.30 ms | **tie** | 24.0 MB | 23.5 MB | tie | 3 |
| 3 | top-expenses | 10000 | 3.25 ms | 1.87 ms | **fxdart** | 23.1 MB | 23.0 MB | tie | 3 |
| 4 | first-visit-merchants | 10000 | 149 µs | 366 µs | **tie** | 17.0 MB | 16.4 MB | tie | 3 |
| 5 | average-basket | 10000 | 183 µs | 241 µs | **tie** | 19.0 MB | 22.2 MB | native | 3 |
| 6 | first-over-limit | 10000 | 53 µs | 122 µs | **tie** | 15.4 MB | 15.4 MB | tie | 3 |
| 7 | top-log-level | 10000 | 349 µs | 418 µs | **tie** | 18.8 MB | 14.1 MB | fxdart | 3 |
| 8 | paginate-users | 10000 | 764 µs | 831 µs | **tie** | 22.8 MB | 23.4 MB | tie | 3 |
| 9 | rank-labels | 10000 | 1.61 ms | 1.73 ms | **tie** | 34.8 MB | 37.7 MB | native | 3 |
| 10 | sequential-configs (async) | 10000 | 37.6 ms | 37.6 ms | **tie** | 50.6 MB | 50.9 MB | tie | 3 |
| 11 | top-merchants | 10000 | 690 µs | 482 µs | **tie** | 23.1 MB | 23.1 MB | tie | 3 |
| 12 | recent-errors | 10000 | 94 µs | 248 µs | **tie** | 15.8 MB | 15.8 MB | tie | 3 |
| 13 | date-window-spend | 10000 | 153 µs | 261 µs | **tie** | 20.8 MB | 23.0 MB | native | 3 |
| 14 | unique-tags | 10000 | 1.21 ms | 907 µs | **tie** | 20.7 MB | 23.2 MB | native | 3 |
| 15 | refunds-vs-charges | 10000 | 2.21 ms | 2.07 ms | **tie** | 23.4 MB | 23.0 MB | tie | 3 |
| 16 | compound-interest | 10000 | 1.83 ms | 2.13 ms | **tie** | 22.8 MB | 22.8 MB | tie | 3 |
| 17 | sensor-anomalies | 10000 | 515 µs | 735 µs | **tie** | 23.6 MB | 23.6 MB | tie | 3 |
| 18 | top-category-average | 10000 | 363 µs | 468 µs | **tie** | 23.0 MB | 22.8 MB | tie | 3 |
| 19 | valid-emails | 10000 | 549 µs | 597 µs | **tie** | 20.0 MB | 20.1 MB | tie | 3 |
| 20 | bounded-concurrency (async) | 10000 | 37.2 ms | 41.8 ms | **native** | 26.2 MB | 22.2 MB | fxdart | 3 |
| 21 | monthly-category-report | 10000 | 109 µs | 257 µs | **tie** | 17.0 MB | 17.1 MB | tie | 3 |
| 22 | paginated-products | 10000 | 824 µs | 1.40 ms | **tie** | 17.7 MB | 22.4 MB | native | 3 |
| 23 | weekly-sensor-averages | 9996 | 395 µs | 664 µs | **tie** | 22.7 MB | 22.2 MB | tie | 3 |
| 24 | consecutive-over-limit | 10000 | 116 µs | 771 µs | **native** | 20.7 MB | 23.6 MB | native | 3 |
| 25 | budget-alerts | 10000 | 190 µs | 421 µs | **tie** | 21.9 MB | 17.8 MB | fxdart | 3 |
| 26 | leaderboard-ties | 10000 | 2.28 ms | 3.18 ms | **native** | 23.5 MB | 26.9 MB | native | 3 |
| 27 | invoice-summary | 10000 | 238 µs | 525 µs | **tie** | 22.5 MB | 23.0 MB | tie | 3 |
| 28 | no-spend-streak | 10000 | 264 µs | 253 µs | **tie** | 19.5 MB | 19.5 MB | tie | 3 |
| 29 | duplicate-transactions | 10000 | 4.12 ms | 4.20 ms | **tie** | 40.3 MB | 35.9 MB | fxdart | 3 |
| 30 | concurrent-enrichment (async) | 10000 | 22.8 ms | 26.9 ms | **native** | 49.3 MB | 50.4 MB | tie | 3 |
| 31 | monthly-ledger-report | 10000 | 907 µs | 1.24 ms | **tie** | 22.9 MB | 23.0 MB | tie | 3 |
| 32 | cohort-retention | 10000 | 2.30 ms | 2.60 ms | **tie** | 18.0 MB | 18.0 MB | tie | 3 |
| 33 | price-drop-detection | 10000 | 7.14 ms | 3.55 ms | **fxdart** | 37.1 MB | 36.2 MB | tie | 3 |
| 34 | anomaly-context | 10000 | 93 µs | 456 µs | **tie** | 18.4 MB | 23.0 MB | native | 3 |
| 35 | sparse-timeseries | 10000 | 482 µs | 637 µs | **tie** | 23.0 MB | 23.1 MB | tie | 3 |
| 36 | multi-currency-report | 10000 | 2.61 ms | 1.39 ms | **fxdart** | 21.9 MB | 23.8 MB | native | 3 |
| 37 | restock-plan | 10000 | 1.29 ms | 1.25 ms | **tie** | 17.4 MB | 22.0 MB | native | 3 |
| 38 | alert-digest | 10000 | 1.41 ms | 2.28 ms | **native** | 17.9 MB | 21.4 MB | native | 3 |
| 39 | latency-percentiles | 10000 | 1.90 ms | 2.27 ms | **tie** | 18.1 MB | 22.4 MB | native | 3 |
| 40 | ledger-diff | 10000 | 2.41 ms | 3.78 ms | **native** | 26.1 MB | 39.0 MB | native | 3 |
| 41 | concurrent-profile-fetch (async) | 10000 | 37.4 ms | 40.5 ms | **native** | 51.2 MB | 32.1 MB | fxdart | 3 |
| 42 | flaky-api-retry (async) | 10000 | 62.7 ms | 125.5 ms | **native** | 29.5 MB | 25.2 MB | fxdart | 3 |
| 43 | price-lookup-fallback (async) | 10000 | 38.3 ms | 51.2 ms | **native** | 49.1 MB | 30.7 MB | fxdart | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.26 ms | 5.58 ms | **native** | 24.0 MB | 25.5 MB | native | 3 |
| 45 | rate-limited-import (async) | 10000 | 14.2 ms | 25.8 ms | **native** | 24.2 MB | 28.4 MB | native | 3 |
| 46 | parallel-downloads (async) | 10000 | 34.5 ms | 50.2 ms | **native** | 50.9 MB | 33.1 MB | fxdart | 3 |
| 47 | paged-feeds-dedupe (async) | 10000 | 8.34 ms | 16.0 ms | **native** | 43.2 MB | 27.3 MB | fxdart | 3 |
| 48 | settlement-pipeline (async) | 10000 | 4.70 ms | 3.77 ms | **fxdart** | 23.1 MB | 23.8 MB | tie | 3 |
| 49 | live-search (async) | 10000 | 8.72 ms | 10.1 ms | **native** | 23.2 MB | 23.8 MB | tie | 3 |
| 50 | daily-ledger-close (async) | 10000 | 332.1 ms | 343.4 ms | **tie** | 50.5 MB | 50.3 MB | tie | 5 |
| 51 | category-rank | 10000 | 277 µs | 401 µs | **tie** | 17.5 MB | 21.6 MB | native | 3 |
| 52 | stock-revaluation (async) | 10000 | 33.0 ms | 51.5 ms | **native** | 49.1 MB | 31.0 MB | fxdart | 3 |
| 53 | smoothed-zone-changes | 10000 | 195 µs | 640 µs | **tie** | 22.0 MB | 22.3 MB | tie | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 1000000 | 12.4 ms | 23.0 ms | **native** | 90.3 MB | 90.6 MB | tie | 3 |
| 2 | running-balance | 1000000 | 244.8 ms | 280.9 ms | **native** | 175.8 MB | 184.8 MB | native | 3 |
| 3 | top-expenses | 1000000 | 509.6 ms | 353.0 ms | **fxdart** | 129.2 MB | 179.9 MB | native | 3 |
| 4 | first-visit-merchants | 1000000 | 24.1 ms | 55.1 ms | **native** | 116.5 MB | 119.9 MB | tie | 3 |
| 5 | average-basket | 1000000 | 17.8 ms | 22.7 ms | **native** | 75.1 MB | 74.8 MB | tie | 3 |
| 6 | first-over-limit | 1000000 | 4.97 ms | 12.1 ms | **native** | 116.7 MB | 117.4 MB | tie | 3 |
| 7 | top-log-level | 1000000 | 45.6 ms | 41.8 ms | **fxdart** | 79.6 MB | 44.8 MB | fxdart | 3 |
| 8 | paginate-users | 1000000 | 82.5 ms | 92.2 ms | **native** | 127.0 MB | 126.9 MB | tie | 3 |
| 9 | rank-labels | 1000000 | 207.1 ms | 229.9 ms | **native** | 241.4 MB | 219.0 MB | fxdart | 3 |
| 10 | sequential-configs (async) | 100000 | 384.9 ms | 431.9 ms | **native** | 82.8 MB | 80.8 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 128.3 ms | 71.0 ms | **fxdart** | 138.0 MB | 117.9 MB | fxdart | 3 |
| 12 | recent-errors | 1000000 | 10.5 ms | 26.4 ms | **native** | 113.9 MB | 113.7 MB | tie | 3 |
| 13 | date-window-spend | 1000000 | 15.1 ms | 24.8 ms | **native** | 125.8 MB | 125.7 MB | tie | 3 |
| 14 | unique-tags | 1000000 | 109.3 ms | 77.3 ms | **fxdart** | 161.9 MB | 161.7 MB | tie | 3 |
| 15 | refunds-vs-charges | 1000000 | 257.0 ms | 242.8 ms | **fxdart** | 179.4 MB | 179.0 MB | tie | 5 |
| 16 | compound-interest | 1000000 | 224.1 ms | 244.5 ms | **native** | 125.0 MB | 125.1 MB | tie | 3 |
| 17 | sensor-anomalies | 1000000 | 64.3 ms | 91.2 ms | **native** | 169.5 MB | 161.2 MB | fxdart | 3 |
| 18 | top-category-average | 1000000 | 58.9 ms | 70.2 ms | **native** | 134.2 MB | 131.0 MB | tie | 3 |
| 19 | valid-emails | 1000000 | 70.8 ms | 76.3 ms | **native** | 174.9 MB | 179.2 MB | tie | 3 |
| 20 | bounded-concurrency (async) | 100000 | 376.6 ms | 432.9 ms | **native** | 49.4 MB | 50.3 MB | tie | 3 |
| 21 | monthly-category-report | 1000000 | 11.7 ms | 28.1 ms | **native** | 120.1 MB | 122.5 MB | tie | 3 |
| 22 | paginated-products | 1000000 | 105.9 ms | 213.0 ms | **native** | 177.8 MB | 233.4 MB | native | 3 |
| 23 | weekly-sensor-averages | 999999 | 51.7 ms | 75.1 ms | **native** | 98.1 MB | 93.8 MB | tie | 3 |
| 24 | consecutive-over-limit | 1000000 | 17.2 ms | 81.3 ms | **native** | 150.4 MB | 148.0 MB | tie | 3 |
| 25 | budget-alerts | 1000000 | 22.1 ms | 57.1 ms | **native** | 90.5 MB | 108.4 MB | native | 3 |
| 26 | leaderboard-ties | 1000000 | 545.3 ms | 722.4 ms | **native** | 232.4 MB | 311.9 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 25.2 ms | 90.6 ms | **native** | 89.7 MB | 123.6 MB | native | 3 |
| 28 | no-spend-streak | 1000000 | 24.1 ms | 23.6 ms | **tie** | 105.9 MB | 105.9 MB | tie | 3 |
| 29 | duplicate-transactions | 1000000 | 980.7 ms | 975.2 ms | **tie** | 324.8 MB | 334.0 MB | tie | 5 |
| 30 | concurrent-enrichment (async) | 100000 | 239.9 ms | 297.7 ms | **native** | 81.4 MB | 83.6 MB | tie | 3 |
| 31 | monthly-ledger-report | 1000000 | 152.3 ms | 186.7 ms | **native** | 140.5 MB | 134.6 MB | tie | 3 |
| 32 | cohort-retention | 1000000 | 661.4 ms | 717.7 ms | **native** | 238.8 MB | 238.8 MB | tie | 3 |
| 33 | price-drop-detection | 1000000 | 1199.2 ms | 663.8 ms | **fxdart** | 392.6 MB | 399.3 MB | tie | 3 |
| 34 | anomaly-context | 1000000 | 11.9 ms | 46.0 ms | **native** | 132.1 MB | 135.1 MB | tie | 3 |
| 35 | sparse-timeseries | 1000000 | 57.0 ms | 93.2 ms | **native** | 124.0 MB | 135.9 MB | native | 3 |
| 36 | multi-currency-report | 1000000 | 382.9 ms | 246.6 ms | **fxdart** | 221.0 MB | 228.7 MB | tie | 3 |
| 37 | restock-plan | 1000000 | 226.9 ms | 213.6 ms | **fxdart** | 173.4 MB | 201.2 MB | native | 3 |
| 38 | alert-digest | 1000000 | 172.4 ms | 283.9 ms | **native** | 125.9 MB | 238.9 MB | native | 3 |
| 39 | latency-percentiles | 1000000 | 201.1 ms | 301.3 ms | **native** | 137.9 MB | 240.3 MB | native | 3 |
| 40 | ledger-diff | 500000 | 235.9 ms | 321.9 ms | **native** | 265.6 MB | 173.3 MB | fxdart | 3 |
| 41 | concurrent-profile-fetch (async) | 100000 | 361.7 ms | 414.8 ms | **native** | 79.7 MB | 81.4 MB | tie | 3 |
| 42 | flaky-api-retry (async) | 100000 | 564.9 ms | 1219.4 ms | **native** | 56.2 MB | 50.5 MB | fxdart | 3 |
| 43 | price-lookup-fallback (async) | 100000 | 417.2 ms | 564.2 ms | **native** | 80.8 MB | 80.7 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100000 | 34.4 ms | 55.9 ms | **native** | 75.1 MB | 76.4 MB | tie | 3 |
| 45 | rate-limited-import (async) | 100000 | 141.7 ms | 255.7 ms | **native** | 76.5 MB | 80.3 MB | tie | 3 |
| 46 | parallel-downloads (async) | 100000 | 358.7 ms | 508.8 ms | **native** | 80.8 MB | 173.0 MB | native | 3 |
| 47 | paged-feeds-dedupe (async) | 100000 | 86.4 ms | 174.4 ms | **native** | 73.6 MB | 81.8 MB | native | 3 |
| 48 | settlement-pipeline (async) | 100000 | 55.5 ms | 46.6 ms | **fxdart** | 56.8 MB | 58.9 MB | tie | 3 |
| 49 | live-search (async) | 100000 | 55.3 ms | 97.5 ms | **native** | 53.0 MB | 60.1 MB | native | 3 |
| 50 | daily-ledger-close (async) | 20000 | 1234.4 ms | 1245.2 ms | **tie** | 52.7 MB | 54.6 MB | tie | 5 |
| 51 | category-rank | 1000000 | 34.8 ms | 47.8 ms | **native** | 148.5 MB | 147.3 MB | tie | 3 |
| 52 | stock-revaluation (async) | 100000 | 331.7 ms | 524.4 ms | **native** | 81.0 MB | 80.0 MB | tie | 3 |
| 53 | smoothed-zone-changes | 1000000 | 38.6 ms | 60.8 ms | **native** | 159.5 MB | 82.1 MB | fxdart | 3 |
