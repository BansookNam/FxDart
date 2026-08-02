# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-03
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | food-spending | 1000000 | 12.4 ms | 23.0 ms | **native** | 90.3 MB | 90.6 MB | tie | 3 |
| 2 | running-balance | 1000000 | 244.8 ms | 280.9 ms | **native** | 175.8 MB | 184.8 MB | native | 3 |
| 3 | top-expenses | 1000000 | 509.6 ms | 353.0 ms | **fxdart** | 129.2 MB | 179.9 MB | native | 3 |
| 4 | first-visit-merchants | 1000000 | 24.1 ms | 55.1 ms | **native** | 116.5 MB | 119.9 MB | tie | 3 |
| 5 | average-basket | 1000000 | 17.8 ms | 22.7 ms | **native** | 75.1 MB | 74.8 MB | tie | 3 |
| 6 | first-over-limit | 1000000 | 4.97 ms | 12.1 ms | **native** | 116.7 MB | 117.4 MB | tie | 3 |
| 7 | top-log-level | 1000000 | 45.6 ms | 41.8 ms | **fxdart** | 79.6 MB | 44.8 MB | fxdart | 3 |
| 8 | paginate-users | 1000000 | 82.5 ms | 92.2 ms | **native** | 127.0 MB | 126.9 MB | tie | 3 |
| 9 | rank-labels | 1000000 | 207.1 ms | 229.9 ms | **native** | 241.4 MB | 219.0 MB | fxdart | 3 |
| 10 | sequential-configs (async) | 100000 | 349.0 ms | 383.0 ms | **native** | 83.3 MB | 82.3 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 128.3 ms | 71.0 ms | **fxdart** | 138.0 MB | 117.9 MB | fxdart | 3 |
| 12 | recent-errors | 1000000 | 10.5 ms | 26.4 ms | **native** | 113.9 MB | 113.7 MB | tie | 3 |
| 13 | date-window-spend | 1000000 | 15.1 ms | 24.8 ms | **native** | 125.8 MB | 125.7 MB | tie | 3 |
| 14 | unique-tags | 1000000 | 109.3 ms | 77.3 ms | **fxdart** | 161.9 MB | 161.7 MB | tie | 3 |
| 15 | refunds-vs-charges | 1000000 | 257.0 ms | 242.8 ms | **fxdart** | 179.4 MB | 179.0 MB | tie | 5 |
| 16 | compound-interest | 1000000 | 224.1 ms | 244.5 ms | **native** | 125.0 MB | 125.1 MB | tie | 3 |
| 17 | sensor-anomalies | 1000000 | 64.3 ms | 91.2 ms | **native** | 169.5 MB | 161.2 MB | fxdart | 3 |
| 18 | top-category-average | 1000000 | 58.9 ms | 70.2 ms | **native** | 134.2 MB | 131.0 MB | tie | 3 |
| 19 | valid-emails | 1000000 | 70.8 ms | 76.3 ms | **native** | 174.9 MB | 179.2 MB | tie | 3 |
| 20 | bounded-concurrency (async) | 100000 | 311.2 ms | 384.6 ms | **native** | 49.8 MB | 50.4 MB | tie | 3 |
| 21 | monthly-category-report | 1000000 | 11.7 ms | 28.1 ms | **native** | 120.1 MB | 122.5 MB | tie | 3 |
| 22 | paginated-products | 1000000 | 105.9 ms | 213.0 ms | **native** | 177.8 MB | 233.4 MB | native | 3 |
| 23 | weekly-sensor-averages | 999999 | 51.7 ms | 75.1 ms | **native** | 98.1 MB | 93.8 MB | tie | 3 |
| 24 | consecutive-over-limit | 1000000 | 17.2 ms | 81.3 ms | **native** | 150.4 MB | 148.0 MB | tie | 3 |
| 25 | budget-alerts | 1000000 | 22.1 ms | 57.1 ms | **native** | 90.5 MB | 108.4 MB | native | 3 |
| 26 | leaderboard-ties | 1000000 | 545.3 ms | 722.4 ms | **native** | 232.4 MB | 311.9 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 25.2 ms | 90.6 ms | **native** | 89.7 MB | 123.6 MB | native | 3 |
| 28 | no-spend-streak | 1000000 | 24.1 ms | 23.6 ms | **tie** | 105.9 MB | 105.9 MB | tie | 3 |
| 29 | duplicate-transactions | 1000000 | 980.7 ms | 975.2 ms | **tie** | 324.8 MB | 334.0 MB | tie | 5 |
| 30 | concurrent-enrichment (async) | 100000 | 202.7 ms | 275.9 ms | **native** | 81.4 MB | 84.0 MB | tie | 3 |
| 31 | monthly-ledger-report | 1000000 | 152.3 ms | 186.7 ms | **native** | 140.5 MB | 134.6 MB | tie | 3 |
| 32 | cohort-retention | 1000000 | 661.4 ms | 717.7 ms | **native** | 238.8 MB | 238.8 MB | tie | 3 |
| 33 | price-drop-detection | 1000000 | 1199.2 ms | 663.8 ms | **fxdart** | 392.6 MB | 399.3 MB | tie | 3 |
| 34 | anomaly-context | 1000000 | 11.9 ms | 46.0 ms | **native** | 132.1 MB | 135.1 MB | tie | 3 |
| 35 | sparse-timeseries | 1000000 | 57.0 ms | 93.2 ms | **native** | 124.0 MB | 135.9 MB | native | 3 |
| 36 | multi-currency-report | 1000000 | 382.9 ms | 246.6 ms | **fxdart** | 221.0 MB | 228.7 MB | tie | 3 |
| 37 | restock-plan | 1000000 | 226.9 ms | 213.6 ms | **fxdart** | 173.4 MB | 201.2 MB | native | 3 |
| 38 | alert-digest | 1000000 | 172.4 ms | 283.9 ms | **native** | 125.9 MB | 238.9 MB | native | 3 |
| 39 | latency-percentiles | 1000000 | 201.1 ms | 301.3 ms | **native** | 137.9 MB | 240.3 MB | native | 3 |
| 40 | ledger-diff | 500000 | 235.9 ms | 321.9 ms | **native** | 265.6 MB | 173.3 MB | fxdart | 3 |
| 41 | concurrent-profile-fetch (async) | 100000 | 307.5 ms | 382.6 ms | **native** | 79.8 MB | 82.0 MB | tie | 3 |
| 42 | flaky-api-retry (async) | 100000 | 531.5 ms | 1120.7 ms | **native** | 56.3 MB | 44.8 MB | fxdart | 3 |
| 43 | price-lookup-fallback (async) | 100000 | 382.2 ms | 540.7 ms | **native** | 80.7 MB | 80.5 MB | tie | 3 |
| 44 | stream-windowed-alerts (async) | 100000 | 33.7 ms | 105.4 ms | **native** | 74.8 MB | 80.1 MB | native | 3 |
| 45 | rate-limited-import (async) | 100000 | 152.4 ms | 320.2 ms | **native** | 76.5 MB | 80.0 MB | tie | 3 |
| 46 | parallel-downloads (async) | 100000 | 356.6 ms | 533.9 ms | **native** | 80.8 MB | 81.6 MB | tie | 3 |
| 47 | paged-feeds-dedupe (async) | 100000 | 81.9 ms | 177.5 ms | **native** | 73.7 MB | 76.2 MB | tie | 3 |
| 48 | settlement-pipeline (async) | 100000 | 52.7 ms | 40.7 ms | **fxdart** | 56.3 MB | 61.0 MB | native | 3 |
| 49 | live-search (async) | 100000 | 47.3 ms | 84.2 ms | **native** | 53.0 MB | 61.6 MB | native | 3 |
| 50 | daily-ledger-close (async) | 20000 | 1211.0 ms | 1229.5 ms | **tie** | 53.2 MB | 54.5 MB | tie | 5 |
| 51 | category-rank | 1000000 | 34.8 ms | 47.8 ms | **native** | 148.5 MB | 147.3 MB | tie | 3 |
| 52 | stock-revaluation (async) | 100000 | 328.3 ms | 556.6 ms | **native** | 80.6 MB | 80.4 MB | tie | 3 |
| 53 | smoothed-zone-changes | 1000000 | 38.6 ms | 60.8 ms | **native** | 159.5 MB | 82.1 MB | fxdart | 3 |
