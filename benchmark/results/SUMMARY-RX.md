# RxDartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-03
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | even-totals | 100 | 10 µs | 1.1 µs | **tie** | 17.1 MB | 16.5 MB | tie | 3 |
| 2 | running-balance-feed | 100 | 8.2 µs | 814 ns | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 3 | first-over-budget-rx | 100 | 11 µs | 515 ns | **tie** | 17.1 MB | 16.5 MB | tie | 3 |
| 4 | skip-warmup-readings | 100 | 28 µs | 17 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 5 | unique-visitors | 100 | 11 µs | 4.7 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 6 | clean-nullable-readings | 100 | 21 µs | 12 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 7 | last-three-errors | 100 | 8.5 µs | 2.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 8 | numbered-checklist | 100 | 20 µs | 13 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 9 | expand-order-lines | 100 | 364 µs | 27 µs | **tie** | 15.8 MB | 16.5 MB | tie | 3 |
| 10 | empty-report-default | 100 | 8.3 µs | 2.9 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 11 | upload-batches | 100 | 44 µs | 17 µs | **tie** | 17.1 MB | 17.0 MB | tie | 3 |
| 12 | sliding-average-rx | 100 | 125 µs | 70 µs | **tie** | 16.7 MB | 16.5 MB | tie | 3 |
| 13 | tick-deltas | 100 | 84 µs | 45 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 14 | status-transitions | 100 | 15 µs | 6.1 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 15 | spend-by-category-rx | 100 | 22 µs | 6.3 µs | **tie** | 17.2 MB | 16.4 MB | tie | 3 |
| 16 | align-forecast-actual | 100 | 93 µs | 48 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 17 | feeds-in-order | 100 | 22 µs | 11 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 18 | bracket-the-session | 100 | 17 µs | 4.4 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 19 | dedupe-paged-feed | 100 | 43 µs | 29 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 20 | latency-extremes (async) | 100 | 1.04 ms | 1.17 ms | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 21 | stock-after-moves | 100 | 357 µs | 14 µs | **tie** | 15.0 MB | 16.5 MB | rxdart | 3 |
| 22 | audit-with-outcomes | 100 | 486 µs | 103 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 23 | stop-at-shutdown | 100 | 18 µs | 9.3 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 24 | weekly-windows-report | 98 | 70 µs | 7.4 µs | **tie** | 17.4 MB | 16.6 MB | tie | 3 |
| 25 | price-or-fallback (async) | 100 | 495 µs | 542 µs | **tie** | 17.2 MB | 17.2 MB | tie | 3 |
| 26 | resume-with-cache (async) | 100 | 23 µs | 27 µs | **tie** | 16.7 MB | 16.9 MB | tie | 3 |
| 27 | retry-the-fetch (async) | 100 | 676 µs | 540 µs | **tie** | 17.0 MB | 16.4 MB | tie | 3 |
| 28 | backoff-retry (async) | 100 | 740 µs | 570 µs | **tie** | 17.0 MB | 16.4 MB | tie | 3 |
| 29 | per-row-retry (async) | 100 | 919 µs | 862 µs | **tie** | 17.2 MB | 16.7 MB | tie | 3 |
| 30 | bound-the-stall (async) | 100 | 197 µs | 201 µs | **tie** | 17.1 MB | 16.9 MB | tie | 3 |
| 31 | cursor-lifetime (async) | 100 | 507 µs | 598 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 32 | successes-and-failures (async) | 100 | 1.24 ms | 873 µs | **tie** | 16.8 MB | 16.5 MB | tie | 3 |
| 33 | all-validation-errors | 100 | 111 µs | 28 µs | **tie** | 15.5 MB | 16.5 MB | rxdart | 3 |
| 34 | stop-after-three-failures (async) | 100 | 825 µs | 581 µs | **tie** | 17.0 MB | 17.1 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 100 | 788 µs | 422 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 36 | completion-order-pool (async) | 100 | 390 µs | 388 µs | **tie** | 16.4 MB | 16.9 MB | tie | 5 |
| 37 | dependent-calls-in-sequence (async) | 100 | 423 µs | 548 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 38 | crawl-the-pages (async) | 100 | 23 µs | 22 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 48 | tee-the-pipeline | 100 | 20 µs | 4.5 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 49 | stream-into-pipeline (async) | 100 | 8.8 µs | 12 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 50 | pipeline-into-stream (async) | 100 | 375 µs | 428 µs | **tie** | 17.0 MB | 16.5 MB | tie | 5 |

