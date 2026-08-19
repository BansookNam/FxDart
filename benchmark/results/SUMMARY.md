# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-19
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 20 µs | 5.4 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.9 µs | 2.1 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 3 | sequential-configs (async) | 100 | 427 µs | 321 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 4 | average-basket | 100 | 2.0 µs | 787 ns | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 5 | paginate-users | 100 | 9.4 µs | 7.3 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 6 | rank-labels | 100 | 16 µs | 15 µs | **tie** | 16.3 MB | 16.5 MB | tie | 3 |
| 7 | running-balance | 100 | 24 µs | 22 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 8 | food-spending | 100 | 1.2 µs | 833 ns | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.4 µs | 1.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 10 | first-over-limit | 100 | 1.1 µs | 969 ns | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 11 | top-merchants | 100 | 25 µs | 138 µs | **tie** | 17.0 MB | 17.1 MB | tie | 3 |
| 12 | unique-tags | 100 | 60 µs | 48 µs | **tie** | 15.9 MB | 16.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 28 µs | 21 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 14 | valid-emails | 100 | 5.2 µs | 4.6 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100 | 323 µs | 360 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 16 | compound-interest | 100 | 18 µs | 22 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 17 | top-category-average | 100 | 8.4 µs | 7.9 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 18 | date-window-spend | 100 | 2.2 µs | 1.6 µs | **tie** | 16.5 MB | 15.3 MB | fxdart | 3 |
| 19 | sensor-anomalies | 100 | 6.9 µs | 7.0 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 20 | recent-errors | 100 | 1.4 µs | 1.5 µs | **tie** | 16.3 MB | 16.6 MB | tie | 3 |
| 21 | duplicate-transactions | 100 | 50 µs | 42 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 4.5 µs | 5.6 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 214 µs | 237 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 22 µs | 26 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 25 | weekly-sensor-averages | 98 | 4.2 µs | 4.5 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 26 | paginated-products | 100 | 6.2 µs | 6.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 27 | invoice-summary | 100 | 4.5 µs | 8.2 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.8 µs | 3.6 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.5 µs | 6.1 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 100 | 1.7 µs | 2.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 14 µs | 11 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 32 | restock-plan | 100 | 11 µs | 6.7 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 33 | price-lookup-fallback (async) | 100 | 374 µs | 395 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 24 µs | 30 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 31 µs | 29 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 373 µs | 444 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 37 | ledger-diff | 100 | 27 µs | 27 µs | **tie** | 16.6 MB | 17.1 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 556 µs | 645 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 39 | alert-digest | 100 | 21 µs | 25 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 22 µs | 20 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 94 µs | 100 µs | **tie** | 16.3 MB | 16.6 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.6 µs | 1.5 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 43 | smoothed-zone-changes | 100 | 2.3 µs | 4.3 µs | **tie** | 16.4 MB | 16.3 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 37 µs | 42 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 45 | live-search (async) | 100 | 53 µs | 68 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 156 µs | 177 µs | **tie** | 16.5 MB | 16.8 MB | tie | 3 |
| 47 | category-rank | 100 | 4.5 µs | 13 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 385 µs | 381 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 285 µs | 316 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 50 | cohort-retention | 100 | 47 µs | 37 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 100 | 371 µs | 401 µs | **tie** | 16.6 MB | 17.2 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 38 µs | 35 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 56 µs | 37 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.35 ms | 871 µs | **fxdart** | 23.1 MB | 21.3 MB | fxdart | 3 |
| 2 | top-log-level | 10000 | 353 µs | 193 µs | **tie** | 20.0 MB | 14.2 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 31.4 ms | 31.2 ms | **tie** | 50.7 MB | 51.1 MB | tie | 3 |
| 4 | average-basket | 10000 | 185 µs | 83 µs | **tie** | 19.1 MB | 15.4 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 754 µs | 628 µs | **tie** | 22.9 MB | 23.5 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.60 ms | 1.56 ms | **tie** | 34.7 MB | 37.5 MB | native | 3 |
| 7 | running-balance | 10000 | 2.07 ms | 2.11 ms | **tie** | 24.0 MB | 23.6 MB | tie | 3 |
| 8 | food-spending | 10000 | 147 µs | 100 µs | **tie** | 17.0 MB | 15.6 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 151 µs | 168 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 10 | first-over-limit | 10000 | 54 µs | 55 µs | **tie** | 15.3 MB | 15.4 MB | tie | 3 |
| 11 | top-merchants | 10000 | 712 µs | 588 µs | **tie** | 22.9 MB | 23.7 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.25 ms | 920 µs | **tie** | 20.6 MB | 23.2 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.20 ms | 1.93 ms | **tie** | 23.4 MB | 22.9 MB | tie | 3 |
| 14 | valid-emails | 10000 | 563 µs | 518 µs | **tie** | 19.9 MB | 20.0 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 10000 | 31.1 ms | 34.6 ms | **native** | 26.1 MB | 22.2 MB | fxdart | 3 |
| 16 | compound-interest | 10000 | 1.94 ms | 2.04 ms | **tie** | 22.5 MB | 22.9 MB | tie | 3 |
| 17 | top-category-average | 10000 | 365 µs | 355 µs | **tie** | 22.9 MB | 22.9 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 176 µs | 110 µs | **tie** | 20.8 MB | 15.6 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 538 µs | 625 µs | **tie** | 23.6 MB | 23.7 MB | tie | 3 |
| 20 | recent-errors | 10000 | 92 µs | 125 µs | **tie** | 15.8 MB | 15.9 MB | tie | 3 |
| 21 | duplicate-transactions | 10000 | 4.17 ms | 3.86 ms | **tie** | 40.2 MB | 36.0 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 261 µs | 262 µs | **tie** | 19.6 MB | 19.6 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 17.7 ms | 21.5 ms | **native** | 49.3 MB | 50.4 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.41 ms | 2.37 ms | **tie** | 23.5 MB | 24.1 MB | tie | 3 |
| 25 | weekly-sensor-averages | 9996 | 396 µs | 464 µs | **tie** | 22.7 MB | 22.7 MB | tie | 3 |
| 26 | paginated-products | 10000 | 886 µs | 848 µs | **tie** | 17.7 MB | 21.3 MB | native | 3 |
| 27 | invoice-summary | 10000 | 243 µs | 111 µs | **tie** | 22.4 MB | 15.8 MB | fxdart | 3 |
| 28 | budget-alerts | 10000 | 185 µs | 90 µs | **tie** | 21.8 MB | 15.6 MB | fxdart | 3 |
| 29 | monthly-category-report | 10000 | 110 µs | 147 µs | **tie** | 16.9 MB | 15.8 MB | fxdart | 3 |
| 30 | consecutive-over-limit | 10000 | 120 µs | 217 µs | **tie** | 20.5 MB | 23.5 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 784 µs | 719 µs | **tie** | 23.5 MB | 22.9 MB | tie | 3 |
| 32 | restock-plan | 10000 | 1.30 ms | 312 µs | **fxdart** | 17.5 MB | 23.4 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 34.9 ms | 34.2 ms | **tie** | 49.1 MB | 30.9 MB | fxdart | 5 |
| 34 | monthly-ledger-report | 10000 | 934 µs | 442 µs | **tie** | 23.4 MB | 17.2 MB | fxdart | 3 |
| 35 | sparse-timeseries | 10000 | 565 µs | 471 µs | **tie** | 23.0 MB | 20.2 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 31.8 ms | 37.3 ms | **native** | 50.8 MB | 33.0 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.40 ms | 3.24 ms | **native** | 26.1 MB | 31.2 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 48.2 ms | 55.5 ms | **native** | 29.5 MB | 24.5 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.46 ms | 1.39 ms | **tie** | 17.9 MB | 18.1 MB | tie | 3 |
| 40 | latency-percentiles | 10000 | 1.93 ms | 1.80 ms | **tie** | 18.1 MB | 17.3 MB | fxdart | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 7.82 ms | 8.77 ms | **native** | 43.1 MB | 24.5 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 113 µs | 93 µs | **tie** | 18.3 MB | 18.7 MB | tie | 3 |
| 43 | smoothed-zone-changes | 10000 | 194 µs | 410 µs | **tie** | 22.5 MB | 22.7 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.30 ms | 3.47 ms | **tie** | 24.0 MB | 25.2 MB | native | 3 |
| 45 | live-search (async) | 10000 | 4.86 ms | 6.12 ms | **native** | 23.5 MB | 23.6 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 12.7 ms | 17.3 ms | **native** | 24.0 MB | 27.5 MB | native | 3 |
| 47 | category-rank | 10000 | 348 µs | 299 µs | **tie** | 17.5 MB | 17.5 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 30.5 ms | 34.1 ms | **native** | 49.0 MB | 31.1 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 28.7 ms | 30.1 ms | **tie** | 51.3 MB | 31.9 MB | fxdart | 5 |
| 50 | cohort-retention | 10000 | 2.43 ms | 2.02 ms | **tie** | 17.5 MB | 18.3 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 10000 | 318.8 ms | 325.6 ms | **tie** | 50.3 MB | 50.2 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 4.21 ms | 2.97 ms | **fxdart** | 23.1 MB | 24.4 MB | native | 3 |
| 53 | price-drop-detection | 10000 | 7.05 ms | 3.62 ms | **fxdart** | 37.2 MB | 34.0 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 508.9 ms | 196.6 ms | **fxdart** | 125.0 MB | 130.9 MB | tie | 3 |
| 2 | top-log-level | 1000000 | 44.8 ms | 19.7 ms | **fxdart** | 85.7 MB | 44.9 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 323.5 ms | 329.8 ms | **tie** | 82.6 MB | 82.1 MB | tie | 5 |
| 4 | average-basket | 1000000 | 17.3 ms | 8.79 ms | **fxdart** | 75.2 MB | 72.9 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 82.1 ms | 73.7 ms | **fxdart** | 125.4 MB | 124.7 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 200.1 ms | 210.7 ms | **native** | 241.4 MB | 222.2 MB | fxdart | 3 |
| 7 | running-balance | 1000000 | 237.8 ms | 275.1 ms | **native** | 182.9 MB | 185.2 MB | tie | 3 |
| 8 | food-spending | 1000000 | 12.6 ms | 11.4 ms | **fxdart** | 91.0 MB | 85.1 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 23.8 ms | 26.2 ms | **native** | 116.6 MB | 116.0 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 4.95 ms | 5.22 ms | **tie** | 117.9 MB | 117.2 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 116.8 ms | 63.4 ms | **fxdart** | 137.3 MB | 117.8 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 106.9 ms | 77.8 ms | **fxdart** | 161.7 MB | 161.8 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 253.3 ms | 235.9 ms | **fxdart** | 176.1 MB | 178.8 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 72.5 ms | 67.1 ms | **fxdart** | 176.3 MB | 176.0 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100000 | 305.9 ms | 339.2 ms | **native** | 49.3 MB | 50.1 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 221.7 ms | 244.5 ms | **native** | 126.6 MB | 128.6 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 60.5 ms | 64.6 ms | **native** | 136.9 MB | 136.1 MB | tie | 3 |
| 18 | date-window-spend | 1000000 | 14.9 ms | 11.4 ms | **fxdart** | 124.3 MB | 120.1 MB | tie | 3 |
| 19 | sensor-anomalies | 1000000 | 61.4 ms | 76.3 ms | **native** | 162.6 MB | 159.9 MB | tie | 3 |
| 20 | recent-errors | 1000000 | 10.4 ms | 14.0 ms | **native** | 113.4 MB | 114.5 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 977.4 ms | 966.1 ms | **tie** | 324.6 MB | 332.5 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 23.8 ms | 24.0 ms | **tie** | 106.6 MB | 106.4 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100000 | 195.0 ms | 233.0 ms | **native** | 81.4 MB | 84.0 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 533.8 ms | 470.7 ms | **fxdart** | 231.5 MB | 228.0 MB | tie | 3 |
| 25 | weekly-sensor-averages | 999999 | 49.1 ms | 48.5 ms | **tie** | 97.2 MB | 146.0 MB | native | 5 |
| 26 | paginated-products | 1000000 | 102.1 ms | 120.7 ms | **native** | 177.8 MB | 195.6 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 25.3 ms | 13.6 ms | **fxdart** | 92.3 MB | 88.4 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.5 ms | 13.0 ms | **fxdart** | 90.1 MB | 82.7 MB | fxdart | 3 |
| 29 | monthly-category-report | 1000000 | 11.3 ms | 14.3 ms | **native** | 119.3 MB | 119.6 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 17.1 ms | 23.3 ms | **native** | 150.1 MB | 148.4 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 123.3 ms | 104.4 ms | **fxdart** | 201.8 MB | 220.0 MB | native | 3 |
| 32 | restock-plan | 1000000 | 216.2 ms | 51.9 ms | **fxdart** | 174.0 MB | 193.1 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 100000 | 351.3 ms | 353.2 ms | **tie** | 81.1 MB | 80.8 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 135.1 ms | 47.3 ms | **fxdart** | 157.8 MB | 127.0 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 57.3 ms | 51.2 ms | **fxdart** | 125.0 MB | 144.6 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 338.8 ms | 380.5 ms | **native** | 80.9 MB | 92.8 MB | native | 3 |
| 37 | ledger-diff | 500000 | 228.5 ms | 282.9 ms | **native** | 265.9 MB | 172.3 MB | fxdart | 3 |
| 38 | flaky-api-retry (async) | 100000 | 495.5 ms | 571.7 ms | **native** | 56.2 MB | 50.4 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 174.1 ms | 174.4 ms | **tie** | 213.2 MB | 239.8 MB | native | 5 |
| 40 | latency-percentiles | 1000000 | 204.7 ms | 209.7 ms | **tie** | 139.4 MB | 192.2 MB | native | 5 |
| 41 | paged-feeds-dedupe (async) | 100000 | 86.1 ms | 91.4 ms | **native** | 73.6 MB | 74.0 MB | tie | 3 |
| 42 | anomaly-context | 1000000 | 11.9 ms | 10.4 ms | **fxdart** | 132.2 MB | 131.7 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 39.4 ms | 37.4 ms | **fxdart** | 237.3 MB | 81.8 MB | fxdart | 3 |
| 44 | stream-windowed-alerts (async) | 100000 | 32.8 ms | 36.6 ms | **native** | 75.0 MB | 74.8 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 45.3 ms | 60.5 ms | **native** | 52.7 MB | 57.4 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 131.0 ms | 157.7 ms | **native** | 75.9 MB | 79.7 MB | tie | 3 |
| 47 | category-rank | 1000000 | 33.2 ms | 32.1 ms | **tie** | 146.9 MB | 148.0 MB | tie | 5 |
| 48 | stock-revaluation (async) | 100000 | 310.9 ms | 352.9 ms | **native** | 80.8 MB | 80.5 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 301.3 ms | 307.9 ms | **tie** | 80.3 MB | 81.0 MB | tie | 5 |
| 50 | cohort-retention | 1000000 | 717.6 ms | 722.8 ms | **tie** | 238.8 MB | 239.0 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 20000 | 1179.1 ms | 1192.2 ms | **tie** | 52.6 MB | 54.5 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 48.9 ms | 30.7 ms | **fxdart** | 56.6 MB | 58.2 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1160.5 ms | 640.7 ms | **fxdart** | 393.6 MB | 427.0 MB | native | 3 |
