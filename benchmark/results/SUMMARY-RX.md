# RxDartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-04
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | even-totals | 100 | 11 µs | 1.1 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 2 | running-balance-feed | 100 | 8.5 µs | 779 ns | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 3 | first-over-budget-rx | 100 | 12 µs | 524 ns | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 4 | skip-warmup-readings | 100 | 30 µs | 18 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 5 | unique-visitors | 100 | 11 µs | 4.4 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 6 | clean-nullable-readings | 100 | 21 µs | 11 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 7 | last-three-errors | 100 | 9.7 µs | 2.7 µs | **tie** | 16.4 MB | 16.4 MB | tie | 3 |
| 8 | numbered-checklist | 100 | 18 µs | 11 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 9 | expand-order-lines | 100 | 371 µs | 27 µs | **tie** | 15.8 MB | 16.5 MB | tie | 3 |
| 10 | empty-report-default | 100 | 6.6 µs | 2.4 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 11 | upload-batches | 100 | 32 µs | 10 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 12 | sliding-average-rx | 100 | 126 µs | 71 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 13 | tick-deltas | 100 | 80 µs | 44 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 14 | status-transitions | 100 | 15 µs | 5.5 µs | **tie** | 16.5 MB | 16.3 MB | tie | 3 |
| 15 | spend-by-category-rx | 100 | 25 µs | 6.5 µs | **tie** | 16.7 MB | 16.5 MB | tie | 3 |
| 16 | align-forecast-actual | 100 | 95 µs | 48 µs | **tie** | 17.0 MB | 16.4 MB | tie | 3 |
| 17 | feeds-in-order | 100 | 20 µs | 9.9 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 18 | bracket-the-session | 100 | 14 µs | 3.2 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 19 | dedupe-paged-feed | 100 | 25 µs | 13 µs | **tie** | 16.7 MB | 16.5 MB | tie | 3 |
| 20 | latency-extremes (async) | 100 | 765 µs | 637 µs | **tie** | 17.0 MB | 16.6 MB | tie | 3 |
| 21 | stock-after-moves | 100 | 386 µs | 13 µs | **tie** | 14.9 MB | 16.5 MB | rxdart | 3 |
| 22 | audit-with-outcomes | 100 | 421 µs | 98 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 23 | stop-at-shutdown | 100 | 19 µs | 8.7 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 24 | weekly-windows-report | 98 | 79 µs | 6.7 µs | **tie** | 16.8 MB | 16.6 MB | tie | 3 |
| 25 | price-or-fallback (async) | 100 | 503 µs | 474 µs | **tie** | 17.2 MB | 17.2 MB | tie | 3 |
| 26 | resume-with-cache (async) | 100 | 27 µs | 28 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 27 | retry-the-fetch (async) | 100 | 555 µs | 575 µs | **tie** | 17.0 MB | 16.4 MB | tie | 3 |
| 28 | backoff-retry (async) | 100 | 839 µs | 550 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 29 | per-row-retry (async) | 100 | 718 µs | 710 µs | **tie** | 16.9 MB | 17.1 MB | tie | 3 |
| 30 | bound-the-stall (async) | 100 | 174 µs | 142 µs | **tie** | 16.7 MB | 16.6 MB | tie | 3 |
| 31 | cursor-lifetime (async) | 100 | 348 µs | 460 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 32 | successes-and-failures (async) | 100 | 892 µs | 423 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 33 | all-validation-errors | 100 | 127 µs | 28 µs | **tie** | 15.3 MB | 16.5 MB | rxdart | 3 |
| 34 | stop-after-three-failures (async) | 100 | 737 µs | 485 µs | **tie** | 16.6 MB | 16.9 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 100 | 823 µs | 376 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 36 | completion-order-pool (async) | 100 | 457 µs | 388 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 37 | dependent-calls-in-sequence (async) | 100 | 431 µs | 359 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 38 | crawl-the-pages (async) | 100 | 27 µs | 22 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 48 | tee-the-pipeline | 100 | 18 µs | 4.1 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 49 | stream-into-pipeline (async) | 100 | 8.8 µs | 12 µs | **tie** | 16.4 MB | 16.6 MB | tie | 3 |
| 50 | pipeline-into-stream (async) | 100 | 460 µs | 423 µs | **tie** | 16.8 MB | 17.0 MB | tie | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | even-totals | 1000000 | 85.9 ms | 13.8 ms | **fxdart** | 24.3 MB | 21.5 MB | fxdart | 3 |
| 2 | running-balance-feed | 1000000 | 71.6 ms | 7.24 ms | **fxdart** | 55.9 MB | 59.9 MB | rxdart | 3 |
| 3 | first-over-budget-rx | 1000000 | 79.8 ms | 2.75 ms | **fxdart** | 123.0 MB | 111.5 MB | fxdart | 3 |
| 4 | skip-warmup-readings | 1000000 | 289.8 ms | 194.5 ms | **fxdart** | 138.1 MB | 144.3 MB | tie | 3 |
| 5 | unique-visitors | 1000000 | 346.8 ms | 88.6 ms | **fxdart** | 208.4 MB | 200.6 MB | tie | 3 |
| 6 | clean-nullable-readings | 1000000 | 214.1 ms | 128.2 ms | **fxdart** | 123.1 MB | 119.6 MB | tie | 3 |
| 7 | last-three-errors | 1000000 | 66.6 ms | 23.8 ms | **fxdart** | 108.4 MB | 106.9 MB | tie | 3 |
| 8 | numbered-checklist | 1000000 | 209.4 ms | 165.6 ms | **fxdart** | 198.8 MB | 198.5 MB | tie | 3 |
| 9 | expand-order-lines | 1000000 | 3695.5 ms | 408.3 ms | **fxdart** | 482.7 MB | 498.0 MB | tie | 3 |
| 10 | empty-report-default | 1000000 | 52.8 ms | 19.4 ms | **fxdart** | 123.1 MB | 121.5 MB | tie | 3 |
| 11 | upload-batches | 1000000 | 294.1 ms | 117.9 ms | **fxdart** | 128.5 MB | 132.3 MB | tie | 3 |
| 12 | sliding-average-rx | 1000000 | 1091.3 ms | 703.2 ms | **fxdart** | 154.0 MB | 151.4 MB | tie | 3 |
| 13 | tick-deltas | 1000000 | 794.0 ms | 458.9 ms | **fxdart** | 159.9 MB | 163.6 MB | tie | 3 |
| 14 | status-transitions | 1000000 | 126.9 ms | 48.2 ms | **fxdart** | 84.2 MB | 88.7 MB | rxdart | 3 |
| 15 | spend-by-category-rx | 1000000 | 107.1 ms | 57.6 ms | **fxdart** | 93.2 MB | 113.5 MB | rxdart | 3 |
| 16 | align-forecast-actual | 1000000 | 805.7 ms | 480.5 ms | **fxdart** | 206.7 MB | 215.4 MB | tie | 3 |
| 17 | feeds-in-order | 1000000 | 220.6 ms | 135.2 ms | **fxdart** | 268.5 MB | 276.1 MB | tie | 3 |
| 18 | bracket-the-session | 1000000 | 97.9 ms | 31.1 ms | **fxdart** | 125.0 MB | 139.9 MB | rxdart | 3 |
| 19 | dedupe-paged-feed | 1000000 | 303.4 ms | 215.0 ms | **fxdart** | 304.5 MB | 233.6 MB | fxdart | 3 |
| 20 | latency-extremes (async) | 10000 | 62.6 ms | 62.9 ms | **tie** | 24.1 MB | 24.2 MB | tie | 3 |
| 21 | stock-after-moves | 1000000 | 3349.4 ms | 176.7 ms | **fxdart** | 126.6 MB | 121.7 MB | tie | 3 |
| 22 | audit-with-outcomes | 1000000 | 3983.7 ms | 1033.8 ms | **fxdart** | 185.0 MB | 190.7 MB | tie | 3 |
| 23 | stop-at-shutdown | 1000000 | 187.2 ms | 117.3 ms | **fxdart** | 187.4 MB | 196.6 MB | tie | 3 |
| 24 | weekly-windows-report | 999999 | 661.9 ms | 69.7 ms | **fxdart** | 58.0 MB | 83.6 MB | rxdart | 3 |
| 25 | price-or-fallback (async) | 10000 | 42.4 ms | 39.8 ms | **fxdart** | 49.1 MB | 52.0 MB | rxdart | 3 |
| 26 | resume-with-cache (async) | 10000 | 1.83 ms | 2.08 ms | **tie** | 23.1 MB | 24.2 MB | tie | 3 |
| 27 | retry-the-fetch (async) | 10000 | 50.8 ms | 45.5 ms | **fxdart** | 24.0 MB | 24.0 MB | tie | 3 |
| 28 | backoff-retry (async) | 10000 | 60.2 ms | 45.6 ms | **fxdart** | 29.1 MB | 26.7 MB | fxdart | 3 |
| 29 | per-row-retry (async) | 10000 | 70.6 ms | 65.9 ms | **fxdart** | 60.9 MB | 40.7 MB | fxdart | 3 |
| 30 | bound-the-stall (async) | 10000 | 14.4 ms | 13.1 ms | **fxdart** | 27.3 MB | 27.3 MB | tie | 3 |
| 31 | cursor-lifetime (async) | 10000 | 32.6 ms | 32.8 ms | **tie** | 25.4 MB | 25.4 MB | tie | 5 |
| 32 | successes-and-failures (async) | 10000 | 67.3 ms | 36.8 ms | **fxdart** | 25.2 MB | 31.1 MB | rxdart | 3 |
| 33 | all-validation-errors | 1000000 | 1112.1 ms | 323.5 ms | **fxdart** | 345.5 MB | 370.1 MB | rxdart | 3 |
| 34 | stop-after-three-failures (async) | 10000 | 68.6 ms | 38.1 ms | **fxdart** | 22.2 MB | 22.4 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 10000 | 63.6 ms | 34.5 ms | **fxdart** | 51.6 MB | 22.1 MB | fxdart | 3 |
| 36 | completion-order-pool (async) | 10000 | 35.0 ms | 33.7 ms | **tie** | 30.2 MB | 22.2 MB | fxdart | 5 |
| 37 | dependent-calls-in-sequence (async) | 10000 | 37.1 ms | 34.8 ms | **fxdart** | 28.4 MB | 28.9 MB | tie | 3 |
| 38 | crawl-the-pages (async) | 10000 | 1.69 ms | 1.64 ms | **tie** | 22.5 MB | 23.1 MB | tie | 3 |
| 48 | tee-the-pipeline | 1000000 | 141.7 ms | 35.6 ms | **fxdart** | 24.2 MB | 54.9 MB | rxdart | 3 |
| 49 | stream-into-pipeline (async) | 10000 | 783 µs | 1.03 ms | **tie** | 22.8 MB | 23.0 MB | tie | 3 |
| 50 | pipeline-into-stream (async) | 10000 | 37.8 ms | 39.4 ms | **tie** | 50.5 MB | 30.5 MB | fxdart | 5 |
