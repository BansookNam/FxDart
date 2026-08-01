# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-02
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | Native time | FxDart time | Time winner | Native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 100 | 1.1 µs | 2.5 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 2 | running-balance | 100 | 21 µs | 23 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 3 | top-expenses | 100 | 21 µs | 15 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 4 | first-visit-merchants | 100 | 2.1 µs | 3.4 µs | **tie** | 16.4 MB | 16.3 MB | tie | 3 |
| 5 | average-basket | 100 | 2.3 µs | 2.9 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 6 | first-over-limit | 100 | 998 ns | 1.7 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 7 | top-log-level | 100 | 4.3 µs | 7.1 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 8 | paginate-users | 100 | 8.8 µs | 8.2 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 9 | rank-labels | 100 | 14 µs | 16 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 10 | sequential-configs (async) | 100 | 392 µs | 371 µs | **tie** | 16.4 MB | 17.0 MB | tie | 3 |
| 11 | top-merchants | 100 | 23 µs | 15 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 12 | recent-errors | 100 | 1.0 µs | 3.1 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 13 | date-window-spend | 100 | 1.9 µs | 3.0 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 14 | unique-tags | 100 | 54 µs | 50 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 15 | refunds-vs-charges | 100 | 28 µs | 23 µs | **tie** | 16.3 MB | 16.4 MB | tie | 3 |
| 16 | compound-interest | 100 | 19 µs | 22 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 17 | sensor-anomalies | 100 | 5.7 µs | 8.7 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 18 | top-category-average | 100 | 9.5 µs | 8.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 19 | valid-emails | 100 | 5.1 µs | 5.8 µs | **tie** | 16.4 MB | 15.8 MB | tie | 3 |
| 20 | bounded-concurrency (async) | 100 | 424 µs | 454 µs | **tie** | 16.4 MB | 17.0 MB | tie | 3 |
| 21 | monthly-category-report | 100 | 2.2 µs | 5.3 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 22 | paginated-products | 100 | 6.9 µs | 9.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 23 | weekly-sensor-averages | 98 | 3.7 µs | 6.9 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 24 | consecutive-over-limit | 100 | 2.1 µs | 9.3 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 25 | budget-alerts | 100 | 3.2 µs | 7.9 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 26 | leaderboard-ties | 100 | 24 µs | 34 µs | **tie** | 16.4 MB | 16.9 MB | tie | 3 |
| 27 | invoice-summary | 100 | 4.0 µs | 12 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 28 | no-spend-streak | 100 | 4.5 µs | 5.3 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 29 | duplicate-transactions | 100 | 43 µs | 42 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 30 | concurrent-enrichment (async) | 100 | 220 µs | 247 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 31 | monthly-ledger-report | 100 | 24 µs | 32 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 32 | cohort-retention | 100 | 43 µs | 47 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 33 | price-drop-detection | 100 | 56 µs | 45 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 34 | anomaly-context | 100 | 1.6 µs | 5.4 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 29 µs | 37 µs | **tie** | 17.1 MB | 17.0 MB | tie | 3 |
| 36 | multi-currency-report | 100 | 39 µs | 62 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 37 | restock-plan | 100 | 11 µs | 11 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 38 | alert-digest | 100 | 21 µs | 36 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 39 | latency-percentiles | 100 | 17 µs | 26 µs | **tie** | 16.6 MB | 17.0 MB | tie | 3 |
| 40 | ledger-diff | 100 | 22 µs | 40 µs | **tie** | 16.7 MB | 17.1 MB | tie | 3 |
| 41 | concurrent-profile-fetch (async) | 100 | 314 µs | 402 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 42 | flaky-api-retry (async) | 100 | 623 µs | 1.17 ms | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 43 | price-lookup-fallback (async) | 100 | 445 µs | 591 µs | **tie** | 16.5 MB | 17.3 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 36 µs | 122 µs | **tie** | 16.5 MB | 16.8 MB | tie | 3 |
| 45 | rate-limited-import (async) | 100 | 184 µs | 312 µs | **tie** | 16.5 MB | 17.3 MB | tie | 3 |
| 46 | parallel-downloads (async) | 100 | 383 µs | 496 µs | **tie** | 16.4 MB | 17.3 MB | native | 3 |
| 47 | paged-feeds-dedupe (async) | 100 | 94 µs | 202 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 48 | settlement-pipeline (async) | 100 | 32 µs | 44 µs | **tie** | 16.6 MB | 17.3 MB | tie | 3 |
| 49 | live-search (async) | 100 | 55 µs | 82 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 50 | daily-ledger-close (async) | 100 | 380 µs | 487 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 51 | category-rank | 100 | 4.5 µs | 11 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 52 | stock-revaluation (async) | 100 | 362 µs | 682 µs | **tie** | 16.4 MB | 17.2 MB | tie | 3 |

