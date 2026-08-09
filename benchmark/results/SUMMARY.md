# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-10
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 20 µs | 5.8 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.7 µs | 3.3 µs | **tie** | 16.6 MB | 15.6 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100 | 374 µs | 321 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 4 | average-basket | 100 | 2.0 µs | 1.1 µs | **tie** | 16.6 MB | 15.9 MB | tie | 3 |
| 5 | paginate-users | 100 | 7.6 µs | 6.4 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 6 | rank-labels | 100 | 15 µs | 17 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 7 | running-balance | 100 | 20 µs | 24 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 8 | food-spending | 100 | 1.1 µs | 1.0 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.5 µs | 2.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 10 | first-over-limit | 100 | 946 ns | 998 ns | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 11 | top-merchants | 100 | 26 µs | 152 µs | **tie** | 16.6 MB | 17.2 MB | tie | 3 |
| 12 | unique-tags | 100 | 54 µs | 49 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 22 µs | 19 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 14 | valid-emails | 100 | 5.1 µs | 4.9 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100 | 342 µs | 411 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 16 | compound-interest | 100 | 19 µs | 21 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 17 | top-category-average | 100 | 7.4 µs | 6.9 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 18 | date-window-spend | 100 | 1.9 µs | 1.5 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 19 | sensor-anomalies | 100 | 5.9 µs | 7.3 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 20 | recent-errors | 100 | 1.1 µs | 2.0 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 21 | duplicate-transactions | 100 | 41 µs | 41 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 4.4 µs | 5.4 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 214 µs | 243 µs | **tie** | 16.6 MB | 16.7 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 23 µs | 31 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 25 | weekly-sensor-averages | 98 | 3.7 µs | 4.5 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 26 | paginated-products | 100 | 5.8 µs | 6.3 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 27 | invoice-summary | 100 | 4.2 µs | 9.5 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.6 µs | 4.7 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.8 µs | 6.5 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 100 | 2.0 µs | 2.8 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 34 µs | 50 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 32 | restock-plan | 100 | 11 µs | 9.0 µs | **tie** | 16.7 MB | 16.6 MB | tie | 3 |
| 33 | price-lookup-fallback (async) | 100 | 401 µs | 371 µs | **tie** | 16.5 MB | 17.2 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 24 µs | 31 µs | **tie** | 17.2 MB | 16.6 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 28 µs | 34 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 364 µs | 473 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 37 | ledger-diff | 100 | 22 µs | 30 µs | **tie** | 16.7 MB | 16.6 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 622 µs | 837 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 39 | alert-digest | 100 | 21 µs | 30 µs | **tie** | 17.1 MB | 16.6 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 17 µs | 20 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 83 µs | 96 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.5 µs | 2.7 µs | **tie** | 16.7 MB | 16.6 MB | tie | 3 |
| 43 | smoothed-zone-changes | 100 | 1.8 µs | 4.2 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 36 µs | 55 µs | **tie** | 17.2 MB | 16.7 MB | tie | 3 |
| 45 | live-search (async) | 100 | 52 µs | 87 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 152 µs | 188 µs | **tie** | 16.4 MB | 16.9 MB | tie | 3 |
| 47 | category-rank | 100 | 3.8 µs | 16 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 373 µs | 415 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 308 µs | 343 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 50 | cohort-retention | 100 | 41 µs | 43 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 100 | 373 µs | 416 µs | **tie** | 16.6 MB | 17.3 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 31 µs | 33 µs | **tie** | 16.7 MB | 16.7 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 51 µs | 39 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.47 ms | 921 µs | **fxdart** | 23.2 MB | 22.1 MB | tie | 3 |
| 2 | top-log-level | 10000 | 353 µs | 319 µs | **tie** | 18.9 MB | 14.1 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 33.9 ms | 34.3 ms | **tie** | 50.7 MB | 50.8 MB | tie | 5 |
| 4 | average-basket | 10000 | 180 µs | 103 µs | **tie** | 19.2 MB | 15.3 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 767 µs | 676 µs | **tie** | 23.0 MB | 23.4 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.56 ms | 1.71 ms | **tie** | 34.8 MB | 37.7 MB | native | 3 |
| 7 | running-balance | 10000 | 1.95 ms | 2.21 ms | **tie** | 24.0 MB | 23.8 MB | tie | 3 |
| 8 | food-spending | 10000 | 128 µs | 128 µs | **tie** | 16.9 MB | 15.6 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 151 µs | 298 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 10 | first-over-limit | 10000 | 54 µs | 57 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 11 | top-merchants | 10000 | 680 µs | 574 µs | **tie** | 23.0 MB | 23.6 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.21 ms | 949 µs | **tie** | 20.6 MB | 23.2 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.15 ms | 1.80 ms | **tie** | 23.4 MB | 23.0 MB | tie | 3 |
| 14 | valid-emails | 10000 | 555 µs | 521 µs | **tie** | 20.0 MB | 20.0 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 10000 | 30.2 ms | 35.6 ms | **native** | 26.4 MB | 22.2 MB | fxdart | 3 |
| 16 | compound-interest | 10000 | 1.86 ms | 2.11 ms | **tie** | 22.6 MB | 22.9 MB | tie | 3 |
| 17 | top-category-average | 10000 | 351 µs | 351 µs | **tie** | 22.4 MB | 22.5 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 154 µs | 111 µs | **tie** | 20.8 MB | 15.7 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 515 µs | 611 µs | **tie** | 23.6 MB | 23.8 MB | tie | 3 |
| 20 | recent-errors | 10000 | 89 µs | 149 µs | **tie** | 15.8 MB | 15.8 MB | tie | 3 |
| 21 | duplicate-transactions | 10000 | 4.15 ms | 4.01 ms | **tie** | 40.3 MB | 36.0 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 260 µs | 260 µs | **tie** | 19.6 MB | 19.6 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 20.3 ms | 24.5 ms | **native** | 49.3 MB | 50.0 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.34 ms | 2.93 ms | **tie** | 23.5 MB | 25.3 MB | native | 3 |
| 25 | weekly-sensor-averages | 9996 | 399 µs | 463 µs | **tie** | 22.8 MB | 22.8 MB | tie | 3 |
| 26 | paginated-products | 10000 | 871 µs | 815 µs | **tie** | 17.7 MB | 20.8 MB | native | 3 |
| 27 | invoice-summary | 10000 | 241 µs | 258 µs | **tie** | 22.5 MB | 19.1 MB | fxdart | 3 |
| 28 | budget-alerts | 10000 | 180 µs | 240 µs | **tie** | 21.9 MB | 19.6 MB | fxdart | 3 |
| 29 | monthly-category-report | 10000 | 107 µs | 173 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 30 | consecutive-over-limit | 10000 | 117 µs | 195 µs | **tie** | 20.9 MB | 23.5 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 2.61 ms | 4.28 ms | **native** | 21.9 MB | 22.4 MB | tie | 3 |
| 32 | restock-plan | 10000 | 1.28 ms | 1.12 ms | **tie** | 17.4 MB | 20.4 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 36.4 ms | 36.9 ms | **tie** | 49.1 MB | 30.9 MB | fxdart | 4 |
| 34 | monthly-ledger-report | 10000 | 924 µs | 662 µs | **tie** | 23.1 MB | 22.9 MB | tie | 3 |
| 35 | sparse-timeseries | 10000 | 463 µs | 443 µs | **tie** | 23.0 MB | 20.4 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 35.9 ms | 42.0 ms | **native** | 50.8 MB | 32.8 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.63 ms | 3.53 ms | **native** | 26.2 MB | 31.3 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 48.6 ms | 70.5 ms | **native** | 29.0 MB | 24.7 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.39 ms | 2.12 ms | **native** | 18.0 MB | 21.4 MB | native | 3 |
| 40 | latency-percentiles | 10000 | 1.91 ms | 2.05 ms | **tie** | 18.2 MB | 20.7 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 8.24 ms | 9.07 ms | **native** | 43.1 MB | 24.6 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 95 µs | 200 µs | **tie** | 18.2 MB | 23.0 MB | native | 3 |
| 43 | smoothed-zone-changes | 10000 | 188 µs | 413 µs | **tie** | 22.0 MB | 22.8 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.28 ms | 4.97 ms | **native** | 23.7 MB | 25.5 MB | native | 3 |
| 45 | live-search (async) | 10000 | 4.95 ms | 6.67 ms | **native** | 23.5 MB | 23.2 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 13.0 ms | 16.1 ms | **native** | 24.0 MB | 28.0 MB | native | 3 |
| 47 | category-rank | 10000 | 289 µs | 299 µs | **tie** | 17.5 MB | 17.9 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 32.9 ms | 38.4 ms | **native** | 48.8 MB | 30.6 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 28.8 ms | 31.1 ms | **native** | 51.8 MB | 32.0 MB | fxdart | 3 |
| 50 | cohort-retention | 10000 | 2.32 ms | 2.45 ms | **tie** | 17.6 MB | 18.1 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 10000 | 325.2 ms | 331.1 ms | **tie** | 50.0 MB | 50.1 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 4.34 ms | 3.06 ms | **fxdart** | 23.2 MB | 24.4 MB | native | 3 |
| 53 | price-drop-detection | 10000 | 7.16 ms | 3.66 ms | **fxdart** | 37.1 MB | 34.6 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 530.2 ms | 227.4 ms | **fxdart** | 127.2 MB | 137.5 MB | native | 3 |
| 2 | top-log-level | 1000000 | 50.6 ms | 33.2 ms | **fxdart** | 78.7 MB | 44.9 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 364.8 ms | 357.7 ms | **tie** | 82.9 MB | 82.0 MB | tie | 5 |
| 4 | average-basket | 1000000 | 17.6 ms | 10.1 ms | **fxdart** | 75.2 MB | 72.9 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 82.3 ms | 78.2 ms | **fxdart** | 127.1 MB | 126.9 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 208.2 ms | 216.4 ms | **tie** | 240.9 MB | 223.2 MB | fxdart | 5 |
| 7 | running-balance | 1000000 | 264.8 ms | 300.7 ms | **native** | 186.9 MB | 184.7 MB | tie | 3 |
| 8 | food-spending | 1000000 | 12.5 ms | 13.4 ms | **native** | 90.6 MB | 85.0 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 25.9 ms | 54.2 ms | **native** | 116.3 MB | 119.9 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 4.97 ms | 5.23 ms | **tie** | 117.2 MB | 117.4 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 118.4 ms | 62.1 ms | **fxdart** | 137.9 MB | 118.4 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 109.4 ms | 82.2 ms | **fxdart** | 161.5 MB | 161.7 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 257.7 ms | 229.4 ms | **fxdart** | 181.2 MB | 179.0 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 71.1 ms | 68.7 ms | **tie** | 174.6 MB | 175.5 MB | tie | 5 |
| 15 | bounded-concurrency (async) | 100000 | 301.4 ms | 344.7 ms | **native** | 49.3 MB | 50.4 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 221.5 ms | 244.7 ms | **native** | 125.6 MB | 124.3 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 60.9 ms | 61.4 ms | **tie** | 133.3 MB | 133.3 MB | tie | 3 |
| 18 | date-window-spend | 1000000 | 15.0 ms | 11.4 ms | **fxdart** | 125.7 MB | 119.0 MB | fxdart | 3 |
| 19 | sensor-anomalies | 1000000 | 65.5 ms | 76.3 ms | **native** | 162.8 MB | 174.6 MB | native | 3 |
| 20 | recent-errors | 1000000 | 10.3 ms | 16.5 ms | **native** | 113.3 MB | 113.8 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 1025.3 ms | 1021.9 ms | **tie** | 327.0 MB | 334.7 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 24.4 ms | 25.3 ms | **tie** | 106.1 MB | 106.3 MB | tie | 5 |
| 23 | concurrent-enrichment (async) | 100000 | 210.7 ms | 237.8 ms | **native** | 81.5 MB | 81.0 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 534.1 ms | 652.1 ms | **native** | 232.0 MB | 293.8 MB | native | 3 |
| 25 | weekly-sensor-averages | 999999 | 50.7 ms | 48.8 ms | **tie** | 95.8 MB | 145.6 MB | native | 5 |
| 26 | paginated-products | 1000000 | 103.6 ms | 127.9 ms | **native** | 177.7 MB | 208.5 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 25.1 ms | 27.5 ms | **native** | 89.5 MB | 91.0 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.7 ms | 27.5 ms | **native** | 90.2 MB | 90.1 MB | tie | 3 |
| 29 | monthly-category-report | 1000000 | 11.5 ms | 17.4 ms | **native** | 119.5 MB | 120.0 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 16.7 ms | 22.5 ms | **native** | 150.1 MB | 148.9 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 378.3 ms | 483.4 ms | **native** | 222.6 MB | 199.8 MB | fxdart | 3 |
| 32 | restock-plan | 1000000 | 224.6 ms | 223.1 ms | **tie** | 173.6 MB | 191.8 MB | native | 5 |
| 33 | price-lookup-fallback (async) | 100000 | 368.1 ms | 369.2 ms | **tie** | 81.1 MB | 80.9 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 142.6 ms | 72.9 ms | **fxdart** | 167.0 MB | 120.1 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 57.6 ms | 48.9 ms | **fxdart** | 125.2 MB | 145.2 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 370.3 ms | 414.3 ms | **native** | 81.1 MB | 124.7 MB | native | 3 |
| 37 | ledger-diff | 500000 | 234.3 ms | 318.0 ms | **native** | 177.0 MB | 170.1 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100000 | 493.9 ms | 710.7 ms | **native** | 56.1 MB | 50.0 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 175.7 ms | 259.1 ms | **native** | 238.1 MB | 239.3 MB | tie | 3 |
| 40 | latency-percentiles | 1000000 | 207.7 ms | 281.9 ms | **native** | 177.3 MB | 219.2 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 100000 | 88.8 ms | 103.1 ms | **native** | 73.6 MB | 74.5 MB | tie | 3 |
| 42 | anomaly-context | 1000000 | 12.8 ms | 21.1 ms | **native** | 132.4 MB | 135.5 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 48.5 ms | 39.9 ms | **fxdart** | 192.0 MB | 82.1 MB | fxdart | 3 |
| 44 | stream-windowed-alerts (async) | 100000 | 32.5 ms | 48.7 ms | **native** | 75.1 MB | 75.8 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 48.7 ms | 65.4 ms | **native** | 53.0 MB | 57.8 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 140.9 ms | 186.0 ms | **native** | 76.2 MB | 79.9 MB | tie | 3 |
| 47 | category-rank | 1000000 | 34.9 ms | 34.9 ms | **tie** | 146.9 MB | 145.9 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100000 | 329.5 ms | 380.7 ms | **native** | 80.7 MB | 80.8 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 305.7 ms | 327.2 ms | **native** | 79.9 MB | 80.2 MB | tie | 3 |
| 50 | cohort-retention | 1000000 | 767.2 ms | 760.5 ms | **tie** | 239.5 MB | 239.0 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 20000 | 1208.9 ms | 1210.4 ms | **tie** | 52.6 MB | 54.6 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 49.7 ms | 33.1 ms | **fxdart** | 56.2 MB | 58.5 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1184.3 ms | 644.7 ms | **fxdart** | 392.3 MB | 443.9 MB | native | 3 |
