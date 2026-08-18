# RxDartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-18
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | first-over-budget-rx | 100 | 11 µs | 293 ns | **tie** | 17.1 MB | 16.3 MB | tie | 3 |
| 2 | running-balance-feed | 100 | 9.7 µs | 763 ns | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 3 | expand-order-lines | 100 | 421 µs | 26 µs | **tie** | 15.5 MB | 16.5 MB | rxdart | 3 |
| 4 | even-totals | 100 | 11 µs | 938 ns | **tie** | 16.5 MB | 15.9 MB | tie | 3 |
| 5 | unique-visitors | 100 | 13 µs | 4.7 µs | **tie** | 16.7 MB | 16.5 MB | tie | 3 |
| 6 | last-three-errors | 100 | 10 µs | 1.3 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 7 | empty-report-default | 100 | 8.0 µs | 895 ns | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 8 | clean-nullable-readings | 100 | 24 µs | 11 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 9 | skip-warmup-readings | 100 | 32 µs | 16 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 10 | numbered-checklist | 100 | 21 µs | 11 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 11 | stock-after-moves | 100 | 335 µs | 12 µs | **tie** | 15.1 MB | 16.5 MB | rxdart | 3 |
| 12 | weekly-windows-report | 98 | 79 µs | 3.9 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 13 | audit-with-outcomes | 100 | 465 µs | 100 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 14 | bracket-the-session | 100 | 13 µs | 3.1 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 15 | status-transitions | 100 | 20 µs | 4.1 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 16 | upload-batches | 100 | 34 µs | 8.9 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 17 | spend-by-category-rx | 100 | 24 µs | 4.9 µs | **tie** | 16.7 MB | 16.4 MB | tie | 3 |
| 18 | feeds-in-order | 100 | 24 µs | 9.6 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 19 | tick-deltas | 100 | 86 µs | 42 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 20 | align-forecast-actual | 100 | 88 µs | 46 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 21 | sliding-average-rx | 100 | 103 µs | 63 µs | **tie** | 16.7 MB | 16.5 MB | tie | 3 |
| 22 | stop-at-shutdown | 100 | 23 µs | 8.0 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 23 | dedupe-paged-feed | 100 | 25 µs | 12 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 24 | latency-extremes (async) | 100 | 707 µs | 628 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 25 | all-validation-errors | 100 | 125 µs | 27 µs | **tie** | 15.5 MB | 16.5 MB | rxdart | 3 |
| 26 | successes-and-failures (async) | 100 | 818 µs | 430 µs | **tie** | 17.0 MB | 16.6 MB | tie | 3 |
| 27 | stop-after-three-failures (async) | 100 | 818 µs | 413 µs | **tie** | 16.6 MB | 17.0 MB | tie | 3 |
| 28 | backoff-retry (async) | 100 | 687 µs | 575 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 29 | retry-the-fetch (async) | 100 | 586 µs | 504 µs | **tie** | 16.5 MB | 16.3 MB | tie | 3 |
| 30 | bound-the-stall (async) | 100 | 174 µs | 145 µs | **tie** | 16.6 MB | 17.1 MB | tie | 3 |
| 31 | per-row-retry (async) | 100 | 737 µs | 768 µs | **tie** | 17.2 MB | 16.7 MB | tie | 3 |
| 32 | cursor-lifetime (async) | 100 | 385 µs | 398 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 33 | price-or-fallback (async) | 100 | 455 µs | 453 µs | **tie** | 17.1 MB | 17.3 MB | tie | 3 |
| 34 | resume-with-cache (async) | 100 | 28 µs | 26 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 100 | 767 µs | 377 µs | **tie** | 16.6 MB | 17.2 MB | tie | 3 |
| 36 | completion-order-pool (async) | 100 | 376 µs | 366 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 37 | stream-into-pipeline (async) | 100 | 8.9 µs | 8.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 47 | pipeline-into-stream (async) | 100 | 438 µs | 415 µs | **tie** | 16.6 MB | 17.2 MB | tie | 3 |
| 48 | crawl-the-pages (async) | 100 | 24 µs | 22 µs | **tie** | 16.6 MB | 17.1 MB | tie | 3 |
| 49 | dependent-calls-in-sequence (async) | 100 | 432 µs | 415 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 50 | tee-the-pipeline | 100 | 20 µs | 2.3 µs | **tie** | 16.7 MB | 16.3 MB | tie | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | first-over-budget-rx | 1000000 | 78.8 ms | 870 µs | **fxdart** | 122.4 MB | 111.8 MB | fxdart | 3 |
| 2 | running-balance-feed | 1000000 | 69.9 ms | 7.12 ms | **fxdart** | 56.0 MB | 59.9 MB | rxdart | 3 |
| 3 | expand-order-lines | 1000000 | 3645.4 ms | 400.1 ms | **fxdart** | 484.3 MB | 493.7 MB | tie | 3 |
| 4 | even-totals | 1000000 | 84.1 ms | 12.8 ms | **fxdart** | 24.2 MB | 21.6 MB | fxdart | 3 |
| 5 | unique-visitors | 1000000 | 294.6 ms | 84.8 ms | **fxdart** | 209.0 MB | 200.7 MB | tie | 3 |
| 6 | last-three-errors | 1000000 | 64.2 ms | 11.6 ms | **fxdart** | 108.3 MB | 104.4 MB | tie | 3 |
| 7 | empty-report-default | 1000000 | 51.9 ms | 7.33 ms | **fxdart** | 123.5 MB | 121.8 MB | tie | 3 |
| 8 | clean-nullable-readings | 1000000 | 208.6 ms | 126.3 ms | **fxdart** | 123.0 MB | 116.8 MB | fxdart | 3 |
| 9 | skip-warmup-readings | 1000000 | 283.0 ms | 180.1 ms | **fxdart** | 132.3 MB | 142.7 MB | rxdart | 3 |
| 10 | numbered-checklist | 1000000 | 206.9 ms | 153.9 ms | **fxdart** | 197.0 MB | 199.2 MB | tie | 3 |
| 11 | stock-after-moves | 1000000 | 3288.1 ms | 162.5 ms | **fxdart** | 126.5 MB | 126.2 MB | tie | 3 |
| 12 | weekly-windows-report | 999999 | 652.7 ms | 41.6 ms | **fxdart** | 58.1 MB | 80.8 MB | rxdart | 3 |
| 13 | audit-with-outcomes | 1000000 | 3894.3 ms | 995.7 ms | **fxdart** | 184.3 MB | 185.3 MB | tie | 3 |
| 14 | bracket-the-session | 1000000 | 96.8 ms | 29.6 ms | **fxdart** | 128.3 MB | 140.6 MB | rxdart | 3 |
| 15 | status-transitions | 1000000 | 124.1 ms | 32.0 ms | **fxdart** | 84.0 MB | 88.7 MB | rxdart | 3 |
| 16 | upload-batches | 1000000 | 287.8 ms | 98.1 ms | **fxdart** | 128.5 MB | 132.1 MB | tie | 3 |
| 17 | spend-by-category-rx | 1000000 | 104.8 ms | 44.6 ms | **fxdart** | 92.5 MB | 96.2 MB | tie | 3 |
| 18 | feeds-in-order | 1000000 | 217.2 ms | 126.0 ms | **fxdart** | 268.6 MB | 275.9 MB | tie | 3 |
| 19 | tick-deltas | 1000000 | 762.6 ms | 439.3 ms | **fxdart** | 159.2 MB | 162.6 MB | tie | 3 |
| 20 | align-forecast-actual | 1000000 | 799.0 ms | 461.3 ms | **fxdart** | 206.6 MB | 215.4 MB | tie | 3 |
| 21 | sliding-average-rx | 1000000 | 1068.2 ms | 657.2 ms | **fxdart** | 154.0 MB | 150.1 MB | tie | 3 |
| 22 | stop-at-shutdown | 1000000 | 182.6 ms | 104.4 ms | **fxdart** | 186.8 MB | 196.8 MB | rxdart | 3 |
| 23 | dedupe-paged-feed | 1000000 | 319.5 ms | 204.1 ms | **fxdart** | 302.1 MB | 241.0 MB | fxdart | 3 |
| 24 | latency-extremes (async) | 10000 | 65.2 ms | 61.4 ms | **fxdart** | 24.1 MB | 24.3 MB | tie | 3 |
| 25 | all-validation-errors | 1000000 | 1094.5 ms | 303.4 ms | **fxdart** | 345.3 MB | 369.0 MB | rxdart | 3 |
| 26 | successes-and-failures (async) | 10000 | 65.2 ms | 34.8 ms | **fxdart** | 25.2 MB | 30.6 MB | rxdart | 3 |
| 27 | stop-after-three-failures (async) | 10000 | 65.5 ms | 37.6 ms | **fxdart** | 22.2 MB | 22.6 MB | tie | 3 |
| 28 | backoff-retry (async) | 10000 | 57.5 ms | 44.2 ms | **fxdart** | 29.4 MB | 27.1 MB | fxdart | 3 |
| 29 | retry-the-fetch (async) | 10000 | 49.8 ms | 43.0 ms | **fxdart** | 24.0 MB | 24.0 MB | tie | 3 |
| 30 | bound-the-stall (async) | 10000 | 14.3 ms | 12.9 ms | **fxdart** | 27.4 MB | 27.0 MB | tie | 3 |
| 31 | per-row-retry (async) | 10000 | 65.4 ms | 62.9 ms | **tie** | 61.2 MB | 40.3 MB | fxdart | 5 |
| 32 | cursor-lifetime (async) | 10000 | 30.8 ms | 32.2 ms | **tie** | 24.9 MB | 25.4 MB | tie | 5 |
| 33 | price-or-fallback (async) | 10000 | 42.7 ms | 38.9 ms | **fxdart** | 49.1 MB | 52.0 MB | rxdart | 3 |
| 34 | resume-with-cache (async) | 10000 | 1.80 ms | 1.97 ms | **tie** | 23.2 MB | 23.7 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 10000 | 60.9 ms | 32.3 ms | **fxdart** | 51.7 MB | 22.2 MB | fxdart | 3 |
| 36 | completion-order-pool (async) | 10000 | 33.7 ms | 33.1 ms | **tie** | 29.8 MB | 22.3 MB | fxdart | 3 |
| 37 | stream-into-pipeline (async) | 10000 | 762 µs | 773 µs | **tie** | 22.9 MB | 23.5 MB | tie | 3 |
| 47 | pipeline-into-stream (async) | 10000 | 36.4 ms | 36.3 ms | **tie** | 50.5 MB | 30.8 MB | fxdart | 3 |
| 48 | crawl-the-pages (async) | 10000 | 1.83 ms | 1.54 ms | **tie** | 23.2 MB | 23.0 MB | tie | 3 |
| 49 | dependent-calls-in-sequence (async) | 10000 | 35.9 ms | 36.1 ms | **tie** | 28.2 MB | 28.6 MB | tie | 3 |
| 50 | tee-the-pipeline | 1000000 | 139.4 ms | 17.3 ms | **fxdart** | 24.3 MB | 21.5 MB | fxdart | 3 |
