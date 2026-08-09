# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-09
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 19 µs | 10 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.3 µs | 4.1 µs | **tie** | 16.4 MB | 16.3 MB | tie | 3 |
| 3 | sequential-configs (async) | 100 | 314 µs | 312 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 4 | average-basket | 100 | 2.0 µs | 2.1 µs | **tie** | 16.5 MB | 16.1 MB | tie | 3 |
| 5 | paginate-users | 100 | 7.5 µs | 6.5 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 6 | rank-labels | 100 | 14 µs | 16 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 7 | running-balance | 100 | 19 µs | 23 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 8 | food-spending | 100 | 1.1 µs | 2.3 µs | **tie** | 16.4 MB | 16.3 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.5 µs | 3.2 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 10 | first-over-limit | 100 | 945 ns | 1.7 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 11 | top-merchants | 100 | 23 µs | 14 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 12 | unique-tags | 100 | 53 µs | 46 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 22 µs | 20 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 14 | valid-emails | 100 | 4.7 µs | 5.5 µs | **tie** | 16.4 MB | 16.4 MB | tie | 5 |
| 15 | bounded-concurrency (async) | 100 | 342 µs | 446 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 16 | compound-interest | 100 | 18 µs | 20 µs | **tie** | 16.3 MB | 16.5 MB | tie | 3 |
| 17 | top-category-average | 100 | 6.7 µs | 8.3 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 18 | date-window-spend | 100 | 1.8 µs | 2.4 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 19 | sensor-anomalies | 100 | 5.8 µs | 6.9 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 20 | recent-errors | 100 | 1.1 µs | 3.1 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 21 | duplicate-transactions | 100 | 40 µs | 41 µs | **tie** | 16.9 MB | 17.1 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 3.9 µs | 5.3 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 189 µs | 223 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 21 µs | 31 µs | **tie** | 16.9 MB | 17.1 MB | tie | 3 |
| 25 | weekly-sensor-averages | 98 | 3.7 µs | 4.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 26 | paginated-products | 100 | 5.7 µs | 9.2 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 27 | invoice-summary | 100 | 3.8 µs | 7.9 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.2 µs | 6.9 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.0 µs | 5.2 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 100 | 1.8 µs | 2.8 µs | **tie** | 16.9 MB | 16.6 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 33 µs | 19 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 32 | restock-plan | 100 | 10 µs | 8.9 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 33 | price-lookup-fallback (async) | 100 | 361 µs | 384 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 22 µs | 22 µs | **tie** | 17.1 MB | 16.6 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 27 µs | 31 µs | **tie** | 17.0 MB | 16.6 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 344 µs | 431 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 37 | ledger-diff | 100 | 22 µs | 29 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 510 µs | 769 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 39 | alert-digest | 100 | 21 µs | 32 µs | **tie** | 16.6 MB | 17.0 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 17 µs | 20 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 84 µs | 176 µs | **tie** | 16.9 MB | 17.0 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.5 µs | 5.2 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 43 | smoothed-zone-changes | 100 | 1.8 µs | 4.9 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 33 µs | 53 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 45 | live-search (async) | 100 | 48 µs | 79 µs | **tie** | 16.4 MB | 16.7 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 140 µs | 196 µs | **tie** | 16.3 MB | 17.3 MB | native | 3 |
| 47 | category-rank | 100 | 3.6 µs | 9.3 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 307 µs | 396 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 289 µs | 360 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 50 | cohort-retention | 100 | 39 µs | 43 µs | **tie** | 17.0 MB | 16.5 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 100 | 333 µs | 407 µs | **tie** | 16.6 MB | 17.2 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 31 µs | 37 µs | **tie** | 16.6 MB | 17.2 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 49 µs | 36 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.29 ms | 1.89 ms | **fxdart** | 23.1 MB | 23.0 MB | tie | 3 |
| 2 | top-log-level | 10000 | 350 µs | 417 µs | **tie** | 18.8 MB | 14.2 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 32.6 ms | 32.4 ms | **tie** | 50.9 MB | 50.5 MB | tie | 4 |
| 4 | average-basket | 10000 | 180 µs | 188 µs | **tie** | 18.6 MB | 15.2 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 758 µs | 643 µs | **tie** | 22.9 MB | 23.3 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.62 ms | 1.74 ms | **tie** | 34.8 MB | 37.5 MB | native | 3 |
| 7 | running-balance | 10000 | 1.91 ms | 2.24 ms | **tie** | 23.9 MB | 23.7 MB | tie | 3 |
| 8 | food-spending | 10000 | 123 µs | 215 µs | **tie** | 16.9 MB | 15.6 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 154 µs | 312 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 10 | first-over-limit | 10000 | 55 µs | 124 µs | **tie** | 15.2 MB | 15.3 MB | tie | 3 |
| 11 | top-merchants | 10000 | 677 µs | 482 µs | **tie** | 23.0 MB | 23.0 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.24 ms | 887 µs | **tie** | 20.6 MB | 23.3 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.11 ms | 1.97 ms | **tie** | 22.8 MB | 22.9 MB | tie | 3 |
| 14 | valid-emails | 10000 | 541 µs | 589 µs | **tie** | 20.0 MB | 20.0 MB | tie | 5 |
| 15 | bounded-concurrency (async) | 10000 | 32.6 ms | 40.0 ms | **native** | 26.5 MB | 22.7 MB | fxdart | 3 |
| 16 | compound-interest | 10000 | 1.85 ms | 2.09 ms | **tie** | 22.7 MB | 22.8 MB | tie | 3 |
| 17 | top-category-average | 10000 | 345 µs | 451 µs | **tie** | 23.5 MB | 22.8 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 154 µs | 204 µs | **tie** | 20.8 MB | 15.5 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 537 µs | 627 µs | **tie** | 22.5 MB | 23.7 MB | native | 3 |
| 20 | recent-errors | 10000 | 89 µs | 237 µs | **tie** | 15.8 MB | 15.7 MB | tie | 3 |
| 21 | duplicate-transactions | 10000 | 4.25 ms | 4.22 ms | **tie** | 40.3 MB | 36.1 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 269 µs | 266 µs | **tie** | 19.6 MB | 19.7 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 19.7 ms | 22.8 ms | **native** | 49.2 MB | 50.1 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.40 ms | 3.27 ms | **native** | 23.4 MB | 26.8 MB | native | 3 |
| 25 | weekly-sensor-averages | 9996 | 396 µs | 457 µs | **tie** | 22.7 MB | 22.8 MB | tie | 3 |
| 26 | paginated-products | 10000 | 808 µs | 1.40 ms | **tie** | 17.7 MB | 22.5 MB | native | 3 |
| 27 | invoice-summary | 10000 | 242 µs | 399 µs | **tie** | 22.4 MB | 17.0 MB | fxdart | 3 |
| 28 | budget-alerts | 10000 | 177 µs | 409 µs | **tie** | 21.8 MB | 17.8 MB | fxdart | 3 |
| 29 | monthly-category-report | 10000 | 108 µs | 254 µs | **tie** | 16.9 MB | 17.0 MB | tie | 3 |
| 30 | consecutive-over-limit | 10000 | 121 µs | 212 µs | **tie** | 20.5 MB | 23.5 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 2.65 ms | 1.31 ms | **fxdart** | 22.0 MB | 23.4 MB | native | 3 |
| 32 | restock-plan | 10000 | 1.23 ms | 1.20 ms | **tie** | 17.4 MB | 22.3 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 35.8 ms | 35.4 ms | **tie** | 48.9 MB | 30.7 MB | fxdart | 3 |
| 34 | monthly-ledger-report | 10000 | 909 µs | 1.07 ms | **tie** | 22.8 MB | 20.2 MB | fxdart | 3 |
| 35 | sparse-timeseries | 10000 | 476 µs | 564 µs | **tie** | 23.0 MB | 18.7 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 33.0 ms | 38.9 ms | **native** | 50.8 MB | 32.8 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.57 ms | 3.72 ms | **native** | 26.1 MB | 31.5 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 50.9 ms | 71.1 ms | **native** | 29.0 MB | 24.8 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.42 ms | 2.33 ms | **native** | 17.9 MB | 21.4 MB | native | 3 |
| 40 | latency-percentiles | 10000 | 1.88 ms | 2.32 ms | **tie** | 18.1 MB | 22.7 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 7.82 ms | 14.7 ms | **native** | 43.2 MB | 27.3 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 95 µs | 467 µs | **tie** | 18.1 MB | 23.0 MB | native | 3 |
| 43 | smoothed-zone-changes | 10000 | 172 µs | 479 µs | **tie** | 22.0 MB | 22.8 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.09 ms | 4.84 ms | **native** | 23.6 MB | 25.5 MB | native | 3 |
| 45 | live-search (async) | 10000 | 4.57 ms | 6.40 ms | **native** | 23.0 MB | 23.7 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 13.2 ms | 17.4 ms | **native** | 24.1 MB | 28.1 MB | native | 3 |
| 47 | category-rank | 10000 | 284 µs | 388 µs | **tie** | 17.4 MB | 17.8 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 31.7 ms | 35.5 ms | **native** | 49.0 MB | 30.8 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 30.1 ms | 32.5 ms | **native** | 51.1 MB | 32.0 MB | fxdart | 3 |
| 50 | cohort-retention | 10000 | 2.27 ms | 2.47 ms | **tie** | 18.0 MB | 18.1 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 10000 | 323.2 ms | 329.1 ms | **tie** | 50.3 MB | 50.8 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 4.08 ms | 3.40 ms | **fxdart** | 23.2 MB | 23.9 MB | tie | 3 |
| 53 | price-drop-detection | 10000 | 7.09 ms | 3.56 ms | **fxdart** | 37.1 MB | 34.9 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 520.8 ms | 352.8 ms | **fxdart** | 126.0 MB | 176.3 MB | native | 3 |
| 2 | top-log-level | 1000000 | 47.4 ms | 41.6 ms | **fxdart** | 94.5 MB | 44.9 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 340.8 ms | 347.9 ms | **tie** | 83.0 MB | 82.2 MB | tie | 5 |
| 4 | average-basket | 1000000 | 17.8 ms | 18.8 ms | **native** | 75.3 MB | 72.8 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 87.7 ms | 82.2 ms | **fxdart** | 126.3 MB | 126.2 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 215.2 ms | 224.8 ms | **tie** | 241.1 MB | 223.1 MB | fxdart | 5 |
| 7 | running-balance | 1000000 | 251.2 ms | 292.5 ms | **native** | 181.5 MB | 185.1 MB | tie | 3 |
| 8 | food-spending | 1000000 | 12.4 ms | 22.4 ms | **native** | 91.1 MB | 85.0 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 25.8 ms | 45.9 ms | **native** | 116.3 MB | 119.9 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 5.14 ms | 12.2 ms | **native** | 117.1 MB | 117.0 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 112.4 ms | 65.3 ms | **fxdart** | 137.8 MB | 118.6 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 111.4 ms | 76.9 ms | **fxdart** | 161.8 MB | 161.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 267.6 ms | 243.2 ms | **fxdart** | 181.4 MB | 176.5 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 71.0 ms | 74.7 ms | **native** | 174.7 MB | 175.7 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100000 | 313.5 ms | 396.0 ms | **native** | 49.3 MB | 50.3 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 221.7 ms | 251.9 ms | **native** | 124.9 MB | 124.3 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 58.3 ms | 68.2 ms | **native** | 130.3 MB | 131.2 MB | tie | 3 |
| 18 | date-window-spend | 1000000 | 15.4 ms | 21.3 ms | **native** | 123.2 MB | 121.2 MB | tie | 3 |
| 19 | sensor-anomalies | 1000000 | 65.2 ms | 76.4 ms | **native** | 161.0 MB | 153.5 MB | tie | 3 |
| 20 | recent-errors | 1000000 | 10.8 ms | 26.9 ms | **native** | 113.2 MB | 113.5 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 960.6 ms | 978.1 ms | **tie** | 329.3 MB | 336.1 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 24.1 ms | 24.1 ms | **tie** | 106.7 MB | 106.9 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100000 | 209.8 ms | 274.0 ms | **native** | 81.5 MB | 83.9 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 568.3 ms | 678.1 ms | **native** | 231.7 MB | 252.8 MB | native | 3 |
| 25 | weekly-sensor-averages | 999999 | 49.5 ms | 55.5 ms | **native** | 94.1 MB | 95.9 MB | tie | 3 |
| 26 | paginated-products | 1000000 | 104.4 ms | 210.4 ms | **native** | 178.5 MB | 239.9 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 25.3 ms | 57.8 ms | **native** | 89.5 MB | 107.0 MB | native | 3 |
| 28 | budget-alerts | 1000000 | 21.5 ms | 53.7 ms | **native** | 90.2 MB | 108.2 MB | native | 3 |
| 29 | monthly-category-report | 1000000 | 11.4 ms | 28.1 ms | **native** | 119.8 MB | 122.8 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 17.1 ms | 23.0 ms | **native** | 149.6 MB | 151.5 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 354.7 ms | 205.6 ms | **fxdart** | 221.5 MB | 218.4 MB | tie | 3 |
| 32 | restock-plan | 1000000 | 217.1 ms | 201.8 ms | **fxdart** | 173.4 MB | 201.2 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 100000 | 359.3 ms | 364.7 ms | **tie** | 81.1 MB | 80.3 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 132.7 ms | 152.3 ms | **native** | 139.4 MB | 156.5 MB | native | 3 |
| 35 | sparse-timeseries | 1000000 | 51.5 ms | 58.4 ms | **native** | 124.5 MB | 145.2 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 344.0 ms | 397.7 ms | **native** | 81.4 MB | 97.3 MB | native | 3 |
| 37 | ledger-diff | 500000 | 227.2 ms | 308.8 ms | **native** | 176.3 MB | 171.5 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100000 | 495.1 ms | 719.4 ms | **native** | 56.1 MB | 50.6 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 167.8 ms | 268.1 ms | **native** | 237.6 MB | 230.7 MB | tie | 3 |
| 40 | latency-percentiles | 1000000 | 205.7 ms | 301.3 ms | **native** | 138.4 MB | 240.0 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 100000 | 81.9 ms | 164.2 ms | **native** | 73.6 MB | 81.5 MB | native | 3 |
| 42 | anomaly-context | 1000000 | 11.7 ms | 46.9 ms | **native** | 132.5 MB | 135.7 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 37.9 ms | 45.3 ms | **native** | 236.5 MB | 82.0 MB | fxdart | 3 |
| 44 | stream-windowed-alerts (async) | 100000 | 32.9 ms | 48.3 ms | **native** | 74.6 MB | 75.7 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 45.9 ms | 69.1 ms | **native** | 52.9 MB | 59.5 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 133.6 ms | 173.7 ms | **native** | 76.4 MB | 80.7 MB | native | 3 |
| 47 | category-rank | 1000000 | 34.5 ms | 43.5 ms | **native** | 146.2 MB | 148.0 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100000 | 321.5 ms | 368.5 ms | **native** | 80.8 MB | 80.8 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 303.7 ms | 322.9 ms | **native** | 79.8 MB | 82.8 MB | tie | 3 |
| 50 | cohort-retention | 1000000 | 641.3 ms | 671.8 ms | **tie** | 239.1 MB | 239.2 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 20000 | 1197.2 ms | 1208.8 ms | **tie** | 53.0 MB | 54.5 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 49.8 ms | 36.5 ms | **fxdart** | 56.6 MB | 57.8 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1162.7 ms | 631.6 ms | **fxdart** | 394.0 MB | 410.8 MB | tie | 3 |
