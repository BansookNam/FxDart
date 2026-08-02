# RxDartComparison benchmark summary

- **Machine:** Apple M1 Max, 32 GB RAM
- **Dart:** 3.12.2 (macos Version 26.3 (Build 25D125)), AOT-compiled
- **Date:** 2026-08-02
- **Method:** per side and N-scale, fresh process × rounds, 2 warmup + 5 measured iterations per process (small N auto-batched to ≥2 ms samples); median reported. Ties — within 5.0% of each other, or within 0.6 ms absolute (beneath human perception) — with close relative races re-run up to 5 rounds.
- Memory is peak process RSS — the runtime and the dataset are identical on both sides, so the *difference* is what the pipeline itself holds onto. At small N it is all runtime baseline; expect ties.

## N = 100

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | even-totals | 100 | 10 µs | 1.1 µs | **tie** | 17.1 MB | 16.5 MB | tie | 3 |
| 2 | running-balance-feed | 100 | 8.1 µs | 1.5 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 3 | first-over-budget-rx | 100 | 18 µs | 1.0 µs | **tie** | 16.6 MB | 16.4 MB | tie | 3 |
| 4 | skip-warmup-readings | 100 | 28 µs | 19 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 5 | unique-visitors | 100 | 12 µs | 4.8 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 6 | clean-nullable-readings | 100 | 35 µs | 20 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 7 | last-three-errors | 100 | 9.3 µs | 3.1 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 8 | numbered-checklist | 100 | 18 µs | 12 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 9 | expand-order-lines | 100 | 408 µs | 27 µs | **tie** | 15.6 MB | 16.5 MB | rxdart | 3 |
| 10 | empty-report-default | 100 | 7.3 µs | 2.3 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 11 | upload-batches | 100 | 31 µs | 13 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 12 | sliding-average-rx | 100 | 113 µs | 68 µs | **tie** | 16.7 MB | 16.5 MB | tie | 3 |
| 13 | tick-deltas | 100 | 79 µs | 45 µs | **tie** | 16.6 MB | 16.3 MB | tie | 3 |
| 14 | status-transitions | 100 | 15 µs | 5.6 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 15 | spend-by-category-rx | 100 | 23 µs | 7.7 µs | **tie** | 16.7 MB | 16.4 MB | tie | 3 |
| 16 | align-forecast-actual | 100 | 79 µs | 47 µs | **tie** | 16.6 MB | 16.6 MB | tie | 3 |
| 17 | feeds-in-order | 100 | 21 µs | 10 µs | **tie** | 17.1 MB | 17.0 MB | tie | 3 |
| 18 | bracket-the-session | 100 | 11 µs | 3.2 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 19 | dedupe-paged-feed | 100 | 23 µs | 14 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 20 | latency-extremes (async) | 100 | 781 µs | 836 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 21 | stock-after-moves | 100 | 343 µs | 14 µs | **tie** | 15.0 MB | 16.5 MB | rxdart | 3 |
| 22 | audit-with-outcomes | 100 | 427 µs | 102 µs | **tie** | 16.5 MB | 16.5 MB | tie | 3 |
| 23 | stop-at-shutdown | 100 | 19 µs | 10 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 24 | weekly-windows-report | 98 | 79 µs | 6.8 µs | **tie** | 16.9 MB | 16.5 MB | tie | 3 |
| 25 | price-or-fallback (async) | 100 | 560 µs | 583 µs | **tie** | 17.2 MB | 16.7 MB | tie | 3 |
| 26 | resume-with-cache (async) | 100 | 24 µs | 28 µs | **tie** | 16.6 MB | 17.0 MB | tie | 3 |
| 27 | retry-the-fetch (async) | 100 | 625 µs | 541 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 28 | backoff-retry (async) | 100 | 762 µs | 535 µs | **tie** | 17.0 MB | 16.5 MB | tie | 3 |
| 29 | per-row-retry (async) | 100 | 837 µs | 910 µs | **tie** | 17.2 MB | 17.2 MB | tie | 3 |
| 30 | bound-the-stall (async) | 100 | 170 µs | 207 µs | **tie** | 17.1 MB | 16.5 MB | tie | 3 |
| 31 | cursor-lifetime (async) | 100 | 406 µs | 532 µs | **tie** | 16.6 MB | 16.5 MB | tie | 3 |
| 32 | successes-and-failures (async) | 100 | 817 µs | 600 µs | **tie** | 16.8 MB | 17.0 MB | tie | 3 |
| 33 | all-validation-errors | 100 | 117 µs | 29 µs | **tie** | 15.5 MB | 16.4 MB | rxdart | 3 |
| 34 | stop-after-three-failures (async) | 100 | 828 µs | 623 µs | **tie** | 17.0 MB | 17.2 MB | tie | 3 |
| 35 | ordered-bounded-fetch (async) | 100 | 703 µs | 444 µs | **tie** | 16.6 MB | 17.1 MB | tie | 3 |
| 36 | completion-order-pool (async) | 100 | 447 µs | 446 µs | **tie** | 16.5 MB | 16.6 MB | tie | 3 |
| 37 | dependent-calls-in-sequence (async) | 100 | 405 µs | 623 µs | **tie** | 16.5 MB | 17.0 MB | tie | 3 |
| 38 | crawl-the-pages (async) | 100 | 24 µs | 62 µs | **tie** | 17.1 MB | 17.0 MB | tie | 3 |
| 48 | tee-the-pipeline | 100 | 20 µs | 12 µs | **tie** | 16.5 MB | 16.4 MB | tie | 3 |
| 49 | stream-into-pipeline (async) | 100 | 8.4 µs | 104 µs | **tie** | 16.4 MB | 16.5 MB | tie | 3 |
| 50 | pipeline-into-stream (async) | 100 | 474 µs | 492 µs | **tie** | 16.8 MB | 17.1 MB | tie | 3 |

