# RxDartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-16
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | first-over-budget-rx | 100 | 13 µs | 319 ns | **tie** | 16.6 MB | 16.3 MB | tie | 3 |
| 2 | running-balance-feed | 100 | 9.4 µs | 766 ns | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 3 | expand-order-lines | 100 | 429 µs | 26 µs | **tie** | 15.5 MB | 16.5 MB | rxdart | 3 |
| 4 | even-totals | 100 | 11 µs | 976 ns | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 5 | unique-visitors | 100 | 13 µs | 4.6 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 6 | last-three-errors | 100 | 9.2 µs | 1.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 7 | empty-report-default | 100 | 7.9 µs | 1.2 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 8 | clean-nullable-readings | 100 | 21 µs | 11 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 9 | skip-warmup-readings | 100 | 32 µs | 16 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 10 | numbered-checklist | 100 | 20 µs | 11 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 11 | stock-after-moves | 100 | 391 µs | 13 µs | **tie** | 14.8 MB | 16.5 MB | rxdart | 3 |
| 12 | weekly-windows-report | 98 | 82 µs | 4.1 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 13 | audit-with-outcomes | 100 | 463 µs | 98 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 14 | bracket-the-session | 100 | 12 µs | 3.1 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 15 | status-transitions | 100 | 16 µs | 3.6 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 16 | upload-batches | 100 | 36 µs | 9.8 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 17 | spend-by-category-rx | 100 | 23 µs | 5.3 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 18 | feeds-in-order | 100 | 23 µs | 9.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 19 | tick-deltas | 100 | 89 µs | 44 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 20 | align-forecast-actual | 100 | 91 µs | 44 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 21 | sliding-average-rx | 100 | 123 µs | 65 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 22 | stop-at-shutdown | 100 | 21 µs | 8.2 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 23 | dedupe-paged-feed | 100 | 23 µs | 12 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 24 | latency-extremes (async) | 100 | 734 µs | 639 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 25 | all-validation-errors | 100 | 126 µs | 28 µs | **tie** | 15.3 MB | 16.5 MB | rxdart | 3 |
| 26 | successes-and-failures (async) | 100 | 740 µs | 426 µs | **tie** | 16.7 MB | 17.0 MB | tie | 3 |
| 27 | stop-after-three-failures (async) | 100 | 762 µs | 422 µs | **tie** | 16.6 MB | 17.0 MB | tie | 3 |
| 28 | backoff-retry (async) | 100 | 691 µs | 587 µs | **tie** | 17.0 MB | 16.4 MB | tie | 3 |
| 29 | retry-the-fetch (async) | 100 | 637 µs | 461 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 30 | bound-the-stall (async) | 100 | 189 µs | 151 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 31 | per-row-retry (async) | 100 | 847 µs | 686 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 32 | cursor-lifetime (async) | 100 | 350 µs | 418 µs | **tie** | 16.5 MB | 16.7 MB | tie | 3 |
| 33 | price-or-fallback (async) | 100 | 509 µs | 449 µs | **tie** | 17.1 MB | 17.3 MB | tie | 3 |
| 34 | resume-with-cache (async) | 100 | 29 µs | 27 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 100 | 770 µs | 415 µs | **tie** | 16.6 MB | 17.0 MB | tie | 3 |
| 36 | completion-order-pool (async) | 100 | 387 µs | 431 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 37 | stream-into-pipeline (async) | 100 | 9.9 µs | 8.9 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 47 | pipeline-into-stream (async) | 100 | 419 µs | 414 µs | **tie** | 17.0 MB | 16.9 MB | tie | 3 |
| 48 | crawl-the-pages (async) | 100 | 24 µs | 20 µs | **tie** | 16.6 MB | 17.1 MB | tie | 3 |
| 49 | dependent-calls-in-sequence (async) | 100 | 423 µs | 417 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 50 | tee-the-pipeline | 100 | 21 µs | 2.3 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | first-over-budget-rx | 1000000 | 78.2 ms | 862 µs | **fxdart** | 122.8 MB | 111.4 MB | fxdart | 3 |
| 2 | running-balance-feed | 1000000 | 70.0 ms | 7.11 ms | **fxdart** | 55.9 MB | 59.8 MB | rxdart | 3 |
| 3 | expand-order-lines | 1000000 | 3630.7 ms | 394.4 ms | **fxdart** | 489.2 MB | 478.7 MB | tie | 3 |
| 4 | even-totals | 1000000 | 85.0 ms | 12.6 ms | **fxdart** | 24.2 MB | 21.6 MB | fxdart | 3 |
| 5 | unique-visitors | 1000000 | 316.3 ms | 90.7 ms | **fxdart** | 209.0 MB | 201.5 MB | tie | 3 |
| 6 | last-three-errors | 1000000 | 64.4 ms | 13.8 ms | **fxdart** | 108.9 MB | 104.4 MB | tie | 3 |
| 7 | empty-report-default | 1000000 | 52.0 ms | 9.33 ms | **fxdart** | 123.2 MB | 121.4 MB | tie | 3 |
| 8 | clean-nullable-readings | 1000000 | 210.9 ms | 127.3 ms | **fxdart** | 122.3 MB | 117.5 MB | tie | 3 |
| 9 | skip-warmup-readings | 1000000 | 283.7 ms | 180.0 ms | **fxdart** | 136.4 MB | 144.5 MB | rxdart | 3 |
| 10 | numbered-checklist | 1000000 | 208.3 ms | 155.4 ms | **fxdart** | 199.1 MB | 196.5 MB | tie | 3 |
| 11 | stock-after-moves | 1000000 | 3303.8 ms | 162.2 ms | **fxdart** | 127.1 MB | 126.4 MB | tie | 3 |
| 12 | weekly-windows-report | 999999 | 653.6 ms | 42.8 ms | **fxdart** | 58.1 MB | 80.8 MB | rxdart | 3 |
| 13 | audit-with-outcomes | 1000000 | 3903.7 ms | 972.7 ms | **fxdart** | 181.6 MB | 195.9 MB | rxdart | 3 |
| 14 | bracket-the-session | 1000000 | 96.1 ms | 30.6 ms | **fxdart** | 122.9 MB | 139.5 MB | rxdart | 3 |
| 15 | status-transitions | 1000000 | 124.3 ms | 32.0 ms | **fxdart** | 84.0 MB | 88.8 MB | rxdart | 3 |
| 16 | upload-batches | 1000000 | 290.1 ms | 98.1 ms | **fxdart** | 124.4 MB | 132.1 MB | rxdart | 3 |
| 17 | spend-by-category-rx | 1000000 | 105.4 ms | 42.3 ms | **fxdart** | 92.3 MB | 117.2 MB | rxdart | 3 |
| 18 | feeds-in-order | 1000000 | 214.1 ms | 124.3 ms | **fxdart** | 268.6 MB | 278.3 MB | tie | 3 |
| 19 | tick-deltas | 1000000 | 772.9 ms | 449.2 ms | **fxdart** | 161.2 MB | 163.2 MB | tie | 3 |
| 20 | align-forecast-actual | 1000000 | 796.3 ms | 464.3 ms | **fxdart** | 205.8 MB | 215.6 MB | tie | 3 |
| 21 | sliding-average-rx | 1000000 | 1075.2 ms | 654.5 ms | **fxdart** | 153.9 MB | 151.1 MB | tie | 3 |
| 22 | stop-at-shutdown | 1000000 | 183.1 ms | 106.8 ms | **fxdart** | 186.7 MB | 201.6 MB | rxdart | 3 |
| 23 | dedupe-paged-feed | 1000000 | 287.2 ms | 207.9 ms | **fxdart** | 301.6 MB | 241.0 MB | fxdart | 3 |
| 24 | latency-extremes (async) | 10000 | 62.1 ms | 61.7 ms | **tie** | 23.7 MB | 24.2 MB | tie | 4 |
| 25 | all-validation-errors | 1000000 | 1092.8 ms | 305.5 ms | **fxdart** | 345.3 MB | 369.5 MB | rxdart | 3 |
| 26 | successes-and-failures (async) | 10000 | 65.3 ms | 35.2 ms | **fxdart** | 25.2 MB | 31.0 MB | rxdart | 3 |
| 27 | stop-after-three-failures (async) | 10000 | 65.8 ms | 37.2 ms | **fxdart** | 22.1 MB | 22.3 MB | tie | 3 |
| 28 | backoff-retry (async) | 10000 | 59.0 ms | 44.4 ms | **fxdart** | 29.2 MB | 27.0 MB | fxdart | 3 |
| 29 | retry-the-fetch (async) | 10000 | 49.2 ms | 43.6 ms | **fxdart** | 23.8 MB | 23.7 MB | tie | 3 |
| 30 | bound-the-stall (async) | 10000 | 14.1 ms | 12.8 ms | **fxdart** | 27.2 MB | 27.3 MB | tie | 3 |
| 31 | per-row-retry (async) | 10000 | 66.1 ms | 64.7 ms | **tie** | 60.8 MB | 40.2 MB | fxdart | 5 |
| 32 | cursor-lifetime (async) | 10000 | 30.4 ms | 32.1 ms | **rxdart** | 25.5 MB | 25.5 MB | tie | 3 |
| 33 | price-or-fallback (async) | 10000 | 41.3 ms | 40.1 ms | **tie** | 49.1 MB | 52.1 MB | rxdart | 5 |
| 34 | resume-with-cache (async) | 10000 | 1.82 ms | 2.01 ms | **tie** | 23.3 MB | 23.6 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 10000 | 61.8 ms | 32.2 ms | **fxdart** | 51.5 MB | 22.1 MB | fxdart | 3 |
| 36 | completion-order-pool (async) | 10000 | 33.8 ms | 33.6 ms | **tie** | 29.8 MB | 22.2 MB | fxdart | 3 |
| 37 | stream-into-pipeline (async) | 10000 | 765 µs | 783 µs | **tie** | 22.7 MB | 23.6 MB | tie | 3 |
| 47 | pipeline-into-stream (async) | 10000 | 36.8 ms | 38.1 ms | **tie** | 50.5 MB | 30.4 MB | fxdart | 5 |
| 48 | crawl-the-pages (async) | 10000 | 1.81 ms | 1.56 ms | **tie** | 23.1 MB | 22.5 MB | tie | 3 |
| 49 | dependent-calls-in-sequence (async) | 10000 | 36.1 ms | 34.6 ms | **tie** | 28.5 MB | 28.7 MB | tie | 5 |
| 50 | tee-the-pipeline | 1000000 | 139.8 ms | 17.3 ms | **fxdart** | 24.2 MB | 21.6 MB | fxdart | 3 |
