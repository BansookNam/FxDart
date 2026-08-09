# RxDartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-09
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | first-over-budget-rx | 100 | 11 µs | 310 ns | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 2 | running-balance-feed | 100 | 9.4 µs | 802 ns | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 3 | expand-order-lines | 100 | 423 µs | 28 µs | **tie** | 15.6 MB | 16.6 MB | rxdart | 3 |
| 4 | even-totals | 100 | 12 µs | 1.0 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 5 | unique-visitors | 100 | 11 µs | 4.4 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 6 | last-three-errors | 100 | 7.8 µs | 1.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 7 | empty-report-default | 100 | 6.7 µs | 1.3 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 8 | clean-nullable-readings | 100 | 22 µs | 11 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 9 | skip-warmup-readings | 100 | 29 µs | 19 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 10 | numbered-checklist | 100 | 21 µs | 11 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 11 | stock-after-moves | 100 | 447 µs | 13 µs | **tie** | 15.0 MB | 17.0 MB | rxdart | 3 |
| 12 | weekly-windows-report | 98 | 70 µs | 4.1 µs | **tie** | 17.5 MB | 16.5 MB | fxdart | 3 |
| 13 | audit-with-outcomes | 100 | 473 µs | 96 µs | **tie** | 16.5 MB | 15.9 MB | tie | 3 |
| 14 | bracket-the-session | 100 | 13 µs | 3.0 µs | **tie** | 16.7 MB | 16.5 MB | tie | 3 |
| 15 | status-transitions | 100 | 18 µs | 4.1 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 16 | upload-batches | 100 | 36 µs | 9.5 µs | **tie** | 16.6 MB | 17.0 MB | tie | 3 |
| 17 | spend-by-category-rx | 100 | 20 µs | 4.7 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 18 | feeds-in-order | 100 | 21 µs | 9.7 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 19 | tick-deltas | 100 | 78 µs | 42 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 20 | align-forecast-actual | 100 | 84 µs | 43 µs | **tie** | 17.2 MB | 16.6 MB | tie | 3 |
| 21 | sliding-average-rx | 100 | 129 µs | 62 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 22 | stop-at-shutdown | 100 | 22 µs | 8.0 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 23 | dedupe-paged-feed | 100 | 26 µs | 13 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 24 | latency-extremes (async) | 100 | 755 µs | 820 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 25 | all-validation-errors | 100 | 128 µs | 27 µs | **tie** | 15.4 MB | 16.4 MB | rxdart | 3 |
| 26 | successes-and-failures (async) | 100 | 753 µs | 436 µs | **tie** | 16.6 MB | 16.7 MB | tie | 3 |
| 27 | stop-after-three-failures (async) | 100 | 780 µs | 408 µs | **tie** | 16.8 MB | 17.1 MB | tie | 3 |
| 28 | backoff-retry (async) | 100 | 725 µs | 522 µs | **tie** | 17.1 MB | 16.5 MB | tie | 3 |
| 29 | retry-the-fetch (async) | 100 | 607 µs | 508 µs | **tie** | 17.0 MB | 16.4 MB | tie | 3 |
| 30 | bound-the-stall (async) | 100 | 160 µs | 146 µs | **tie** | 16.7 MB | 16.7 MB | tie | 3 |
| 31 | per-row-retry (async) | 100 | 771 µs | 781 µs | **tie** | 16.6 MB | 16.9 MB | tie | 3 |
| 32 | cursor-lifetime (async) | 100 | 372 µs | 326 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 33 | price-or-fallback (async) | 100 | 501 µs | 494 µs | **tie** | 17.2 MB | 16.7 MB | tie | 3 |
| 34 | resume-with-cache (async) | 100 | 25 µs | 26 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 100 | 759 µs | 390 µs | **tie** | 16.6 MB | 17.1 MB | tie | 3 |
| 36 | completion-order-pool (async) | 100 | 387 µs | 356 µs | **tie** | 16.6 MB | 17.0 MB | tie | 3 |
| 37 | stream-into-pipeline (async) | 100 | 9.1 µs | 9.9 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 47 | pipeline-into-stream (async) | 100 | 451 µs | 407 µs | **tie** | 17.1 MB | 17.1 MB | tie | 3 |
| 48 | crawl-the-pages (async) | 100 | 26 µs | 24 µs | **tie** | 17.1 MB | 16.6 MB | tie | 3 |
| 49 | dependent-calls-in-sequence (async) | 100 | 396 µs | 373 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 50 | tee-the-pipeline | 100 | 22 µs | 2.4 µs | **tie** | 17.1 MB | 16.5 MB | tie | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | first-over-budget-rx | 1000000 | 80.2 ms | 944 µs | **fxdart** | 122.2 MB | 112.0 MB | fxdart | 3 |
| 2 | running-balance-feed | 1000000 | 71.7 ms | 7.13 ms | **fxdart** | 56.0 MB | 59.9 MB | rxdart | 3 |
| 3 | expand-order-lines | 1000000 | 3755.3 ms | 401.8 ms | **fxdart** | 487.1 MB | 489.3 MB | tie | 3 |
| 4 | even-totals | 1000000 | 86.2 ms | 12.8 ms | **fxdart** | 24.3 MB | 21.6 MB | fxdart | 3 |
| 5 | unique-visitors | 1000000 | 369.6 ms | 100.8 ms | **fxdart** | 209.1 MB | 200.7 MB | tie | 3 |
| 6 | last-three-errors | 1000000 | 68.7 ms | 14.9 ms | **fxdart** | 111.3 MB | 107.9 MB | tie | 3 |
| 7 | empty-report-default | 1000000 | 57.7 ms | 9.62 ms | **fxdart** | 123.6 MB | 121.3 MB | tie | 3 |
| 8 | clean-nullable-readings | 1000000 | 218.8 ms | 132.3 ms | **fxdart** | 123.0 MB | 117.3 MB | tie | 3 |
| 9 | skip-warmup-readings | 1000000 | 298.0 ms | 193.2 ms | **fxdart** | 136.1 MB | 143.8 MB | rxdart | 3 |
| 10 | numbered-checklist | 1000000 | 216.6 ms | 163.1 ms | **fxdart** | 196.4 MB | 197.0 MB | tie | 3 |
| 11 | stock-after-moves | 1000000 | 3470.9 ms | 169.7 ms | **fxdart** | 125.2 MB | 126.2 MB | tie | 3 |
| 12 | weekly-windows-report | 999999 | 673.4 ms | 44.6 ms | **fxdart** | 57.2 MB | 80.8 MB | rxdart | 3 |
| 13 | audit-with-outcomes | 1000000 | 4046.0 ms | 999.4 ms | **fxdart** | 182.9 MB | 191.0 MB | tie | 3 |
| 14 | bracket-the-session | 1000000 | 99.2 ms | 30.6 ms | **fxdart** | 128.6 MB | 141.1 MB | rxdart | 3 |
| 15 | status-transitions | 1000000 | 127.2 ms | 34.3 ms | **fxdart** | 84.0 MB | 88.8 MB | rxdart | 3 |
| 16 | upload-batches | 1000000 | 296.3 ms | 102.7 ms | **fxdart** | 124.8 MB | 132.3 MB | rxdart | 3 |
| 17 | spend-by-category-rx | 1000000 | 109.8 ms | 47.6 ms | **fxdart** | 92.4 MB | 117.2 MB | rxdart | 3 |
| 18 | feeds-in-order | 1000000 | 262.0 ms | 149.0 ms | **fxdart** | 270.4 MB | 275.9 MB | tie | 3 |
| 19 | tick-deltas | 1000000 | 820.4 ms | 462.0 ms | **fxdart** | 161.4 MB | 163.6 MB | tie | 3 |
| 20 | align-forecast-actual | 1000000 | 827.9 ms | 486.4 ms | **fxdart** | 206.6 MB | 220.0 MB | rxdart | 3 |
| 21 | sliding-average-rx | 1000000 | 1110.4 ms | 676.9 ms | **fxdart** | 154.1 MB | 151.5 MB | tie | 3 |
| 22 | stop-at-shutdown | 1000000 | 190.6 ms | 110.1 ms | **fxdart** | 187.3 MB | 202.0 MB | rxdart | 3 |
| 23 | dedupe-paged-feed | 1000000 | 304.5 ms | 214.9 ms | **fxdart** | 297.2 MB | 241.0 MB | fxdart | 3 |
| 24 | latency-extremes (async) | 10000 | 65.1 ms | 65.0 ms | **tie** | 24.2 MB | 24.3 MB | tie | 3 |
| 25 | all-validation-errors | 1000000 | 1168.7 ms | 321.8 ms | **fxdart** | 345.2 MB | 370.1 MB | rxdart | 3 |
| 26 | successes-and-failures (async) | 10000 | 67.6 ms | 36.9 ms | **fxdart** | 25.3 MB | 30.6 MB | rxdart | 3 |
| 27 | stop-after-three-failures (async) | 10000 | 72.1 ms | 39.7 ms | **fxdart** | 22.7 MB | 22.8 MB | tie | 3 |
| 28 | backoff-retry (async) | 10000 | 60.1 ms | 46.9 ms | **fxdart** | 29.3 MB | 27.1 MB | fxdart | 3 |
| 29 | retry-the-fetch (async) | 10000 | 54.5 ms | 46.7 ms | **fxdart** | 24.0 MB | 24.0 MB | tie | 3 |
| 30 | bound-the-stall (async) | 10000 | 14.6 ms | 13.4 ms | **fxdart** | 27.4 MB | 27.6 MB | tie | 3 |
| 31 | per-row-retry (async) | 10000 | 71.1 ms | 67.1 ms | **fxdart** | 60.7 MB | 40.2 MB | fxdart | 3 |
| 32 | cursor-lifetime (async) | 10000 | 31.4 ms | 33.7 ms | **rxdart** | 25.4 MB | 25.5 MB | tie | 3 |
| 33 | price-or-fallback (async) | 10000 | 46.6 ms | 42.4 ms | **fxdart** | 49.0 MB | 52.0 MB | rxdart | 3 |
| 34 | resume-with-cache (async) | 10000 | 1.86 ms | 2.10 ms | **tie** | 23.3 MB | 24.2 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 10000 | 65.1 ms | 33.5 ms | **fxdart** | 51.5 MB | 22.5 MB | fxdart | 3 |
| 36 | completion-order-pool (async) | 10000 | 34.6 ms | 34.7 ms | **tie** | 29.8 MB | 22.1 MB | fxdart | 4 |
| 37 | stream-into-pipeline (async) | 10000 | 757 µs | 772 µs | **tie** | 22.9 MB | 23.7 MB | tie | 3 |
| 47 | pipeline-into-stream (async) | 10000 | 38.5 ms | 38.9 ms | **tie** | 50.8 MB | 30.5 MB | fxdart | 3 |
| 48 | crawl-the-pages (async) | 10000 | 1.77 ms | 1.59 ms | **tie** | 22.7 MB | 23.1 MB | tie | 3 |
| 49 | dependent-calls-in-sequence (async) | 10000 | 37.3 ms | 34.7 ms | **fxdart** | 28.4 MB | 28.4 MB | tie | 5 |
| 50 | tee-the-pipeline | 1000000 | 143.4 ms | 17.6 ms | **fxdart** | 24.4 MB | 21.6 MB | fxdart | 3 |