## Headline N (1M sync / case-specific async)

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | even-totals | 1000000 | 87.3 ms | 14.0 ms | **fxdart** | 24.7 MB | 21.6 MB | fxdart | 3 |
| 2 | running-balance-feed | 1000000 | 72.4 ms | 7.97 ms | **fxdart** | 56.4 MB | 59.9 MB | rxdart | 3 |
| 3 | first-over-budget-rx | 1000000 | 81.7 ms | 3.01 ms | **fxdart** | 121.4 MB | 110.9 MB | fxdart | 3 |
| 4 | skip-warmup-readings | 1000000 | 300.7 ms | 209.0 ms | **fxdart** | 138.4 MB | 144.9 MB | tie | 3 |
| 5 | unique-visitors | 1000000 | 448.1 ms | 105.0 ms | **fxdart** | 208.3 MB | 200.7 MB | tie | 3 |
| 6 | clean-nullable-readings | 1000000 | 224.1 ms | 139.2 ms | **fxdart** | 122.5 MB | 122.2 MB | tie | 3 |
| 7 | last-three-errors | 1000000 | 66.6 ms | 24.2 ms | **fxdart** | 112.4 MB | 104.5 MB | fxdart | 3 |
| 8 | numbered-checklist | 1000000 | 219.9 ms | 177.2 ms | **fxdart** | 199.3 MB | 199.5 MB | tie | 3 |
| 9 | expand-order-lines | 1000000 | 3834.9 ms | 492.5 ms | **fxdart** | 483.8 MB | 492.5 MB | tie | 3 |
| 10 | empty-report-default | 1000000 | 59.8 ms | 20.8 ms | **fxdart** | 123.5 MB | 121.2 MB | tie | 3 |
| 11 | upload-batches | 1000000 | 379.0 ms | 137.8 ms | **fxdart** | 127.3 MB | 132.0 MB | tie | 3 |
| 12 | sliding-average-rx | 1000000 | 1290.5 ms | 736.2 ms | **fxdart** | 154.1 MB | 151.4 MB | tie | 3 |
| 13 | tick-deltas | 1000000 | 872.6 ms | 513.7 ms | **fxdart** | 159.3 MB | 162.6 MB | tie | 3 |
| 14 | status-transitions | 1000000 | 131.6 ms | 50.0 ms | **fxdart** | 84.1 MB | 88.8 MB | rxdart | 3 |
| 15 | spend-by-category-rx | 1000000 | 114.1 ms | 73.3 ms | **fxdart** | 92.9 MB | 114.9 MB | rxdart | 3 |
| 16 | align-forecast-actual | 1000000 | 1221.9 ms | 535.9 ms | **fxdart** | 206.5 MB | 215.2 MB | tie | 3 |
| 17 | feeds-in-order | 1000000 | 278.1 ms | 196.0 ms | **fxdart** | 270.1 MB | 275.6 MB | tie | 3 |
| 18 | bracket-the-session | 1000000 | 181.1 ms | 80.9 ms | **fxdart** | 129.3 MB | 138.9 MB | rxdart | 3 |
| 19 | dedupe-paged-feed | 1000000 | 576.0 ms | 399.3 ms | **fxdart** | 293.7 MB | 238.7 MB | fxdart | 3 |
| 20 | latency-extremes (async) | 10000 | 82.7 ms | 92.2 ms | **rxdart** | 24.1 MB | 24.3 MB | tie | 3 |
| 21 | stock-after-moves | 1000000 | 3712.8 ms | 194.6 ms | **fxdart** | 124.8 MB | 126.2 MB | tie | 3 |
| 22 | audit-with-outcomes | 1000000 | 4247.1 ms | 1123.3 ms | **fxdart** | 182.7 MB | 186.1 MB | tie | 3 |
| 23 | stop-at-shutdown | 1000000 | 202.0 ms | 125.4 ms | **fxdart** | 187.0 MB | 200.9 MB | rxdart | 3 |
| 24 | weekly-windows-report | 999999 | 702.6 ms | 76.2 ms | **fxdart** | 57.6 MB | 83.2 MB | rxdart | 3 |
| 25 | price-or-fallback (async) | 10000 | 48.4 ms | 48.6 ms | **tie** | 49.1 MB | 52.4 MB | rxdart | 3 |
| 26 | resume-with-cache (async) | 10000 | 1.85 ms | 2.15 ms | **tie** | 23.2 MB | 24.1 MB | tie | 3 |
| 27 | retry-the-fetch (async) | 10000 | 60.1 ms | 53.1 ms | **fxdart** | 24.1 MB | 24.0 MB | tie | 3 |
| 28 | backoff-retry (async) | 10000 | 64.0 ms | 53.3 ms | **fxdart** | 29.3 MB | 26.9 MB | fxdart | 3 |
| 29 | per-row-retry (async) | 10000 | 104.2 ms | 96.9 ms | **fxdart** | 59.3 MB | 40.5 MB | fxdart | 3 |
| 30 | bound-the-stall (async) | 10000 | 18.8 ms | 19.0 ms | **tie** | 28.0 MB | 28.1 MB | tie | 3 |
| 31 | cursor-lifetime (async) | 10000 | 45.4 ms | 45.8 ms | **tie** | 25.5 MB | 25.5 MB | tie | 5 |
| 32 | successes-and-failures (async) | 10000 | 80.6 ms | 58.2 ms | **fxdart** | 25.2 MB | 32.6 MB | rxdart | 3 |
| 33 | all-validation-errors | 1000000 | 1211.2 ms | 359.1 ms | **fxdart** | 342.8 MB | 368.0 MB | rxdart | 3 |
| 34 | stop-after-three-failures (async) | 10000 | 76.6 ms | 52.9 ms | **fxdart** | 22.1 MB | 22.3 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 10000 | 75.8 ms | 40.3 ms | **fxdart** | 51.7 MB | 22.2 MB | fxdart | 3 |
| 36 | completion-order-pool (async) | 10000 | 34.7 ms | 34.0 ms | **tie** | 29.6 MB | 22.2 MB | fxdart | 5 |
| 37 | dependent-calls-in-sequence (async) | 10000 | 42.0 ms | 53.4 ms | **rxdart** | 29.0 MB | 29.0 MB | tie | 3 |
| 38 | crawl-the-pages (async) | 10000 | 1.89 ms | 1.81 ms | **tie** | 23.1 MB | 23.1 MB | tie | 3 |
| 48 | tee-the-pipeline | 1000000 | 151.1 ms | 37.2 ms | **fxdart** | 24.8 MB | 54.9 MB | rxdart | 3 |
| 49 | stream-into-pipeline (async) | 10000 | 809 µs | 1.08 ms | **tie** | 22.8 MB | 22.9 MB | tie | 3 |
| 50 | pipeline-into-stream (async) | 10000 | 37.9 ms | 39.9 ms | **rxdart** | 50.4 MB | 30.5 MB | fxdart | 5 |
