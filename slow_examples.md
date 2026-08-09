# Cases where fxdart is slower than native

Ordered by fxdart/native median time at the headline scale, slowest first.
Source: benchmark/results/results.json. Columns: ratio, sync/async,
native / fxdart median.

Note: the ~5% run-to-run noise floor means the tail below ~1.15x is not
reliably ordered — treat those as a group, not a ranking.

Cases already worked on are marked; see enhancement_example.md for what
changed and what was tried and reverted.

DartComparison/anomaly-context.html           4.00x  sync      11.7 /    46.9 ms
DartComparison/recent-errors.html             2.50x  sync      10.8 /    26.9 ms
DartComparison/first-over-limit.html          2.37x  sync       5.1 /    12.2 ms
DartComparison/monthly-category-report.html   2.17x  sync      11.4 /    24.8 ms  <- was 2.46x
DartComparison/paginated-products.html        2.02x  sync     104.4 /   210.4 ms
DartComparison/paged-feeds-dedupe.html        2.01x  async     81.9 /   164.2 ms
DartComparison/first-visit-merchants.html     1.78x  sync      25.8 /    45.9 ms
DartComparison/alert-digest.html              1.54x  sync     177.0 /   273.2 ms
DartComparison/live-search.html               1.51x  async     45.9 /    69.1 ms
DartComparison/stream-windowed-alerts.html    1.47x  async     32.9 /    48.3 ms
DartComparison/flaky-api-retry.html           1.45x  async    495.1 /   719.4 ms
DartComparison/latency-percentiles.html       1.45x  sync     210.2 /   305.2 ms
DartComparison/date-window-spend.html         1.38x  sync      15.4 /    21.3 ms
DartComparison/ledger-diff.html               1.36x  sync     227.2 /   308.8 ms
DartComparison/consecutive-over-limit.html    1.34x  sync      17.1 /    23.0 ms
DartComparison/concurrent-enrichment.html     1.31x  async    209.8 /   274.0 ms
DartComparison/rate-limited-import.html       1.30x  async    133.6 /   173.7 ms
DartComparison/budget-alerts.html             1.27x  sync      21.8 /    27.6 ms  <- was 2.50x
DartComparison/bounded-concurrency.html       1.26x  async    313.5 /   396.0 ms
DartComparison/leaderboard-ties.html          1.22x  sync     554.8 /   679.3 ms
DartComparison/category-rank.html             1.22x  sync      36.4 /    44.3 ms
DartComparison/top-category-average.html      1.21x  sync      64.2 /    77.9 ms
DartComparison/smoothed-zone-changes.html     1.20x  sync      37.9 /    45.3 ms
DartComparison/sensor-anomalies.html          1.17x  sync      65.2 /    76.4 ms
DartComparison/running-balance.html           1.16x  sync     251.2 /   292.5 ms
DartComparison/parallel-downloads.html        1.16x  async    344.0 /   397.7 ms
DartComparison/stock-revaluation.html         1.15x  async    321.5 /   368.5 ms
DartComparison/sparse-timeseries.html         1.13x  sync      51.5 /    58.4 ms
DartComparison/weekly-sensor-averages.html    1.12x  sync      49.5 /    55.5 ms
DartComparison/invoice-summary.html           1.06x  sync      25.1 /    26.5 ms  <- was 2.29x
DartComparison/valid-emails.html              1.05x  sync      71.0 /    74.7 ms
