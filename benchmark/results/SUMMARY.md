# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-17
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 19 µs | 6.1 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.5 µs | 3.1 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 3 | sequential-configs (async) | 100 | 315 µs | 333 µs | **tie** | 16.4 MB | 16.7 MB | tie | 3 |
| 4 | average-basket | 100 | 2.0 µs | 1.1 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 5 | paginate-users | 100 | 7.5 µs | 6.5 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 6 | rank-labels | 100 | 14 µs | 14 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 7 | running-balance | 100 | 19 µs | 22 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 8 | food-spending | 100 | 1.1 µs | 1.0 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.4 µs | 1.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 10 | first-over-limit | 100 | 927 ns | 965 ns | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 11 | top-merchants | 100 | 23 µs | 138 µs | **tie** | 17.1 MB | 17.0 MB | tie | 3 |
| 12 | unique-tags | 100 | 53 µs | 46 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 22 µs | 20 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 14 | valid-emails | 100 | 4.8 µs | 4.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100 | 341 µs | 411 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 16 | compound-interest | 100 | 18 µs | 21 µs | **tie** | 16.4 MB | 16.9 MB | tie | 3 |
| 17 | top-category-average | 100 | 7.0 µs | 6.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 18 | date-window-spend | 100 | 1.8 µs | 1.4 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 19 | sensor-anomalies | 100 | 5.7 µs | 6.8 µs | **tie** | 16.5 MB | 16.4 MB | tie | 8 |
| 20 | recent-errors | 100 | 1.0 µs | 1.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 21 | duplicate-transactions | 100 | 40 µs | 39 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 3.9 µs | 5.1 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 189 µs | 231 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 21 µs | 28 µs | **tie** | 16.5 MB | 16.5 MB | tie | 8 |
| 25 | weekly-sensor-averages | 98 | 3.9 µs | 4.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 8 |
| 26 | paginated-products | 100 | 5.7 µs | 6.6 µs | **tie** | 16.5 MB | 16.6 MB | tie | 8 |
| 27 | invoice-summary | 100 | 4.0 µs | 9.9 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.3 µs | 4.5 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.0 µs | 6.1 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 100 | 1.8 µs | 2.9 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 11 µs | 13 µs | **tie** | 16.5 MB | 16.6 MB | tie | 8 |
| 32 | restock-plan | 100 | 10 µs | 9.3 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 33 | price-lookup-fallback (async) | 100 | 410 µs | 416 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 22 µs | 31 µs | **tie** | 16.7 MB | 16.5 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 27 µs | 29 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 364 µs | 425 µs | **tie** | 17.0 MB | 17.2 MB | tie | 3 |
| 37 | ledger-diff | 100 | 22 µs | 28 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 508 µs | 801 µs | **tie** | 16.4 MB | 17.0 MB | tie | 3 |
| 39 | alert-digest | 100 | 21 µs | 32 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 17 µs | 20 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 83 µs | 100 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.4 µs | 2.3 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 43 | smoothed-zone-changes | 100 | 1.8 µs | 4.2 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 32 µs | 51 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 45 | live-search (async) | 100 | 50 µs | 71 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 148 µs | 177 µs | **tie** | 16.4 MB | 17.2 MB | tie | 3 |
| 47 | category-rank | 100 | 3.7 µs | 15 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 328 µs | 400 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 344 µs | 387 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 50 | cohort-retention | 100 | 40 µs | 41 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 100 | 391 µs | 412 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 34 µs | 35 µs | **tie** | 16.6 MB | 17.2 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 59 µs | 38 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.35 ms | 900 µs | **fxdart** | 23.1 MB | 22.0 MB | tie | 3 |
| 2 | top-log-level | 10000 | 349 µs | 307 µs | **tie** | 20.0 MB | 14.1 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 32.1 ms | 32.2 ms | **tie** | 51.0 MB | 50.9 MB | tie | 3 |
| 4 | average-basket | 10000 | 181 µs | 103 µs | **tie** | 19.1 MB | 15.3 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 762 µs | 653 µs | **tie** | 22.9 MB | 23.3 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.60 ms | 1.64 ms | **tie** | 34.8 MB | 37.7 MB | native | 3 |
| 7 | running-balance | 10000 | 1.94 ms | 2.08 ms | **tie** | 23.9 MB | 23.6 MB | tie | 3 |
| 8 | food-spending | 10000 | 126 µs | 127 µs | **tie** | 16.9 MB | 15.5 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 145 µs | 168 µs | **tie** | 16.9 MB | 17.0 MB | tie | 3 |
| 10 | first-over-limit | 10000 | 54 µs | 56 µs | **tie** | 15.4 MB | 15.3 MB | tie | 3 |
| 11 | top-merchants | 10000 | 684 µs | 576 µs | **tie** | 23.0 MB | 23.6 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.21 ms | 939 µs | **tie** | 20.6 MB | 23.2 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.18 ms | 1.96 ms | **tie** | 23.4 MB | 22.9 MB | tie | 3 |
| 14 | valid-emails | 10000 | 547 µs | 525 µs | **tie** | 20.0 MB | 20.1 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 10000 | 34.0 ms | 36.1 ms | **native** | 26.6 MB | 22.7 MB | fxdart | 3 |
| 16 | compound-interest | 10000 | 1.88 ms | 2.10 ms | **tie** | 22.6 MB | 22.8 MB | tie | 3 |
| 17 | top-category-average | 10000 | 353 µs | 356 µs | **tie** | 22.9 MB | 22.9 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 151 µs | 109 µs | **tie** | 20.7 MB | 15.7 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 525 µs | 613 µs | **tie** | 23.1 MB | 23.6 MB | tie | 8 |
| 20 | recent-errors | 10000 | 90 µs | 147 µs | **tie** | 15.8 MB | 15.8 MB | tie | 3 |
| 21 | duplicate-transactions | 10000 | 4.07 ms | 3.96 ms | **tie** | 40.3 MB | 36.0 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 251 µs | 258 µs | **tie** | 19.5 MB | 19.7 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 19.1 ms | 22.7 ms | **native** | 49.2 MB | 50.3 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.34 ms | 3.03 ms | **native** | 23.5 MB | 25.4 MB | native | 8 |
| 25 | weekly-sensor-averages | 9996 | 409 µs | 468 µs | **tie** | 22.7 MB | 22.7 MB | tie | 8 |
| 26 | paginated-products | 10000 | 833 µs | 821 µs | **tie** | 17.7 MB | 20.8 MB | native | 8 |
| 27 | invoice-summary | 10000 | 233 µs | 257 µs | **tie** | 22.4 MB | 19.0 MB | fxdart | 3 |
| 28 | budget-alerts | 10000 | 180 µs | 241 µs | **tie** | 21.8 MB | 19.5 MB | fxdart | 3 |
| 29 | monthly-category-report | 10000 | 106 µs | 174 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 30 | consecutive-over-limit | 10000 | 117 µs | 209 µs | **tie** | 21.0 MB | 23.5 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 726 µs | 950 µs | **tie** | 23.5 MB | 22.9 MB | tie | 8 |
| 32 | restock-plan | 10000 | 1.26 ms | 1.10 ms | **tie** | 17.5 MB | 20.8 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 37.3 ms | 37.3 ms | **tie** | 48.9 MB | 30.7 MB | fxdart | 3 |
| 34 | monthly-ledger-report | 10000 | 901 µs | 711 µs | **tie** | 23.4 MB | 22.2 MB | fxdart | 3 |
| 35 | sparse-timeseries | 10000 | 475 µs | 440 µs | **tie** | 22.9 MB | 20.2 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 33.8 ms | 39.7 ms | **native** | 50.8 MB | 32.8 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.49 ms | 3.58 ms | **native** | 26.1 MB | 31.2 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 50.4 ms | 73.6 ms | **native** | 28.9 MB | 24.7 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.43 ms | 2.27 ms | **native** | 17.9 MB | 21.3 MB | native | 3 |
| 40 | latency-percentiles | 10000 | 1.88 ms | 2.09 ms | **tie** | 18.1 MB | 21.0 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 8.38 ms | 9.18 ms | **native** | 43.1 MB | 24.5 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 97 µs | 171 µs | **tie** | 18.4 MB | 23.1 MB | native | 3 |
| 43 | smoothed-zone-changes | 10000 | 197 µs | 415 µs | **tie** | 22.0 MB | 22.8 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.20 ms | 4.94 ms | **native** | 23.9 MB | 25.0 MB | tie | 3 |
| 45 | live-search (async) | 10000 | 4.80 ms | 6.34 ms | **native** | 23.2 MB | 23.6 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 13.2 ms | 16.4 ms | **native** | 23.7 MB | 28.0 MB | native | 3 |
| 47 | category-rank | 10000 | 290 µs | 303 µs | **tie** | 17.4 MB | 17.5 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 31.4 ms | 36.9 ms | **native** | 49.5 MB | 30.8 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 32.2 ms | 34.5 ms | **native** | 51.3 MB | 32.0 MB | fxdart | 3 |
| 50 | cohort-retention | 10000 | 2.36 ms | 2.31 ms | **tie** | 17.9 MB | 17.6 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 10000 | 329.9 ms | 336.5 ms | **tie** | 49.9 MB | 50.3 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 4.42 ms | 3.26 ms | **fxdart** | 23.1 MB | 24.4 MB | native | 3 |
| 53 | price-drop-detection | 10000 | 7.17 ms | 3.77 ms | **fxdart** | 37.1 MB | 34.4 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 510.4 ms | 213.4 ms | **fxdart** | 126.6 MB | 135.6 MB | native | 3 |
| 2 | top-log-level | 1000000 | 44.2 ms | 31.6 ms | **fxdart** | 80.6 MB | 44.8 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 333.3 ms | 331.8 ms | **tie** | 83.0 MB | 82.5 MB | tie | 5 |
| 4 | average-basket | 1000000 | 17.3 ms | 10.1 ms | **fxdart** | 75.2 MB | 72.9 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 81.1 ms | 74.7 ms | **fxdart** | 127.0 MB | 126.8 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 206.1 ms | 211.7 ms | **tie** | 241.1 MB | 223.0 MB | fxdart | 5 |
| 7 | running-balance | 1000000 | 240.2 ms | 274.4 ms | **native** | 178.8 MB | 185.1 MB | tie | 3 |
| 8 | food-spending | 1000000 | 12.4 ms | 13.2 ms | **native** | 90.4 MB | 85.0 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 24.3 ms | 26.0 ms | **native** | 116.3 MB | 116.7 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 4.97 ms | 5.34 ms | **tie** | 117.9 MB | 117.2 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 118.3 ms | 58.3 ms | **fxdart** | 137.3 MB | 118.6 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 106.8 ms | 77.7 ms | **fxdart** | 161.8 MB | 161.3 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 253.2 ms | 234.9 ms | **fxdart** | 176.4 MB | 177.3 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 71.3 ms | 69.9 ms | **tie** | 175.0 MB | 175.0 MB | tie | 5 |
| 15 | bounded-concurrency (async) | 100000 | 339.1 ms | 361.9 ms | **native** | 49.3 MB | 50.4 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 222.4 ms | 245.7 ms | **native** | 124.3 MB | 125.6 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 63.8 ms | 63.4 ms | **tie** | 134.0 MB | 134.1 MB | tie | 5 |
| 18 | date-window-spend | 1000000 | 15.0 ms | 11.5 ms | **fxdart** | 123.9 MB | 119.4 MB | tie | 3 |
| 19 | sensor-anomalies | 1000000 | 65.3 ms | 76.2 ms | **native** | 169.4 MB | 157.7 MB | fxdart | 8 |
| 20 | recent-errors | 1000000 | 10.7 ms | 16.3 ms | **native** | 114.0 MB | 113.8 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 998.1 ms | 977.0 ms | **tie** | 324.9 MB | 332.5 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 24.0 ms | 23.9 ms | **tie** | 105.7 MB | 106.3 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100000 | 209.6 ms | 242.8 ms | **native** | 81.3 MB | 81.5 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 546.8 ms | 665.7 ms | **native** | 232.4 MB | 238.0 MB | tie | 8 |
| 25 | weekly-sensor-averages | 999999 | 50.9 ms | 49.4 ms | **tie** | 97.3 MB | 145.3 MB | native | 8 |
| 26 | paginated-products | 1000000 | 103.8 ms | 128.0 ms | **native** | 177.7 MB | 207.1 MB | native | 8 |
| 27 | invoice-summary | 1000000 | 25.0 ms | 27.3 ms | **native** | 89.6 MB | 90.5 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.5 ms | 27.4 ms | **native** | 89.6 MB | 89.6 MB | tie | 3 |
| 29 | monthly-category-report | 1000000 | 11.4 ms | 17.4 ms | **native** | 119.7 MB | 119.7 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 17.1 ms | 22.9 ms | **native** | 150.0 MB | 148.3 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 128.2 ms | 132.0 ms | **tie** | 205.1 MB | 189.3 MB | fxdart | 8 |
| 32 | restock-plan | 1000000 | 218.4 ms | 203.9 ms | **fxdart** | 173.5 MB | 186.2 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 100000 | 364.6 ms | 373.8 ms | **tie** | 80.8 MB | 80.6 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 135.6 ms | 77.2 ms | **fxdart** | 148.0 MB | 120.6 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 55.3 ms | 50.7 ms | **fxdart** | 124.3 MB | 144.5 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 352.5 ms | 406.2 ms | **native** | 80.8 MB | 92.8 MB | native | 3 |
| 37 | ledger-diff | 500000 | 235.3 ms | 317.6 ms | **native** | 182.5 MB | 170.8 MB | fxdart | 3 |
| 38 | flaky-api-retry (async) | 100000 | 508.6 ms | 727.7 ms | **native** | 56.1 MB | 50.1 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 175.2 ms | 266.0 ms | **native** | 239.1 MB | 126.3 MB | fxdart | 3 |
| 40 | latency-percentiles | 1000000 | 207.7 ms | 283.1 ms | **native** | 216.3 MB | 136.9 MB | fxdart | 3 |
| 41 | paged-feeds-dedupe (async) | 100000 | 84.4 ms | 94.7 ms | **native** | 73.6 MB | 74.4 MB | tie | 3 |
| 42 | anomaly-context | 1000000 | 11.9 ms | 18.0 ms | **native** | 132.1 MB | 135.9 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 40.0 ms | 38.1 ms | **fxdart** | 291.5 MB | 82.1 MB | fxdart | 3 |
| 44 | stream-windowed-alerts (async) | 100000 | 33.9 ms | 49.5 ms | **native** | 74.6 MB | 75.7 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 48.7 ms | 64.9 ms | **native** | 53.2 MB | 57.6 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 135.6 ms | 167.3 ms | **native** | 76.4 MB | 79.9 MB | tie | 3 |
| 47 | category-rank | 1000000 | 35.0 ms | 34.2 ms | **tie** | 146.9 MB | 145.2 MB | tie | 5 |
| 48 | stock-revaluation (async) | 100000 | 323.1 ms | 377.5 ms | **native** | 80.4 MB | 80.7 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 312.3 ms | 334.5 ms | **native** | 80.0 MB | 80.2 MB | tie | 3 |
| 50 | cohort-retention | 1000000 | 722.2 ms | 723.8 ms | **tie** | 239.0 MB | 238.9 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 20000 | 1208.0 ms | 1228.4 ms | **tie** | 53.0 MB | 54.2 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 52.3 ms | 33.8 ms | **fxdart** | 56.7 MB | 58.3 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1188.7 ms | 659.7 ms | **fxdart** | 392.9 MB | 445.5 MB | native | 3 |
