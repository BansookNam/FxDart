# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-09
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 20 µs | 9.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.7 µs | 3.2 µs | **tie** | 16.4 MB | 16.3 MB | tie | 3 |
| 3 | sequential-configs (async) | 100 | 346 µs | 359 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 4 | average-basket | 100 | 2.0 µs | 1.1 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 5 | paginate-users | 100 | 8.1 µs | 6.8 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 6 | rank-labels | 100 | 15 µs | 14 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 7 | running-balance | 100 | 20 µs | 25 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 8 | food-spending | 100 | 1.1 µs | 1.0 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.4 µs | 2.8 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 10 | first-over-limit | 100 | 955 ns | 972 ns | **tie** | 16.3 MB | 16.5 MB | tie | 3 |
| 11 | top-merchants | 100 | 24 µs | 13 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 12 | unique-tags | 100 | 54 µs | 47 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 22 µs | 20 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 14 | valid-emails | 100 | 4.8 µs | 4.9 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100 | 375 µs | 384 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 16 | compound-interest | 100 | 20 µs | 21 µs | **tie** | 16.3 MB | 16.5 MB | tie | 3 |
| 17 | top-category-average | 100 | 7.3 µs | 7.2 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 18 | date-window-spend | 100 | 2.0 µs | 1.5 µs | **tie** | 16.4 MB | 15.6 MB | fxdart | 3 |
| 19 | sensor-anomalies | 100 | 5.8 µs | 7.2 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 20 | recent-errors | 100 | 1.0 µs | 2.0 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 21 | duplicate-transactions | 100 | 39 µs | 42 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 3.9 µs | 5.0 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 182 µs | 241 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 21 µs | 30 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 25 | weekly-sensor-averages | 98 | 4.0 µs | 4.7 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 26 | paginated-products | 100 | 5.9 µs | 8.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 27 | invoice-summary | 100 | 4.0 µs | 5.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.4 µs | 4.7 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.1 µs | 4.2 µs | **tie** | 16.8 MB | 16.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 100 | 1.7 µs | 2.9 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 36 µs | 70 µs | **tie** | 16.5 MB | 15.7 MB | fxdart | 3 |
| 32 | restock-plan | 100 | 11 µs | 9.3 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 33 | price-lookup-fallback (async) | 100 | 404 µs | 403 µs | **tie** | 16.6 MB | 17.1 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 23 µs | 16 µs | **tie** | 16.7 MB | 16.5 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 28 µs | 31 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 342 µs | 476 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 37 | ledger-diff | 100 | 23 µs | 31 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 539 µs | 817 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 39 | alert-digest | 100 | 21 µs | 30 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 17 µs | 20 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 86 µs | 186 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.5 µs | 2.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 43 | smoothed-zone-changes | 100 | 2.0 µs | 4.7 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 35 µs | 55 µs | **tie** | 17.0 MB | 17.1 MB | tie | 3 |
| 45 | live-search (async) | 100 | 58 µs | 76 µs | **tie** | 16.4 MB | 17.2 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 155 µs | 189 µs | **tie** | 16.4 MB | 16.7 MB | tie | 3 |
| 47 | category-rank | 100 | 3.7 µs | 8.2 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 315 µs | 390 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 293 µs | 328 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 50 | cohort-retention | 100 | 42 µs | 43 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 100 | 378 µs | 430 µs | **tie** | 16.6 MB | 17.2 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 35 µs | 36 µs | **tie** | 16.7 MB | 16.7 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 52 µs | 41 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.25 ms | 1.78 ms | **fxdart** | 23.1 MB | 23.3 MB | tie | 3 |
| 2 | top-log-level | 10000 | 349 µs | 315 µs | **tie** | 20.0 MB | 14.2 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 34.8 ms | 32.2 ms | **fxdart** | 50.7 MB | 50.6 MB | tie | 3 |
| 4 | average-basket | 10000 | 184 µs | 103 µs | **tie** | 19.1 MB | 15.3 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 756 µs | 655 µs | **tie** | 22.9 MB | 23.4 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.60 ms | 1.65 ms | **tie** | 34.8 MB | 37.8 MB | native | 3 |
| 7 | running-balance | 10000 | 1.98 ms | 2.15 ms | **tie** | 24.0 MB | 23.7 MB | tie | 3 |
| 8 | food-spending | 10000 | 126 µs | 127 µs | **tie** | 16.9 MB | 15.5 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 147 µs | 289 µs | **tie** | 16.9 MB | 16.9 MB | tie | 3 |
| 10 | first-over-limit | 10000 | 53 µs | 56 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 11 | top-merchants | 10000 | 712 µs | 405 µs | **tie** | 23.0 MB | 23.0 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.20 ms | 959 µs | **tie** | 20.6 MB | 23.2 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.12 ms | 1.81 ms | **tie** | 22.8 MB | 22.8 MB | tie | 3 |
| 14 | valid-emails | 10000 | 547 µs | 526 µs | **tie** | 20.0 MB | 20.1 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 10000 | 31.2 ms | 35.4 ms | **native** | 26.0 MB | 22.0 MB | fxdart | 3 |
| 16 | compound-interest | 10000 | 1.86 ms | 2.07 ms | **tie** | 22.6 MB | 22.8 MB | tie | 3 |
| 17 | top-category-average | 10000 | 351 µs | 367 µs | **tie** | 22.8 MB | 22.9 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 153 µs | 112 µs | **tie** | 20.8 MB | 15.6 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 521 µs | 618 µs | **tie** | 22.6 MB | 23.7 MB | tie | 3 |
| 20 | recent-errors | 10000 | 88 µs | 150 µs | **tie** | 15.8 MB | 15.8 MB | tie | 3 |
| 21 | duplicate-transactions | 10000 | 3.99 ms | 3.98 ms | **tie** | 40.3 MB | 36.1 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 265 µs | 267 µs | **tie** | 19.6 MB | 19.6 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 20.1 ms | 24.3 ms | **native** | 49.3 MB | 50.0 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.36 ms | 2.94 ms | **tie** | 23.5 MB | 25.4 MB | native | 3 |
| 25 | weekly-sensor-averages | 9996 | 393 µs | 467 µs | **tie** | 22.7 MB | 22.6 MB | tie | 3 |
| 26 | paginated-products | 10000 | 836 µs | 1.29 ms | **tie** | 17.8 MB | 20.9 MB | native | 3 |
| 27 | invoice-summary | 10000 | 238 µs | 260 µs | **tie** | 22.4 MB | 19.0 MB | fxdart | 3 |
| 28 | budget-alerts | 10000 | 182 µs | 237 µs | **tie** | 21.9 MB | 19.6 MB | fxdart | 3 |
| 29 | monthly-category-report | 10000 | 108 µs | 170 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 30 | consecutive-over-limit | 10000 | 117 µs | 203 µs | **tie** | 20.6 MB | 23.4 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 2.66 ms | 6.31 ms | **native** | 22.0 MB | 19.1 MB | fxdart | 3 |
| 32 | restock-plan | 10000 | 1.27 ms | 1.10 ms | **tie** | 17.4 MB | 20.3 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 37.4 ms | 36.9 ms | **tie** | 48.9 MB | 31.3 MB | fxdart | 3 |
| 34 | monthly-ledger-report | 10000 | 924 µs | 661 µs | **tie** | 23.0 MB | 22.9 MB | tie | 3 |
| 35 | sparse-timeseries | 10000 | 489 µs | 431 µs | **tie** | 23.0 MB | 20.3 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 33.7 ms | 39.6 ms | **native** | 50.9 MB | 33.1 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.54 ms | 3.52 ms | **native** | 26.0 MB | 31.2 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 51.1 ms | 72.7 ms | **native** | 29.1 MB | 24.8 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.41 ms | 2.15 ms | **native** | 17.9 MB | 21.4 MB | native | 3 |
| 40 | latency-percentiles | 10000 | 1.95 ms | 2.14 ms | **tie** | 18.1 MB | 21.2 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 8.24 ms | 15.7 ms | **native** | 43.1 MB | 27.2 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 96 µs | 200 µs | **tie** | 18.1 MB | 23.0 MB | native | 3 |
| 43 | smoothed-zone-changes | 10000 | 179 µs | 419 µs | **tie** | 22.0 MB | 22.8 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.14 ms | 4.77 ms | **native** | 23.6 MB | 25.4 MB | native | 3 |
| 45 | live-search (async) | 10000 | 4.60 ms | 6.82 ms | **native** | 23.5 MB | 23.8 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 13.7 ms | 17.4 ms | **native** | 24.1 MB | 28.5 MB | native | 3 |
| 47 | category-rank | 10000 | 294 µs | 315 µs | **tie** | 17.3 MB | 17.8 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 30.9 ms | 37.5 ms | **native** | 49.6 MB | 30.8 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 29.6 ms | 31.8 ms | **native** | 51.8 MB | 32.0 MB | fxdart | 3 |
| 50 | cohort-retention | 10000 | 2.31 ms | 2.38 ms | **tie** | 18.0 MB | 17.5 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 10000 | 329.9 ms | 335.0 ms | **tie** | 50.0 MB | 50.2 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 4.40 ms | 3.17 ms | **fxdart** | 23.5 MB | 23.9 MB | tie | 3 |
| 53 | price-drop-detection | 10000 | 7.17 ms | 3.94 ms | **fxdart** | 37.1 MB | 34.4 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 518.1 ms | 337.9 ms | **fxdart** | 124.7 MB | 150.0 MB | native | 3 |
| 2 | top-log-level | 1000000 | 45.1 ms | 31.8 ms | **fxdart** | 82.6 MB | 44.8 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 352.2 ms | 335.4 ms | **fxdart** | 83.1 MB | 82.4 MB | tie | 3 |
| 4 | average-basket | 1000000 | 17.5 ms | 10.1 ms | **fxdart** | 75.3 MB | 72.9 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 83.0 ms | 76.3 ms | **fxdart** | 127.1 MB | 126.1 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 206.5 ms | 218.3 ms | **native** | 240.0 MB | 220.8 MB | fxdart | 3 |
| 7 | running-balance | 1000000 | 242.6 ms | 275.7 ms | **native** | 183.3 MB | 185.2 MB | tie | 3 |
| 8 | food-spending | 1000000 | 12.6 ms | 13.2 ms | **tie** | 91.1 MB | 84.5 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 26.9 ms | 51.5 ms | **native** | 116.3 MB | 119.9 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 5.07 ms | 5.30 ms | **tie** | 117.2 MB | 117.5 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 125.7 ms | 61.7 ms | **fxdart** | 137.2 MB | 118.4 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 108.1 ms | 83.0 ms | **fxdart** | 161.5 MB | 161.8 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 254.4 ms | 229.6 ms | **fxdart** | 180.2 MB | 177.7 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 72.2 ms | 70.0 ms | **tie** | 174.7 MB | 174.7 MB | tie | 5 |
| 15 | bounded-concurrency (async) | 100000 | 314.7 ms | 359.5 ms | **native** | 49.1 MB | 50.3 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 224.0 ms | 246.1 ms | **native** | 125.3 MB | 128.6 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 64.0 ms | 66.5 ms | **tie** | 133.8 MB | 133.9 MB | tie | 5 |
| 18 | date-window-spend | 1000000 | 15.1 ms | 11.5 ms | **fxdart** | 123.5 MB | 119.4 MB | tie | 3 |
| 19 | sensor-anomalies | 1000000 | 64.1 ms | 75.3 ms | **native** | 162.8 MB | 155.1 MB | tie | 3 |
| 20 | recent-errors | 1000000 | 10.7 ms | 16.8 ms | **native** | 113.7 MB | 113.9 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 1018.7 ms | 1010.6 ms | **tie** | 323.4 MB | 332.8 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 24.1 ms | 24.6 ms | **tie** | 106.1 MB | 106.0 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100000 | 210.5 ms | 257.4 ms | **native** | 82.0 MB | 81.9 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 546.7 ms | 674.6 ms | **native** | 232.0 MB | 293.0 MB | native | 3 |
| 25 | weekly-sensor-averages | 999999 | 50.1 ms | 50.2 ms | **tie** | 98.0 MB | 145.5 MB | native | 3 |
| 26 | paginated-products | 1000000 | 103.7 ms | 188.2 ms | **native** | 177.8 MB | 212.6 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 25.0 ms | 26.6 ms | **native** | 89.5 MB | 91.1 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.8 ms | 27.3 ms | **native** | 90.1 MB | 90.4 MB | tie | 3 |
| 29 | monthly-category-report | 1000000 | 11.5 ms | 17.2 ms | **native** | 119.3 MB | 120.0 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 17.7 ms | 23.2 ms | **native** | 150.2 MB | 149.5 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 372.6 ms | 671.9 ms | **native** | 220.3 MB | 196.6 MB | fxdart | 3 |
| 32 | restock-plan | 1000000 | 222.5 ms | 208.3 ms | **fxdart** | 173.6 MB | 193.7 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 100000 | 362.2 ms | 372.2 ms | **tie** | 80.8 MB | 80.9 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 139.3 ms | 72.8 ms | **fxdart** | 166.6 MB | 120.4 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 59.3 ms | 49.6 ms | **fxdart** | 122.1 MB | 143.5 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 342.1 ms | 406.9 ms | **native** | 80.8 MB | 87.2 MB | native | 3 |
| 37 | ledger-diff | 500000 | 242.3 ms | 343.9 ms | **native** | 182.0 MB | 170.1 MB | fxdart | 3 |
| 38 | flaky-api-retry (async) | 100000 | 496.8 ms | 724.8 ms | **native** | 55.9 MB | 50.1 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 182.1 ms | 274.3 ms | **native** | 135.4 MB | 239.5 MB | native | 3 |
| 40 | latency-percentiles | 1000000 | 213.0 ms | 283.0 ms | **native** | 168.6 MB | 190.3 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 100000 | 84.2 ms | 168.7 ms | **native** | 73.7 MB | 82.2 MB | native | 3 |
| 42 | anomaly-context | 1000000 | 12.3 ms | 20.7 ms | **native** | 132.4 MB | 136.2 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 37.6 ms | 38.0 ms | **tie** | 236.6 MB | 82.0 MB | fxdart | 3 |
| 44 | stream-windowed-alerts (async) | 100000 | 32.5 ms | 50.0 ms | **native** | 75.0 MB | 75.6 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 48.2 ms | 70.5 ms | **native** | 53.1 MB | 59.1 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 135.7 ms | 179.4 ms | **native** | 76.1 MB | 80.2 MB | native | 3 |
| 47 | category-rank | 1000000 | 36.1 ms | 34.7 ms | **tie** | 146.5 MB | 145.5 MB | tie | 5 |
| 48 | stock-revaluation (async) | 100000 | 313.7 ms | 374.5 ms | **native** | 80.7 MB | 80.7 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 313.2 ms | 333.9 ms | **native** | 80.3 MB | 80.4 MB | tie | 3 |
| 50 | cohort-retention | 1000000 | 778.1 ms | 772.5 ms | **tie** | 239.1 MB | 238.8 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 20000 | 1215.8 ms | 1220.5 ms | **tie** | 53.0 MB | 54.5 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 52.5 ms | 34.0 ms | **fxdart** | 56.2 MB | 58.6 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1225.7 ms | 712.0 ms | **fxdart** | 393.2 MB | 433.2 MB | native | 3 |
