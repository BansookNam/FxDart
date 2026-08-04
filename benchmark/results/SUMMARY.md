# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-04
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 100 | 1.2 µs | 2.4 µs | **tie** | 16.4 MB | 15.4 MB | fxdart | 3 |
| 2 | running-balance | 100 | 19 µs | 24 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 3 | top-expenses | 100 | 19 µs | 11 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 4 | first-visit-merchants | 100 | 1.5 µs | 3.4 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 5 | average-basket | 100 | 2.0 µs | 2.1 µs | **tie** | 16.5 MB | 16.1 MB | tie | 3 |
| 6 | first-over-limit | 100 | 916 ns | 1.6 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 7 | top-log-level | 100 | 3.9 µs | 4.3 µs | **tie** | 16.5 MB | 16.3 MB | tie | 3 |
| 8 | paginate-users | 100 | 8.1 µs | 8.9 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 9 | rank-labels | 100 | 14 µs | 17 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 10 | sequential-configs (async) | 100 | 333 µs | 385 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 11 | top-merchants | 100 | 23 µs | 14 µs | **tie** | 16.6 MB | 16.4 MB | tie | 5 |
| 12 | recent-errors | 100 | 1.1 µs | 3.1 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 13 | date-window-spend | 100 | 1.7 µs | 2.4 µs | **tie** | 16.4 MB | 16.0 MB | tie | 3 |
| 14 | unique-tags | 100 | 53 µs | 47 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 15 | refunds-vs-charges | 100 | 22 µs | 20 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 16 | compound-interest | 100 | 19 µs | 21 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 17 | sensor-anomalies | 100 | 5.7 µs | 8.1 µs | **tie** | 16.3 MB | 16.5 MB | tie | 3 |
| 18 | top-category-average | 100 | 7.5 µs | 8.5 µs | **tie** | 16.6 MB | 17.0 MB | tie | 3 |
| 19 | valid-emails | 100 | 4.8 µs | 5.7 µs | **tie** | 16.3 MB | 16.4 MB | tie | 3 |
| 20 | bounded-concurrency (async) | 100 | 357 µs | 404 µs | **tie** | 16.4 MB | 17.0 MB | tie | 3 |
| 21 | monthly-category-report | 100 | 2.1 µs | 5.5 µs | **tie** | 15.6 MB | 16.6 MB | native | 3 |
| 22 | paginated-products | 100 | 5.8 µs | 10 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 23 | weekly-sensor-averages | 98 | 4.3 µs | 6.8 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 24 | consecutive-over-limit | 100 | 1.9 µs | 8.6 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 25 | budget-alerts | 100 | 3.2 µs | 7.2 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 26 | leaderboard-ties | 100 | 22 µs | 31 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 27 | invoice-summary | 100 | 4.2 µs | 8.1 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 28 | no-spend-streak | 100 | 4.1 µs | 5.5 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 29 | duplicate-transactions | 100 | 39 µs | 42 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 30 | concurrent-enrichment (async) | 100 | 187 µs | 239 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 31 | monthly-ledger-report | 100 | 21 µs | 23 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 32 | cohort-retention | 100 | 42 µs | 47 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 33 | price-drop-detection | 100 | 51 µs | 35 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 34 | anomaly-context | 100 | 1.5 µs | 5.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 30 µs | 33 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 36 | multi-currency-report | 100 | 34 µs | 19 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 37 | restock-plan | 100 | 10 µs | 9.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 38 | alert-digest | 100 | 20 µs | 32 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 39 | latency-percentiles | 100 | 17 µs | 23 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 40 | ledger-diff | 100 | 23 µs | 32 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 41 | concurrent-profile-fetch (async) | 100 | 294 µs | 325 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 42 | flaky-api-retry (async) | 100 | 507 µs | 755 µs | **tie** | 16.3 MB | 17.1 MB | tie | 3 |
| 43 | price-lookup-fallback (async) | 100 | 384 µs | 370 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 44 µs | 50 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 45 | rate-limited-import (async) | 100 | 160 µs | 191 µs | **tie** | 16.3 MB | 17.2 MB | native | 3 |
| 46 | parallel-downloads (async) | 100 | 346 µs | 403 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 47 | paged-feeds-dedupe (async) | 100 | 104 µs | 174 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 48 | settlement-pipeline (async) | 100 | 32 µs | 45 µs | **tie** | 16.6 MB | 16.7 MB | tie | 3 |
| 49 | live-search (async) | 100 | 53 µs | 76 µs | **tie** | 16.4 MB | 17.2 MB | native | 3 |
| 50 | daily-ledger-close (async) | 100 | 404 µs | 464 µs | **tie** | 16.6 MB | 17.2 MB | tie | 3 |
| 51 | category-rank | 100 | 3.8 µs | 9.3 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 52 | stock-revaluation (async) | 100 | 330 µs | 410 µs | **tie** | 16.9 MB | 17.1 MB | tie | 3 |
| 53 | smoothed-zone-changes | 100 | 1.8 µs | 6.4 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 10000 | 124 µs | 221 µs | **tie** | 16.9 MB | 15.6 MB | fxdart | 3 |
| 2 | running-balance | 10000 | 1.89 ms | 2.23 ms | **tie** | 23.9 MB | 23.6 MB | tie | 3 |
| 3 | top-expenses | 10000 | 3.36 ms | 1.90 ms | **fxdart** | 23.1 MB | 22.9 MB | tie | 3 |
| 4 | first-visit-merchants | 10000 | 157 µs | 322 µs | **tie** | 17.2 MB | 16.4 MB | tie | 3 |
| 5 | average-basket | 10000 | 188 µs | 187 µs | **tie** | 19.1 MB | 15.3 MB | fxdart | 3 |
| 6 | first-over-limit | 10000 | 54 µs | 119 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 7 | top-log-level | 10000 | 346 µs | 410 µs | **tie** | 18.8 MB | 14.1 MB | fxdart | 3 |
| 8 | paginate-users | 10000 | 750 µs | 780 µs | **tie** | 22.9 MB | 23.4 MB | tie | 3 |
| 9 | rank-labels | 10000 | 1.58 ms | 1.70 ms | **tie** | 34.8 MB | 37.8 MB | native | 3 |
| 10 | sequential-configs (async) | 10000 | 31.9 ms | 31.7 ms | **tie** | 50.6 MB | 50.3 MB | tie | 4 |
| 11 | top-merchants | 10000 | 663 µs | 482 µs | **tie** | 23.0 MB | 22.9 MB | tie | 5 |
| 12 | recent-errors | 10000 | 86 µs | 232 µs | **tie** | 15.8 MB | 15.8 MB | tie | 3 |
| 13 | date-window-spend | 10000 | 156 µs | 206 µs | **tie** | 20.7 MB | 15.5 MB | fxdart | 3 |
| 14 | unique-tags | 10000 | 1.22 ms | 875 µs | **tie** | 20.5 MB | 23.3 MB | native | 3 |
| 15 | refunds-vs-charges | 10000 | 2.08 ms | 1.87 ms | **tie** | 23.3 MB | 23.0 MB | tie | 3 |
| 16 | compound-interest | 10000 | 1.80 ms | 2.06 ms | **tie** | 22.7 MB | 22.8 MB | tie | 3 |
| 17 | sensor-anomalies | 10000 | 509 µs | 735 µs | **tie** | 23.6 MB | 23.6 MB | tie | 3 |
| 18 | top-category-average | 10000 | 367 µs | 459 µs | **tie** | 23.0 MB | 22.8 MB | tie | 3 |
| 19 | valid-emails | 10000 | 549 µs | 589 µs | **tie** | 20.0 MB | 20.0 MB | tie | 3 |
| 20 | bounded-concurrency (async) | 10000 | 31.7 ms | 33.7 ms | **native** | 26.0 MB | 22.2 MB | fxdart | 3 |
| 21 | monthly-category-report | 10000 | 108 µs | 256 µs | **tie** | 16.9 MB | 17.4 MB | tie | 3 |
| 22 | paginated-products | 10000 | 799 µs | 1.37 ms | **tie** | 17.7 MB | 23.0 MB | native | 3 |
| 23 | weekly-sensor-averages | 9996 | 396 µs | 634 µs | **tie** | 22.8 MB | 22.8 MB | tie | 3 |
| 24 | consecutive-over-limit | 10000 | 114 µs | 764 µs | **native** | 20.6 MB | 23.5 MB | native | 3 |
| 25 | budget-alerts | 10000 | 177 µs | 401 µs | **tie** | 21.8 MB | 17.9 MB | fxdart | 3 |
| 26 | leaderboard-ties | 10000 | 2.35 ms | 3.19 ms | **native** | 23.5 MB | 26.9 MB | native | 3 |
| 27 | invoice-summary | 10000 | 234 µs | 403 µs | **tie** | 22.4 MB | 16.9 MB | fxdart | 3 |
| 28 | no-spend-streak | 10000 | 251 µs | 257 µs | **tie** | 19.5 MB | 19.6 MB | tie | 3 |
| 29 | duplicate-transactions | 10000 | 4.06 ms | 4.03 ms | **tie** | 40.3 MB | 36.0 MB | fxdart | 3 |
| 30 | concurrent-enrichment (async) | 10000 | 17.9 ms | 22.2 ms | **native** | 49.3 MB | 49.9 MB | tie | 3 |
| 31 | monthly-ledger-report | 10000 | 903 µs | 1.09 ms | **tie** | 22.9 MB | 23.0 MB | tie | 3 |
| 32 | cohort-retention | 10000 | 2.43 ms | 2.58 ms | **tie** | 17.6 MB | 17.5 MB | tie | 3 |
| 33 | price-drop-detection | 10000 | 7.31 ms | 3.60 ms | **fxdart** | 37.1 MB | 34.8 MB | fxdart | 3 |
| 34 | anomaly-context | 10000 | 92 µs | 458 µs | **tie** | 18.3 MB | 23.1 MB | native | 3 |
| 35 | sparse-timeseries | 10000 | 456 µs | 552 µs | **tie** | 23.0 MB | 18.7 MB | fxdart | 3 |
| 36 | multi-currency-report | 10000 | 2.62 ms | 1.28 ms | **fxdart** | 22.0 MB | 23.3 MB | native | 3 |
| 37 | restock-plan | 10000 | 1.24 ms | 1.19 ms | **tie** | 17.5 MB | 21.9 MB | native | 3 |
| 38 | alert-digest | 10000 | 1.36 ms | 2.27 ms | **native** | 17.9 MB | 21.5 MB | native | 3 |
| 39 | latency-percentiles | 10000 | 1.95 ms | 2.30 ms | **tie** | 18.1 MB | 22.4 MB | native | 3 |
| 40 | ledger-diff | 10000 | 2.45 ms | 3.57 ms | **native** | 26.1 MB | 31.5 MB | native | 3 |
| 41 | concurrent-profile-fetch (async) | 10000 | 27.9 ms | 31.1 ms | **native** | 51.8 MB | 32.0 MB | fxdart | 3 |
| 42 | flaky-api-retry (async) | 10000 | 49.0 ms | 69.3 ms | **native** | 29.2 MB | 24.7 MB | fxdart | 3 |
| 43 | price-lookup-fallback (async) | 10000 | 36.3 ms | 34.7 ms | **tie** | 48.9 MB | 31.3 MB | fxdart | 5 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.13 ms | 4.70 ms | **native** | 23.6 MB | 26.0 MB | native | 3 |
| 45 | rate-limited-import (async) | 10000 | 12.6 ms | 16.5 ms | **native** | 24.0 MB | 28.0 MB | native | 3 |
| 46 | parallel-downloads (async) | 10000 | 32.4 ms | 37.3 ms | **native** | 50.8 MB | 32.8 MB | fxdart | 3 |
| 47 | paged-feeds-dedupe (async) | 10000 | 7.79 ms | 14.9 ms | **native** | 43.1 MB | 27.2 MB | fxdart | 3 |
| 48 | settlement-pipeline (async) | 10000 | 4.07 ms | 3.35 ms | **fxdart** | 23.2 MB | 24.3 MB | tie | 3 |
| 49 | live-search (async) | 10000 | 4.60 ms | 6.67 ms | **native** | 23.5 MB | 23.8 MB | tie | 3 |
| 50 | daily-ledger-close (async) | 10000 | 327.9 ms | 336.6 ms | **tie** | 49.9 MB | 50.2 MB | tie | 5 |
| 51 | category-rank | 10000 | 284 µs | 380 µs | **tie** | 17.4 MB | 18.0 MB | tie | 3 |
| 52 | stock-revaluation (async) | 10000 | 29.8 ms | 36.5 ms | **native** | 49.1 MB | 31.3 MB | fxdart | 3 |
| 53 | smoothed-zone-changes | 10000 | 191 µs | 641 µs | **tie** | 22.0 MB | 22.3 MB | tie | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 1000000 | 12.5 ms | 22.2 ms | **native** | 90.7 MB | 85.0 MB | fxdart | 3 |
| 2 | running-balance | 1000000 | 243.6 ms | 288.7 ms | **native** | 183.3 MB | 185.3 MB | tie | 3 |
| 3 | top-expenses | 1000000 | 538.7 ms | 354.8 ms | **fxdart** | 126.3 MB | 182.8 MB | native | 3 |
| 4 | first-visit-merchants | 1000000 | 25.9 ms | 59.8 ms | **native** | 116.1 MB | 119.8 MB | tie | 3 |
| 5 | average-basket | 1000000 | 17.5 ms | 18.8 ms | **native** | 75.3 MB | 72.8 MB | tie | 3 |
| 6 | first-over-limit | 1000000 | 5.07 ms | 11.9 ms | **native** | 116.9 MB | 117.5 MB | tie | 3 |
| 7 | top-log-level | 1000000 | 44.2 ms | 41.8 ms | **fxdart** | 79.8 MB | 44.8 MB | fxdart | 3 |
| 8 | paginate-users | 1000000 | 81.3 ms | 90.6 ms | **native** | 122.8 MB | 126.8 MB | tie | 3 |
| 9 | rank-labels | 1000000 | 202.4 ms | 216.0 ms | **native** | 241.0 MB | 221.9 MB | fxdart | 3 |
| 10 | sequential-configs (async) | 100000 | 324.3 ms | 322.2 ms | **tie** | 82.6 MB | 82.1 MB | tie | 5 |
| 11 | top-merchants | 1000000 | 116.1 ms | 65.6 ms | **fxdart** | 137.4 MB | 118.5 MB | fxdart | 5 |
| 12 | recent-errors | 1000000 | 10.2 ms | 26.0 ms | **native** | 113.9 MB | 113.5 MB | tie | 3 |
| 13 | date-window-spend | 1000000 | 14.9 ms | 20.8 ms | **native** | 125.8 MB | 119.2 MB | fxdart | 3 |
| 14 | unique-tags | 1000000 | 107.8 ms | 74.3 ms | **fxdart** | 161.8 MB | 161.8 MB | tie | 3 |
| 15 | refunds-vs-charges | 1000000 | 249.4 ms | 233.6 ms | **fxdart** | 180.8 MB | 176.9 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 219.9 ms | 242.1 ms | **native** | 128.2 MB | 126.5 MB | tie | 3 |
| 17 | sensor-anomalies | 1000000 | 63.2 ms | 85.7 ms | **native** | 162.5 MB | 159.8 MB | tie | 3 |
| 18 | top-category-average | 1000000 | 56.7 ms | 69.3 ms | **native** | 134.7 MB | 130.5 MB | tie | 3 |
| 19 | valid-emails | 1000000 | 70.9 ms | 74.1 ms | **tie** | 174.6 MB | 174.1 MB | tie | 5 |
| 20 | bounded-concurrency (async) | 100000 | 314.2 ms | 343.9 ms | **native** | 49.4 MB | 50.4 MB | tie | 3 |
| 21 | monthly-category-report | 1000000 | 11.3 ms | 27.8 ms | **native** | 120.4 MB | 122.9 MB | tie | 3 |
| 22 | paginated-products | 1000000 | 102.2 ms | 206.2 ms | **native** | 177.8 MB | 238.5 MB | native | 3 |
| 23 | weekly-sensor-averages | 999999 | 48.9 ms | 74.9 ms | **native** | 97.3 MB | 98.5 MB | tie | 3 |
| 24 | consecutive-over-limit | 1000000 | 16.4 ms | 78.8 ms | **native** | 149.8 MB | 148.3 MB | tie | 3 |
| 25 | budget-alerts | 1000000 | 21.5 ms | 54.6 ms | **native** | 90.2 MB | 109.0 MB | native | 3 |
| 26 | leaderboard-ties | 1000000 | 526.6 ms | 659.7 ms | **native** | 232.0 MB | 311.4 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 24.9 ms | 55.6 ms | **native** | 89.0 MB | 106.9 MB | native | 3 |
| 28 | no-spend-streak | 1000000 | 23.9 ms | 23.5 ms | **tie** | 106.0 MB | 105.9 MB | tie | 3 |
| 29 | duplicate-transactions | 1000000 | 935.4 ms | 938.9 ms | **tie** | 323.2 MB | 328.7 MB | tie | 5 |
| 30 | concurrent-enrichment (async) | 100000 | 192.9 ms | 245.0 ms | **native** | 81.4 MB | 83.6 MB | tie | 3 |
| 31 | monthly-ledger-report | 1000000 | 143.7 ms | 159.5 ms | **native** | 138.6 MB | 155.9 MB | native | 3 |
| 32 | cohort-retention | 1000000 | 611.4 ms | 622.4 ms | **tie** | 238.7 MB | 239.0 MB | tie | 5 |
| 33 | price-drop-detection | 1000000 | 1166.1 ms | 647.7 ms | **fxdart** | 394.3 MB | 410.6 MB | tie | 3 |
| 34 | anomaly-context | 1000000 | 11.5 ms | 45.6 ms | **native** | 132.6 MB | 135.2 MB | tie | 3 |
| 35 | sparse-timeseries | 1000000 | 52.6 ms | 58.4 ms | **native** | 125.9 MB | 143.1 MB | native | 3 |
| 36 | multi-currency-report | 1000000 | 349.3 ms | 209.0 ms | **fxdart** | 217.4 MB | 223.5 MB | tie | 3 |
| 37 | restock-plan | 1000000 | 213.8 ms | 204.2 ms | **tie** | 172.9 MB | 200.6 MB | native | 5 |
| 38 | alert-digest | 1000000 | 172.8 ms | 260.6 ms | **native** | 237.3 MB | 239.1 MB | tie | 3 |
| 39 | latency-percentiles | 1000000 | 195.7 ms | 295.0 ms | **native** | 216.3 MB | 137.5 MB | fxdart | 3 |
| 40 | ledger-diff | 500000 | 223.1 ms | 297.4 ms | **native** | 264.9 MB | 170.1 MB | fxdart | 3 |
| 41 | concurrent-profile-fetch (async) | 100000 | 299.2 ms | 323.9 ms | **native** | 79.9 MB | 81.5 MB | tie | 3 |
| 42 | flaky-api-retry (async) | 100000 | 490.7 ms | 696.4 ms | **native** | 56.1 MB | 50.1 MB | fxdart | 3 |
| 43 | price-lookup-fallback (async) | 100000 | 357.8 ms | 359.0 ms | **tie** | 81.0 MB | 80.4 MB | tie | 5 |
| 44 | stream-windowed-alerts (async) | 100000 | 31.6 ms | 48.0 ms | **native** | 74.8 MB | 75.3 MB | tie | 3 |
| 45 | rate-limited-import (async) | 100000 | 131.3 ms | 172.7 ms | **native** | 76.4 MB | 80.5 MB | native | 3 |
| 46 | parallel-downloads (async) | 100000 | 342.9 ms | 399.3 ms | **native** | 80.9 MB | 124.7 MB | native | 3 |
| 47 | paged-feeds-dedupe (async) | 100000 | 80.5 ms | 156.9 ms | **native** | 74.1 MB | 81.5 MB | native | 3 |
| 48 | settlement-pipeline (async) | 100000 | 51.6 ms | 37.2 ms | **fxdart** | 56.8 MB | 57.6 MB | tie | 3 |
| 49 | live-search (async) | 100000 | 45.9 ms | 67.9 ms | **native** | 52.9 MB | 59.6 MB | native | 3 |
| 50 | daily-ledger-close (async) | 20000 | 1199.8 ms | 1225.7 ms | **tie** | 53.1 MB | 54.7 MB | tie | 5 |
| 51 | category-rank | 1000000 | 33.6 ms | 41.8 ms | **native** | 146.6 MB | 147.8 MB | tie | 3 |
| 52 | stock-revaluation (async) | 100000 | 308.6 ms | 363.2 ms | **native** | 80.8 MB | 81.1 MB | tie | 3 |
| 53 | smoothed-zone-changes | 1000000 | 37.0 ms | 60.0 ms | **native** | 234.5 MB | 82.2 MB | fxdart | 3 |
