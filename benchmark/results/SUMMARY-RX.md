# RxDartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-17
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | first-over-budget-rx | 100 | 12 µs | 291 ns | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 2 | running-balance-feed | 100 | 9.4 µs | 794 ns | **tie** | 17.0 MB | 16.4 MB | tie | 3 |
| 3 | expand-order-lines | 100 | 380 µs | 29 µs | **tie** | 15.8 MB | 16.5 MB | tie | 3 |
| 4 | even-totals | 100 | 11 µs | 922 ns | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 5 | unique-visitors | 100 | 12 µs | 4.6 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 6 | last-three-errors | 100 | 8.6 µs | 1.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 7 | empty-report-default | 100 | 6.9 µs | 1.3 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 8 | clean-nullable-readings | 100 | 24 µs | 11 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 9 | skip-warmup-readings | 100 | 29 µs | 16 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 10 | numbered-checklist | 100 | 21 µs | 11 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 11 | stock-after-moves | 100 | 392 µs | 13 µs | **tie** | 14.9 MB | 16.4 MB | rxdart | 3 |
| 12 | weekly-windows-report | 98 | 78 µs | 3.9 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 13 | audit-with-outcomes | 100 | 430 µs | 98 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 14 | bracket-the-session | 100 | 13 µs | 3.1 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 15 | status-transitions | 100 | 18 µs | 3.8 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 16 | upload-batches | 100 | 32 µs | 9.5 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 17 | spend-by-category-rx | 100 | 26 µs | 5.3 µs | **tie** | 17.2 MB | 16.4 MB | tie | 3 |
| 18 | feeds-in-order | 100 | 23 µs | 9.2 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 19 | tick-deltas | 100 | 92 µs | 44 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 20 | align-forecast-actual | 100 | 88 µs | 45 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 21 | sliding-average-rx | 100 | 108 µs | 65 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 22 | stop-at-shutdown | 100 | 23 µs | 8.6 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 23 | dedupe-paged-feed | 100 | 25 µs | 13 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 24 | latency-extremes (async) | 100 | 686 µs | 650 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 25 | all-validation-errors | 100 | 109 µs | 27 µs | **tie** | 15.6 MB | 16.4 MB | rxdart | 3 |
| 26 | successes-and-failures (async) | 100 | 769 µs | 498 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 27 | stop-after-three-failures (async) | 100 | 785 µs | 451 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 28 | backoff-retry (async) | 100 | 676 µs | 526 µs | **tie** | 17.1 MB | 16.4 MB | tie | 3 |
| 29 | retry-the-fetch (async) | 100 | 626 µs | 491 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 30 | bound-the-stall (async) | 100 | 176 µs | 149 µs | **tie** | 16.7 MB | 17.0 MB | tie | 3 |
| 31 | per-row-retry (async) | 100 | 859 µs | 761 µs | **tie** | 17.1 MB | 16.6 MB | tie | 3 |
| 32 | cursor-lifetime (async) | 100 | 393 µs | 364 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 33 | price-or-fallback (async) | 100 | 507 µs | 499 µs | **tie** | 17.1 MB | 17.2 MB | tie | 3 |
| 34 | resume-with-cache (async) | 100 | 25 µs | 26 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 100 | 806 µs | 384 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 36 | completion-order-pool (async) | 100 | 402 µs | 365 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 37 | stream-into-pipeline (async) | 100 | 9.9 µs | 9.9 µs | **tie** | 16.4 MB | 17.0 MB | tie | 3 |
| 47 | pipeline-into-stream (async) | 100 | 497 µs | 445 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 48 | crawl-the-pages (async) | 100 | 27 µs | 21 µs | **tie** | 17.1 MB | 16.6 MB | tie | 3 |
| 49 | dependent-calls-in-sequence (async) | 100 | 446 µs | 403 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 50 | tee-the-pipeline | 100 | 18 µs | 2.1 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | first-over-budget-rx | 1000000 | 80.9 ms | 886 µs | **fxdart** | 122.6 MB | 112.1 MB | fxdart | 3 |
| 2 | running-balance-feed | 1000000 | 73.8 ms | 7.83 ms | **fxdart** | 55.9 MB | 59.8 MB | rxdart | 3 |
| 3 | expand-order-lines | 1000000 | 3725.1 ms | 410.3 ms | **fxdart** | 489.5 MB | 482.1 MB | tie | 3 |
| 4 | even-totals | 1000000 | 86.4 ms | 12.9 ms | **fxdart** | 24.7 MB | 21.5 MB | fxdart | 3 |
| 5 | unique-visitors | 1000000 | 374.8 ms | 101.7 ms | **fxdart** | 209.5 MB | 200.2 MB | tie | 3 |
| 6 | last-three-errors | 1000000 | 66.0 ms | 13.9 ms | **fxdart** | 113.9 MB | 104.4 MB | fxdart | 3 |
| 7 | empty-report-default | 1000000 | 53.5 ms | 9.53 ms | **fxdart** | 123.9 MB | 121.4 MB | tie | 3 |
| 8 | clean-nullable-readings | 1000000 | 217.9 ms | 129.2 ms | **fxdart** | 122.6 MB | 117.3 MB | tie | 3 |
| 9 | skip-warmup-readings | 1000000 | 292.2 ms | 186.0 ms | **fxdart** | 137.3 MB | 144.4 MB | rxdart | 3 |
| 10 | numbered-checklist | 1000000 | 210.9 ms | 157.9 ms | **fxdart** | 198.9 MB | 199.5 MB | tie | 3 |
| 11 | stock-after-moves | 1000000 | 3371.9 ms | 165.6 ms | **fxdart** | 127.0 MB | 121.9 MB | tie | 3 |
| 12 | weekly-windows-report | 999999 | 667.8 ms | 44.5 ms | **fxdart** | 57.6 MB | 80.8 MB | rxdart | 3 |
| 13 | audit-with-outcomes | 1000000 | 3995.3 ms | 997.1 ms | **fxdart** | 184.4 MB | 189.7 MB | tie | 3 |
| 14 | bracket-the-session | 1000000 | 98.7 ms | 31.0 ms | **fxdart** | 126.8 MB | 141.0 MB | rxdart | 3 |
| 15 | status-transitions | 1000000 | 127.6 ms | 32.7 ms | **fxdart** | 84.1 MB | 88.7 MB | rxdart | 3 |
| 16 | upload-batches | 1000000 | 296.0 ms | 101.3 ms | **fxdart** | 128.4 MB | 132.1 MB | tie | 3 |
| 17 | spend-by-category-rx | 1000000 | 107.7 ms | 44.4 ms | **fxdart** | 92.3 MB | 112.6 MB | rxdart | 3 |
| 18 | feeds-in-order | 1000000 | 227.1 ms | 128.9 ms | **fxdart** | 268.5 MB | 283.7 MB | rxdart | 3 |
| 19 | tick-deltas | 1000000 | 787.2 ms | 459.9 ms | **fxdart** | 161.3 MB | 163.3 MB | tie | 3 |
| 20 | align-forecast-actual | 1000000 | 821.9 ms | 478.5 ms | **fxdart** | 206.2 MB | 215.2 MB | tie | 3 |
| 21 | sliding-average-rx | 1000000 | 1099.4 ms | 678.9 ms | **fxdart** | 153.7 MB | 151.3 MB | tie | 3 |
| 22 | stop-at-shutdown | 1000000 | 188.7 ms | 111.6 ms | **fxdart** | 188.1 MB | 201.3 MB | rxdart | 3 |
| 23 | dedupe-paged-feed | 1000000 | 293.9 ms | 216.4 ms | **fxdart** | 297.6 MB | 239.9 MB | fxdart | 3 |
| 24 | latency-extremes (async) | 10000 | 69.5 ms | 64.1 ms | **fxdart** | 24.1 MB | 24.2 MB | tie | 3 |
| 25 | all-validation-errors | 1000000 | 1119.4 ms | 313.1 ms | **fxdart** | 345.3 MB | 368.4 MB | rxdart | 3 |
| 26 | successes-and-failures (async) | 10000 | 71.5 ms | 39.4 ms | **fxdart** | 25.1 MB | 30.3 MB | rxdart | 3 |
| 27 | stop-after-three-failures (async) | 10000 | 70.4 ms | 39.1 ms | **fxdart** | 22.3 MB | 22.2 MB | tie | 3 |
| 28 | backoff-retry (async) | 10000 | 61.6 ms | 48.3 ms | **fxdart** | 29.3 MB | 26.7 MB | fxdart | 3 |
| 29 | retry-the-fetch (async) | 10000 | 53.9 ms | 47.6 ms | **fxdart** | 23.9 MB | 24.0 MB | tie | 3 |
| 30 | bound-the-stall (async) | 10000 | 14.5 ms | 13.3 ms | **fxdart** | 27.2 MB | 27.5 MB | tie | 3 |
| 31 | per-row-retry (async) | 10000 | 72.8 ms | 68.9 ms | **fxdart** | 61.3 MB | 40.5 MB | fxdart | 5 |
| 32 | cursor-lifetime (async) | 10000 | 31.5 ms | 33.6 ms | **rxdart** | 25.0 MB | 25.5 MB | tie | 3 |
| 33 | price-or-fallback (async) | 10000 | 43.3 ms | 43.6 ms | **tie** | 49.4 MB | 52.2 MB | rxdart | 4 |
| 34 | resume-with-cache (async) | 10000 | 1.81 ms | 2.03 ms | **tie** | 23.3 MB | 23.6 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 10000 | 65.6 ms | 34.3 ms | **fxdart** | 51.4 MB | 22.3 MB | fxdart | 3 |
| 36 | completion-order-pool (async) | 10000 | 35.3 ms | 34.2 ms | **tie** | 29.9 MB | 22.8 MB | fxdart | 5 |
| 37 | stream-into-pipeline (async) | 10000 | 796 µs | 801 µs | **tie** | 22.8 MB | 23.6 MB | tie | 3 |
| 47 | pipeline-into-stream (async) | 10000 | 38.9 ms | 41.6 ms | **rxdart** | 50.6 MB | 30.5 MB | fxdart | 3 |
| 48 | crawl-the-pages (async) | 10000 | 1.71 ms | 1.68 ms | **tie** | 22.6 MB | 22.6 MB | tie | 3 |
| 49 | dependent-calls-in-sequence (async) | 10000 | 38.7 ms | 36.7 ms | **fxdart** | 28.4 MB | 29.0 MB | tie | 3 |
| 50 | tee-the-pipeline | 1000000 | 143.7 ms | 17.7 ms | **fxdart** | 24.3 MB | 21.6 MB | fxdart | 3 |
