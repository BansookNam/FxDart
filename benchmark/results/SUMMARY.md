# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-16
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 20 µs | 6.1 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.6 µs | 3.2 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 3 | sequential-configs (async) | 100 | 318 µs | 398 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 4 | average-basket | 100 | 2.1 µs | 1.1 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 5 | paginate-users | 100 | 7.7 µs | 7.0 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 6 | rank-labels | 100 | 14 µs | 15 µs | **tie** | 16.3 MB | 16.4 MB | tie | 3 |
| 7 | running-balance | 100 | 20 µs | 22 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 8 | food-spending | 100 | 1.4 µs | 1.1 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.4 µs | 1.6 µs | **tie** | 16.3 MB | 16.5 MB | tie | 3 |
| 10 | first-over-limit | 100 | 1.0 µs | 987 ns | **tie** | 16.3 MB | 16.4 MB | tie | 3 |
| 11 | top-merchants | 100 | 29 µs | 139 µs | **tie** | 17.1 MB | 17.2 MB | tie | 3 |
| 12 | unique-tags | 100 | 52 µs | 46 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 22 µs | 19 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 14 | valid-emails | 100 | 5.5 µs | 4.9 µs | **tie** | 16.4 MB | 16.3 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100 | 360 µs | 389 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 16 | compound-interest | 100 | 22 µs | 21 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 17 | top-category-average | 100 | 8.0 µs | 7.7 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 18 | date-window-spend | 100 | 2.3 µs | 1.5 µs | **tie** | 16.4 MB | 15.6 MB | fxdart | 3 |
| 19 | sensor-anomalies | 100 | 6.2 µs | 7.3 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 20 | recent-errors | 100 | 1.1 µs | 1.9 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 21 | duplicate-transactions | 100 | 42 µs | 39 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 4.7 µs | 5.2 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 223 µs | 222 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 24 µs | 30 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 25 | weekly-sensor-averages | 98 | 4.7 µs | 5.0 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 26 | paginated-products | 100 | 7.0 µs | 6.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 27 | invoice-summary | 100 | 4.6 µs | 9.7 µs | **tie** | 16.7 MB | 16.4 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.6 µs | 4.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.5 µs | 6.2 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 100 | 1.8 µs | 3.0 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 34 µs | 48 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 32 | restock-plan | 100 | 10 µs | 9.6 µs | **tie** | 16.5 MB | 15.6 MB | fxdart | 3 |
| 33 | price-lookup-fallback (async) | 100 | 493 µs | 420 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 23 µs | 33 µs | **tie** | 17.1 MB | 16.5 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 31 µs | 31 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 347 µs | 412 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 37 | ledger-diff | 100 | 26 µs | 29 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 566 µs | 754 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 39 | alert-digest | 100 | 20 µs | 31 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 17 µs | 19 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 85 µs | 108 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.4 µs | 2.9 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 43 | smoothed-zone-changes | 100 | 1.9 µs | 4.4 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 40 µs | 54 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 45 | live-search (async) | 100 | 56 µs | 76 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 139 µs | 183 µs | **tie** | 16.4 MB | 17.4 MB | native | 3 |
| 47 | category-rank | 100 | 3.9 µs | 16 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 413 µs | 401 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 286 µs | 361 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 50 | cohort-retention | 100 | 47 µs | 44 µs | **tie** | 16.6 MB | 17.0 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 100 | 414 µs | 420 µs | **tie** | 16.6 MB | 17.2 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 34 µs | 34 µs | **tie** | 16.7 MB | 17.3 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 56 µs | 37 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.34 ms | 906 µs | **fxdart** | 23.1 MB | 22.0 MB | tie | 3 |
| 2 | top-log-level | 10000 | 342 µs | 310 µs | **tie** | 20.0 MB | 14.2 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 31.9 ms | 31.8 ms | **tie** | 50.6 MB | 50.8 MB | tie | 3 |
| 4 | average-basket | 10000 | 183 µs | 102 µs | **tie** | 19.1 MB | 15.3 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 763 µs | 620 µs | **tie** | 22.9 MB | 23.4 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.54 ms | 1.59 ms | **tie** | 34.7 MB | 37.7 MB | native | 3 |
| 7 | running-balance | 10000 | 1.96 ms | 2.24 ms | **tie** | 23.9 MB | 23.7 MB | tie | 3 |
| 8 | food-spending | 10000 | 133 µs | 127 µs | **tie** | 16.9 MB | 15.5 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 151 µs | 162 µs | **tie** | 16.9 MB | 17.0 MB | tie | 3 |
| 10 | first-over-limit | 10000 | 53 µs | 56 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 11 | top-merchants | 10000 | 677 µs | 588 µs | **tie** | 23.0 MB | 23.5 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.21 ms | 921 µs | **tie** | 20.6 MB | 23.2 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.17 ms | 1.78 ms | **tie** | 23.2 MB | 23.0 MB | tie | 3 |
| 14 | valid-emails | 10000 | 549 µs | 527 µs | **tie** | 20.0 MB | 20.0 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 10000 | 30.8 ms | 35.7 ms | **native** | 26.0 MB | 22.1 MB | fxdart | 3 |
| 16 | compound-interest | 10000 | 1.85 ms | 2.07 ms | **tie** | 22.6 MB | 22.8 MB | tie | 3 |
| 17 | top-category-average | 10000 | 362 µs | 356 µs | **tie** | 22.8 MB | 22.9 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 152 µs | 112 µs | **tie** | 20.7 MB | 15.6 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 520 µs | 615 µs | **tie** | 23.6 MB | 23.7 MB | tie | 3 |
| 20 | recent-errors | 10000 | 88 µs | 145 µs | **tie** | 15.7 MB | 15.8 MB | tie | 3 |
| 21 | duplicate-transactions | 10000 | 3.96 ms | 3.98 ms | **tie** | 40.2 MB | 36.0 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 256 µs | 261 µs | **tie** | 19.5 MB | 19.6 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 18.4 ms | 21.2 ms | **native** | 49.3 MB | 50.3 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.31 ms | 2.89 ms | **tie** | 23.5 MB | 25.3 MB | native | 3 |
| 25 | weekly-sensor-averages | 9996 | 391 µs | 451 µs | **tie** | 22.7 MB | 22.8 MB | tie | 3 |
| 26 | paginated-products | 10000 | 825 µs | 816 µs | **tie** | 17.7 MB | 20.8 MB | native | 3 |
| 27 | invoice-summary | 10000 | 237 µs | 260 µs | **tie** | 22.4 MB | 19.1 MB | fxdart | 3 |
| 28 | budget-alerts | 10000 | 179 µs | 230 µs | **tie** | 21.8 MB | 19.5 MB | fxdart | 3 |
| 29 | monthly-category-report | 10000 | 106 µs | 171 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 30 | consecutive-over-limit | 10000 | 113 µs | 203 µs | **tie** | 20.5 MB | 23.5 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 2.57 ms | 4.29 ms | **native** | 21.9 MB | 22.5 MB | tie | 3 |
| 32 | restock-plan | 10000 | 1.23 ms | 1.09 ms | **tie** | 17.4 MB | 20.8 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 35.6 ms | 35.2 ms | **tie** | 49.1 MB | 30.8 MB | fxdart | 3 |
| 34 | monthly-ledger-report | 10000 | 925 µs | 670 µs | **tie** | 23.0 MB | 22.9 MB | tie | 3 |
| 35 | sparse-timeseries | 10000 | 468 µs | 431 µs | **tie** | 23.0 MB | 20.3 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 33.7 ms | 39.1 ms | **native** | 50.8 MB | 33.1 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.52 ms | 3.53 ms | **native** | 26.2 MB | 31.2 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 49.7 ms | 73.0 ms | **native** | 29.1 MB | 24.8 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.36 ms | 2.12 ms | **native** | 17.9 MB | 21.4 MB | native | 3 |
| 40 | latency-percentiles | 10000 | 1.89 ms | 2.04 ms | **tie** | 18.1 MB | 21.1 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 8.14 ms | 9.29 ms | **native** | 43.2 MB | 24.6 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 94 µs | 195 µs | **tie** | 18.1 MB | 23.0 MB | native | 3 |
| 43 | smoothed-zone-changes | 10000 | 174 µs | 409 µs | **tie** | 22.0 MB | 22.8 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.16 ms | 4.90 ms | **native** | 23.6 MB | 25.8 MB | native | 3 |
| 45 | live-search (async) | 10000 | 4.79 ms | 5.83 ms | **native** | 23.5 MB | 23.2 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 13.2 ms | 16.5 ms | **native** | 23.7 MB | 28.5 MB | native | 3 |
| 47 | category-rank | 10000 | 281 µs | 301 µs | **tie** | 17.5 MB | 17.8 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 30.9 ms | 35.6 ms | **native** | 49.5 MB | 30.7 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 30.5 ms | 31.4 ms | **tie** | 51.8 MB | 32.0 MB | fxdart | 5 |
| 50 | cohort-retention | 10000 | 2.30 ms | 2.28 ms | **tie** | 18.0 MB | 18.1 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 10000 | 322.1 ms | 329.5 ms | **tie** | 49.8 MB | 50.6 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 4.15 ms | 3.12 ms | **fxdart** | 23.1 MB | 24.0 MB | tie | 3 |
| 53 | price-drop-detection | 10000 | 7.10 ms | 3.72 ms | **fxdart** | 37.1 MB | 34.4 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 510.9 ms | 217.7 ms | **fxdart** | 125.0 MB | 134.5 MB | native | 3 |
| 2 | top-log-level | 1000000 | 44.6 ms | 31.8 ms | **fxdart** | 94.0 MB | 44.9 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 351.0 ms | 344.9 ms | **tie** | 83.2 MB | 82.0 MB | tie | 5 |
| 4 | average-basket | 1000000 | 17.6 ms | 10.2 ms | **fxdart** | 75.2 MB | 72.8 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 81.6 ms | 76.0 ms | **fxdart** | 126.2 MB | 126.3 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 204.6 ms | 214.7 ms | **tie** | 241.1 MB | 222.3 MB | fxdart | 5 |
| 7 | running-balance | 1000000 | 238.9 ms | 270.1 ms | **native** | 175.9 MB | 185.3 MB | native | 3 |
| 8 | food-spending | 1000000 | 12.4 ms | 13.2 ms | **native** | 90.4 MB | 84.9 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 23.9 ms | 26.8 ms | **native** | 115.8 MB | 116.9 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 5.01 ms | 5.26 ms | **tie** | 117.1 MB | 117.8 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 121.4 ms | 56.4 ms | **fxdart** | 137.8 MB | 118.8 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 106.3 ms | 79.3 ms | **fxdart** | 161.6 MB | 161.8 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 252.6 ms | 225.1 ms | **fxdart** | 181.6 MB | 178.0 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 71.2 ms | 68.8 ms | **tie** | 174.2 MB | 174.9 MB | tie | 5 |
| 15 | bounded-concurrency (async) | 100000 | 307.4 ms | 348.2 ms | **native** | 49.2 MB | 50.4 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 221.0 ms | 244.1 ms | **native** | 126.8 MB | 124.8 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 61.9 ms | 62.2 ms | **tie** | 133.9 MB | 135.2 MB | tie | 3 |
| 18 | date-window-spend | 1000000 | 14.9 ms | 11.5 ms | **fxdart** | 125.7 MB | 119.5 MB | fxdart | 3 |
| 19 | sensor-anomalies | 1000000 | 62.9 ms | 75.0 ms | **native** | 162.6 MB | 152.5 MB | fxdart | 3 |
| 20 | recent-errors | 1000000 | 10.7 ms | 16.2 ms | **native** | 114.3 MB | 113.7 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 982.7 ms | 969.6 ms | **tie** | 325.0 MB | 332.5 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 23.9 ms | 24.0 ms | **tie** | 106.0 MB | 106.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100000 | 200.8 ms | 235.3 ms | **native** | 81.4 MB | 81.1 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 530.4 ms | 630.7 ms | **native** | 231.9 MB | 236.9 MB | tie | 3 |
| 25 | weekly-sensor-averages | 999999 | 48.6 ms | 53.7 ms | **native** | 95.8 MB | 95.2 MB | tie | 3 |
| 26 | paginated-products | 1000000 | 102.7 ms | 126.6 ms | **native** | 177.8 MB | 206.6 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 24.7 ms | 27.2 ms | **native** | 89.2 MB | 89.8 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.8 ms | 27.1 ms | **native** | 93.1 MB | 89.6 MB | tie | 3 |
| 29 | monthly-category-report | 1000000 | 11.3 ms | 17.4 ms | **native** | 119.3 MB | 119.4 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 16.9 ms | 22.4 ms | **native** | 150.2 MB | 148.3 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 317.2 ms | 458.9 ms | **native** | 217.6 MB | 199.0 MB | fxdart | 3 |
| 32 | restock-plan | 1000000 | 214.7 ms | 202.1 ms | **fxdart** | 173.1 MB | 194.0 MB | native | 5 |
| 33 | price-lookup-fallback (async) | 100000 | 373.3 ms | 371.9 ms | **tie** | 80.8 MB | 80.9 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 134.4 ms | 71.2 ms | **fxdart** | 134.4 MB | 120.2 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 57.3 ms | 47.6 ms | **fxdart** | 124.3 MB | 144.6 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 357.8 ms | 410.5 ms | **native** | 80.9 MB | 89.4 MB | native | 3 |
| 37 | ledger-diff | 500000 | 230.5 ms | 314.4 ms | **native** | 265.5 MB | 172.6 MB | fxdart | 3 |
| 38 | flaky-api-retry (async) | 100000 | 511.8 ms | 706.7 ms | **native** | 56.1 MB | 50.1 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 171.9 ms | 250.8 ms | **native** | 125.2 MB | 239.8 MB | native | 3 |
| 40 | latency-percentiles | 1000000 | 205.1 ms | 259.9 ms | **native** | 192.7 MB | 211.0 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 100000 | 81.7 ms | 92.8 ms | **native** | 73.7 MB | 74.5 MB | tie | 3 |
| 42 | anomaly-context | 1000000 | 11.9 ms | 20.4 ms | **native** | 132.2 MB | 135.8 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 45.0 ms | 38.0 ms | **fxdart** | 205.5 MB | 82.2 MB | fxdart | 3 |
| 44 | stream-windowed-alerts (async) | 100000 | 32.3 ms | 48.2 ms | **native** | 74.7 MB | 75.7 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 47.8 ms | 62.9 ms | **native** | 53.1 MB | 57.5 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 131.0 ms | 173.0 ms | **native** | 76.2 MB | 80.5 MB | native | 3 |
| 47 | category-rank | 1000000 | 35.1 ms | 34.3 ms | **tie** | 146.5 MB | 145.6 MB | tie | 5 |
| 48 | stock-revaluation (async) | 100000 | 325.0 ms | 362.3 ms | **native** | 80.7 MB | 80.8 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 303.2 ms | 330.6 ms | **native** | 79.9 MB | 80.5 MB | tie | 3 |
| 50 | cohort-retention | 1000000 | 728.9 ms | 735.8 ms | **tie** | 239.1 MB | 239.1 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 20000 | 1196.5 ms | 1206.7 ms | **tie** | 53.0 MB | 54.6 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 52.3 ms | 32.4 ms | **fxdart** | 56.2 MB | 58.7 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1185.6 ms | 647.6 ms | **fxdart** | 394.5 MB | 436.2 MB | native | 3 |
