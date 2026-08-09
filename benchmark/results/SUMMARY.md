# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-10
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 100 | 20 µs | 6.4 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 2 | top-log-level | 100 | 3.5 µs | 3.4 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 3 | sequential-configs (async) | 100 | 333 µs | 338 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 4 | average-basket | 100 | 2.0 µs | 1.2 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 5 | paginate-users | 100 | 7.2 µs | 7.2 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 6 | rank-labels | 100 | 15 µs | 15 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 7 | running-balance | 100 | 20 µs | 23 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 8 | food-spending | 100 | 1.1 µs | 1.1 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 9 | first-visit-merchants | 100 | 1.5 µs | 2.9 µs | **tie** | 16.5 MB | 16.4 MB | tie | 5 |
| 10 | first-over-limit | 100 | 965 ns | 1.0 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 11 | top-merchants | 100 | 25 µs | 138 µs | **tie** | 17.0 MB | 17.1 MB | tie | 3 |
| 12 | unique-tags | 100 | 53 µs | 52 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 13 | refunds-vs-charges | 100 | 23 µs | 21 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 14 | valid-emails | 100 | 4.8 µs | 4.9 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100 | 411 µs | 450 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 16 | compound-interest | 100 | 18 µs | 20 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 17 | top-category-average | 100 | 6.9 µs | 7.3 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 18 | date-window-spend | 100 | 1.7 µs | 1.4 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 19 | sensor-anomalies | 100 | 6.1 µs | 6.8 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 20 | recent-errors | 100 | 1.1 µs | 1.9 µs | **tie** | 16.5 MB | 16.5 MB | tie | 5 |
| 21 | duplicate-transactions | 100 | 42 µs | 42 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 22 | no-spend-streak | 100 | 3.9 µs | 5.5 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 100 | 180 µs | 211 µs | **tie** | 16.6 MB | 16.7 MB | tie | 3 |
| 24 | leaderboard-ties | 100 | 20 µs | 30 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 25 | weekly-sensor-averages | 98 | 4.1 µs | 4.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 26 | paginated-products | 100 | 5.7 µs | 6.4 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 27 | invoice-summary | 100 | 4.3 µs | 9.8 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 28 | budget-alerts | 100 | 3.4 µs | 4.7 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 29 | monthly-category-report | 100 | 2.1 µs | 6.5 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 30 | consecutive-over-limit | 100 | 1.7 µs | 2.7 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 31 | multi-currency-report | 100 | 32 µs | 47 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 32 | restock-plan | 100 | 10 µs | 9.4 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 33 | price-lookup-fallback (async) | 100 | 446 µs | 443 µs | **tie** | 16.6 MB | 17.3 MB | tie | 3 |
| 34 | monthly-ledger-report | 100 | 22 µs | 31 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 35 | sparse-timeseries | 100 | 28 µs | 31 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 36 | parallel-downloads (async) | 100 | 367 µs | 457 µs | **tie** | 16.6 MB | 17.2 MB | tie | 3 |
| 37 | ledger-diff | 100 | 23 µs | 31 µs | **tie** | 16.7 MB | 16.6 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100 | 502 µs | 794 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 39 | alert-digest | 100 | 21 µs | 31 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 40 | latency-percentiles | 100 | 17 µs | 19 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 41 | paged-feeds-dedupe (async) | 100 | 83 µs | 103 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 42 | anomaly-context | 100 | 1.5 µs | 3.9 µs | **tie** | 16.6 MB | 16.5 MB | tie | 5 |
| 43 | smoothed-zone-changes | 100 | 1.9 µs | 4.7 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100 | 31 µs | 53 µs | **tie** | 16.6 MB | 17.1 MB | tie | 3 |
| 45 | live-search (async) | 100 | 47 µs | 65 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 46 | rate-limited-import (async) | 100 | 152 µs | 187 µs | **tie** | 16.4 MB | 17.4 MB | native | 3 |
| 47 | category-rank | 100 | 3.7 µs | 15 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100 | 307 µs | 390 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100 | 315 µs | 322 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 50 | cohort-retention | 100 | 40 µs | 39 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 100 | 383 µs | 413 µs | **tie** | 16.6 MB | 17.2 MB | tie | 3 |
| 52 | settlement-pipeline (async) | 100 | 35 µs | 38 µs | **tie** | 16.6 MB | 17.3 MB | tie | 3 |
| 53 | price-drop-detection | 100 | 51 µs | 38 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |

