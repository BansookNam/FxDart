# RxDartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-02
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | even-totals | 100 | 11 µs | 1.1 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 2 | running-balance-feed | 100 | 8.5 µs | 1.5 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 3 | first-over-budget-rx | 100 | 10 µs | 502 ns | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 4 | skip-warmup-readings | 100 | 27 µs | 17 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 5 | unique-visitors | 100 | 11 µs | 4.7 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 6 | clean-nullable-readings | 100 | 22 µs | 12 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 7 | last-three-errors | 100 | 8.3 µs | 2.7 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 8 | numbered-checklist | 100 | 18 µs | 11 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 9 | expand-order-lines | 100 | 368 µs | 28 µs | **tie** | 15.8 MB | 16.5 MB | tie | 3 |
| 10 | empty-report-default | 100 | 6.8 µs | 2.4 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 11 | upload-batches | 100 | 30 µs | 11 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 12 | sliding-average-rx | 100 | 115 µs | 69 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 13 | tick-deltas | 100 | 78 µs | 54 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 14 | status-transitions | 100 | 15 µs | 5.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 15 | spend-by-category-rx | 100 | 19 µs | 6.1 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 16 | align-forecast-actual | 100 | 81 µs | 45 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 17 | feeds-in-order | 100 | 22 µs | 10 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 18 | bracket-the-session | 100 | 12 µs | 3.2 µs | **tie** | 17.0 MB | 16.4 MB | tie | 3 |
| 19 | dedupe-paged-feed | 100 | 22 µs | 12 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 20 | latency-extremes (async) | 100 | 706 µs | 758 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 21 | stock-after-moves | 100 | 337 µs | 13 µs | **tie** | 14.9 MB | 16.4 MB | rxdart | 3 |
| 22 | audit-with-outcomes | 100 | 412 µs | 103 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 23 | stop-at-shutdown | 100 | 19 µs | 12 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 24 | weekly-windows-report | 98 | 69 µs | 7.0 µs | **tie** | 17.4 MB | 16.6 MB | tie | 3 |
| 25 | price-or-fallback (async) | 100 | 485 µs | 531 µs | **tie** | 17.2 MB | 16.6 MB | tie | 3 |
| 26 | resume-with-cache (async) | 100 | 24 µs | 27 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 27 | retry-the-fetch (async) | 100 | 596 µs | 503 µs | **tie** | 16.9 MB | 16.9 MB | tie | 3 |
| 28 | backoff-retry (async) | 100 | 704 µs | 598 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 29 | per-row-retry (async) | 100 | 785 µs | 803 µs | **tie** | 17.2 MB | 16.7 MB | tie | 3 |
| 30 | bound-the-stall (async) | 100 | 153 µs | 207 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 31 | cursor-lifetime (async) | 100 | 331 µs | 422 µs | **tie** | 16.5 MB | 16.9 MB | tie | 3 |
| 32 | successes-and-failures (async) | 100 | 751 µs | 535 µs | **tie** | 17.0 MB | 17.0 MB | tie | 3 |
| 33 | all-validation-errors | 100 | 110 µs | 28 µs | **tie** | 15.6 MB | 16.4 MB | rxdart | 3 |
| 34 | stop-after-three-failures (async) | 100 | 819 µs | 603 µs | **tie** | 16.6 MB | 17.0 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 100 | 724 µs | 469 µs | **tie** | 16.7 MB | 17.0 MB | tie | 3 |
| 36 | completion-order-pool (async) | 100 | 423 µs | 438 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 37 | dependent-calls-in-sequence (async) | 100 | 412 µs | 571 µs | **tie** | 16.5 MB | 16.9 MB | tie | 3 |
| 38 | crawl-the-pages (async) | 100 | 22 µs | 60 µs | **tie** | 17.1 MB | 17.0 MB | tie | 3 |
| 48 | tee-the-pipeline | 100 | 19 µs | 4.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 49 | stream-into-pipeline (async) | 100 | 8.3 µs | 107 µs | **tie** | 16.3 MB | 16.5 MB | tie | 3 |
| 50 | pipeline-into-stream (async) | 100 | 439 µs | 514 µs | **tie** | 16.5 MB | 17.1 MB | tie | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | even-totals | 1000000 | 86.2 ms | 13.9 ms | **fxdart** | 24.2 MB | 21.5 MB | fxdart | 3 |
| 2 | running-balance-feed | 1000000 | 71.8 ms | 15.1 ms | **fxdart** | 56.0 MB | 55.0 MB | tie | 3 |
| 3 | first-over-budget-rx | 1000000 | 81.2 ms | 2.78 ms | **fxdart** | 122.2 MB | 111.4 MB | fxdart | 3 |
| 4 | skip-warmup-readings | 1000000 | 300.2 ms | 196.2 ms | **fxdart** | 132.2 MB | 144.9 MB | rxdart | 3 |
| 5 | unique-visitors | 1000000 | 441.9 ms | 95.7 ms | **fxdart** | 208.7 MB | 199.7 MB | tie | 3 |
| 6 | clean-nullable-readings | 1000000 | 219.0 ms | 129.8 ms | **fxdart** | 122.9 MB | 120.6 MB | tie | 3 |
| 7 | last-three-errors | 1000000 | 66.0 ms | 24.2 ms | **fxdart** | 112.4 MB | 108.0 MB | tie | 3 |
| 8 | numbered-checklist | 1000000 | 212.9 ms | 166.4 ms | **fxdart** | 199.1 MB | 199.5 MB | tie | 3 |
| 9 | expand-order-lines | 1000000 | 3754.1 ms | 410.7 ms | **fxdart** | 483.4 MB | 490.3 MB | tie | 3 |
| 10 | empty-report-default | 1000000 | 52.6 ms | 19.4 ms | **fxdart** | 123.0 MB | 121.2 MB | tie | 3 |
| 11 | upload-batches | 1000000 | 296.7 ms | 114.6 ms | **fxdart** | 128.3 MB | 132.9 MB | tie | 3 |
| 12 | sliding-average-rx | 1000000 | 1093.0 ms | 702.9 ms | **fxdart** | 153.7 MB | 151.5 MB | tie | 3 |
| 13 | tick-deltas | 1000000 | 788.4 ms | 460.9 ms | **fxdart** | 161.1 MB | 162.9 MB | tie | 3 |
| 14 | status-transitions | 1000000 | 126.7 ms | 48.6 ms | **fxdart** | 84.1 MB | 88.8 MB | rxdart | 3 |
| 15 | spend-by-category-rx | 1000000 | 107.2 ms | 58.9 ms | **fxdart** | 93.5 MB | 113.7 MB | rxdart | 3 |
| 16 | align-forecast-actual | 1000000 | 813.4 ms | 484.1 ms | **fxdart** | 206.6 MB | 213.0 MB | tie | 3 |
| 17 | feeds-in-order | 1000000 | 218.3 ms | 144.2 ms | **fxdart** | 272.4 MB | 282.8 MB | tie | 3 |
| 18 | bracket-the-session | 1000000 | 98.6 ms | 31.5 ms | **fxdart** | 127.7 MB | 138.1 MB | rxdart | 3 |
| 19 | dedupe-paged-feed | 1000000 | 311.9 ms | 237.6 ms | **fxdart** | 297.0 MB | 237.6 MB | fxdart | 3 |
| 20 | latency-extremes (async) | 10000 | 72.6 ms | 79.3 ms | **rxdart** | 24.2 MB | 24.2 MB | tie | 3 |
| 21 | stock-after-moves | 1000000 | 3362.1 ms | 172.4 ms | **fxdart** | 125.3 MB | 126.3 MB | tie | 3 |
| 22 | audit-with-outcomes | 1000000 | 3990.8 ms | 1049.1 ms | **fxdart** | 183.2 MB | 185.3 MB | tie | 3 |
| 23 | stop-at-shutdown | 1000000 | 192.9 ms | 122.6 ms | **fxdart** | 187.4 MB | 205.4 MB | rxdart | 3 |
| 24 | weekly-windows-report | 999999 | 675.0 ms | 72.2 ms | **fxdart** | 57.5 MB | 82.9 MB | rxdart | 3 |
| 25 | price-or-fallback (async) | 10000 | 44.7 ms | 47.7 ms | **rxdart** | 49.1 MB | 55.6 MB | rxdart | 4 |
| 26 | resume-with-cache (async) | 10000 | 1.91 ms | 2.20 ms | **tie** | 23.2 MB | 23.6 MB | tie | 3 |
| 27 | retry-the-fetch (async) | 10000 | 56.1 ms | 48.5 ms | **fxdart** | 23.9 MB | 23.8 MB | tie | 3 |
| 28 | backoff-retry (async) | 10000 | 62.4 ms | 50.5 ms | **fxdart** | 29.1 MB | 26.9 MB | fxdart | 3 |
| 29 | per-row-retry (async) | 10000 | 72.4 ms | 77.9 ms | **rxdart** | 61.3 MB | 44.4 MB | fxdart | 3 |
| 30 | bound-the-stall (async) | 10000 | 14.8 ms | 19.3 ms | **rxdart** | 27.5 MB | 27.2 MB | tie | 3 |
| 31 | cursor-lifetime (async) | 10000 | 31.0 ms | 35.3 ms | **rxdart** | 25.5 MB | 25.5 MB | tie | 3 |
| 32 | successes-and-failures (async) | 10000 | 69.3 ms | 49.6 ms | **fxdart** | 25.7 MB | 27.6 MB | rxdart | 3 |
| 33 | all-validation-errors | 1000000 | 1207.3 ms | 354.8 ms | **fxdart** | 344.6 MB | 366.5 MB | rxdart | 3 |
| 34 | stop-after-three-failures (async) | 10000 | 72.3 ms | 55.9 ms | **fxdart** | 22.1 MB | 29.8 MB | rxdart | 3 |
| 35 | ordered-bounded-fetch (async) | 10000 | 67.3 ms | 37.9 ms | **fxdart** | 51.7 MB | 22.5 MB | fxdart | 3 |
| 36 | completion-order-pool (async) | 10000 | 35.7 ms | 38.5 ms | **rxdart** | 30.3 MB | 22.2 MB | fxdart | 3 |
| 37 | dependent-calls-in-sequence (async) | 10000 | 39.1 ms | 57.0 ms | **rxdart** | 28.5 MB | 29.5 MB | tie | 3 |
| 38 | crawl-the-pages (async) | 10000 | 1.89 ms | 5.57 ms | **rxdart** | 22.6 MB | 22.1 MB | tie | 3 |
| 48 | tee-the-pipeline | 1000000 | 143.7 ms | 36.2 ms | **fxdart** | 24.3 MB | 55.0 MB | rxdart | 3 |
| 49 | stream-into-pipeline (async) | 10000 | 791 µs | 9.99 ms | **rxdart** | 22.8 MB | 25.5 MB | rxdart | 3 |
| 50 | pipeline-into-stream (async) | 10000 | 40.9 ms | 44.7 ms | **rxdart** | 50.7 MB | 31.0 MB | fxdart | 3 |
