# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-02
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | Native time | FxDart time | Time winner | Native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 100 | 1.1 µs | 2.5 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 2 | running-balance | 100 | 22 µs | 26 µs | **tie** | 17.0 MB | 17.1 MB | tie | 3 |
| 3 | top-expenses | 100 | 19 µs | 11 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 4 | first-visit-merchants | 100 | 1.6 µs | 3.4 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 5 | average-basket | 100 | 2.0 µs | 2.5 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 6 | first-over-limit | 100 | 960 ns | 1.7 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 7 | top-log-level | 100 | 3.7 µs | 7.1 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 8 | paginate-users | 100 | 8.0 µs | 8.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 9 | rank-labels | 100 | 14 µs | 16 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 10 | sequential-configs (async) | 100 | 342 µs | 378 µs | **tie** | 16.4 MB | 17.0 MB | tie | 3 |
| 11 | top-merchants | 100 | 25 µs | 16 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 12 | recent-errors | 100 | 1.0 µs | 3.3 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 13 | date-window-spend | 100 | 1.9 µs | 2.9 µs | **tie** | 17.0 MB | 16.4 MB | tie | 3 |
| 14 | unique-tags | 100 | 56 µs | 50 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 15 | refunds-vs-charges | 100 | 22 µs | 23 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 16 | compound-interest | 100 | 19 µs | 21 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 17 | sensor-anomalies | 100 | 5.8 µs | 8.3 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 18 | top-category-average | 100 | 7.1 µs | 8.5 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 19 | valid-emails | 100 | 5.1 µs | 6.1 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 20 | bounded-concurrency (async) | 100 | 338 µs | 431 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 21 | monthly-category-report | 100 | 2.1 µs | 5.5 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 22 | paginated-products | 100 | 5.9 µs | 10 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 23 | weekly-sensor-averages | 98 | 3.8 µs | 6.6 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 24 | consecutive-over-limit | 100 | 1.7 µs | 8.7 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 25 | budget-alerts | 100 | 3.3 µs | 7.5 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 26 | leaderboard-ties | 100 | 22 µs | 31 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 27 | invoice-summary | 100 | 4.1 µs | 11 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 28 | no-spend-streak | 100 | 4.3 µs | 5.5 µs | **tie** | 16.9 MB | 16.4 MB | tie | 3 |
| 29 | duplicate-transactions | 100 | 39 µs | 41 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 30 | concurrent-enrichment (async) | 100 | 185 µs | 258 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 31 | monthly-ledger-report | 100 | 22 µs | 24 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 32 | cohort-retention | 100 | 43 µs | 48 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 33 | price-drop-detection | 100 | 54 µs | 41 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 34 | anomaly-context | 100 | 1.6 µs | 5.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 27 µs | 36 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 36 | multi-currency-report | 100 | 34 µs | 23 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 37 | restock-plan | 100 | 10 µs | 9.8 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 38 | alert-digest | 100 | 21 µs | 36 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 39 | latency-percentiles | 100 | 18 µs | 24 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 40 | ledger-diff | 100 | 22 µs | 37 µs | **tie** | 16.7 MB | 16.5 MB | tie | 3 |
| 41 | concurrent-profile-fetch (async) | 100 | 301 µs | 413 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 42 | flaky-api-retry (async) | 100 | 647 µs | 1.31 ms | **native** | 16.5 MB | 17.0 MB | tie | 3 |
| 43 | price-lookup-fallback (async) | 100 | 374 µs | 574 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 33 µs | 110 µs | **tie** | 16.5 MB | 16.9 MB | tie | 3 |
| 45 | rate-limited-import (async) | 100 | 154 µs | 295 µs | **tie** | 16.5 MB | 17.3 MB | native | 3 |
| 46 | parallel-downloads (async) | 100 | 379 µs | 581 µs | **tie** | 16.5 MB | 16.8 MB | tie | 3 |
| 47 | paged-feeds-dedupe (async) | 100 | 96 µs | 195 µs | **tie** | 16.4 MB | 17.1 MB | tie | 3 |
| 48 | settlement-pipeline (async) | 100 | 32 µs | 42 µs | **tie** | 16.6 MB | 17.0 MB | tie | 3 |
| 49 | live-search (async) | 100 | 52 µs | 92 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 50 | daily-ledger-close (async) | 100 | 370 µs | 491 µs | **tie** | 16.7 MB | 17.2 MB | tie | 3 |
| 51 | category-rank | 100 | 3.8 µs | 10 µs | **tie** | 17.0 MB | 16.6 MB | tie | 3 |
| 52 | stock-revaluation (async) | 100 | 318 µs | 560 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 53 | smoothed-zone-changes | 100 | 1.8 µs | 6.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |

