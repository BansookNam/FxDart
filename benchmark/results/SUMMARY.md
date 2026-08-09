# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-09
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 19 µs | 11 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.6 µs | 3.2 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 3 | sequential-configs (async) | 100 | 331 µs | 347 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 4 | average-basket | 100 | 2.0 µs | 1.1 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 5 | paginate-users | 100 | 7.3 µs | 6.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 6 | rank-labels | 100 | 14 µs | 15 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 7 | running-balance | 100 | 19 µs | 21 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 8 | food-spending | 100 | 1.1 µs | 1.0 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.4 µs | 2.8 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 10 | first-over-limit | 100 | 910 ns | 952 ns | **tie** | 16.3 MB | 16.5 MB | tie | 3 |
| 11 | top-merchants | 100 | 23 µs | 12 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 12 | unique-tags | 100 | 54 µs | 48 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 22 µs | 21 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 14 | valid-emails | 100 | 4.8 µs | 4.4 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100 | 322 µs | 403 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 16 | compound-interest | 100 | 18 µs | 21 µs | **tie** | 16.3 MB | 16.5 MB | tie | 3 |
| 17 | top-category-average | 100 | 7.2 µs | 6.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 18 | date-window-spend | 100 | 1.8 µs | 1.4 µs | **tie** | 16.5 MB | 15.5 MB | fxdart | 3 |
| 19 | sensor-anomalies | 100 | 5.8 µs | 6.7 µs | **tie** | 16.3 MB | 16.5 MB | tie | 3 |
| 20 | recent-errors | 100 | 1.0 µs | 1.9 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 21 | duplicate-transactions | 100 | 38 µs | 40 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 4.0 µs | 5.3 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 183 µs | 221 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 21 µs | 31 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 25 | weekly-sensor-averages | 98 | 3.7 µs | 4.9 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 26 | paginated-products | 100 | 5.8 µs | 10 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 27 | invoice-summary | 100 | 3.9 µs | 5.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.2 µs | 4.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.0 µs | 4.2 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 100 | 1.8 µs | 2.8 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 33 µs | 71 µs | **tie** | 16.6 MB | 16.2 MB | tie | 3 |
| 32 | restock-plan | 100 | 11 µs | 9.4 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 33 | price-lookup-fallback (async) | 100 | 378 µs | 413 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 22 µs | 16 µs | **tie** | 16.7 MB | 16.6 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 28 µs | 29 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 340 µs | 420 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 37 | ledger-diff | 100 | 23 µs | 30 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 497 µs | 789 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 39 | alert-digest | 100 | 21 µs | 31 µs | **tie** | 16.8 MB | 16.5 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 17 µs | 20 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 89 µs | 159 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.6 µs | 2.8 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 43 | smoothed-zone-changes | 100 | 1.8 µs | 4.2 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 33 µs | 52 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 45 | live-search (async) | 100 | 52 µs | 76 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 149 µs | 191 µs | **tie** | 16.4 MB | 17.3 MB | native | 3 |
| 47 | category-rank | 100 | 3.9 µs | 8.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 307 µs | 430 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 311 µs | 346 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 50 | cohort-retention | 100 | 40 µs | 41 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 100 | 359 µs | 409 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 33 µs | 40 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 51 µs | 44 µs | **tie** | 16.7 MB | 16.5 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.20 ms | 1.81 ms | **fxdart** | 23.1 MB | 23.0 MB | tie | 3 |
| 2 | top-log-level | 10000 | 344 µs | 310 µs | **tie** | 20.0 MB | 14.1 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 31.1 ms | 31.2 ms | **tie** | 50.5 MB | 51.0 MB | tie | 3 |
| 4 | average-basket | 10000 | 181 µs | 102 µs | **tie** | 19.2 MB | 15.3 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 755 µs | 622 µs | **tie** | 22.9 MB | 23.4 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.57 ms | 1.61 ms | **tie** | 34.8 MB | 37.7 MB | native | 3 |
| 7 | running-balance | 10000 | 1.90 ms | 2.14 ms | **tie** | 24.0 MB | 23.7 MB | tie | 3 |
| 8 | food-spending | 10000 | 128 µs | 130 µs | **tie** | 16.9 MB | 15.6 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 147 µs | 286 µs | **tie** | 16.9 MB | 16.4 MB | tie | 3 |
| 10 | first-over-limit | 10000 | 53 µs | 56 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 11 | top-merchants | 10000 | 652 µs | 392 µs | **tie** | 23.0 MB | 22.9 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.23 ms | 949 µs | **tie** | 20.6 MB | 23.1 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.12 ms | 1.81 ms | **tie** | 23.3 MB | 22.9 MB | tie | 3 |
| 14 | valid-emails | 10000 | 555 µs | 528 µs | **tie** | 19.9 MB | 20.1 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 10000 | 34.6 ms | 36.7 ms | **native** | 26.6 MB | 22.3 MB | fxdart | 3 |
| 16 | compound-interest | 10000 | 1.83 ms | 2.09 ms | **tie** | 22.6 MB | 22.8 MB | tie | 3 |
| 17 | top-category-average | 10000 | 359 µs | 356 µs | **tie** | 22.8 MB | 23.0 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 152 µs | 111 µs | **tie** | 20.8 MB | 15.5 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 507 µs | 622 µs | **tie** | 23.6 MB | 23.7 MB | tie | 3 |
| 20 | recent-errors | 10000 | 88 µs | 150 µs | **tie** | 15.8 MB | 15.8 MB | tie | 3 |
| 21 | duplicate-transactions | 10000 | 3.96 ms | 3.99 ms | **tie** | 40.3 MB | 36.1 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 258 µs | 263 µs | **tie** | 19.6 MB | 19.6 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 18.6 ms | 22.1 ms | **native** | 49.3 MB | 50.1 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.50 ms | 3.28 ms | **native** | 23.5 MB | 26.9 MB | native | 3 |
| 25 | weekly-sensor-averages | 9996 | 396 µs | 466 µs | **tie** | 22.8 MB | 22.7 MB | tie | 3 |
| 26 | paginated-products | 10000 | 860 µs | 1.34 ms | **tie** | 17.8 MB | 22.4 MB | native | 3 |
| 27 | invoice-summary | 10000 | 242 µs | 264 µs | **tie** | 22.4 MB | 19.0 MB | fxdart | 3 |
| 28 | budget-alerts | 10000 | 184 µs | 243 µs | **tie** | 21.8 MB | 19.6 MB | fxdart | 3 |
| 29 | monthly-category-report | 10000 | 106 µs | 164 µs | **tie** | 17.0 MB | 16.9 MB | tie | 3 |
| 30 | consecutive-over-limit | 10000 | 118 µs | 205 µs | **tie** | 20.6 MB | 23.5 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 2.62 ms | 6.26 ms | **native** | 22.0 MB | 19.1 MB | fxdart | 3 |
| 32 | restock-plan | 10000 | 1.28 ms | 1.17 ms | **tie** | 17.4 MB | 21.8 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 36.2 ms | 35.6 ms | **tie** | 49.0 MB | 30.7 MB | fxdart | 5 |
| 34 | monthly-ledger-report | 10000 | 931 µs | 651 µs | **tie** | 23.0 MB | 23.0 MB | tie | 3 |
| 35 | sparse-timeseries | 10000 | 459 µs | 447 µs | **tie** | 23.0 MB | 20.3 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 33.1 ms | 38.5 ms | **native** | 50.9 MB | 32.8 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.61 ms | 3.49 ms | **native** | 26.1 MB | 31.4 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 50.1 ms | 70.6 ms | **native** | 28.9 MB | 24.8 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.40 ms | 2.21 ms | **native** | 17.9 MB | 21.4 MB | native | 3 |
| 40 | latency-percentiles | 10000 | 1.89 ms | 2.16 ms | **tie** | 18.1 MB | 22.4 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 7.85 ms | 14.8 ms | **native** | 43.2 MB | 27.3 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 96 µs | 196 µs | **tie** | 18.1 MB | 23.0 MB | native | 3 |
| 43 | smoothed-zone-changes | 10000 | 171 µs | 414 µs | **tie** | 22.0 MB | 22.8 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.12 ms | 4.84 ms | **native** | 23.6 MB | 26.0 MB | native | 3 |
| 45 | live-search (async) | 10000 | 4.83 ms | 6.68 ms | **native** | 23.5 MB | 23.6 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 13.1 ms | 17.2 ms | **native** | 24.1 MB | 28.1 MB | native | 3 |
| 47 | category-rank | 10000 | 289 µs | 295 µs | **tie** | 17.3 MB | 17.9 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 31.5 ms | 35.8 ms | **native** | 49.5 MB | 31.3 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 29.8 ms | 31.0 ms | **tie** | 51.2 MB | 32.1 MB | fxdart | 5 |
| 50 | cohort-retention | 10000 | 2.23 ms | 2.35 ms | **tie** | 18.1 MB | 17.7 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 10000 | 323.9 ms | 330.9 ms | **tie** | 49.9 MB | 50.2 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 4.13 ms | 3.08 ms | **fxdart** | 23.1 MB | 24.5 MB | native | 3 |
| 53 | price-drop-detection | 10000 | 7.25 ms | 3.88 ms | **fxdart** | 37.2 MB | 34.9 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 500.1 ms | 335.7 ms | **fxdart** | 125.6 MB | 204.8 MB | native | 3 |
| 2 | top-log-level | 1000000 | 43.3 ms | 31.0 ms | **fxdart** | 89.3 MB | 44.8 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 349.8 ms | 331.7 ms | **fxdart** | 82.8 MB | 82.1 MB | tie | 5 |
| 4 | average-basket | 1000000 | 16.9 ms | 9.94 ms | **fxdart** | 75.3 MB | 72.8 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 78.8 ms | 73.6 ms | **fxdart** | 122.7 MB | 122.7 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 208.5 ms | 209.1 ms | **tie** | 241.3 MB | 220.4 MB | fxdart | 5 |
| 7 | running-balance | 1000000 | 238.8 ms | 271.4 ms | **native** | 176.0 MB | 184.8 MB | tie | 3 |
| 8 | food-spending | 1000000 | 12.5 ms | 13.1 ms | **tie** | 91.0 MB | 85.1 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 25.7 ms | 46.3 ms | **native** | 115.9 MB | 119.8 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 4.95 ms | 5.22 ms | **tie** | 117.8 MB | 117.7 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 115.2 ms | 59.1 ms | **fxdart** | 137.7 MB | 118.0 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 106.8 ms | 80.9 ms | **fxdart** | 161.7 MB | 161.6 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 249.5 ms | 225.7 ms | **fxdart** | 180.4 MB | 175.9 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 71.6 ms | 69.1 ms | **tie** | 174.4 MB | 175.2 MB | tie | 5 |
| 15 | bounded-concurrency (async) | 100000 | 312.8 ms | 351.8 ms | **native** | 49.2 MB | 50.4 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 221.3 ms | 243.1 ms | **native** | 124.6 MB | 127.9 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 61.7 ms | 61.5 ms | **tie** | 133.6 MB | 132.2 MB | tie | 4 |
| 18 | date-window-spend | 1000000 | 15.2 ms | 11.3 ms | **fxdart** | 123.5 MB | 119.5 MB | tie | 3 |
| 19 | sensor-anomalies | 1000000 | 62.5 ms | 73.8 ms | **native** | 166.2 MB | 159.3 MB | tie | 3 |
| 20 | recent-errors | 1000000 | 10.2 ms | 16.6 ms | **native** | 113.8 MB | 113.4 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 967.3 ms | 955.4 ms | **tie** | 323.3 MB | 332.7 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 23.8 ms | 24.3 ms | **tie** | 106.0 MB | 105.6 MB | tie | 5 |
| 23 | concurrent-enrichment (async) | 100000 | 203.6 ms | 252.3 ms | **native** | 81.4 MB | 83.7 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 544.4 ms | 661.2 ms | **native** | 231.8 MB | 311.9 MB | native | 3 |
| 25 | weekly-sensor-averages | 999999 | 49.7 ms | 49.6 ms | **tie** | 99.1 MB | 120.0 MB | native | 4 |
| 26 | paginated-products | 1000000 | 102.5 ms | 204.7 ms | **native** | 177.8 MB | 232.8 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 24.9 ms | 26.6 ms | **native** | 89.7 MB | 91.1 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.9 ms | 27.4 ms | **native** | 89.7 MB | 90.2 MB | tie | 3 |
| 29 | monthly-category-report | 1000000 | 11.4 ms | 17.0 ms | **native** | 119.7 MB | 119.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 17.3 ms | 23.1 ms | **native** | 150.0 MB | 148.4 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 374.0 ms | 666.3 ms | **native** | 218.4 MB | 196.9 MB | fxdart | 3 |
| 32 | restock-plan | 1000000 | 218.4 ms | 201.5 ms | **fxdart** | 173.6 MB | 201.5 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 100000 | 361.7 ms | 362.7 ms | **tie** | 80.9 MB | 80.4 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 144.2 ms | 71.9 ms | **fxdart** | 139.1 MB | 131.3 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 54.0 ms | 47.8 ms | **fxdart** | 124.8 MB | 144.0 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 344.5 ms | 401.6 ms | **native** | 81.1 MB | 89.0 MB | native | 3 |
| 37 | ledger-diff | 500000 | 228.9 ms | 323.5 ms | **native** | 265.5 MB | 173.0 MB | fxdart | 3 |
| 38 | flaky-api-retry (async) | 100000 | 504.5 ms | 713.3 ms | **native** | 56.1 MB | 49.9 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 174.7 ms | 251.3 ms | **native** | 238.0 MB | 239.5 MB | tie | 3 |
| 40 | latency-percentiles | 1000000 | 203.2 ms | 283.2 ms | **native** | 216.3 MB | 207.5 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100000 | 82.1 ms | 158.7 ms | **native** | 73.6 MB | 81.3 MB | native | 3 |
| 42 | anomaly-context | 1000000 | 12.0 ms | 20.0 ms | **native** | 132.1 MB | 135.8 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 40.9 ms | 38.4 ms | **fxdart** | 158.8 MB | 82.0 MB | fxdart | 3 |
| 44 | stream-windowed-alerts (async) | 100000 | 32.5 ms | 48.2 ms | **native** | 75.0 MB | 75.8 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 46.9 ms | 68.6 ms | **native** | 53.1 MB | 59.0 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 132.6 ms | 171.3 ms | **native** | 76.4 MB | 80.3 MB | native | 3 |
| 47 | category-rank | 1000000 | 35.5 ms | 33.7 ms | **fxdart** | 146.2 MB | 145.9 MB | tie | 4 |
| 48 | stock-revaluation (async) | 100000 | 321.7 ms | 363.9 ms | **native** | 80.7 MB | 80.8 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 313.7 ms | 329.6 ms | **native** | 79.9 MB | 81.9 MB | tie | 3 |
| 50 | cohort-retention | 1000000 | 705.9 ms | 707.5 ms | **tie** | 239.0 MB | 239.0 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 20000 | 1197.8 ms | 1208.7 ms | **tie** | 53.1 MB | 54.6 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 50.1 ms | 32.3 ms | **fxdart** | 56.2 MB | 58.0 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1163.8 ms | 654.2 ms | **fxdart** | 393.1 MB | 410.4 MB | tie | 3 |