## N = 10000

| # | Case | N | Native time | FxDart time | Time winner | Native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 10000 | 127 µs | 236 µs | **tie** | 16.9 MB | 16.9 MB | tie | 3 |
| 2 | running-balance | 10000 | 1.99 ms | 2.29 ms | **tie** | 23.9 MB | 23.6 MB | tie | 3 |
| 3 | top-expenses | 10000 | 3.53 ms | 1.91 ms | **fxdart** | 23.1 MB | 22.9 MB | tie | 3 |
| 4 | first-visit-merchants | 10000 | 178 µs | 327 µs | **tie** | 16.9 MB | 16.4 MB | tie | 3 |
| 5 | average-basket | 10000 | 184 µs | 247 µs | **tie** | 18.5 MB | 22.2 MB | native | 3 |
| 6 | first-over-limit | 10000 | 53 µs | 118 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 7 | top-log-level | 10000 | 340 µs | 667 µs | **tie** | 18.9 MB | 22.8 MB | native | 3 |
| 8 | paginate-users | 10000 | 766 µs | 752 µs | **tie** | 22.9 MB | 23.4 MB | tie | 3 |
| 9 | rank-labels | 10000 | 1.55 ms | 1.69 ms | **tie** | 34.8 MB | 37.8 MB | native | 3 |
| 10 | sequential-configs (async) | 10000 | 31.9 ms | 38.0 ms | **native** | 50.6 MB | 52.0 MB | tie | 3 |
| 11 | top-merchants | 10000 | 695 µs | 557 µs | **tie** | 23.1 MB | 23.1 MB | tie | 3 |
| 12 | recent-errors | 10000 | 90 µs | 239 µs | **tie** | 15.8 MB | 15.8 MB | tie | 3 |
| 13 | date-window-spend | 10000 | 152 µs | 275 µs | **tie** | 20.8 MB | 22.9 MB | native | 3 |
| 14 | unique-tags | 10000 | 1.21 ms | 909 µs | **tie** | 20.6 MB | 23.2 MB | native | 3 |
| 15 | refunds-vs-charges | 10000 | 2.15 ms | 2.05 ms | **tie** | 23.3 MB | 22.9 MB | tie | 3 |
| 16 | compound-interest | 10000 | 1.85 ms | 2.12 ms | **tie** | 22.8 MB | 22.8 MB | tie | 3 |
| 17 | sensor-anomalies | 10000 | 514 µs | 723 µs | **tie** | 23.6 MB | 23.7 MB | tie | 3 |
| 18 | top-category-average | 10000 | 350 µs | 504 µs | **tie** | 23.0 MB | 22.9 MB | tie | 3 |
| 19 | valid-emails | 10000 | 555 µs | 594 µs | **tie** | 20.0 MB | 20.0 MB | tie | 3 |
| 20 | bounded-concurrency (async) | 10000 | 29.9 ms | 37.5 ms | **native** | 26.0 MB | 22.3 MB | fxdart | 3 |
| 21 | monthly-category-report | 10000 | 108 µs | 283 µs | **tie** | 17.0 MB | 17.8 MB | tie | 3 |
| 22 | paginated-products | 10000 | 804 µs | 1.34 ms | **tie** | 17.6 MB | 22.5 MB | native | 3 |
| 23 | weekly-sensor-averages | 9996 | 399 µs | 712 µs | **tie** | 22.7 MB | 22.7 MB | tie | 3 |
| 24 | consecutive-over-limit | 10000 | 118 µs | 789 µs | **native** | 20.5 MB | 23.5 MB | native | 3 |
| 25 | budget-alerts | 10000 | 180 µs | 473 µs | **tie** | 21.9 MB | 23.0 MB | native | 3 |
| 26 | leaderboard-ties | 10000 | 2.31 ms | 3.23 ms | **native** | 23.4 MB | 31.9 MB | native | 3 |
| 27 | invoice-summary | 10000 | 239 µs | 768 µs | **tie** | 22.4 MB | 23.0 MB | tie | 3 |
| 28 | no-spend-streak | 10000 | 256 µs | 252 µs | **tie** | 19.5 MB | 18.1 MB | fxdart | 3 |
| 29 | duplicate-transactions | 10000 | 3.91 ms | 4.30 ms | **tie** | 40.3 MB | 40.2 MB | tie | 3 |
| 30 | concurrent-enrichment (async) | 10000 | 18.5 ms | 25.3 ms | **native** | 49.3 MB | 51.8 MB | native | 3 |
| 31 | monthly-ledger-report | 10000 | 914 µs | 1.62 ms | **native** | 22.9 MB | 23.7 MB | tie | 3 |
| 32 | cohort-retention | 10000 | 2.40 ms | 2.81 ms | **tie** | 17.6 MB | 21.9 MB | native | 3 |
| 33 | price-drop-detection | 10000 | 7.24 ms | 4.29 ms | **fxdart** | 37.0 MB | 36.4 MB | tie | 3 |
| 34 | anomaly-context | 10000 | 95 µs | 468 µs | **tie** | 18.2 MB | 23.0 MB | native | 3 |
| 35 | sparse-timeseries | 10000 | 474 µs | 820 µs | **tie** | 23.0 MB | 22.9 MB | tie | 3 |
| 36 | multi-currency-report | 10000 | 2.63 ms | 5.19 ms | **native** | 21.8 MB | 23.8 MB | native | 3 |
| 37 | restock-plan | 10000 | 1.27 ms | 1.22 ms | **tie** | 17.5 MB | 22.0 MB | native | 3 |
| 38 | alert-digest | 10000 | 1.42 ms | 2.69 ms | **native** | 18.0 MB | 23.5 MB | native | 3 |
| 39 | latency-percentiles | 10000 | 1.90 ms | 2.62 ms | **native** | 18.2 MB | 23.1 MB | native | 3 |
| 40 | ledger-diff | 10000 | 2.46 ms | 4.53 ms | **native** | 26.1 MB | 39.2 MB | native | 3 |
| 41 | concurrent-profile-fetch (async) | 10000 | 30.9 ms | 37.5 ms | **native** | 51.3 MB | 32.0 MB | fxdart | 3 |
| 42 | flaky-api-retry (async) | 10000 | 51.0 ms | 110.1 ms | **native** | 29.1 MB | 24.6 MB | fxdart | 3 |
| 43 | price-lookup-fallback (async) | 10000 | 36.7 ms | 56.3 ms | **native** | 48.9 MB | 38.5 MB | fxdart | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.12 ms | 11.4 ms | **native** | 23.5 MB | 27.3 MB | native | 3 |
| 45 | rate-limited-import (async) | 10000 | 13.4 ms | 26.6 ms | **native** | 24.2 MB | 30.9 MB | native | 3 |
| 46 | parallel-downloads (async) | 10000 | 34.2 ms | 51.0 ms | **native** | 50.8 MB | 41.8 MB | fxdart | 3 |
| 47 | paged-feeds-dedupe (async) | 10000 | 8.48 ms | 17.2 ms | **native** | 43.2 MB | 26.5 MB | fxdart | 3 |
| 48 | settlement-pipeline (async) | 10000 | 4.29 ms | 4.35 ms | **tie** | 23.1 MB | 46.8 MB | native | 3 |
| 49 | live-search (async) | 10000 | 5.05 ms | 9.25 ms | **native** | 23.5 MB | 24.1 MB | tie | 3 |
| 50 | daily-ledger-close (async) | 10000 | 328.6 ms | 343.0 ms | **tie** | 49.9 MB | 50.5 MB | tie | 5 |
| 51 | category-rank | 10000 | 282 µs | 482 µs | **tie** | 17.3 MB | 23.4 MB | native | 3 |
| 52 | stock-revaluation (async) | 10000 | 29.6 ms | 55.8 ms | **native** | 48.8 MB | 38.0 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | Native time | FxDart time | Time winner | Native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 1000000 | 12.6 ms | 23.2 ms | **native** | 90.3 MB | 91.2 MB | tie | 3 |
| 2 | running-balance | 1000000 | 242.1 ms | 289.6 ms | **native** | 181.7 MB | 184.8 MB | tie | 3 |
| 3 | top-expenses | 1000000 | 515.3 ms | 348.5 ms | **fxdart** | 125.2 MB | 179.1 MB | native | 3 |
| 4 | first-visit-merchants | 1000000 | 25.4 ms | 46.8 ms | **native** | 115.9 MB | 119.9 MB | tie | 3 |
| 5 | average-basket | 1000000 | 17.3 ms | 22.4 ms | **native** | 75.3 MB | 75.2 MB | tie | 3 |
| 6 | first-over-limit | 1000000 | 5.04 ms | 11.8 ms | **native** | 117.3 MB | 117.2 MB | tie | 3 |
| 7 | top-log-level | 1000000 | 45.3 ms | 64.6 ms | **native** | 79.6 MB | 74.8 MB | fxdart | 3 |
| 8 | paginate-users | 1000000 | 80.9 ms | 87.8 ms | **native** | 126.5 MB | 125.5 MB | tie | 3 |
| 9 | rank-labels | 1000000 | 208.9 ms | 219.9 ms | **native** | 241.3 MB | 222.9 MB | fxdart | 3 |
| 10 | sequential-configs (async) | 100000 | 346.9 ms | 391.1 ms | **native** | 82.7 MB | 82.0 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 120.2 ms | 87.5 ms | **fxdart** | 137.3 MB | 133.9 MB | tie | 3 |
| 12 | recent-errors | 1000000 | 10.5 ms | 26.2 ms | **native** | 113.8 MB | 113.8 MB | tie | 3 |
| 13 | date-window-spend | 1000000 | 15.0 ms | 25.5 ms | **native** | 125.8 MB | 125.6 MB | tie | 3 |
| 14 | unique-tags | 1000000 | 107.3 ms | 77.7 ms | **fxdart** | 161.8 MB | 162.0 MB | tie | 3 |
| 15 | refunds-vs-charges | 1000000 | 258.3 ms | 254.5 ms | **tie** | 181.1 MB | 176.9 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 221.5 ms | 245.7 ms | **native** | 126.7 MB | 125.2 MB | tie | 3 |
| 17 | sensor-anomalies | 1000000 | 64.0 ms | 88.2 ms | **native** | 169.8 MB | 159.5 MB | fxdart | 3 |
| 18 | top-category-average | 1000000 | 62.2 ms | 84.1 ms | **native** | 134.2 MB | 128.7 MB | tie | 3 |
| 19 | valid-emails | 1000000 | 70.1 ms | 76.4 ms | **native** | 176.3 MB | 174.2 MB | tie | 3 |
| 20 | bounded-concurrency (async) | 5000 | 15.2 ms | 18.4 ms | **native** | 18.7 MB | 19.8 MB | native | 3 |
| 21 | monthly-category-report | 1000000 | 11.4 ms | 29.1 ms | **native** | 120.0 MB | 124.0 MB | tie | 3 |
| 22 | paginated-products | 1000000 | 102.7 ms | 210.6 ms | **native** | 177.6 MB | 231.3 MB | native | 3 |
| 23 | weekly-sensor-averages | 999999 | 47.4 ms | 78.7 ms | **native** | 102.8 MB | 92.3 MB | fxdart | 3 |
| 24 | consecutive-over-limit | 1000000 | 17.1 ms | 80.6 ms | **native** | 150.3 MB | 148.0 MB | tie | 3 |
| 25 | budget-alerts | 1000000 | 21.9 ms | 72.9 ms | **native** | 90.4 MB | 117.9 MB | native | 3 |
| 26 | leaderboard-ties | 1000000 | 533.0 ms | 661.5 ms | **native** | 232.1 MB | 307.5 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 25.5 ms | 114.4 ms | **native** | 89.2 MB | 121.0 MB | native | 3 |
| 28 | no-spend-streak | 1000000 | 23.8 ms | 23.5 ms | **tie** | 105.4 MB | 106.7 MB | tie | 3 |
| 29 | duplicate-transactions | 1000000 | 1013.1 ms | 1041.6 ms | **tie** | 324.4 MB | 331.6 MB | tie | 5 |
| 30 | concurrent-enrichment (async) | 5000 | 9.46 ms | 12.6 ms | **native** | 43.3 MB | 26.8 MB | fxdart | 3 |
| 31 | monthly-ledger-report | 1000000 | 139.8 ms | 217.7 ms | **native** | 138.6 MB | 134.8 MB | tie | 3 |
| 32 | cohort-retention | 1000000 | 795.1 ms | 852.2 ms | **native** | 238.7 MB | 242.7 MB | tie | 3 |
| 33 | price-drop-detection | 1000000 | 1233.4 ms | 767.3 ms | **fxdart** | 393.6 MB | 404.4 MB | tie | 3 |
| 34 | anomaly-context | 1000000 | 12.7 ms | 47.1 ms | **native** | 132.6 MB | 135.3 MB | tie | 3 |
| 35 | sparse-timeseries | 1000000 | 60.7 ms | 113.4 ms | **native** | 123.9 MB | 136.8 MB | native | 3 |
| 36 | multi-currency-report | 1000000 | 335.2 ms | 587.1 ms | **native** | 223.9 MB | 217.6 MB | tie | 3 |
| 37 | restock-plan | 1000000 | 227.4 ms | 217.1 ms | **tie** | 173.4 MB | 199.6 MB | native | 5 |
| 38 | alert-digest | 1000000 | 184.6 ms | 313.3 ms | **native** | 238.1 MB | 135.1 MB | fxdart | 3 |
| 39 | latency-percentiles | 1000000 | 209.9 ms | 326.6 ms | **native** | 193.3 MB | 141.5 MB | fxdart | 3 |
| 40 | ledger-diff | 500000 | 247.9 ms | 394.9 ms | **native** | 181.8 MB | 170.1 MB | fxdart | 3 |
| 41 | concurrent-profile-fetch (async) | 5000 | 15.7 ms | 19.2 ms | **native** | 24.0 MB | 27.1 MB | native | 3 |
| 42 | flaky-api-retry (async) | 5000 | 25.2 ms | 54.6 ms | **native** | 20.4 MB | 20.9 MB | tie | 3 |
| 43 | price-lookup-fallback (async) | 6000 | 21.6 ms | 33.9 ms | **native** | 25.4 MB | 31.6 MB | native | 3 |
| 44 | stream-windowed-alerts (async) | 8000 | 2.56 ms | 8.86 ms | **native** | 23.3 MB | 26.7 MB | native | 3 |
| 45 | rate-limited-import (async) | 6000 | 7.85 ms | 16.3 ms | **native** | 23.5 MB | 21.3 MB | fxdart | 3 |
| 46 | parallel-downloads (async) | 5000 | 16.5 ms | 24.9 ms | **native** | 25.0 MB | 31.2 MB | native | 3 |
| 47 | paged-feeds-dedupe (async) | 8000 | 6.69 ms | 13.6 ms | **native** | 24.0 MB | 26.5 MB | native | 3 |
| 48 | settlement-pipeline (async) | 8000 | 3.48 ms | 3.20 ms | **tie** | 22.8 MB | 23.8 MB | tie | 3 |
| 49 | live-search (async) | 6000 | 3.19 ms | 5.14 ms | **native** | 23.2 MB | 23.8 MB | tie | 3 |
| 50 | daily-ledger-close (async) | 3000 | 36.9 ms | 41.0 ms | **native** | 23.8 MB | 24.4 MB | tie | 3 |
| 51 | category-rank | 1000000 | 34.9 ms | 53.1 ms | **native** | 147.4 MB | 147.9 MB | tie | 3 |
| 52 | stock-revaluation (async) | 4000 | 12.4 ms | 22.9 ms | **native** | 23.4 MB | 28.4 MB | native | 3 |