## Headline N (1M sync / case-specific async)

| # | Case | N | rxdart time | FxDart time | Time winner | rxdart mem | FxDart mem | Mem winner | Rounds |
|--:|------|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 1 | even-totals | 1000000 | 87.1 ms | 14.1 ms | **fxdart** | 24.2 MB | 21.6 MB | fxdart | 3 |
| 2 | running-balance-feed | 1000000 | 76.3 ms | 15.5 ms | **fxdart** | 56.5 MB | 54.9 MB | tie | 3 |
| 3 | first-over-budget-rx | 1000000 | 88.1 ms | 6.00 ms | **fxdart** | 123.2 MB | 110.6 MB | fxdart | 3 |
| 4 | skip-warmup-readings | 1000000 | 320.9 ms | 214.7 ms | **fxdart** | 137.3 MB | 144.8 MB | rxdart | 3 |
| 5 | unique-visitors | 1000000 | 428.3 ms | 106.4 ms | **fxdart** | 209.0 MB | 200.6 MB | tie | 3 |
| 6 | clean-nullable-readings | 1000000 | 240.7 ms | 143.1 ms | **fxdart** | 122.6 MB | 118.3 MB | tie | 3 |
| 7 | last-three-errors | 1000000 | 67.9 ms | 24.6 ms | **fxdart** | 111.9 MB | 127.7 MB | rxdart | 3 |
| 8 | numbered-checklist | 1000000 | 234.5 ms | 187.9 ms | **fxdart** | 198.8 MB | 197.1 MB | tie | 3 |
| 9 | expand-order-lines | 1000000 | 4000.0 ms | 445.3 ms | **fxdart** | 487.1 MB | 488.4 MB | tie | 3 |
| 10 | empty-report-default | 1000000 | 54.0 ms | 19.9 ms | **fxdart** | 123.4 MB | 120.8 MB | tie | 3 |
| 11 | upload-batches | 1000000 | 304.7 ms | 126.6 ms | **fxdart** | 128.4 MB | 134.2 MB | tie | 3 |
| 12 | sliding-average-rx | 1000000 | 1137.6 ms | 732.3 ms | **fxdart** | 153.6 MB | 151.3 MB | tie | 3 |
| 13 | tick-deltas | 1000000 | 814.0 ms | 476.7 ms | **fxdart** | 161.7 MB | 163.0 MB | tie | 3 |
| 14 | status-transitions | 1000000 | 132.6 ms | 50.7 ms | **fxdart** | 84.1 MB | 88.8 MB | rxdart | 3 |
| 15 | spend-by-category-rx | 1000000 | 110.9 ms | 73.1 ms | **fxdart** | 92.5 MB | 115.5 MB | rxdart | 3 |
| 16 | align-forecast-actual | 1000000 | 863.6 ms | 520.3 ms | **fxdart** | 206.4 MB | 219.4 MB | rxdart | 3 |
| 17 | feeds-in-order | 1000000 | 236.2 ms | 162.2 ms | **fxdart** | 275.0 MB | 282.6 MB | tie | 3 |
| 18 | bracket-the-session | 1000000 | 101.9 ms | 32.0 ms | **fxdart** | 128.0 MB | 139.0 MB | rxdart | 3 |
| 19 | dedupe-paged-feed | 1000000 | 312.6 ms | 231.5 ms | **fxdart** | 299.6 MB | 240.6 MB | fxdart | 3 |
| 20 | latency-extremes (async) | 10000 | 70.7 ms | 77.5 ms | **rxdart** | 24.2 MB | 24.2 MB | tie | 3 |
| 21 | stock-after-moves | 1000000 | 3503.4 ms | 185.9 ms | **fxdart** | 124.8 MB | 121.8 MB | tie | 3 |
| 22 | audit-with-outcomes | 1000000 | 4106.5 ms | 1068.8 ms | **fxdart** | 184.0 MB | 190.5 MB | tie | 3 |
| 23 | stop-at-shutdown | 1000000 | 194.9 ms | 124.8 ms | **fxdart** | 187.5 MB | 198.5 MB | rxdart | 3 |
| 24 | weekly-windows-report | 999999 | 692.8 ms | 80.3 ms | **fxdart** | 57.6 MB | 83.0 MB | rxdart | 3 |
| 25 | price-or-fallback (async) | 10000 | 51.0 ms | 51.0 ms | **tie** | 49.1 MB | 55.5 MB | rxdart | 3 |
| 26 | resume-with-cache (async) | 10000 | 1.85 ms | 2.05 ms | **tie** | 23.3 MB | 24.1 MB | tie | 3 |
| 27 | retry-the-fetch (async) | 10000 | 59.0 ms | 53.2 ms | **fxdart** | 24.0 MB | 23.5 MB | tie | 3 |
| 28 | backoff-retry (async) | 10000 | 67.2 ms | 52.6 ms | **fxdart** | 29.3 MB | 26.7 MB | fxdart | 3 |
| 29 | per-row-retry (async) | 10000 | 84.2 ms | 83.8 ms | **tie** | 60.9 MB | 44.3 MB | fxdart | 5 |
| 30 | bound-the-stall (async) | 10000 | 15.3 ms | 21.2 ms | **rxdart** | 27.5 MB | 28.0 MB | tie | 3 |
| 31 | cursor-lifetime (async) | 10000 | 40.8 ms | 44.8 ms | **rxdart** | 25.5 MB | 25.6 MB | tie | 3 |
| 32 | successes-and-failures (async) | 10000 | 76.2 ms | 55.8 ms | **fxdart** | 25.3 MB | 27.2 MB | rxdart | 3 |
| 33 | all-validation-errors | 1000000 | 1161.1 ms | 341.6 ms | **fxdart** | 343.0 MB | 366.6 MB | rxdart | 3 |
| 34 | stop-after-three-failures (async) | 10000 | 77.4 ms | 59.8 ms | **fxdart** | 22.6 MB | 29.7 MB | rxdart | 3 |
| 35 | ordered-bounded-fetch (async) | 10000 | 71.3 ms | 39.6 ms | **fxdart** | 51.6 MB | 22.3 MB | fxdart | 3 |
| 36 | completion-order-pool (async) | 10000 | 38.7 ms | 41.9 ms | **rxdart** | 30.2 MB | 22.3 MB | fxdart | 3 |
| 37 | dependent-calls-in-sequence (async) | 10000 | 40.5 ms | 56.4 ms | **rxdart** | 28.9 MB | 29.6 MB | tie | 3 |
| 38 | crawl-the-pages (async) | 10000 | 1.98 ms | 6.14 ms | **rxdart** | 23.1 MB | 21.7 MB | fxdart | 3 |
| 48 | tee-the-pipeline | 1000000 | 147.5 ms | 110.8 ms | **fxdart** | 24.3 MB | 54.5 MB | rxdart | 3 |
| 49 | stream-into-pipeline (async) | 10000 | 788 µs | 9.95 ms | **rxdart** | 22.8 MB | 25.9 MB | rxdart | 3 |
| 50 | pipeline-into-stream (async) | 10000 | 40.8 ms | 46.5 ms | **rxdart** | 50.8 MB | 31.1 MB | fxdart | 3 |
