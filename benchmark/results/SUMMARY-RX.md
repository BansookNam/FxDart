# RxDartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-04
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | even-totals | 100 | 11 µs | 1.1 µs | **tie** | 17.0 MB | 16.3 MB | tie | 3 |
| 2 | running-balance-feed | 100 | 9.3 µs | 795 ns | **tie** | 17.0 MB | 16.4 MB | tie | 3 |
| 3 | first-over-budget-rx | 100 | 11 µs | 295 ns | **tie** | 17.1 MB | 16.4 MB | tie | 3 |
| 4 | skip-warmup-readings | 100 | 27 µs | 18 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 5 | unique-visitors | 100 | 13 µs | 4.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 6 | clean-nullable-readings | 100 | 24 µs | 12 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 7 | last-three-errors | 100 | 9.5 µs | 2.6 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 8 | numbered-checklist | 100 | 21 µs | 12 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 9 | expand-order-lines | 100 | 400 µs | 27 µs | **tie** | 15.5 MB | 16.5 MB | rxdart | 3 |
| 10 | empty-report-default | 100 | 7.3 µs | 2.5 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 11 | upload-batches | 100 | 35 µs | 11 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 12 | sliding-average-rx | 100 | 109 µs | 65 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 13 | tick-deltas | 100 | 82 µs | 44 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 14 | status-transitions | 100 | 16 µs | 7.1 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 15 | spend-by-category-rx | 100 | 24 µs | 6.0 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 16 | align-forecast-actual | 100 | 85 µs | 46 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 17 | feeds-in-order | 100 | 23 µs | 10 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 18 | bracket-the-session | 100 | 13 µs | 3.0 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 19 | dedupe-paged-feed | 100 | 25 µs | 12 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 20 | latency-extremes (async) | 100 | 738 µs | 655 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 21 | stock-after-moves | 100 | 392 µs | 14 µs | **tie** | 15.0 MB | 16.5 MB | rxdart | 3 |
| 22 | audit-with-outcomes | 100 | 422 µs | 100 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 23 | stop-at-shutdown | 100 | 19 µs | 8.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 24 | weekly-windows-report | 98 | 70 µs | 6.2 µs | **tie** | 17.5 MB | 16.6 MB | fxdart | 3 |
| 25 | price-or-fallback (async) | 100 | 553 µs | 464 µs | **tie** | 17.2 MB | 16.7 MB | tie | 3 |
| 26 | resume-with-cache (async) | 100 | 27 µs | 27 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 27 | retry-the-fetch (async) | 100 | 579 µs | 476 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 28 | backoff-retry (async) | 100 | 806 µs | 527 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 29 | per-row-retry (async) | 100 | 819 µs | 782 µs | **tie** | 16.6 MB | 16.7 MB | tie | 3 |
| 30 | bound-the-stall (async) | 100 | 161 µs | 153 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 31 | cursor-lifetime (async) | 100 | 421 µs | 361 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |
| 32 | successes-and-failures (async) | 100 | 790 µs | 393 µs | **tie** | 16.6 MB | 17.0 MB | tie | 3 |
| 33 | all-validation-errors | 100 | 128 µs | 29 µs | **tie** | 15.2 MB | 16.4 MB | rxdart | 3 |
| 34 | stop-after-three-failures (async) | 100 | 830 µs | 427 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 100 | 776 µs | 378 µs | **tie** | 16.6 MB | 16.9 MB | tie | 3 |
| 36 | completion-order-pool (async) | 100 | 386 µs | 354 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 37 | dependent-calls-in-sequence (async) | 100 | 383 µs | 354 µs | **tie** | 17.0 MB | 16.6 MB | tie | 3 |
| 38 | crawl-the-pages (async) | 100 | 23 µs | 20 µs | **tie** | 16.6 MB | 17.1 MB | tie | 3 |
| 48 | tee-the-pipeline | 100 | 22 µs | 2.3 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 49 | stream-into-pipeline (async) | 100 | 9.3 µs | 9.3 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 50 | pipeline-into-stream (async) | 100 | 409 µs | 513 µs | **tie** | 17.1 MB | 17.1 MB | tie | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | even-totals | 1000000 | 86.9 ms | 13.8 ms | **fxdart** | 24.7 MB | 21.4 MB | fxdart | 3 |
| 2 | running-balance-feed | 1000000 | 72.1 ms | 7.54 ms | **fxdart** | 56.4 MB | 59.8 MB | rxdart | 3 |
| 3 | first-over-budget-rx | 1000000 | 80.9 ms | 965 µs | **fxdart** | 122.5 MB | 111.2 MB | fxdart | 3 |
| 4 | skip-warmup-readings | 1000000 | 289.3 ms | 197.1 ms | **fxdart** | 136.4 MB | 144.0 MB | rxdart | 3 |
| 5 | unique-visitors | 1000000 | 408.6 ms | 93.4 ms | **fxdart** | 208.6 MB | 200.2 MB | tie | 3 |
| 6 | clean-nullable-readings | 1000000 | 215.9 ms | 131.9 ms | **fxdart** | 122.6 MB | 112.9 MB | fxdart | 3 |
| 7 | last-three-errors | 1000000 | 66.7 ms | 23.6 ms | **fxdart** | 112.0 MB | 104.3 MB | fxdart | 3 |
| 8 | numbered-checklist | 1000000 | 212.9 ms | 169.7 ms | **fxdart** | 198.4 MB | 198.9 MB | tie | 3 |
| 9 | expand-order-lines | 1000000 | 3736.7 ms | 406.1 ms | **fxdart** | 479.8 MB | 489.3 MB | tie | 3 |
| 10 | empty-report-default | 1000000 | 53.2 ms | 19.6 ms | **fxdart** | 123.5 MB | 121.3 MB | tie | 3 |
| 11 | upload-batches | 1000000 | 298.1 ms | 117.6 ms | **fxdart** | 128.5 MB | 133.6 MB | tie | 3 |
| 12 | sliding-average-rx | 1000000 | 1109.6 ms | 704.2 ms | **fxdart** | 154.3 MB | 151.9 MB | tie | 3 |
| 13 | tick-deltas | 1000000 | 786.2 ms | 472.6 ms | **fxdart** | 160.3 MB | 162.9 MB | tie | 3 |
| 14 | status-transitions | 1000000 | 129.1 ms | 48.9 ms | **fxdart** | 84.0 MB | 88.8 MB | rxdart | 3 |
| 15 | spend-by-category-rx | 1000000 | 107.5 ms | 59.8 ms | **fxdart** | 92.8 MB | 115.9 MB | rxdart | 3 |
| 16 | align-forecast-actual | 1000000 | 825.6 ms | 490.9 ms | **fxdart** | 208.3 MB | 216.5 MB | tie | 3 |
| 17 | feeds-in-order | 1000000 | 224.3 ms | 133.6 ms | **fxdart** | 272.4 MB | 276.6 MB | tie | 3 |
| 18 | bracket-the-session | 1000000 | 98.7 ms | 31.1 ms | **fxdart** | 123.2 MB | 138.8 MB | rxdart | 3 |
| 19 | dedupe-paged-feed | 1000000 | 321.8 ms | 224.9 ms | **fxdart** | 296.7 MB | 241.1 MB | fxdart | 3 |
| 20 | latency-extremes (async) | 10000 | 63.1 ms | 63.7 ms | **tie** | 24.2 MB | 24.2 MB | tie | 3 |
| 21 | stock-after-moves | 1000000 | 3374.6 ms | 174.9 ms | **fxdart** | 127.0 MB | 126.4 MB | tie | 3 |
| 22 | audit-with-outcomes | 1000000 | 4142.9 ms | 1042.0 ms | **fxdart** | 184.3 MB | 185.0 MB | tie | 3 |
| 23 | stop-at-shutdown | 1000000 | 189.5 ms | 121.9 ms | **fxdart** | 186.7 MB | 191.1 MB | tie | 3 |
| 24 | weekly-windows-report | 999999 | 667.7 ms | 63.6 ms | **fxdart** | 58.1 MB | 80.9 MB | rxdart | 3 |
| 25 | price-or-fallback (async) | 10000 | 44.0 ms | 44.6 ms | **tie** | 49.1 MB | 52.1 MB | rxdart | 3 |
| 26 | resume-with-cache (async) | 10000 | 1.84 ms | 2.11 ms | **tie** | 23.2 MB | 24.1 MB | tie | 3 |
| 27 | retry-the-fetch (async) | 10000 | 54.2 ms | 48.1 ms | **fxdart** | 23.7 MB | 24.0 MB | tie | 3 |
| 28 | backoff-retry (async) | 10000 | 63.0 ms | 48.2 ms | **fxdart** | 29.3 MB | 27.0 MB | fxdart | 3 |
| 29 | per-row-retry (async) | 10000 | 71.6 ms | 70.3 ms | **tie** | 61.2 MB | 40.5 MB | fxdart | 5 |
| 30 | bound-the-stall (async) | 10000 | 14.8 ms | 13.4 ms | **fxdart** | 27.6 MB | 27.5 MB | tie | 3 |
| 31 | cursor-lifetime (async) | 10000 | 32.9 ms | 33.0 ms | **tie** | 25.4 MB | 25.5 MB | tie | 3 |
| 32 | successes-and-failures (async) | 10000 | 70.3 ms | 36.3 ms | **fxdart** | 25.2 MB | 30.7 MB | rxdart | 3 |
| 33 | all-validation-errors | 1000000 | 1122.9 ms | 330.9 ms | **fxdart** | 345.5 MB | 368.0 MB | rxdart | 3 |
| 34 | stop-after-three-failures (async) | 10000 | 68.1 ms | 38.8 ms | **fxdart** | 22.7 MB | 22.1 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 10000 | 64.7 ms | 34.1 ms | **fxdart** | 51.7 MB | 22.3 MB | fxdart | 3 |
| 36 | completion-order-pool (async) | 10000 | 34.9 ms | 34.0 ms | **tie** | 29.7 MB | 22.2 MB | fxdart | 5 |
| 37 | dependent-calls-in-sequence (async) | 10000 | 38.3 ms | 35.5 ms | **fxdart** | 28.9 MB | 28.9 MB | tie | 3 |
| 38 | crawl-the-pages (async) | 10000 | 1.73 ms | 1.63 ms | **tie** | 22.6 MB | 23.2 MB | tie | 3 |
| 48 | tee-the-pipeline | 1000000 | 142.4 ms | 17.6 ms | **fxdart** | 24.3 MB | 21.6 MB | fxdart | 3 |
| 49 | stream-into-pipeline (async) | 10000 | 766 µs | 778 µs | **tie** | 22.8 MB | 23.7 MB | tie | 3 |
| 50 | pipeline-into-stream (async) | 10000 | 38.4 ms | 40.0 ms | **tie** | 50.4 MB | 30.5 MB | fxdart | 5 |
