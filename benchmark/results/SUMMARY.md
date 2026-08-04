# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-04
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 10000 | 144 µs | 225 µs | **tie** | 16.9 MB | 15.6 MB | fxdart | 5 |
| 2 | running-balance | 10000 | 1.98 ms | 2.26 ms | **tie** | 23.9 MB | 23.6 MB | tie | 3 |
| 3 | top-expenses | 10000 | 3.25 ms | 1.83 ms | **fxdart** | 23.1 MB | 22.9 MB | tie | 3 |
| 4 | first-visit-merchants | 10000 | 147 µs | 316 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 5 | average-basket | 10000 | 181 µs | 240 µs | **tie** | 19.0 MB | 22.3 MB | native | 3 |
| 6 | first-over-limit | 10000 | 53 µs | 119 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 7 | top-log-level | 10000 | 351 µs | 416 µs | **tie** | 18.9 MB | 14.2 MB | fxdart | 3 |
| 8 | paginate-users | 10000 | 765 µs | 847 µs | **tie** | 22.8 MB | 23.4 MB | tie | 3 |
| 9 | rank-labels | 10000 | 1.60 ms | 1.75 ms | **tie** | 34.8 MB | 37.9 MB | native | 3 |
| 10 | sequential-configs (async) | 10000 | 32.7 ms | 31.8 ms | **tie** | 50.7 MB | 50.6 MB | tie | 5 |
| 11 | top-merchants | 10000 | 679 µs | 489 µs | **tie** | 23.1 MB | 23.1 MB | tie | 3 |
| 12 | recent-errors | 10000 | 91 µs | 248 µs | **tie** | 15.8 MB | 15.8 MB | tie | 3 |
| 13 | date-window-spend | 10000 | 155 µs | 259 µs | **tie** | 20.8 MB | 23.0 MB | native | 3 |
| 14 | unique-tags | 10000 | 1.20 ms | 902 µs | **tie** | 20.5 MB | 23.1 MB | native | 3 |
| 15 | refunds-vs-charges | 10000 | 2.13 ms | 1.92 ms | **tie** | 22.9 MB | 22.9 MB | tie | 3 |
| 16 | compound-interest | 10000 | 1.83 ms | 2.09 ms | **tie** | 22.7 MB | 22.9 MB | tie | 3 |
| 17 | sensor-anomalies | 10000 | 537 µs | 768 µs | **tie** | 23.7 MB | 22.5 MB | fxdart | 3 |
| 18 | top-category-average | 10000 | 386 µs | 473 µs | **tie** | 22.9 MB | 22.7 MB | tie | 3 |
| 19 | valid-emails | 10000 | 567 µs | 603 µs | **tie** | 20.0 MB | 20.0 MB | tie | 3 |
| 20 | bounded-concurrency (async) | 10000 | 31.1 ms | 34.8 ms | **native** | 26.6 MB | 22.3 MB | fxdart | 3 |
| 21 | monthly-category-report | 10000 | 106 µs | 256 µs | **tie** | 17.0 MB | 17.3 MB | tie | 3 |
| 22 | paginated-products | 10000 | 837 µs | 1.39 ms | **tie** | 17.6 MB | 23.0 MB | native | 3 |
| 23 | weekly-sensor-averages | 9996 | 411 µs | 655 µs | **tie** | 22.6 MB | 22.8 MB | tie | 5 |
| 24 | consecutive-over-limit | 10000 | 117 µs | 782 µs | **native** | 20.6 MB | 23.6 MB | native | 3 |
| 25 | budget-alerts | 10000 | 183 µs | 417 µs | **tie** | 20.9 MB | 17.9 MB | fxdart | 3 |
| 26 | leaderboard-ties | 10000 | 2.31 ms | 3.19 ms | **native** | 23.5 MB | 26.8 MB | native | 3 |
| 27 | invoice-summary | 10000 | 248 µs | 429 µs | **tie** | 22.4 MB | 17.4 MB | fxdart | 5 |
| 28 | no-spend-streak | 10000 | 300 µs | 308 µs | **tie** | 18.0 MB | 19.5 MB | native | 3 |
| 29 | duplicate-transactions | 10000 | 4.09 ms | 4.13 ms | **tie** | 40.3 MB | 36.0 MB | fxdart | 3 |
| 30 | concurrent-enrichment (async) | 10000 | 18.5 ms | 22.8 ms | **native** | 49.3 MB | 50.3 MB | tie | 3 |
| 31 | monthly-ledger-report | 10000 | 919 µs | 1.12 ms | **tie** | 22.9 MB | 20.2 MB | fxdart | 5 |
| 32 | cohort-retention | 10000 | 2.70 ms | 2.44 ms | **tie** | 18.0 MB | 18.0 MB | tie | 3 |
| 33 | price-drop-detection | 10000 | 7.13 ms | 3.56 ms | **fxdart** | 37.1 MB | 36.2 MB | tie | 3 |
| 34 | anomaly-context | 10000 | 98 µs | 463 µs | **tie** | 18.4 MB | 23.0 MB | native | 3 |
| 35 | sparse-timeseries | 10000 | 495 µs | 601 µs | **tie** | 23.0 MB | 18.8 MB | fxdart | 5 |
| 36 | multi-currency-report | 10000 | 2.71 ms | 1.35 ms | **fxdart** | 22.0 MB | 23.4 MB | native | 3 |
| 37 | restock-plan | 10000 | 1.25 ms | 1.22 ms | **tie** | 17.5 MB | 22.5 MB | native | 3 |
| 38 | alert-digest | 10000 | 1.43 ms | 2.31 ms | **native** | 17.9 MB | 21.5 MB | native | 3 |
| 39 | latency-percentiles | 10000 | 1.92 ms | 2.41 ms | **tie** | 18.0 MB | 22.3 MB | native | 3 |
| 40 | ledger-diff | 10000 | 2.74 ms | 3.56 ms | **native** | 26.1 MB | 31.4 MB | native | 3 |
| 41 | concurrent-profile-fetch (async) | 10000 | 29.3 ms | 31.1 ms | **native** | 51.3 MB | 32.1 MB | fxdart | 3 |
| 42 | flaky-api-retry (async) | 10000 | 49.3 ms | 70.7 ms | **native** | 29.4 MB | 24.8 MB | fxdart | 3 |
| 43 | price-lookup-fallback (async) | 10000 | 35.3 ms | 37.4 ms | **native** | 49.0 MB | 31.2 MB | fxdart | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.28 ms | 4.96 ms | **native** | 24.0 MB | 25.9 MB | native | 3 |
| 45 | rate-limited-import (async) | 10000 | 12.7 ms | 17.6 ms | **native** | 24.2 MB | 28.5 MB | native | 3 |
| 46 | parallel-downloads (async) | 10000 | 33.1 ms | 39.1 ms | **native** | 50.7 MB | 33.2 MB | fxdart | 3 |
| 47 | paged-feeds-dedupe (async) | 10000 | 8.41 ms | 14.9 ms | **native** | 43.1 MB | 27.2 MB | fxdart | 3 |
| 48 | settlement-pipeline (async) | 10000 | 4.28 ms | 3.70 ms | **tie** | 23.0 MB | 24.3 MB | native | 3 |
| 49 | live-search (async) | 10000 | 4.50 ms | 6.53 ms | **native** | 23.0 MB | 23.7 MB | tie | 3 |
| 50 | daily-ledger-close (async) | 10000 | 325.5 ms | 332.9 ms | **tie** | 49.9 MB | 50.2 MB | tie | 5 |
| 51 | category-rank | 10000 | 284 µs | 412 µs | **tie** | 17.3 MB | 17.9 MB | tie | 5 |
| 52 | stock-revaluation (async) | 10000 | 30.4 ms | 36.1 ms | **native** | 48.9 MB | 31.3 MB | fxdart | 3 |
| 53 | smoothed-zone-changes | 10000 | 202 µs | 663 µs | **tie** | 22.0 MB | 22.3 MB | tie | 5 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 1000000 | 12.7 ms | 22.6 ms | **native** | 90.4 MB | 84.5 MB | fxdart | 5 |
| 2 | running-balance | 1000000 | 241.9 ms | 277.4 ms | **native** | 182.7 MB | 184.9 MB | tie | 3 |
| 3 | top-expenses | 1000000 | 508.0 ms | 346.2 ms | **fxdart** | 124.5 MB | 288.4 MB | native | 3 |
| 4 | first-visit-merchants | 1000000 | 27.4 ms | 44.0 ms | **native** | 116.4 MB | 119.9 MB | tie | 3 |
| 5 | average-basket | 1000000 | 17.4 ms | 22.4 ms | **native** | 75.2 MB | 75.2 MB | tie | 3 |
| 6 | first-over-limit | 1000000 | 4.97 ms | 11.8 ms | **native** | 117.3 MB | 117.3 MB | tie | 3 |
| 7 | top-log-level | 1000000 | 43.3 ms | 41.0 ms | **fxdart** | 94.0 MB | 44.9 MB | fxdart | 3 |
| 8 | paginate-users | 1000000 | 80.5 ms | 90.0 ms | **native** | 126.5 MB | 127.3 MB | tie | 3 |
| 9 | rank-labels | 1000000 | 201.5 ms | 226.2 ms | **native** | 241.3 MB | 220.9 MB | fxdart | 3 |
| 10 | sequential-configs (async) | 100000 | 332.3 ms | 336.3 ms | **tie** | 83.0 MB | 82.0 MB | tie | 5 |
| 11 | top-merchants | 1000000 | 117.7 ms | 66.7 ms | **fxdart** | 137.9 MB | 119.2 MB | fxdart | 3 |
| 12 | recent-errors | 1000000 | 10.4 ms | 26.3 ms | **native** | 113.8 MB | 113.9 MB | tie | 3 |
| 13 | date-window-spend | 1000000 | 14.8 ms | 24.4 ms | **native** | 125.9 MB | 126.1 MB | tie | 3 |
| 14 | unique-tags | 1000000 | 106.5 ms | 75.0 ms | **fxdart** | 161.9 MB | 161.9 MB | tie | 3 |
| 15 | refunds-vs-charges | 1000000 | 248.4 ms | 232.3 ms | **fxdart** | 181.7 MB | 176.8 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 219.5 ms | 246.2 ms | **native** | 122.9 MB | 128.8 MB | tie | 3 |
| 17 | sensor-anomalies | 1000000 | 64.2 ms | 85.0 ms | **native** | 169.8 MB | 159.7 MB | fxdart | 3 |
| 18 | top-category-average | 1000000 | 60.2 ms | 72.7 ms | **native** | 134.3 MB | 131.3 MB | tie | 3 |
| 19 | valid-emails | 1000000 | 73.4 ms | 86.3 ms | **native** | 174.7 MB | 175.8 MB | tie | 3 |
| 20 | bounded-concurrency (async) | 100000 | 312.0 ms | 346.3 ms | **native** | 49.5 MB | 50.3 MB | tie | 3 |
| 21 | monthly-category-report | 1000000 | 11.4 ms | 28.2 ms | **native** | 119.6 MB | 122.8 MB | tie | 3 |
| 22 | paginated-products | 1000000 | 102.6 ms | 208.3 ms | **native** | 171.8 MB | 231.0 MB | native | 3 |
| 23 | weekly-sensor-averages | 999999 | 50.8 ms | 74.6 ms | **native** | 98.9 MB | 94.8 MB | tie | 5 |
| 24 | consecutive-over-limit | 1000000 | 17.0 ms | 77.8 ms | **native** | 149.8 MB | 146.7 MB | tie | 3 |
| 25 | budget-alerts | 1000000 | 21.8 ms | 60.1 ms | **native** | 90.0 MB | 108.5 MB | native | 3 |
| 26 | leaderboard-ties | 1000000 | 528.6 ms | 671.4 ms | **native** | 232.4 MB | 311.5 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 25.2 ms | 60.0 ms | **native** | 89.6 MB | 107.0 MB | native | 5 |
| 28 | no-spend-streak | 1000000 | 24.1 ms | 23.9 ms | **tie** | 105.7 MB | 106.5 MB | tie | 3 |
| 29 | duplicate-transactions | 1000000 | 979.9 ms | 980.1 ms | **tie** | 324.1 MB | 332.5 MB | tie | 5 |
| 30 | concurrent-enrichment (async) | 100000 | 203.9 ms | 250.9 ms | **native** | 81.5 MB | 84.0 MB | tie | 3 |
| 31 | monthly-ledger-report | 1000000 | 144.1 ms | 158.3 ms | **native** | 157.5 MB | 154.1 MB | tie | 5 |
| 32 | cohort-retention | 1000000 | 713.1 ms | 707.6 ms | **tie** | 238.6 MB | 239.0 MB | tie | 5 |
| 33 | price-drop-detection | 1000000 | 1195.5 ms | 655.9 ms | **fxdart** | 393.5 MB | 399.6 MB | tie | 3 |
| 34 | anomaly-context | 1000000 | 11.7 ms | 46.0 ms | **native** | 131.9 MB | 135.3 MB | tie | 3 |
| 35 | sparse-timeseries | 1000000 | 59.7 ms | 63.9 ms | **native** | 125.2 MB | 143.4 MB | native | 5 |
| 36 | multi-currency-report | 1000000 | 349.9 ms | 216.4 ms | **fxdart** | 219.1 MB | 215.0 MB | tie | 3 |
| 37 | restock-plan | 1000000 | 215.3 ms | 203.7 ms | **fxdart** | 173.6 MB | 200.6 MB | native | 3 |
| 38 | alert-digest | 1000000 | 175.9 ms | 269.9 ms | **native** | 238.7 MB | 126.9 MB | fxdart | 3 |
| 39 | latency-percentiles | 1000000 | 206.5 ms | 302.5 ms | **native** | 197.8 MB | 235.8 MB | native | 3 |
| 40 | ledger-diff | 500000 | 234.2 ms | 319.3 ms | **native** | 175.2 MB | 170.2 MB | tie | 3 |
| 41 | concurrent-profile-fetch (async) | 100000 | 305.6 ms | 325.5 ms | **native** | 79.9 MB | 82.8 MB | tie | 3 |
| 42 | flaky-api-retry (async) | 100000 | 500.0 ms | 718.7 ms | **native** | 55.9 MB | 50.0 MB | fxdart | 3 |
| 43 | price-lookup-fallback (async) | 100000 | 360.6 ms | 363.7 ms | **tie** | 80.9 MB | 80.5 MB | tie | 5 |
| 44 | stream-windowed-alerts (async) | 100000 | 34.3 ms | 50.0 ms | **native** | 74.3 MB | 75.7 MB | tie | 3 |
| 45 | rate-limited-import (async) | 100000 | 134.1 ms | 175.6 ms | **native** | 76.5 MB | 80.7 MB | native | 3 |
| 46 | parallel-downloads (async) | 100000 | 347.4 ms | 404.3 ms | **native** | 80.7 MB | 130.9 MB | native | 3 |
| 47 | paged-feeds-dedupe (async) | 100000 | 85.9 ms | 160.8 ms | **native** | 73.6 MB | 81.6 MB | native | 3 |
| 48 | settlement-pipeline (async) | 100000 | 51.5 ms | 36.6 ms | **fxdart** | 56.6 MB | 57.9 MB | tie | 3 |
| 49 | live-search (async) | 100000 | 46.8 ms | 68.5 ms | **native** | 53.1 MB | 59.8 MB | native | 3 |
| 50 | daily-ledger-close (async) | 20000 | 1197.2 ms | 1211.8 ms | **tie** | 53.1 MB | 54.6 MB | tie | 5 |
| 51 | category-rank | 1000000 | 35.5 ms | 44.2 ms | **native** | 147.3 MB | 148.0 MB | tie | 5 |
| 52 | stock-revaluation (async) | 100000 | 315.2 ms | 375.4 ms | **native** | 80.7 MB | 80.3 MB | tie | 3 |
| 53 | smoothed-zone-changes | 1000000 | 39.4 ms | 60.7 ms | **native** | 197.9 MB | 82.1 MB | fxdart | 5 |
