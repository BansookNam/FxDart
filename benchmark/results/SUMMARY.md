# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-18
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 19 µs | 6.1 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.7 µs | 2.0 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 3 | sequential-configs (async) | 100 | 317 µs | 373 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 4 | average-basket | 100 | 2.2 µs | 785 ns | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 5 | paginate-users | 100 | 7.8 µs | 6.6 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 6 | rank-labels | 100 | 14 µs | 14 µs | **tie** | 16.3 MB | 16.5 MB | tie | 3 |
| 7 | running-balance | 100 | 22 µs | 23 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 8 | food-spending | 100 | 1.3 µs | 834 ns | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.5 µs | 1.7 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 10 | first-over-limit | 100 | 999 ns | 994 ns | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 11 | top-merchants | 100 | 25 µs | 136 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 12 | unique-tags | 100 | 60 µs | 46 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 25 µs | 20 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 14 | valid-emails | 100 | 4.8 µs | 4.7 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100 | 368 µs | 419 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 16 | compound-interest | 100 | 20 µs | 21 µs | **tie** | 16.3 MB | 16.4 MB | tie | 3 |
| 17 | top-category-average | 100 | 7.7 µs | 7.0 µs | **tie** | 16.9 MB | 17.0 MB | tie | 3 |
| 18 | date-window-spend | 100 | 2.0 µs | 1.5 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 19 | sensor-anomalies | 100 | 6.4 µs | 6.8 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 20 | recent-errors | 100 | 1.2 µs | 1.4 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 21 | duplicate-transactions | 100 | 40 µs | 40 µs | **tie** | 17.0 MB | 16.4 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 4.4 µs | 5.3 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 199 µs | 241 µs | **tie** | 16.6 MB | 16.7 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 23 µs | 29 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 25 | weekly-sensor-averages | 98 | 4.5 µs | 4.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 26 | paginated-products | 100 | 6.6 µs | 7.3 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 27 | invoice-summary | 100 | 4.6 µs | 9.5 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.7 µs | 4.1 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.2 µs | 6.0 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 100 | 2.2 µs | 3.0 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 12 µs | 12 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 32 | restock-plan | 100 | 12 µs | 9.5 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 33 | price-lookup-fallback (async) | 100 | 406 µs | 370 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 22 µs | 32 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 31 µs | 28 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 365 µs | 435 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 37 | ledger-diff | 100 | 24 µs | 29 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 562 µs | 764 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 39 | alert-digest | 100 | 25 µs | 25 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 19 µs | 20 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 109 µs | 101 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.7 µs | 2.3 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 43 | smoothed-zone-changes | 100 | 2.1 µs | 4.7 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 33 µs | 40 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 45 | live-search (async) | 100 | 61 µs | 66 µs | **tie** | 16.4 MB | 16.7 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 164 µs | 180 µs | **tie** | 16.4 MB | 17.2 MB | tie | 3 |
| 47 | category-rank | 100 | 3.8 µs | 13 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 346 µs | 367 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 308 µs | 315 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 50 | cohort-retention | 100 | 45 µs | 39 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 100 | 428 µs | 449 µs | **tie** | 16.6 MB | 16.7 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 34 µs | 34 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 54 µs | 37 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.42 ms | 889 µs | **fxdart** | 23.1 MB | 22.0 MB | fxdart | 3 |
| 2 | top-log-level | 10000 | 350 µs | 193 µs | **tie** | 18.8 MB | 14.3 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 30.9 ms | 31.6 ms | **tie** | 50.7 MB | 50.4 MB | tie | 5 |
| 4 | average-basket | 10000 | 188 µs | 83 µs | **tie** | 18.5 MB | 15.3 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 769 µs | 625 µs | **tie** | 22.8 MB | 23.4 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.59 ms | 1.61 ms | **tie** | 34.6 MB | 37.7 MB | native | 3 |
| 7 | running-balance | 10000 | 2.06 ms | 2.09 ms | **tie** | 24.0 MB | 23.6 MB | tie | 3 |
| 8 | food-spending | 10000 | 137 µs | 102 µs | **tie** | 16.9 MB | 15.6 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 154 µs | 168 µs | **tie** | 17.0 MB | 16.9 MB | tie | 3 |
| 10 | first-over-limit | 10000 | 55 µs | 57 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 11 | top-merchants | 10000 | 699 µs | 571 µs | **tie** | 22.9 MB | 23.6 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.26 ms | 909 µs | **tie** | 20.6 MB | 23.3 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.20 ms | 1.88 ms | **tie** | 23.4 MB | 22.9 MB | tie | 3 |
| 14 | valid-emails | 10000 | 550 µs | 515 µs | **tie** | 19.9 MB | 20.0 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 10000 | 30.7 ms | 33.7 ms | **native** | 26.3 MB | 22.1 MB | fxdart | 3 |
| 16 | compound-interest | 10000 | 1.93 ms | 2.06 ms | **tie** | 22.6 MB | 22.7 MB | tie | 3 |
| 17 | top-category-average | 10000 | 361 µs | 352 µs | **tie** | 23.0 MB | 23.0 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 151 µs | 110 µs | **tie** | 20.8 MB | 15.6 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 522 µs | 635 µs | **tie** | 23.7 MB | 23.6 MB | tie | 3 |
| 20 | recent-errors | 10000 | 88 µs | 115 µs | **tie** | 15.8 MB | 15.8 MB | tie | 3 |
| 21 | duplicate-transactions | 10000 | 3.98 ms | 3.88 ms | **tie** | 40.3 MB | 36.0 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 256 µs | 258 µs | **tie** | 19.7 MB | 19.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 17.9 ms | 21.0 ms | **native** | 49.4 MB | 50.2 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.38 ms | 2.96 ms | **tie** | 23.5 MB | 25.4 MB | native | 3 |
| 25 | weekly-sensor-averages | 9996 | 406 µs | 447 µs | **tie** | 22.7 MB | 22.8 MB | tie | 3 |
| 26 | paginated-products | 10000 | 897 µs | 849 µs | **tie** | 17.7 MB | 20.8 MB | native | 3 |
| 27 | invoice-summary | 10000 | 242 µs | 179 µs | **tie** | 22.3 MB | 22.9 MB | tie | 3 |
| 28 | budget-alerts | 10000 | 178 µs | 168 µs | **tie** | 21.7 MB | 20.8 MB | tie | 3 |
| 29 | monthly-category-report | 10000 | 109 µs | 147 µs | **tie** | 16.9 MB | 17.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 10000 | 114 µs | 195 µs | **tie** | 20.6 MB | 23.5 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 738 µs | 747 µs | **tie** | 23.4 MB | 23.0 MB | tie | 3 |
| 32 | restock-plan | 10000 | 1.28 ms | 1.14 ms | **tie** | 17.5 MB | 20.3 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 35.8 ms | 33.2 ms | **fxdart** | 49.1 MB | 30.9 MB | fxdart | 3 |
| 34 | monthly-ledger-report | 10000 | 890 µs | 591 µs | **tie** | 22.9 MB | 23.5 MB | tie | 3 |
| 35 | sparse-timeseries | 10000 | 503 µs | 451 µs | **tie** | 23.0 MB | 20.2 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 31.5 ms | 37.0 ms | **native** | 51.0 MB | 32.7 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.52 ms | 3.27 ms | **native** | 26.2 MB | 31.1 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 48.5 ms | 61.3 ms | **native** | 29.0 MB | 24.4 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.48 ms | 1.44 ms | **tie** | 18.0 MB | 18.0 MB | tie | 3 |
| 40 | latency-percentiles | 10000 | 1.91 ms | 2.07 ms | **tie** | 18.2 MB | 19.9 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 7.79 ms | 8.19 ms | **tie** | 43.0 MB | 24.1 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 101 µs | 159 µs | **tie** | 18.0 MB | 23.0 MB | native | 3 |
| 43 | smoothed-zone-changes | 10000 | 202 µs | 403 µs | **tie** | 22.0 MB | 22.8 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.07 ms | 3.65 ms | **tie** | 23.6 MB | 26.0 MB | native | 3 |
| 45 | live-search (async) | 10000 | 4.68 ms | 5.91 ms | **native** | 23.0 MB | 23.3 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 12.3 ms | 15.2 ms | **native** | 24.1 MB | 27.7 MB | native | 3 |
| 47 | category-rank | 10000 | 293 µs | 293 µs | **tie** | 17.5 MB | 17.7 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 30.0 ms | 32.9 ms | **native** | 49.0 MB | 30.8 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 27.7 ms | 29.4 ms | **native** | 51.2 MB | 31.7 MB | fxdart | 5 |
| 50 | cohort-retention | 10000 | 2.32 ms | 1.99 ms | **tie** | 17.5 MB | 18.2 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 10000 | 320.5 ms | 327.2 ms | **tie** | 49.9 MB | 50.6 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 4.15 ms | 2.94 ms | **fxdart** | 23.1 MB | 23.9 MB | tie | 3 |
| 53 | price-drop-detection | 10000 | 7.09 ms | 3.60 ms | **fxdart** | 37.1 MB | 34.5 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 500.5 ms | 203.4 ms | **fxdart** | 124.6 MB | 134.1 MB | native | 3 |
| 2 | top-log-level | 1000000 | 43.5 ms | 19.5 ms | **fxdart** | 103.0 MB | 44.9 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 317.7 ms | 320.3 ms | **tie** | 83.3 MB | 81.9 MB | tie | 5 |
| 4 | average-basket | 1000000 | 16.7 ms | 8.57 ms | **fxdart** | 74.7 MB | 72.9 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 79.2 ms | 74.1 ms | **fxdart** | 127.0 MB | 127.0 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 200.6 ms | 209.3 ms | **tie** | 241.3 MB | 219.1 MB | fxdart | 5 |
| 7 | running-balance | 1000000 | 234.1 ms | 266.7 ms | **native** | 176.4 MB | 185.3 MB | native | 3 |
| 8 | food-spending | 1000000 | 12.3 ms | 10.8 ms | **fxdart** | 90.5 MB | 85.0 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 24.3 ms | 26.4 ms | **native** | 116.4 MB | 116.0 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 4.93 ms | 5.23 ms | **tie** | 117.9 MB | 117.2 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 109.1 ms | 52.6 ms | **fxdart** | 137.6 MB | 119.2 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 106.2 ms | 76.4 ms | **fxdart** | 161.8 MB | 162.0 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 251.1 ms | 229.0 ms | **fxdart** | 179.3 MB | 176.3 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 70.4 ms | 67.0 ms | **fxdart** | 174.5 MB | 174.9 MB | tie | 5 |
| 15 | bounded-concurrency (async) | 100000 | 307.0 ms | 336.2 ms | **native** | 49.3 MB | 50.4 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 216.5 ms | 241.8 ms | **native** | 189.9 MB | 124.8 MB | fxdart | 3 |
| 17 | top-category-average | 1000000 | 57.3 ms | 57.1 ms | **tie** | 135.5 MB | 133.4 MB | tie | 4 |
| 18 | date-window-spend | 1000000 | 14.8 ms | 11.2 ms | **fxdart** | 125.8 MB | 119.6 MB | fxdart | 3 |
| 19 | sensor-anomalies | 1000000 | 61.9 ms | 73.5 ms | **native** | 162.6 MB | 154.4 MB | fxdart | 3 |
| 20 | recent-errors | 1000000 | 10.2 ms | 14.0 ms | **native** | 114.1 MB | 113.5 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 939.0 ms | 926.4 ms | **tie** | 324.2 MB | 331.5 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 23.4 ms | 23.9 ms | **tie** | 105.8 MB | 106.2 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100000 | 190.1 ms | 223.5 ms | **native** | 81.5 MB | 81.4 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 510.7 ms | 629.6 ms | **native** | 231.9 MB | 293.2 MB | native | 3 |
| 25 | weekly-sensor-averages | 999999 | 50.6 ms | 47.5 ms | **fxdart** | 98.6 MB | 145.5 MB | native | 3 |
| 26 | paginated-products | 1000000 | 101.8 ms | 125.9 ms | **native** | 172.3 MB | 207.8 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 24.4 ms | 19.9 ms | **fxdart** | 89.5 MB | 90.1 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.2 ms | 18.7 ms | **fxdart** | 90.5 MB | 90.1 MB | tie | 3 |
| 29 | monthly-category-report | 1000000 | 11.3 ms | 14.7 ms | **native** | 120.0 MB | 121.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 16.2 ms | 21.9 ms | **native** | 150.5 MB | 151.5 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 121.7 ms | 118.4 ms | **tie** | 204.7 MB | 209.0 MB | tie | 5 |
| 32 | restock-plan | 1000000 | 211.7 ms | 196.4 ms | **fxdart** | 173.5 MB | 192.8 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 100000 | 345.7 ms | 344.1 ms | **tie** | 81.1 MB | 80.8 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 145.2 ms | 60.1 ms | **fxdart** | 148.0 MB | 131.5 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 52.4 ms | 46.8 ms | **fxdart** | 124.4 MB | 144.5 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 336.1 ms | 378.3 ms | **native** | 80.8 MB | 121.5 MB | native | 3 |
| 37 | ledger-diff | 500000 | 224.2 ms | 284.3 ms | **native** | 252.5 MB | 169.9 MB | fxdart | 3 |
| 38 | flaky-api-retry (async) | 100000 | 486.7 ms | 609.9 ms | **native** | 56.2 MB | 50.0 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 165.7 ms | 165.3 ms | **tie** | 239.6 MB | 238.8 MB | tie | 3 |
| 40 | latency-percentiles | 1000000 | 193.9 ms | 258.1 ms | **native** | 137.8 MB | 194.4 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 100000 | 77.2 ms | 87.3 ms | **native** | 73.6 MB | 73.9 MB | tie | 3 |
| 42 | anomaly-context | 1000000 | 11.2 ms | 16.7 ms | **native** | 132.7 MB | 135.4 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 38.9 ms | 37.1 ms | **tie** | 160.0 MB | 82.2 MB | fxdart | 5 |
| 44 | stream-windowed-alerts (async) | 100000 | 31.6 ms | 36.2 ms | **native** | 75.0 MB | 75.6 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 43.7 ms | 58.6 ms | **native** | 53.0 MB | 57.7 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 126.4 ms | 155.5 ms | **native** | 76.4 MB | 79.7 MB | tie | 3 |
| 47 | category-rank | 1000000 | 32.7 ms | 32.4 ms | **tie** | 146.5 MB | 147.4 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100000 | 300.7 ms | 345.0 ms | **native** | 80.4 MB | 80.6 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 292.4 ms | 313.4 ms | **native** | 79.9 MB | 80.3 MB | tie | 3 |
| 50 | cohort-retention | 1000000 | 592.9 ms | 594.2 ms | **tie** | 238.8 MB | 239.7 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 20000 | 1184.0 ms | 1195.5 ms | **tie** | 52.6 MB | 54.7 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 49.4 ms | 31.9 ms | **fxdart** | 56.2 MB | 58.3 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1136.3 ms | 611.9 ms | **fxdart** | 393.4 MB | 445.5 MB | native | 3 |
