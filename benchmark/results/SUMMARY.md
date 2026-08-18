# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-18
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 19 µs | 7.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.9 µs | 2.0 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 3 | sequential-configs (async) | 100 | 415 µs | 330 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 4 | average-basket | 100 | 2.2 µs | 780 ns | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 5 | paginate-users | 100 | 8.7 µs | 7.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 6 | rank-labels | 100 | 16 µs | 15 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 7 | running-balance | 100 | 23 µs | 24 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 8 | food-spending | 100 | 1.3 µs | 838 ns | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.4 µs | 1.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 10 | first-over-limit | 100 | 1.1 µs | 989 ns | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 11 | top-merchants | 100 | 27 µs | 136 µs | **tie** | 17.0 MB | 17.2 MB | tie | 3 |
| 12 | unique-tags | 100 | 60 µs | 46 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 22 µs | 20 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 14 | valid-emails | 100 | 5.9 µs | 4.8 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100 | 379 µs | 377 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 16 | compound-interest | 100 | 21 µs | 20 µs | **tie** | 16.3 MB | 16.6 MB | tie | 3 |
| 17 | top-category-average | 100 | 8.4 µs | 8.0 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 18 | date-window-spend | 100 | 1.9 µs | 1.4 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 19 | sensor-anomalies | 100 | 5.8 µs | 7.9 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 20 | recent-errors | 100 | 1.1 µs | 1.4 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 21 | duplicate-transactions | 100 | 46 µs | 42 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 4.3 µs | 5.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 213 µs | 243 µs | **tie** | 16.6 MB | 17.1 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 24 µs | 30 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 25 | weekly-sensor-averages | 98 | 4.3 µs | 4.9 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 26 | paginated-products | 100 | 7.2 µs | 7.8 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 27 | invoice-summary | 100 | 4.4 µs | 8.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.9 µs | 3.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.3 µs | 6.1 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 100 | 2.1 µs | 3.1 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 12 µs | 11 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 32 | restock-plan | 100 | 12 µs | 10 µs | **tie** | 14.7 MB | 16.4 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 100 | 475 µs | 377 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 27 µs | 31 µs | **tie** | 16.5 MB | 16.3 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 31 µs | 30 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 409 µs | 424 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 37 | ledger-diff | 100 | 21 µs | 25 µs | **tie** | 16.7 MB | 16.5 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 570 µs | 679 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 39 | alert-digest | 100 | 23 µs | 25 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 19 µs | 18 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 111 µs | 93 µs | **tie** | 16.3 MB | 16.6 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.8 µs | 1.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 43 | smoothed-zone-changes | 100 | 2.1 µs | 4.1 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 37 µs | 42 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 45 | live-search (async) | 100 | 56 µs | 68 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 157 µs | 162 µs | **tie** | 16.4 MB | 16.8 MB | tie | 3 |
| 47 | category-rank | 100 | 3.7 µs | 13 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 346 µs | 398 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 363 µs | 299 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 50 | cohort-retention | 100 | 47 µs | 38 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 100 | 414 µs | 443 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 34 µs | 35 µs | **tie** | 16.6 MB | 16.7 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 58 µs | 37 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.27 ms | 885 µs | **fxdart** | 23.1 MB | 22.0 MB | fxdart | 3 |
| 2 | top-log-level | 10000 | 368 µs | 198 µs | **tie** | 18.9 MB | 14.2 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 31.4 ms | 33.2 ms | **native** | 50.7 MB | 50.6 MB | tie | 3 |
| 4 | average-basket | 10000 | 184 µs | 86 µs | **tie** | 18.5 MB | 15.3 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 768 µs | 653 µs | **tie** | 22.8 MB | 23.4 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.61 ms | 1.64 ms | **tie** | 34.7 MB | 37.7 MB | native | 3 |
| 7 | running-balance | 10000 | 2.10 ms | 2.12 ms | **tie** | 24.0 MB | 23.6 MB | tie | 3 |
| 8 | food-spending | 10000 | 137 µs | 97 µs | **tie** | 16.8 MB | 15.6 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 159 µs | 170 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 10 | first-over-limit | 10000 | 53 µs | 57 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 11 | top-merchants | 10000 | 710 µs | 569 µs | **tie** | 22.9 MB | 23.6 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.23 ms | 936 µs | **tie** | 20.5 MB | 23.2 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.17 ms | 1.91 ms | **tie** | 23.4 MB | 22.8 MB | tie | 3 |
| 14 | valid-emails | 10000 | 539 µs | 513 µs | **tie** | 20.0 MB | 20.0 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 10000 | 31.7 ms | 33.5 ms | **native** | 26.5 MB | 22.4 MB | fxdart | 5 |
| 16 | compound-interest | 10000 | 1.85 ms | 2.06 ms | **tie** | 22.6 MB | 22.8 MB | tie | 3 |
| 17 | top-category-average | 10000 | 364 µs | 354 µs | **tie** | 22.9 MB | 22.9 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 163 µs | 108 µs | **tie** | 20.8 MB | 15.5 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 526 µs | 629 µs | **tie** | 23.7 MB | 23.7 MB | tie | 3 |
| 20 | recent-errors | 10000 | 90 µs | 118 µs | **tie** | 15.7 MB | 15.9 MB | tie | 3 |
| 21 | duplicate-transactions | 10000 | 4.07 ms | 3.82 ms | **tie** | 40.2 MB | 36.0 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 274 µs | 274 µs | **tie** | 19.5 MB | 19.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 17.8 ms | 21.1 ms | **native** | 49.3 MB | 50.3 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.42 ms | 2.93 ms | **tie** | 23.5 MB | 25.3 MB | native | 3 |
| 25 | weekly-sensor-averages | 9996 | 396 µs | 457 µs | **tie** | 22.7 MB | 22.7 MB | tie | 3 |
| 26 | paginated-products | 10000 | 907 µs | 846 µs | **tie** | 17.6 MB | 20.7 MB | native | 3 |
| 27 | invoice-summary | 10000 | 239 µs | 110 µs | **tie** | 22.4 MB | 15.7 MB | fxdart | 3 |
| 28 | budget-alerts | 10000 | 183 µs | 88 µs | **tie** | 21.8 MB | 15.6 MB | fxdart | 3 |
| 29 | monthly-category-report | 10000 | 109 µs | 141 µs | **tie** | 16.9 MB | 15.9 MB | fxdart | 3 |
| 30 | consecutive-over-limit | 10000 | 119 µs | 203 µs | **tie** | 20.6 MB | 23.5 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 752 µs | 710 µs | **tie** | 23.4 MB | 22.9 MB | tie | 3 |
| 32 | restock-plan | 10000 | 1.35 ms | 1.10 ms | **tie** | 17.5 MB | 20.4 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 35.4 ms | 35.1 ms | **tie** | 49.1 MB | 30.8 MB | fxdart | 3 |
| 34 | monthly-ledger-report | 10000 | 934 µs | 431 µs | **tie** | 22.9 MB | 17.2 MB | fxdart | 3 |
| 35 | sparse-timeseries | 10000 | 517 µs | 438 µs | **tie** | 22.9 MB | 20.2 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 33.9 ms | 37.9 ms | **native** | 50.8 MB | 33.1 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.73 ms | 3.19 ms | **tie** | 26.1 MB | 31.2 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 49.7 ms | 61.5 ms | **native** | 28.8 MB | 24.7 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.39 ms | 1.43 ms | **tie** | 17.8 MB | 18.0 MB | tie | 3 |
| 40 | latency-percentiles | 10000 | 1.89 ms | 1.75 ms | **tie** | 18.1 MB | 17.2 MB | fxdart | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 7.68 ms | 8.35 ms | **native** | 42.9 MB | 24.1 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 102 µs | 93 µs | **tie** | 18.4 MB | 18.9 MB | tie | 3 |
| 43 | smoothed-zone-changes | 10000 | 203 µs | 404 µs | **tie** | 22.0 MB | 22.8 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.18 ms | 3.53 ms | **tie** | 24.0 MB | 25.0 MB | tie | 3 |
| 45 | live-search (async) | 10000 | 4.56 ms | 5.88 ms | **native** | 23.1 MB | 23.8 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 13.5 ms | 15.3 ms | **native** | 24.0 MB | 27.5 MB | native | 3 |
| 47 | category-rank | 10000 | 286 µs | 276 µs | **tie** | 17.3 MB | 17.9 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 30.0 ms | 33.5 ms | **native** | 49.0 MB | 31.0 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 28.8 ms | 30.6 ms | **native** | 51.2 MB | 31.7 MB | fxdart | 3 |
| 50 | cohort-retention | 10000 | 2.43 ms | 2.14 ms | **tie** | 17.5 MB | 18.1 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 10000 | 321.8 ms | 326.0 ms | **tie** | 50.4 MB | 50.1 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 4.31 ms | 2.97 ms | **fxdart** | 23.0 MB | 23.9 MB | tie | 3 |
| 53 | price-drop-detection | 10000 | 7.13 ms | 3.63 ms | **fxdart** | 37.1 MB | 34.5 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 498.5 ms | 202.6 ms | **fxdart** | 126.1 MB | 134.1 MB | native | 3 |
| 2 | top-log-level | 1000000 | 43.8 ms | 19.3 ms | **fxdart** | 92.9 MB | 44.9 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 332.3 ms | 335.7 ms | **tie** | 83.2 MB | 81.9 MB | tie | 5 |
| 4 | average-basket | 1000000 | 17.1 ms | 8.61 ms | **fxdart** | 75.2 MB | 72.9 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 79.1 ms | 72.5 ms | **fxdart** | 127.0 MB | 126.4 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 194.8 ms | 206.8 ms | **native** | 241.3 MB | 223.2 MB | fxdart | 3 |
| 7 | running-balance | 1000000 | 232.1 ms | 262.4 ms | **native** | 182.0 MB | 184.6 MB | tie | 3 |
| 8 | food-spending | 1000000 | 12.2 ms | 11.0 ms | **fxdart** | 90.4 MB | 84.5 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 23.7 ms | 25.9 ms | **native** | 116.0 MB | 116.6 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 4.87 ms | 5.15 ms | **tie** | 117.2 MB | 117.5 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 106.7 ms | 54.6 ms | **fxdart** | 137.8 MB | 120.0 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 105.4 ms | 77.1 ms | **fxdart** | 161.7 MB | 161.7 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 246.1 ms | 227.8 ms | **fxdart** | 180.7 MB | 178.6 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 69.9 ms | 66.5 ms | **fxdart** | 174.4 MB | 175.9 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100000 | 315.3 ms | 336.5 ms | **native** | 49.2 MB | 50.6 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 215.5 ms | 236.5 ms | **native** | 127.5 MB | 128.0 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 56.1 ms | 55.6 ms | **tie** | 133.7 MB | 132.7 MB | tie | 4 |
| 18 | date-window-spend | 1000000 | 14.5 ms | 11.1 ms | **fxdart** | 126.3 MB | 119.3 MB | fxdart | 3 |
| 19 | sensor-anomalies | 1000000 | 62.0 ms | 71.2 ms | **native** | 162.3 MB | 159.2 MB | tie | 3 |
| 20 | recent-errors | 1000000 | 10.3 ms | 13.8 ms | **native** | 113.7 MB | 113.8 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 934.4 ms | 914.6 ms | **tie** | 324.0 MB | 332.4 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 23.3 ms | 23.9 ms | **tie** | 106.4 MB | 105.8 MB | tie | 4 |
| 23 | concurrent-enrichment (async) | 100000 | 196.3 ms | 227.9 ms | **native** | 81.4 MB | 81.3 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 505.6 ms | 631.0 ms | **native** | 232.5 MB | 235.6 MB | tie | 3 |
| 25 | weekly-sensor-averages | 999999 | 47.0 ms | 47.3 ms | **tie** | 94.9 MB | 145.5 MB | native | 3 |
| 26 | paginated-products | 1000000 | 100.9 ms | 126.6 ms | **native** | 177.8 MB | 204.8 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 24.7 ms | 13.0 ms | **fxdart** | 89.6 MB | 88.3 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.3 ms | 12.9 ms | **fxdart** | 90.0 MB | 82.7 MB | fxdart | 3 |
| 29 | monthly-category-report | 1000000 | 11.1 ms | 14.0 ms | **native** | 120.0 MB | 119.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 16.3 ms | 22.4 ms | **native** | 150.2 MB | 151.1 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 120.0 ms | 103.5 ms | **fxdart** | 204.9 MB | 211.3 MB | tie | 3 |
| 32 | restock-plan | 1000000 | 209.5 ms | 198.9 ms | **fxdart** | 173.6 MB | 193.7 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 100000 | 366.0 ms | 356.1 ms | **tie** | 81.2 MB | 80.6 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 142.1 ms | 47.4 ms | **fxdart** | 155.7 MB | 134.7 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 50.5 ms | 44.5 ms | **fxdart** | 125.4 MB | 144.4 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 350.5 ms | 393.5 ms | **native** | 80.9 MB | 90.3 MB | native | 3 |
| 37 | ledger-diff | 500000 | 221.2 ms | 265.0 ms | **native** | 266.0 MB | 172.5 MB | fxdart | 3 |
| 38 | flaky-api-retry (async) | 100000 | 518.9 ms | 617.5 ms | **native** | 56.0 MB | 50.4 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 164.6 ms | 165.7 ms | **tie** | 238.0 MB | 240.2 MB | tie | 5 |
| 40 | latency-percentiles | 1000000 | 194.4 ms | 200.3 ms | **tie** | 216.3 MB | 136.3 MB | fxdart | 5 |
| 41 | paged-feeds-dedupe (async) | 100000 | 81.8 ms | 90.1 ms | **native** | 74.0 MB | 74.4 MB | tie | 3 |
| 42 | anomaly-context | 1000000 | 11.3 ms | 10.3 ms | **fxdart** | 132.3 MB | 132.1 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 37.9 ms | 37.2 ms | **tie** | 234.5 MB | 82.1 MB | fxdart | 5 |
| 44 | stream-windowed-alerts (async) | 100000 | 31.5 ms | 35.1 ms | **native** | 74.3 MB | 74.8 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 45.1 ms | 61.1 ms | **native** | 53.0 MB | 57.1 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 130.2 ms | 158.2 ms | **native** | 76.2 MB | 79.6 MB | tie | 3 |
| 47 | category-rank | 1000000 | 32.4 ms | 32.7 ms | **tie** | 146.6 MB | 147.9 MB | tie | 4 |
| 48 | stock-revaluation (async) | 100000 | 312.4 ms | 346.7 ms | **native** | 80.6 MB | 80.7 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 296.3 ms | 318.1 ms | **native** | 80.4 MB | 80.1 MB | tie | 3 |
| 50 | cohort-retention | 1000000 | 571.8 ms | 571.7 ms | **tie** | 239.4 MB | 238.9 MB | tie | 4 |
| 51 | daily-ledger-close (async) | 20000 | 1183.5 ms | 1194.2 ms | **tie** | 52.6 MB | 54.3 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 50.9 ms | 32.1 ms | **fxdart** | 56.2 MB | 58.8 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1148.3 ms | 613.1 ms | **fxdart** | 392.9 MB | 445.6 MB | native | 3 |