## N = 10000

| # | Case | N | Native time | FxDart time | Time winner | Native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 10000 | 129 µs | 250 µs | **tie** | 16.9 MB | 16.9 MB | tie | 3 |
| 2 | running-balance | 10000 | 2.07 ms | 2.55 ms | **tie** | 24.0 MB | 23.6 MB | tie | 3 |
| 3 | top-expenses | 10000 | 3.25 ms | 1.86 ms | **fxdart** | 23.1 MB | 22.8 MB | tie | 3 |
| 4 | first-visit-merchants | 10000 | 179 µs | 331 µs | **tie** | 16.9 MB | 16.4 MB | tie | 3 |
| 5 | average-basket | 10000 | 188 µs | 242 µs | **tie** | 19.0 MB | 22.3 MB | native | 3 |
| 6 | first-over-limit | 10000 | 54 µs | 125 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 7 | top-log-level | 10000 | 356 µs | 684 µs | **tie** | 18.8 MB | 22.8 MB | native | 3 |
| 8 | paginate-users | 10000 | 775 µs | 802 µs | **tie** | 22.9 MB | 23.4 MB | tie | 3 |
| 9 | rank-labels | 10000 | 1.61 ms | 1.73 ms | **tie** | 34.8 MB | 37.9 MB | native | 3 |
| 10 | sequential-configs (async) | 10000 | 33.9 ms | 38.7 ms | **native** | 51.0 MB | 51.5 MB | tie | 3 |
| 11 | top-merchants | 10000 | 713 µs | 549 µs | **tie** | 23.1 MB | 23.0 MB | tie | 3 |
| 12 | recent-errors | 10000 | 91 µs | 238 µs | **tie** | 15.8 MB | 15.8 MB | tie | 3 |
| 13 | date-window-spend | 10000 | 154 µs | 266 µs | **tie** | 20.8 MB | 23.0 MB | native | 3 |
| 14 | unique-tags | 10000 | 1.25 ms | 985 µs | **tie** | 20.7 MB | 23.1 MB | native | 3 |
| 15 | refunds-vs-charges | 10000 | 2.14 ms | 2.08 ms | **tie** | 23.3 MB | 22.9 MB | tie | 3 |
| 16 | compound-interest | 10000 | 1.88 ms | 2.10 ms | **tie** | 22.8 MB | 22.8 MB | tie | 3 |
| 17 | sensor-anomalies | 10000 | 511 µs | 746 µs | **tie** | 23.7 MB | 23.6 MB | tie | 3 |
| 18 | top-category-average | 10000 | 353 µs | 484 µs | **tie** | 22.9 MB | 23.0 MB | tie | 3 |
| 19 | valid-emails | 10000 | 561 µs | 598 µs | **tie** | 20.0 MB | 20.0 MB | tie | 3 |
| 20 | bounded-concurrency (async) | 10000 | 32.3 ms | 39.2 ms | **native** | 26.4 MB | 22.3 MB | fxdart | 3 |
| 21 | monthly-category-report | 10000 | 110 µs | 287 µs | **tie** | 16.9 MB | 17.9 MB | native | 3 |
| 22 | paginated-products | 10000 | 853 µs | 1.37 ms | **tie** | 17.7 MB | 22.5 MB | native | 3 |
| 23 | weekly-sensor-averages | 9996 | 396 µs | 689 µs | **tie** | 22.7 MB | 22.3 MB | tie | 3 |
| 24 | consecutive-over-limit | 10000 | 113 µs | 791 µs | **native** | 21.0 MB | 23.4 MB | native | 3 |
| 25 | budget-alerts | 10000 | 193 µs | 476 µs | **tie** | 21.1 MB | 23.0 MB | native | 3 |
| 26 | leaderboard-ties | 10000 | 2.53 ms | 3.59 ms | **native** | 23.5 MB | 32.0 MB | native | 3 |
| 27 | invoice-summary | 10000 | 244 µs | 591 µs | **tie** | 22.4 MB | 23.0 MB | tie | 3 |
| 28 | no-spend-streak | 10000 | 270 µs | 259 µs | **tie** | 19.5 MB | 19.4 MB | tie | 3 |
| 29 | duplicate-transactions | 10000 | 4.01 ms | 4.31 ms | **tie** | 40.3 MB | 40.2 MB | tie | 3 |
| 30 | concurrent-enrichment (async) | 10000 | 22.1 ms | 28.7 ms | **native** | 49.3 MB | 52.3 MB | native | 3 |
| 31 | monthly-ledger-report | 10000 | 929 µs | 1.30 ms | **tie** | 23.0 MB | 23.8 MB | tie | 3 |
| 32 | cohort-retention | 10000 | 2.47 ms | 2.84 ms | **tie** | 18.0 MB | 22.0 MB | native | 3 |
| 33 | price-drop-detection | 10000 | 7.16 ms | 3.57 ms | **fxdart** | 37.1 MB | 36.5 MB | tie | 3 |
| 34 | anomaly-context | 10000 | 103 µs | 470 µs | **tie** | 18.4 MB | 23.0 MB | native | 3 |
| 35 | sparse-timeseries | 10000 | 467 µs | 704 µs | **tie** | 23.0 MB | 22.9 MB | tie | 3 |
| 36 | multi-currency-report | 10000 | 2.65 ms | 1.63 ms | **fxdart** | 21.8 MB | 33.9 MB | native | 3 |
| 37 | restock-plan | 10000 | 1.25 ms | 1.24 ms | **tie** | 17.4 MB | 22.0 MB | native | 3 |
| 38 | alert-digest | 10000 | 1.37 ms | 2.56 ms | **native** | 18.0 MB | 23.4 MB | native | 3 |
| 39 | latency-percentiles | 10000 | 1.94 ms | 2.69 ms | **native** | 18.1 MB | 23.1 MB | native | 3 |
| 40 | ledger-diff | 10000 | 2.63 ms | 4.44 ms | **native** | 26.1 MB | 39.1 MB | native | 3 |
| 41 | concurrent-profile-fetch (async) | 10000 | 32.1 ms | 35.5 ms | **native** | 51.3 MB | 32.5 MB | fxdart | 3 |
| 42 | flaky-api-retry (async) | 10000 | 54.5 ms | 123.4 ms | **native** | 29.5 MB | 24.8 MB | fxdart | 3 |
| 43 | price-lookup-fallback (async) | 10000 | 37.4 ms | 54.4 ms | **native** | 49.0 MB | 38.1 MB | fxdart | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.23 ms | 10.5 ms | **native** | 24.1 MB | 27.5 MB | native | 3 |
| 45 | rate-limited-import (async) | 10000 | 13.9 ms | 27.5 ms | **native** | 24.2 MB | 31.0 MB | native | 3 |
| 46 | parallel-downloads (async) | 10000 | 36.7 ms | 56.5 ms | **native** | 50.9 MB | 41.8 MB | fxdart | 3 |
| 47 | paged-feeds-dedupe (async) | 10000 | 9.00 ms | 17.8 ms | **native** | 43.1 MB | 26.8 MB | fxdart | 3 |
| 48 | settlement-pipeline (async) | 10000 | 4.54 ms | 4.53 ms | **tie** | 23.1 MB | 46.5 MB | native | 3 |
| 49 | live-search (async) | 10000 | 5.02 ms | 8.50 ms | **native** | 23.4 MB | 24.0 MB | tie | 3 |
| 50 | daily-ledger-close (async) | 10000 | 330.7 ms | 342.3 ms | **tie** | 49.9 MB | 50.5 MB | tie | 5 |
| 51 | category-rank | 10000 | 289 µs | 461 µs | **tie** | 17.4 MB | 23.6 MB | native | 3 |
| 52 | stock-revaluation (async) | 10000 | 32.3 ms | 54.7 ms | **native** | 49.6 MB | 38.5 MB | fxdart | 3 |
| 53 | smoothed-zone-changes | 10000 | 182 µs | 650 µs | **tie** | 22.0 MB | 22.2 MB | tie | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | Native time | FxDart time | Time winner | Native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 1000000 | 12.9 ms | 23.8 ms | **native** | 89.6 MB | 90.2 MB | tie | 3 |
| 2 | running-balance | 1000000 | 271.7 ms | 314.6 ms | **native** | 182.1 MB | 185.2 MB | tie | 3 |
| 3 | top-expenses | 1000000 | 557.4 ms | 363.7 ms | **fxdart** | 126.4 MB | 176.3 MB | native | 3 |
| 4 | first-visit-merchants | 1000000 | 34.7 ms | 58.2 ms | **native** | 116.8 MB | 119.8 MB | tie | 3 |
| 5 | average-basket | 1000000 | 17.9 ms | 23.1 ms | **native** | 74.7 MB | 75.2 MB | tie | 3 |
| 6 | first-over-limit | 1000000 | 5.28 ms | 12.6 ms | **native** | 116.8 MB | 117.9 MB | tie | 3 |
| 7 | top-log-level | 1000000 | 51.9 ms | 65.7 ms | **native** | 80.8 MB | 75.3 MB | fxdart | 3 |
| 8 | paginate-users | 1000000 | 82.2 ms | 91.9 ms | **native** | 122.8 MB | 127.2 MB | tie | 3 |
| 9 | rank-labels | 1000000 | 208.9 ms | 220.7 ms | **native** | 241.4 MB | 221.8 MB | fxdart | 4 |
| 10 | sequential-configs (async) | 100000 | 338.5 ms | 398.1 ms | **native** | 82.8 MB | 81.8 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 115.2 ms | 83.4 ms | **fxdart** | 137.5 MB | 133.4 MB | tie | 3 |
| 12 | recent-errors | 1000000 | 10.6 ms | 26.5 ms | **native** | 113.4 MB | 113.8 MB | tie | 3 |
| 13 | date-window-spend | 1000000 | 15.1 ms | 24.9 ms | **native** | 123.6 MB | 124.6 MB | tie | 3 |
| 14 | unique-tags | 1000000 | 109.1 ms | 78.4 ms | **fxdart** | 161.6 MB | 161.8 MB | tie | 3 |
| 15 | refunds-vs-charges | 1000000 | 256.4 ms | 259.5 ms | **tie** | 179.9 MB | 178.0 MB | tie | 5 |
| 16 | compound-interest | 1000000 | 225.0 ms | 253.0 ms | **native** | 127.2 MB | 127.1 MB | tie | 3 |
| 17 | sensor-anomalies | 1000000 | 63.6 ms | 85.9 ms | **native** | 169.9 MB | 159.8 MB | fxdart | 3 |
| 18 | top-category-average | 1000000 | 62.0 ms | 81.3 ms | **native** | 134.9 MB | 129.2 MB | tie | 3 |
| 19 | valid-emails | 1000000 | 73.8 ms | 77.5 ms | **native** | 174.3 MB | 174.9 MB | tie | 4 |
| 20 | bounded-concurrency (async) | 100000 | 320.5 ms | 387.8 ms | **native** | 49.5 MB | 50.5 MB | tie | 3 |
| 21 | monthly-category-report | 1000000 | 11.4 ms | 28.9 ms | **native** | 119.4 MB | 124.1 MB | tie | 3 |
| 22 | paginated-products | 1000000 | 104.4 ms | 213.8 ms | **native** | 178.5 MB | 240.5 MB | native | 3 |
| 23 | weekly-sensor-averages | 999999 | 51.2 ms | 77.7 ms | **native** | 95.3 MB | 92.6 MB | tie | 3 |
| 24 | consecutive-over-limit | 1000000 | 17.5 ms | 84.7 ms | **native** | 149.7 MB | 148.3 MB | tie | 3 |
| 25 | budget-alerts | 1000000 | 22.4 ms | 91.0 ms | **native** | 90.2 MB | 116.6 MB | native | 3 |
| 26 | leaderboard-ties | 1000000 | 666.1 ms | 793.2 ms | **native** | 232.0 MB | 247.2 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 25.4 ms | 113.1 ms | **native** | 89.8 MB | 123.5 MB | native | 3 |
| 28 | no-spend-streak | 1000000 | 24.6 ms | 24.3 ms | **tie** | 106.0 MB | 105.0 MB | tie | 3 |
| 29 | duplicate-transactions | 1000000 | 1021.3 ms | 1045.9 ms | **tie** | 327.2 MB | 329.0 MB | tie | 5 |
| 30 | concurrent-enrichment (async) | 100000 | 230.9 ms | 290.8 ms | **native** | 81.3 MB | 84.0 MB | tie | 3 |
| 31 | monthly-ledger-report | 1000000 | 134.4 ms | 197.7 ms | **native** | 158.5 MB | 139.1 MB | fxdart | 3 |
| 32 | cohort-retention | 1000000 | 750.0 ms | 778.6 ms | **tie** | 238.6 MB | 245.0 MB | tie | 5 |
| 33 | price-drop-detection | 1000000 | 1207.8 ms | 703.3 ms | **fxdart** | 390.0 MB | 405.7 MB | tie | 3 |
| 34 | anomaly-context | 1000000 | 12.8 ms | 46.0 ms | **native** | 131.9 MB | 135.8 MB | tie | 3 |
| 35 | sparse-timeseries | 1000000 | 63.1 ms | 108.4 ms | **native** | 124.1 MB | 211.9 MB | native | 3 |
| 36 | multi-currency-report | 1000000 | 381.7 ms | 249.9 ms | **fxdart** | 222.9 MB | 257.3 MB | native | 3 |
| 37 | restock-plan | 1000000 | 228.0 ms | 220.0 ms | **tie** | 173.4 MB | 200.1 MB | native | 5 |
| 38 | alert-digest | 1000000 | 180.6 ms | 314.0 ms | **native** | 236.3 MB | 135.0 MB | fxdart | 3 |
| 39 | latency-percentiles | 1000000 | 222.9 ms | 372.5 ms | **native** | 137.5 MB | 135.0 MB | tie | 3 |
| 40 | ledger-diff | 500000 | 244.6 ms | 393.0 ms | **native** | 185.4 MB | 169.9 MB | fxdart | 3 |
| 41 | concurrent-profile-fetch (async) | 100000 | 336.1 ms | 416.8 ms | **native** | 80.2 MB | 82.0 MB | tie | 3 |
| 42 | flaky-api-retry (async) | 100000 | 588.4 ms | 1276.5 ms | **native** | 56.3 MB | 50.0 MB | fxdart | 3 |
| 43 | price-lookup-fallback (async) | 100000 | 368.8 ms | 599.8 ms | **native** | 81.1 MB | 80.5 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100000 | 33.4 ms | 106.5 ms | **native** | 74.9 MB | 80.3 MB | native | 3 |
| 45 | rate-limited-import (async) | 100000 | 138.6 ms | 295.0 ms | **native** | 76.5 MB | 80.2 MB | tie | 3 |
| 46 | parallel-downloads (async) | 100000 | 378.5 ms | 597.6 ms | **native** | 81.0 MB | 81.4 MB | tie | 3 |
| 47 | paged-feeds-dedupe (async) | 100000 | 89.3 ms | 193.9 ms | **native** | 74.2 MB | 76.2 MB | tie | 3 |
| 48 | settlement-pipeline (async) | 100000 | 52.5 ms | 43.8 ms | **fxdart** | 56.7 MB | 62.2 MB | native | 3 |
| 49 | live-search (async) | 100000 | 51.7 ms | 87.3 ms | **native** | 52.9 MB | 61.5 MB | native | 3 |
| 50 | daily-ledger-close (async) | 20000 | 1243.7 ms | 1271.2 ms | **tie** | 51.4 MB | 53.2 MB | tie | 5 |
| 51 | category-rank | 1000000 | 37.5 ms | 53.4 ms | **native** | 146.6 MB | 148.0 MB | tie | 3 |
| 52 | stock-revaluation (async) | 100000 | 318.4 ms | 562.6 ms | **native** | 80.7 MB | 80.0 MB | tie | 3 |
| 53 | smoothed-zone-changes | 1000000 | 40.7 ms | 61.0 ms | **native** | 159.3 MB | 82.2 MB | fxdart | 3 |
