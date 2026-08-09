# DartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-09
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## Headline N (1M sync / case-specific async)

| # | Case | N | native time | FxDart time | Time winner | native mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | top-expenses | 1000000 | 516.2 ms | 218.0 ms | **fxdart** | 125.4 MB | 136.2 MB | native | 3 |
| 2 | top-log-level | 1000000 | 46.8 ms | 31.7 ms | **fxdart** | 74.2 MB | 44.9 MB | fxdart | 3 |
| 3 | sequential-configs (async) | 100000 | 350.1 ms | 331.4 ms | **fxdart** | 83.2 MB | 82.0 MB | tie | 3 |
| 4 | average-basket | 1000000 | 17.4 ms | 10.2 ms | **fxdart** | 75.2 MB | 72.9 MB | tie | 3 |
| 5 | paginate-users | 1000000 | 82.2 ms | 75.2 ms | **fxdart** | 122.7 MB | 126.7 MB | tie | 3 |
| 6 | rank-labels | 1000000 | 208.5 ms | 215.4 ms | **tie** | 240.9 MB | 223.0 MB | fxdart | 5 |
| 7 | running-balance | 1000000 | 242.1 ms | 273.9 ms | **native** | 183.2 MB | 185.5 MB | tie | 3 |
| 8 | food-spending | 1000000 | 12.4 ms | 13.5 ms | **native** | 90.3 MB | 84.9 MB | fxdart | 3 |
| 9 | first-visit-merchants | 1000000 | 28.1 ms | 52.2 ms | **native** | 116.3 MB | 119.8 MB | tie | 3 |
| 10 | first-over-limit | 1000000 | 5.03 ms | 5.30 ms | **tie** | 117.0 MB | 117.3 MB | tie | 3 |
| 11 | top-merchants | 1000000 | 125.6 ms | 61.2 ms | **fxdart** | 137.8 MB | 118.8 MB | fxdart | 3 |
| 12 | unique-tags | 1000000 | 108.2 ms | 82.0 ms | **fxdart** | 161.7 MB | 161.9 MB | tie | 3 |
| 13 | refunds-vs-charges | 1000000 | 252.8 ms | 229.4 ms | **fxdart** | 176.5 MB | 178.0 MB | tie | 3 |
| 14 | valid-emails | 1000000 | 72.6 ms | 70.3 ms | **tie** | 174.4 MB | 175.1 MB | tie | 5 |
| 15 | bounded-concurrency (async) | 100000 | 312.4 ms | 356.3 ms | **native** | 49.2 MB | 50.4 MB | tie | 3 |
| 16 | compound-interest | 1000000 | 222.6 ms | 247.2 ms | **native** | 127.9 MB | 127.8 MB | tie | 3 |
| 17 | top-category-average | 1000000 | 66.2 ms | 65.9 ms | **tie** | 134.8 MB | 133.0 MB | tie | 4 |
| 18 | date-window-spend | 1000000 | 15.2 ms | 11.6 ms | **fxdart** | 125.8 MB | 119.7 MB | fxdart | 3 |
| 19 | sensor-anomalies | 1000000 | 64.5 ms | 73.9 ms | **native** | 162.8 MB | 155.3 MB | tie | 3 |
| 20 | recent-errors | 1000000 | 10.8 ms | 16.7 ms | **native** | 113.5 MB | 114.1 MB | tie | 3 |
| 21 | duplicate-transactions | 1000000 | 1012.8 ms | 1006.0 ms | **tie** | 323.4 MB | 332.6 MB | tie | 5 |
| 22 | no-spend-streak | 1000000 | 24.1 ms | 24.8 ms | **tie** | 106.4 MB | 106.5 MB | tie | 5 |
| 23 | concurrent-enrichment (async) | 100000 | 204.1 ms | 261.4 ms | **native** | 81.4 MB | 81.5 MB | tie | 3 |
| 24 | leaderboard-ties | 1000000 | 555.0 ms | 666.8 ms | **native** | 232.5 MB | 235.9 MB | tie | 3 |
| 25 | weekly-sensor-averages | 999999 | 51.5 ms | 60.4 ms | **native** | 99.0 MB | 96.6 MB | tie | 3 |
| 26 | paginated-products | 1000000 | 103.0 ms | 128.4 ms | **native** | 177.8 MB | 208.1 MB | native | 3 |
| 27 | invoice-summary | 1000000 | 25.1 ms | 27.4 ms | **native** | 89.2 MB | 90.1 MB | tie | 3 |
| 28 | budget-alerts | 1000000 | 21.7 ms | 27.7 ms | **native** | 90.3 MB | 90.1 MB | tie | 3 |
| 29 | monthly-category-report | 1000000 | 11.6 ms | 17.5 ms | **native** | 119.5 MB | 120.1 MB | tie | 3 |
| 30 | consecutive-over-limit | 1000000 | 17.8 ms | 22.9 ms | **native** | 150.1 MB | 151.3 MB | tie | 3 |
| 31 | multi-currency-report | 1000000 | 383.8 ms | 665.8 ms | **native** | 222.0 MB | 196.6 MB | fxdart | 3 |
| 32 | restock-plan | 1000000 | 221.9 ms | 208.4 ms | **fxdart** | 173.4 MB | 196.3 MB | native | 3 |
| 33 | price-lookup-fallback (async) | 100000 | 387.9 ms | 372.3 ms | **tie** | 80.9 MB | 80.9 MB | tie | 5 |
| 34 | monthly-ledger-report | 1000000 | 155.5 ms | 71.6 ms | **fxdart** | 166.4 MB | 120.1 MB | fxdart | 3 |
| 35 | sparse-timeseries | 1000000 | 59.1 ms | 49.0 ms | **fxdart** | 124.0 MB | 143.8 MB | native | 3 |
| 36 | parallel-downloads (async) | 100000 | 365.7 ms | 407.8 ms | **native** | 81.1 MB | 120.8 MB | native | 3 |
| 37 | ledger-diff | 500000 | 253.8 ms | 330.7 ms | **native** | 252.1 MB | 170.0 MB | fxdart | 3 |
| 38 | flaky-api-retry (async) | 100000 | 503.2 ms | 724.9 ms | **native** | 56.2 MB | 50.5 MB | fxdart | 3 |
| 39 | alert-digest | 1000000 | 176.6 ms | 261.7 ms | **native** | 237.3 MB | 240.1 MB | tie | 3 |
| 40 | latency-percentiles | 1000000 | 211.1 ms | 281.8 ms | **native** | 189.8 MB | 209.9 MB | native | 3 |
| 41 | paged-feeds-dedupe (async) | 100000 | 82.3 ms | 169.2 ms | **native** | 73.6 MB | 81.8 MB | native | 3 |
| 42 | anomaly-context | 1000000 | 12.2 ms | 20.6 ms | **native** | 132.2 MB | 135.4 MB | tie | 3 |
| 43 | smoothed-zone-changes | 1000000 | 39.2 ms | 38.2 ms | **tie** | 245.0 MB | 82.0 MB | fxdart | 5 |
| 44 | stream-windowed-alerts (async) | 100000 | 32.4 ms | 48.5 ms | **native** | 74.7 MB | 75.7 MB | tie | 3 |
| 45 | live-search (async) | 100000 | 48.4 ms | 70.5 ms | **native** | 52.8 MB | 59.1 MB | native | 3 |
| 46 | rate-limited-import (async) | 100000 | 134.7 ms | 176.4 ms | **native** | 76.3 MB | 80.6 MB | native | 3 |
| 47 | category-rank | 1000000 | 35.6 ms | 35.4 ms | **tie** | 146.8 MB | 147.7 MB | tie | 3 |
| 48 | stock-revaluation (async) | 100000 | 314.1 ms | 364.6 ms | **native** | 80.9 MB | 80.6 MB | tie | 3 |
| 49 | concurrent-profile-fetch (async) | 100000 | 333.0 ms | 335.7 ms | **tie** | 79.8 MB | 80.2 MB | tie | 5 |
| 50 | cohort-retention | 1000000 | 793.0 ms | 802.7 ms | **tie** | 238.6 MB | 238.7 MB | tie | 5 |
| 51 | daily-ledger-close (async) | 20000 | 1206.0 ms | 1218.8 ms | **tie** | 53.1 MB | 54.8 MB | tie | 5 |
| 52 | settlement-pipeline (async) | 100000 | 52.4 ms | 33.9 ms | **fxdart** | 56.2 MB | 58.7 MB | tie | 3 |
| 53 | price-drop-detection | 1000000 | 1208.2 ms | 676.8 ms | **fxdart** | 393.7 MB | 445.4 MB | native | 3 |