## N = 10000

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 10000 | 3.31 ms | 946 µs | **fxdart** | 23.1 MB | 22.1 MB | tie | 3 |
| 2 | top-log-level | 10000 | 358 µs | 313 µs | **tie** | 18.9 MB | 14.3 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 10000 | 31.8 ms | 33.5 ms | **native** | 50.6 MB | 50.7 MB | tie | 3 |
| 4 | average-basket | 10000 | 181 µs | 101 µs | **tie** | 19.2 MB | 15.2 MB | fxdart | 3 |
| 5 | paginate-users | 10000 | 764 µs | 639 µs | **tie** | 22.9 MB | 23.3 MB | tie | 3 |
| 6 | rank-labels | 10000 | 1.56 ms | 1.65 ms | **tie** | 34.8 MB | 37.7 MB | native | 3 |
| 7 | running-balance | 10000 | 1.97 ms | 2.15 ms | **tie** | 24.0 MB | 23.7 MB | tie | 3 |
| 8 | food-spending | 10000 | 134 µs | 123 µs | **tie** | 16.9 MB | 15.6 MB | fxdart | 3 |
| 9 | first-visit-merchants | 10000 | 147 µs | 290 µs | **tie** | 17.0 MB | 16.8 MB | tie | 5 |
| 10 | first-over-limit | 10000 | 55 µs | 57 µs | **tie** | 15.3 MB | 15.3 MB | tie | 3 |
| 11 | top-merchants | 10000 | 724 µs | 572 µs | **tie** | 23.0 MB | 23.6 MB | tie | 3 |
| 12 | unique-tags | 10000 | 1.19 ms | 949 µs | **tie** | 20.7 MB | 23.3 MB | native | 3 |
| 13 | refunds-vs-charges | 10000 | 2.20 ms | 1.92 ms | **tie** | 22.9 MB | 23.0 MB | tie | 3 |
| 14 | valid-emails | 10000 | 558 µs | 523 µs | **tie** | 20.1 MB | 20.0 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 10000 | 31.2 ms | 35.9 ms | **native** | 25.8 MB | 22.1 MB | fxdart | 3 |
| 16 | compound-interest | 10000 | 1.88 ms | 2.25 ms | **tie** | 22.7 MB | 22.8 MB | tie | 3 |
| 17 | top-category-average | 10000 | 351 µs | 355 µs | **tie** | 22.5 MB | 22.5 MB | tie | 3 |
| 18 | date-window-spend | 10000 | 154 µs | 113 µs | **tie** | 20.8 MB | 15.6 MB | fxdart | 3 |
| 19 | sensor-anomalies | 10000 | 519 µs | 614 µs | **tie** | 23.6 MB | 23.7 MB | tie | 3 |
| 20 | recent-errors | 10000 | 92 µs | 157 µs | **tie** | 15.9 MB | 15.9 MB | tie | 5 |
| 21 | duplicate-transactions | 10000 | 3.99 ms | 4.06 ms | **tie** | 40.3 MB | 36.0 MB | fxdart | 3 |
| 22 | no-spend-streak | 10000 | 252 µs | 262 µs | **tie** | 19.7 MB | 19.6 MB | tie | 3 |
| 23 | concurrent-enrichment (async) | 10000 | 17.4 ms | 19.9 ms | **native** | 49.3 MB | 50.3 MB | tie | 3 |
| 24 | leaderboard-ties | 10000 | 2.33 ms | 2.95 ms | **native** | 23.4 MB | 25.3 MB | native | 3 |
| 25 | weekly-sensor-averages | 9996 | 388 µs | 453 µs | **tie** | 22.7 MB | 22.8 MB | tie | 3 |
| 26 | paginated-products | 10000 | 815 µs | 819 µs | **tie** | 17.7 MB | 20.9 MB | native | 3 |
| 27 | invoice-summary | 10000 | 239 µs | 256 µs | **tie** | 22.5 MB | 19.1 MB | fxdart | 3 |
| 28 | budget-alerts | 10000 | 176 µs | 232 µs | **tie** | 21.9 MB | 19.6 MB | fxdart | 3 |
| 29 | monthly-category-report | 10000 | 107 µs | 168 µs | **tie** | 17.0 MB | 16.9 MB | tie | 3 |
| 30 | consecutive-over-limit | 10000 | 111 µs | 204 µs | **tie** | 20.9 MB | 23.5 MB | native | 3 |
| 31 | multi-currency-report | 10000 | 2.59 ms | 4.20 ms | **native** | 22.0 MB | 22.5 MB | tie | 3 |
| 32 | restock-plan | 10000 | 1.30 ms | 1.13 ms | **tie** | 17.5 MB | 20.3 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 10000 | 40.4 ms | 42.5 ms | **native** | 49.0 MB | 31.0 MB | fxdart | 3 |
| 34 | monthly-ledger-report | 10000 | 903 µs | 660 µs | **tie** | 23.0 MB | 23.0 MB | tie | 3 |
| 35 | sparse-timeseries | 10000 | 461 µs | 444 µs | **tie** | 23.0 MB | 20.2 MB | fxdart | 3 |
| 36 | parallel-downloads (async) | 10000 | 32.2 ms | 38.3 ms | **native** | 50.9 MB | 33.0 MB | fxdart | 3 |
| 37 | ledger-diff | 10000 | 2.56 ms | 3.57 ms | **native** | 26.1 MB | 31.3 MB | native | 3 |
| 38 | flaky-api-retry (async) | 10000 | 49.6 ms | 71.3 ms | **native** | 29.0 MB | 24.6 MB | fxdart | 3 |
| 39 | alert-digest | 10000 | 1.39 ms | 2.12 ms | **native** | 18.0 MB | 21.4 MB | native | 3 |
| 40 | latency-percentiles | 10000 | 1.85 ms | 2.00 ms | **tie** | 18.2 MB | 20.7 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 10000 | 7.54 ms | 8.41 ms | **native** | 43.3 MB | 24.6 MB | fxdart | 3 |
| 42 | anomaly-context | 10000 | 96 µs | 302 µs | **tie** | 18.1 MB | 21.1 MB | native | 5 |
| 43 | smoothed-zone-changes | 10000 | 174 µs | 410 µs | **tie** | 22.0 MB | 22.7 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 10000 | 3.04 ms | 4.63 ms | **native** | 23.7 MB | 25.3 MB | native | 3 |
| 45 | live-search (async) | 10000 | 4.44 ms | 5.90 ms | **native** | 23.5 MB | 23.7 MB | tie | 3 |
| 46 | rate-limited-import (async) | 10000 | 12.3 ms | 15.6 ms | **native** | 23.6 MB | 28.1 MB | native | 3 |
| 47 | category-rank | 10000 | 278 µs | 308 µs | **tie** | 17.3 MB | 17.9 MB | tie | 3 |
| 48 | stock-revaluation (async) | 10000 | 29.5 ms | 33.6 ms | **native** | 49.1 MB | 30.8 MB | fxdart | 3 |
| 49 | concurrent-profile-fetch (async) | 10000 | 27.8 ms | 29.3 ms | **native** | 51.3 MB | 32.0 MB | fxdart | 3 |
| 50 | cohort-retention | 10000 | 2.27 ms | 2.23 ms | **tie** | 17.7 MB | 18.1 MB | tie | 3 |
| 51 | daily-ledger-close (async) | 10000 | 316.4 ms | 323.0 ms | **tie** | 49.9 MB | 50.4 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 10000 | 3.99 ms | 2.96 ms | **fxdart** | 23.2 MB | 24.0 MB | tie | 3 |
| 53 | price-drop-detection | 10000 | 7.00 ms | 3.66 ms | **fxdart** | 37.2 MB | 34.4 MB | fxdart | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 510.6 ms | 216.1 ms | **fxdart** | 125.0 MB | 136.8 MB | native | 3 |
| 2 | top-log-level | 1000000 | 46.0 ms | 32.3 ms | **fxdart** | 97.9 MB | 44.9 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 334.6 ms | 334.5 ms | **tie** | 82.5 MB | 82.2 MB | tie | 4 |
| 4 | average-basket | 1000000 | 17.1 ms | 10.1 ms | **fxdart** | 75.3 MB | 72.8 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 81.4 ms | 77.0 ms | **fxdart** | 122.8 MB | 126.9 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 207.2 ms | 214.7 ms | **tie** | 240.9 MB | 223.0 MB | fxdart | 5 |
| 7 | running-balance | 1000000 | 240.8 ms | 275.5 ms | **native** | 186.7 MB | 185.0 MB | tie | 3 |
| 8 | food-spending | 1000000 | 12.4 ms | 13.3 ms | **native** | 90.3 MB | 84.7 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 33.0 ms | 51.5 ms | **native** | 116.0 MB | 119.9 MB | tie | 5 |
| 10 | first-over-limit | 1000000 | 5.01 ms | 5.35 ms | **tie** | 117.0 MB | 117.6 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 120.9 ms | 59.3 ms | **fxdart** | 137.7 MB | 118.4 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 107.5 ms | 81.8 ms | **fxdart** | 161.8 MB | 161.6 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 259.9 ms | 233.0 ms | **fxdart** | 180.8 MB | 177.8 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 73.6 ms | 69.4 ms | **fxdart** | 174.9 MB | 173.4 MB | tie | 3 |
| 15 | bounded-concurrency (async) | 100000 | 314.5 ms | 355.5 ms | **native** | 49.2 MB | 50.4 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 222.3 ms | 245.4 ms | **native** | 126.9 MB | 122.8 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 61.1 ms | 66.0 ms | **native** | 134.1 MB | 135.0 MB | tie | 3 |
| 18 | date-window-spend | 1000000 | 14.8 ms | 11.4 ms | **fxdart** | 126.3 MB | 119.5 MB | fxdart | 3 |
| 19 | sensor-anomalies | 1000000 | 63.2 ms | 76.4 ms | **native** | 162.5 MB | 156.5 MB | tie | 3 |
| 20 | recent-errors | 1000000 | 10.6 ms | 16.9 ms | **native** | 113.8 MB | 113.4 MB | tie | 5 |
| 21 | duplicate-transactions | 1000000 | 920.7 ms | 907.4 ms | **tie** | 324.3 MB | 331.2 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 23.6 ms | 24.2 ms | **tie** | 105.7 MB | 106.2 MB | tie | 5 |
| 23 | concurrent-enrichment (async) | 100000 | 186.9 ms | 213.3 ms | **native** | 81.4 MB | 81.5 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 519.0 ms | 648.7 ms | **native** | 260.8 MB | 293.5 MB | native | 3 |
| 25 | weekly-sensor-averages | 999999 | 46.6 ms | 49.1 ms | **native** | 98.8 MB | 145.6 MB | native | 3 |
| 26 | paginated-products | 1000000 | 103.0 ms | 125.0 ms | **native** | 177.7 MB | 208.0 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 24.7 ms | 27.0 ms | **native** | 89.3 MB | 90.7 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.4 ms | 27.3 ms | **native** | 89.9 MB | 90.2 MB | tie | 3 |
| 29 | monthly-category-report | 1000000 | 11.4 ms | 17.4 ms | **native** | 119.6 MB | 120.7 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 16.9 ms | 22.8 ms | **native** | 149.8 MB | 148.2 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 348.5 ms | 462.8 ms | **native** | 219.2 MB | 198.9 MB | fxdart | 3 |
| 32 | restock-plan | 1000000 | 223.6 ms | 223.0 ms | **tie** | 173.7 MB | 191.6 MB | native | 4 |
| 33 | price-lookup-fallback (async) | 100000 | 367.1 ms | 366.2 ms | **tie** | 81.1 MB | 80.7 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 132.2 ms | 73.0 ms | **fxdart** | 156.1 MB | 120.1 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 58.6 ms | 46.8 ms | **fxdart** | 123.5 MB | 144.7 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 344.7 ms | 391.9 ms | **native** | 80.8 MB | 100.9 MB | native | 3 |
| 37 | ledger-diff | 500000 | 228.0 ms | 314.3 ms | **native** | 177.0 MB | 180.1 MB | tie | 3 |
| 38 | flaky-api-retry (async) | 100000 | 485.6 ms | 693.9 ms | **native** | 55.9 MB | 50.1 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 165.8 ms | 244.3 ms | **native** | 239.8 MB | 126.5 MB | fxdart | 3 |
| 40 | latency-percentiles | 1000000 | 195.4 ms | 271.9 ms | **native** | 232.3 MB | 221.2 MB | fxdart | 3 |
| 41 | paged-feeds-dedupe (async) | 100000 | 78.5 ms | 91.3 ms | **native** | 73.6 MB | 74.0 MB | tie | 3 |
| 42 | anomaly-context | 1000000 | 12.4 ms | 32.0 ms | **native** | 131.8 MB | 135.6 MB | tie | 5 |
| 43 | smoothed-zone-changes | 1000000 | 38.1 ms | 36.6 ms | **tie** | 199.4 MB | 82.3 MB | fxdart | 5 |
| 44 | stream-windowed-alerts (async) | 100000 | 31.5 ms | 46.7 ms | **native** | 75.2 MB | 75.7 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 43.8 ms | 58.9 ms | **native** | 52.8 MB | 57.7 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 129.2 ms | 163.0 ms | **native** | 76.6 MB | 80.6 MB | native | 3 |
| 47 | category-rank | 1000000 | 32.9 ms | 33.3 ms | **tie** | 146.4 MB | 145.6 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100000 | 303.1 ms | 342.6 ms | **native** | 80.8 MB | 80.5 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 298.5 ms | 310.2 ms | **tie** | 80.0 MB | 80.3 MB | tie | 5 |
| 50 | cohort-retention | 1000000 | 609.6 ms | 632.8 ms | **tie** | 238.8 MB | 243.7 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 20000 | 1184.6 ms | 1192.9 ms | **tie** | 53.1 MB | 54.3 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 49.3 ms | 31.3 ms | **fxdart** | 56.8 MB | 58.6 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1137.1 ms | 610.5 ms | **fxdart** | 394.0 MB | 443.8 MB | native | 3 |
