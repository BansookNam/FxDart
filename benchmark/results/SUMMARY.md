# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-17
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 19 µs | 6.2 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.7 µs | 3.2 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 3 | sequential-configs (async) | 100 | 320 µs | 351 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 4 | average-basket | 100 | 2.4 µs | 1.1 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 5 | paginate-users | 100 | 8.5 µs | 6.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 6 | rank-labels | 100 | 16 µs | 15 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 7 | running-balance | 100 | 21 µs | 22 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 8 | food-spending | 100 | 1.1 µs | 1.0 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.5 µs | 1.7 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 10 | first-over-limit | 100 | 978 ns | 952 ns | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 11 | top-merchants | 100 | 27 µs | 138 µs | **tie** | 17.1 MB | 16.8 MB | tie | 3 |
| 12 | unique-tags | 100 | 55 µs | 47 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 25 µs | 19 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 14 | valid-emails | 100 | 5.4 µs | 5.0 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100 | 368 µs | 396 µs | **tie** | 16.5 MB | 16.9 MB | tie | 3 |
| 16 | compound-interest | 100 | 19 µs | 21 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 17 | top-category-average | 100 | 7.7 µs | 7.0 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 18 | date-window-spend | 100 | 2.0 µs | 1.4 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 19 | sensor-anomalies | 100 | 6.5 µs | 7.3 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 20 | recent-errors | 100 | 1.1 µs | 1.9 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 21 | duplicate-transactions | 100 | 46 µs | 41 µs | **tie** | 16.9 MB | 16.9 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 4.1 µs | 4.8 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 192 µs | 222 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 23 µs | 29 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 25 | weekly-sensor-averages | 98 | 4.3 µs | 4.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 26 | paginated-products | 100 | 6.4 µs | 6.5 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 27 | invoice-summary | 100 | 4.4 µs | 9.5 µs | **tie** | 16.5 MB | 16.3 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.2 µs | 4.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.1 µs | 6.1 µs | **tie** | 16.5 MB | 16.4 MB | tie | 5 |
| 30 | consecutive-over-limit | 100 | 2.0 µs | 3.1 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 33 µs | 40 µs | **tie** | 16.6 MB | 16.6 MB | tie | 5 |
| 32 | restock-plan | 100 | 11 µs | 9.5 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 33 | price-lookup-fallback (async) | 100 | 390 µs | 405 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 25 µs | 31 µs | **tie** | 17.1 MB | 16.3 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 31 µs | 30 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 363 µs | 404 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 37 | ledger-diff | 100 | 21 µs | 30 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 568 µs | 744 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 39 | alert-digest | 100 | 24 µs | 30 µs | **tie** | 16.5 MB | 16.9 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 18 µs | 19 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 97 µs | 115 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.5 µs | 2.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 43 | smoothed-zone-changes | 100 | 2.1 µs | 4.3 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 39 µs | 52 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 45 | live-search (async) | 100 | 64 µs | 77 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 161 µs | 194 µs | **tie** | 16.4 MB | 16.9 MB | tie | 3 |
| 47 | category-rank | 100 | 4.5 µs | 16 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 373 µs | 431 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 418 µs | 344 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 50 | cohort-retention | 100 | 46 µs | 41 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 100 | 410 µs | 420 µs | **tie** | 16.6 MB | 17.3 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 32 µs | 29 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 61 µs | 43 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.34 ms | 895 µs | **fxdart** | 23.1 MB | 22.0 MB | tie | 3 |
| 2 | top-log-level | 10000 | 358 µs | 316 µs | **tie** | 18.8 MB | 14.1 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 30.7 ms | 31.0 ms | **tie** | 50.3 MB | 50.8 MB | tie | 3 |
| 4 | average-basket | 10000 | 183 µs | 103 µs | **tie** | 19.1 MB | 15.3 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 776 µs | 641 µs | **tie** | 22.9 MB | 23.3 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.62 ms | 1.62 ms | **tie** | 34.8 MB | 37.6 MB | native | 3 |
| 7 | running-balance | 10000 | 2.08 ms | 2.14 ms | **tie** | 31.1 MB | 23.7 MB | fxdart | 3 |
| 8 | food-spending | 10000 | 136 µs | 130 µs | **tie** | 16.9 MB | 15.5 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 150 µs | 167 µs | **tie** | 16.9 MB | 17.0 MB | tie | 3 |
| 10 | first-over-limit | 10000 | 55 µs | 55 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 11 | top-merchants | 10000 | 713 µs | 579 µs | **tie** | 23.0 MB | 23.4 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.22 ms | 910 µs | **tie** | 20.6 MB | 23.2 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.21 ms | 1.79 ms | **tie** | 23.3 MB | 22.9 MB | tie | 3 |
| 14 | valid-emails | 10000 | 543 µs | 519 µs | **tie** | 20.0 MB | 20.1 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 10000 | 31.1 ms | 33.6 ms | **native** | 26.0 MB | 22.1 MB | fxdart | 3 |
| 16 | compound-interest | 10000 | 1.84 ms | 2.12 ms | **tie** | 22.7 MB | 22.8 MB | tie | 3 |
| 17 | top-category-average | 10000 | 356 µs | 345 µs | **tie** | 22.9 MB | 22.9 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 166 µs | 112 µs | **tie** | 20.3 MB | 15.6 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 533 µs | 623 µs | **tie** | 23.5 MB | 23.7 MB | tie | 3 |
| 20 | recent-errors | 10000 | 89 µs | 146 µs | **tie** | 15.7 MB | 15.9 MB | tie | 3 |
| 21 | duplicate-transactions | 10000 | 4.14 ms | 3.88 ms | **tie** | 40.3 MB | 36.0 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 266 µs | 255 µs | **tie** | 19.6 MB | 19.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 18.5 ms | 21.4 ms | **native** | 49.3 MB | 50.3 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.36 ms | 2.91 ms | **tie** | 23.4 MB | 25.3 MB | native | 3 |
| 25 | weekly-sensor-averages | 9996 | 392 µs | 462 µs | **tie** | 22.7 MB | 22.8 MB | tie | 3 |
| 26 | paginated-products | 10000 | 890 µs | 812 µs | **tie** | 17.7 MB | 20.8 MB | native | 3 |
| 27 | invoice-summary | 10000 | 236 µs | 254 µs | **tie** | 22.5 MB | 19.7 MB | fxdart | 3 |
| 28 | budget-alerts | 10000 | 185 µs | 237 µs | **tie** | 21.8 MB | 19.5 MB | fxdart | 3 |
| 29 | monthly-category-report | 10000 | 111 µs | 176 µs | **tie** | 17.0 MB | 17.0 MB | tie | 5 |
| 30 | consecutive-over-limit | 10000 | 118 µs | 219 µs | **tie** | 20.9 MB | 23.5 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 2.72 ms | 2.82 ms | **tie** | 22.0 MB | 19.2 MB | fxdart | 5 |
| 32 | restock-plan | 10000 | 1.28 ms | 1.10 ms | **tie** | 17.6 MB | 20.8 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 34.4 ms | 34.5 ms | **tie** | 49.0 MB | 30.6 MB | fxdart | 4 |
| 34 | monthly-ledger-report | 10000 | 940 µs | 688 µs | **tie** | 23.0 MB | 22.8 MB | tie | 3 |
| 35 | sparse-timeseries | 10000 | 469 µs | 441 µs | **tie** | 23.0 MB | 20.2 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 32.9 ms | 37.4 ms | **native** | 50.8 MB | 33.1 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.60 ms | 3.45 ms | **native** | 26.1 MB | 31.2 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 47.8 ms | 69.0 ms | **native** | 29.1 MB | 24.7 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.47 ms | 2.15 ms | **native** | 17.9 MB | 21.3 MB | native | 3 |
| 40 | latency-percentiles | 10000 | 2.10 ms | 2.48 ms | **tie** | 18.1 MB | 21.3 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 8.01 ms | 9.30 ms | **native** | 43.2 MB | 24.6 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 100 µs | 192 µs | **tie** | 18.3 MB | 23.0 MB | native | 3 |
| 43 | smoothed-zone-changes | 10000 | 181 µs | 434 µs | **tie** | 22.0 MB | 22.7 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.29 ms | 4.72 ms | **native** | 23.6 MB | 25.4 MB | native | 3 |
| 45 | live-search (async) | 10000 | 5.32 ms | 6.19 ms | **native** | 23.5 MB | 23.7 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 13.2 ms | 16.2 ms | **native** | 24.0 MB | 28.5 MB | native | 3 |
| 47 | category-rank | 10000 | 302 µs | 304 µs | **tie** | 17.3 MB | 17.9 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 30.0 ms | 35.1 ms | **native** | 49.0 MB | 30.8 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 28.5 ms | 31.0 ms | **native** | 51.2 MB | 32.6 MB | fxdart | 3 |
| 50 | cohort-retention | 10000 | 2.35 ms | 2.25 ms | **tie** | 18.0 MB | 17.6 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 10000 | 322.5 ms | 328.2 ms | **tie** | 49.9 MB | 50.3 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 4.28 ms | 2.94 ms | **fxdart** | 23.2 MB | 23.9 MB | tie | 3 |
| 53 | price-drop-detection | 10000 | 7.15 ms | 3.65 ms | **fxdart** | 37.1 MB | 34.5 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 499.0 ms | 205.1 ms | **fxdart** | 124.6 MB | 135.0 MB | native | 3 |
| 2 | top-log-level | 1000000 | 44.3 ms | 31.1 ms | **fxdart** | 79.5 MB | 44.8 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 319.6 ms | 320.7 ms | **tie** | 82.5 MB | 82.3 MB | tie | 5 |
| 4 | average-basket | 1000000 | 16.9 ms | 10.0 ms | **fxdart** | 75.3 MB | 72.9 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 79.6 ms | 72.8 ms | **fxdart** | 127.3 MB | 126.8 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 198.7 ms | 208.4 ms | **tie** | 241.1 MB | 221.1 MB | fxdart | 5 |
| 7 | running-balance | 1000000 | 236.9 ms | 270.7 ms | **native** | 175.7 MB | 185.1 MB | native | 3 |
| 8 | food-spending | 1000000 | 12.2 ms | 12.9 ms | **native** | 90.6 MB | 85.0 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 24.2 ms | 26.3 ms | **native** | 116.0 MB | 116.3 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 4.92 ms | 5.21 ms | **tie** | 117.7 MB | 117.3 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 116.7 ms | 57.6 ms | **fxdart** | 137.6 MB | 119.9 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 105.6 ms | 77.7 ms | **fxdart** | 161.7 MB | 161.8 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 248.7 ms | 222.8 ms | **fxdart** | 181.7 MB | 177.3 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 70.2 ms | 68.4 ms | **tie** | 174.4 MB | 175.3 MB | tie | 5 |
| 15 | bounded-concurrency (async) | 100000 | 303.0 ms | 334.4 ms | **native** | 49.2 MB | 50.1 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 216.3 ms | 241.4 ms | **native** | 126.9 MB | 125.6 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 59.5 ms | 59.7 ms | **tie** | 131.5 MB | 134.4 MB | tie | 3 |
| 18 | date-window-spend | 1000000 | 15.0 ms | 11.4 ms | **fxdart** | 126.3 MB | 119.4 MB | fxdart | 3 |
| 19 | sensor-anomalies | 1000000 | 62.1 ms | 73.3 ms | **native** | 162.5 MB | 157.2 MB | tie | 3 |
| 20 | recent-errors | 1000000 | 10.7 ms | 16.1 ms | **native** | 114.1 MB | 113.8 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 975.6 ms | 954.1 ms | **tie** | 327.7 MB | 334.2 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 23.8 ms | 23.4 ms | **tie** | 106.4 MB | 105.9 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100000 | 193.0 ms | 229.5 ms | **native** | 81.5 MB | 81.5 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 522.4 ms | 615.8 ms | **native** | 232.4 MB | 293.4 MB | native | 3 |
| 25 | weekly-sensor-averages | 999999 | 49.7 ms | 49.8 ms | **tie** | 98.3 MB | 145.5 MB | native | 5 |
| 26 | paginated-products | 1000000 | 101.8 ms | 122.2 ms | **native** | 172.4 MB | 207.5 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 24.4 ms | 26.8 ms | **native** | 89.5 MB | 91.1 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.2 ms | 26.8 ms | **native** | 90.3 MB | 90.0 MB | tie | 3 |
| 29 | monthly-category-report | 1000000 | 11.5 ms | 17.5 ms | **native** | 119.7 MB | 119.4 MB | tie | 5 |
| 30 | consecutive-over-limit | 1000000 | 16.5 ms | 23.8 ms | **native** | 150.3 MB | 151.3 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 359.3 ms | 359.7 ms | **tie** | 217.9 MB | 197.0 MB | fxdart | 5 |
| 32 | restock-plan | 1000000 | 212.9 ms | 192.9 ms | **fxdart** | 173.4 MB | 193.3 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 100000 | 350.0 ms | 349.7 ms | **tie** | 80.9 MB | 80.8 MB | tie | 3 |
| 34 | monthly-ledger-report | 1000000 | 146.5 ms | 73.6 ms | **fxdart** | 167.4 MB | 131.5 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 54.9 ms | 47.0 ms | **fxdart** | 123.8 MB | 144.8 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 354.8 ms | 403.6 ms | **native** | 80.9 MB | 88.0 MB | native | 3 |
| 37 | ledger-diff | 500000 | 243.6 ms | 328.0 ms | **native** | 182.3 MB | 180.9 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100000 | 488.1 ms | 702.1 ms | **native** | 56.0 MB | 50.0 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 169.9 ms | 250.2 ms | **native** | 237.6 MB | 240.3 MB | tie | 3 |
| 40 | latency-percentiles | 1000000 | 210.2 ms | 282.3 ms | **native** | 216.4 MB | 136.5 MB | fxdart | 3 |
| 41 | paged-feeds-dedupe (async) | 100000 | 81.0 ms | 92.6 ms | **native** | 73.6 MB | 74.4 MB | tie | 3 |
| 42 | anomaly-context | 1000000 | 11.9 ms | 20.8 ms | **native** | 132.2 MB | 135.5 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 38.6 ms | 37.7 ms | **tie** | 245.2 MB | 82.2 MB | fxdart | 5 |
| 44 | stream-windowed-alerts (async) | 100000 | 33.2 ms | 50.1 ms | **native** | 74.7 MB | 75.6 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 46.1 ms | 62.2 ms | **native** | 52.9 MB | 57.4 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 138.6 ms | 180.7 ms | **native** | 76.4 MB | 80.7 MB | native | 3 |
| 47 | category-rank | 1000000 | 36.1 ms | 33.4 ms | **fxdart** | 146.1 MB | 145.0 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100000 | 320.9 ms | 373.9 ms | **native** | 80.7 MB | 80.5 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 297.6 ms | 313.8 ms | **native** | 79.8 MB | 80.2 MB | tie | 4 |
| 50 | cohort-retention | 1000000 | 627.0 ms | 627.4 ms | **tie** | 239.6 MB | 238.7 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 20000 | 1187.7 ms | 1199.1 ms | **tie** | 53.0 MB | 54.9 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 49.8 ms | 31.7 ms | **fxdart** | 56.7 MB | 58.2 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1146.1 ms | 619.8 ms | **fxdart** | 393.3 MB | 446.2 MB | native | 3 |
