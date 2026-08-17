# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-17
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 20 µs | 5.8 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.6 µs | 2.0 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 3 | sequential-configs (async) | 100 | 374 µs | 361 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 4 | average-basket | 100 | 2.1 µs | 1.1 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 5 | paginate-users | 100 | 7.9 µs | 6.4 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 6 | rank-labels | 100 | 16 µs | 14 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 7 | running-balance | 100 | 26 µs | 23 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 8 | food-spending | 100 | 1.1 µs | 1.0 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.5 µs | 1.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 10 | first-over-limit | 100 | 1.0 µs | 997 ns | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 11 | top-merchants | 100 | 25 µs | 142 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 12 | unique-tags | 100 | 53 µs | 45 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 24 µs | 22 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 14 | valid-emails | 100 | 4.7 µs | 4.8 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100 | 351 µs | 440 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 16 | compound-interest | 100 | 23 µs | 21 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 17 | top-category-average | 100 | 7.5 µs | 6.8 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 18 | date-window-spend | 100 | 1.9 µs | 1.5 µs | **tie** | 16.5 MB | 15.7 MB | fxdart | 3 |
| 19 | sensor-anomalies | 100 | 6.3 µs | 7.5 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 20 | recent-errors | 100 | 1.2 µs | 1.9 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 21 | duplicate-transactions | 100 | 42 µs | 39 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 4.6 µs | 5.6 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 203 µs | 248 µs | **tie** | 16.6 MB | 17.1 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 24 µs | 30 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 25 | weekly-sensor-averages | 98 | 4.4 µs | 4.9 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 26 | paginated-products | 100 | 6.4 µs | 6.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 27 | invoice-summary | 100 | 3.9 µs | 9.2 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.2 µs | 3.9 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.1 µs | 6.3 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 100 | 1.9 µs | 2.9 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 10 µs | 13 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 32 | restock-plan | 100 | 12 µs | 9.2 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 33 | price-lookup-fallback (async) | 100 | 449 µs | 408 µs | **tie** | 16.6 MB | 17.1 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 21 µs | 31 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 29 µs | 30 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 431 µs | 462 µs | **tie** | 16.4 MB | 17.0 MB | tie | 3 |
| 37 | ledger-diff | 100 | 25 µs | 30 µs | **tie** | 16.7 MB | 16.5 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 621 µs | 784 µs | **tie** | 16.4 MB | 17.0 MB | tie | 3 |
| 39 | alert-digest | 100 | 20 µs | 30 µs | **tie** | 16.7 MB | 16.6 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 18 µs | 20 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 98 µs | 109 µs | **tie** | 16.3 MB | 16.7 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.5 µs | 2.3 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 43 | smoothed-zone-changes | 100 | 2.0 µs | 4.3 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 35 µs | 52 µs | **tie** | 17.0 MB | 16.7 MB | tie | 3 |
| 45 | live-search (async) | 100 | 56 µs | 67 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 163 µs | 198 µs | **tie** | 16.5 MB | 17.4 MB | native | 3 |
| 47 | category-rank | 100 | 4.0 µs | 16 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 425 µs | 524 µs | **tie** | 16.4 MB | 17.2 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 323 µs | 325 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 50 | cohort-retention | 100 | 42 µs | 40 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 100 | 396 µs | 434 µs | **tie** | 16.6 MB | 17.2 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 44 µs | 47 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 168 µs | 111 µs | **tie** | 16.3 MB | 16.5 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.22 ms | 886 µs | **fxdart** | 23.1 MB | 22.0 MB | tie | 3 |
| 2 | top-log-level | 10000 | 365 µs | 191 µs | **tie** | 18.8 MB | 14.2 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 31.3 ms | 31.7 ms | **tie** | 50.3 MB | 50.9 MB | tie | 3 |
| 4 | average-basket | 10000 | 185 µs | 104 µs | **tie** | 18.5 MB | 15.3 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 764 µs | 629 µs | **tie** | 22.9 MB | 23.5 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.61 ms | 1.65 ms | **tie** | 34.8 MB | 37.8 MB | native | 3 |
| 7 | running-balance | 10000 | 1.93 ms | 2.13 ms | **tie** | 24.0 MB | 23.6 MB | tie | 3 |
| 8 | food-spending | 10000 | 125 µs | 127 µs | **tie** | 17.0 MB | 15.6 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 149 µs | 164 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 10 | first-over-limit | 10000 | 52 µs | 56 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 11 | top-merchants | 10000 | 682 µs | 596 µs | **tie** | 23.0 MB | 23.6 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.23 ms | 944 µs | **tie** | 20.6 MB | 23.2 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.10 ms | 1.93 ms | **tie** | 22.9 MB | 22.9 MB | tie | 3 |
| 14 | valid-emails | 10000 | 560 µs | 533 µs | **tie** | 20.0 MB | 20.0 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 10000 | 31.7 ms | 35.5 ms | **native** | 26.6 MB | 22.7 MB | fxdart | 3 |
| 16 | compound-interest | 10000 | 1.88 ms | 2.05 ms | **tie** | 22.6 MB | 22.8 MB | tie | 3 |
| 17 | top-category-average | 10000 | 342 µs | 359 µs | **tie** | 23.0 MB | 23.0 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 152 µs | 112 µs | **tie** | 20.8 MB | 15.6 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 523 µs | 632 µs | **tie** | 23.7 MB | 23.7 MB | tie | 3 |
| 20 | recent-errors | 10000 | 91 µs | 145 µs | **tie** | 15.8 MB | 15.9 MB | tie | 3 |
| 21 | duplicate-transactions | 10000 | 4.14 ms | 4.02 ms | **tie** | 40.2 MB | 36.1 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 252 µs | 255 µs | **tie** | 19.6 MB | 19.6 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 18.6 ms | 21.8 ms | **native** | 49.4 MB | 49.9 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.38 ms | 2.97 ms | **tie** | 23.5 MB | 25.3 MB | native | 3 |
| 25 | weekly-sensor-averages | 9996 | 398 µs | 453 µs | **tie** | 22.7 MB | 22.8 MB | tie | 3 |
| 26 | paginated-products | 10000 | 809 µs | 823 µs | **tie** | 17.7 MB | 20.8 MB | native | 3 |
| 27 | invoice-summary | 10000 | 238 µs | 185 µs | **tie** | 22.4 MB | 22.4 MB | tie | 3 |
| 28 | budget-alerts | 10000 | 182 µs | 173 µs | **tie** | 21.8 MB | 20.8 MB | tie | 3 |
| 29 | monthly-category-report | 10000 | 109 µs | 169 µs | **tie** | 17.0 MB | 17.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 10000 | 115 µs | 203 µs | **tie** | 21.0 MB | 23.5 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 724 µs | 850 µs | **tie** | 23.5 MB | 23.0 MB | tie | 3 |
| 32 | restock-plan | 10000 | 1.25 ms | 1.14 ms | **tie** | 17.5 MB | 20.4 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 36.9 ms | 36.3 ms | **tie** | 49.2 MB | 30.7 MB | fxdart | 5 |
| 34 | monthly-ledger-report | 10000 | 891 µs | 559 µs | **tie** | 22.9 MB | 23.1 MB | tie | 3 |
| 35 | sparse-timeseries | 10000 | 463 µs | 452 µs | **tie** | 23.0 MB | 20.3 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 33.9 ms | 40.2 ms | **native** | 51.0 MB | 32.9 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.69 ms | 3.55 ms | **native** | 26.1 MB | 31.1 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 51.3 ms | 75.5 ms | **native** | 29.1 MB | 25.2 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.35 ms | 2.19 ms | **native** | 18.0 MB | 21.5 MB | native | 3 |
| 40 | latency-percentiles | 10000 | 1.91 ms | 2.17 ms | **tie** | 18.2 MB | 21.2 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 8.78 ms | 9.58 ms | **native** | 43.1 MB | 24.5 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 99 µs | 174 µs | **tie** | 18.2 MB | 23.1 MB | native | 3 |
| 43 | smoothed-zone-changes | 10000 | 183 µs | 409 µs | **tie** | 22.0 MB | 22.8 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.15 ms | 5.00 ms | **native** | 24.0 MB | 25.3 MB | native | 3 |
| 45 | live-search (async) | 10000 | 4.67 ms | 6.26 ms | **native** | 23.1 MB | 23.7 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 13.5 ms | 16.2 ms | **native** | 24.3 MB | 28.0 MB | native | 3 |
| 47 | category-rank | 10000 | 293 µs | 317 µs | **tie** | 17.3 MB | 17.6 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 34.5 ms | 37.3 ms | **native** | 49.0 MB | 31.3 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 30.8 ms | 32.7 ms | **native** | 51.2 MB | 32.1 MB | fxdart | 3 |
| 50 | cohort-retention | 10000 | 2.27 ms | 2.31 ms | **tie** | 18.1 MB | 17.6 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 10000 | 330.3 ms | 337.4 ms | **tie** | 50.0 MB | 50.2 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 8.59 ms | 7.67 ms | **fxdart** | 23.0 MB | 24.5 MB | native | 3 |
| 53 | price-drop-detection | 10000 | 23.4 ms | 12.1 ms | **fxdart** | 37.2 MB | 34.5 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 508.6 ms | 218.0 ms | **fxdart** | 126.1 MB | 136.3 MB | native | 3 |
| 2 | top-log-level | 1000000 | 44.5 ms | 19.7 ms | **fxdart** | 93.3 MB | 44.8 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 339.9 ms | 329.6 ms | **tie** | 83.5 MB | 82.1 MB | tie | 5 |
| 4 | average-basket | 1000000 | 17.1 ms | 10.2 ms | **fxdart** | 75.1 MB | 72.9 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 82.6 ms | 76.3 ms | **fxdart** | 125.1 MB | 126.4 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 206.5 ms | 214.4 ms | **tie** | 241.2 MB | 220.3 MB | fxdart | 5 |
| 7 | running-balance | 1000000 | 241.7 ms | 275.2 ms | **native** | 176.2 MB | 185.5 MB | native | 3 |
| 8 | food-spending | 1000000 | 12.4 ms | 13.1 ms | **native** | 91.0 MB | 85.0 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 25.3 ms | 27.0 ms | **native** | 116.2 MB | 116.2 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 5.00 ms | 5.24 ms | **tie** | 117.3 MB | 117.3 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 119.2 ms | 59.9 ms | **fxdart** | 137.8 MB | 118.0 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 107.6 ms | 78.5 ms | **fxdart** | 161.9 MB | 161.4 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 262.6 ms | 244.0 ms | **fxdart** | 181.2 MB | 178.4 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 71.7 ms | 69.1 ms | **tie** | 174.5 MB | 175.3 MB | tie | 5 |
| 15 | bounded-concurrency (async) | 100000 | 317.0 ms | 354.7 ms | **native** | 49.4 MB | 50.5 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 223.6 ms | 249.0 ms | **native** | 126.5 MB | 128.9 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 63.1 ms | 63.3 ms | **tie** | 134.5 MB | 135.6 MB | tie | 3 |
| 18 | date-window-spend | 1000000 | 15.1 ms | 11.6 ms | **fxdart** | 126.3 MB | 119.3 MB | fxdart | 3 |
| 19 | sensor-anomalies | 1000000 | 66.3 ms | 74.3 ms | **native** | 170.0 MB | 159.7 MB | fxdart | 3 |
| 20 | recent-errors | 1000000 | 10.5 ms | 16.3 ms | **native** | 113.4 MB | 114.2 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 989.4 ms | 981.5 ms | **tie** | 323.2 MB | 332.8 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 23.8 ms | 23.7 ms | **tie** | 105.9 MB | 106.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100000 | 205.6 ms | 242.1 ms | **native** | 81.4 MB | 81.2 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 546.8 ms | 653.5 ms | **native** | 232.3 MB | 293.3 MB | native | 3 |
| 25 | weekly-sensor-averages | 999999 | 49.8 ms | 50.2 ms | **tie** | 99.4 MB | 145.5 MB | native | 4 |
| 26 | paginated-products | 1000000 | 103.3 ms | 126.5 ms | **native** | 177.8 MB | 207.0 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 24.7 ms | 20.0 ms | **fxdart** | 89.3 MB | 89.6 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.8 ms | 19.1 ms | **fxdart** | 90.0 MB | 90.6 MB | tie | 3 |
| 29 | monthly-category-report | 1000000 | 11.4 ms | 16.9 ms | **native** | 120.1 MB | 121.7 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 17.1 ms | 23.1 ms | **native** | 149.8 MB | 149.1 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 124.7 ms | 128.2 ms | **tie** | 202.0 MB | 207.9 MB | tie | 5 |
| 32 | restock-plan | 1000000 | 219.1 ms | 199.5 ms | **fxdart** | 173.4 MB | 189.2 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 100000 | 367.2 ms | 368.2 ms | **tie** | 81.0 MB | 80.9 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 139.0 ms | 61.3 ms | **fxdart** | 161.7 MB | 134.1 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 57.8 ms | 49.3 ms | **fxdart** | 123.9 MB | 143.4 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 355.7 ms | 411.8 ms | **native** | 80.9 MB | 92.2 MB | native | 3 |
| 37 | ledger-diff | 500000 | 242.4 ms | 327.5 ms | **native** | 265.7 MB | 172.0 MB | fxdart | 3 |
| 38 | flaky-api-retry (async) | 100000 | 515.5 ms | 732.0 ms | **native** | 56.1 MB | 50.5 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 177.6 ms | 259.2 ms | **native** | 238.1 MB | 126.5 MB | fxdart | 3 |
| 40 | latency-percentiles | 1000000 | 211.0 ms | 282.2 ms | **native** | 138.8 MB | 220.3 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 100000 | 87.9 ms | 98.1 ms | **native** | 73.6 MB | 74.5 MB | tie | 3 |
| 42 | anomaly-context | 1000000 | 12.3 ms | 18.3 ms | **native** | 131.9 MB | 135.3 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 41.2 ms | 37.8 ms | **fxdart** | 161.4 MB | 82.3 MB | fxdart | 3 |
| 44 | stream-windowed-alerts (async) | 100000 | 33.0 ms | 48.5 ms | **native** | 75.0 MB | 75.6 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 48.0 ms | 64.6 ms | **native** | 53.6 MB | 57.6 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 138.0 ms | 165.0 ms | **native** | 76.4 MB | 79.7 MB | tie | 3 |
| 47 | category-rank | 1000000 | 35.7 ms | 34.6 ms | **tie** | 146.8 MB | 145.1 MB | tie | 5 |
| 48 | stock-revaluation (async) | 100000 | 356.9 ms | 378.8 ms | **native** | 80.9 MB | 80.8 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 318.5 ms | 339.5 ms | **native** | 79.9 MB | 80.5 MB | tie | 3 |
| 50 | cohort-retention | 1000000 | 764.8 ms | 757.1 ms | **tie** | 238.8 MB | 238.7 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 20000 | 1207.8 ms | 1228.7 ms | **tie** | 53.1 MB | 54.6 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 226.4 ms | 147.2 ms | **fxdart** | 56.3 MB | 58.8 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 3480.0 ms | 780.0 ms | **fxdart** | 414.4 MB | 443.7 MB | native | 3 |
