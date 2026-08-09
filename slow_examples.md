# Cases where fxdart is slower than native

Ordered by fxdart/native median at the headline scale, slowest first.
Source: benchmark/results/results.json.

Resolved cases (tie or fxdart-faster) are in enhancement_example.md.

Note: the ~5% run-to-run noise floor means the tail below ~1.15x is not
reliably ordered. The async cases are bounded by one future per element (see
the 0.7.4 changelog) and are not expected to reach parity on time.

DartComparison/paged-feeds-dedupe.html        2.06x  async     82.3 /   169.2 ms
DartComparison/first-visit-merchants.html     1.86x  sync      28.1 /    52.2 ms
DartComparison/multi-currency-report.html     1.73x  sync     383.8 /   665.8 ms
DartComparison/anomaly-context.html           1.69x  sync      12.2 /    20.6 ms
DartComparison/recent-errors.html             1.54x  sync      10.8 /    16.7 ms
DartComparison/monthly-category-report.html   1.51x  sync      11.6 /    17.5 ms
DartComparison/stream-windowed-alerts.html    1.50x  async     32.4 /    48.5 ms
DartComparison/alert-digest.html              1.48x  sync     176.6 /   261.7 ms
DartComparison/live-search.html               1.46x  async     48.4 /    70.5 ms
DartComparison/flaky-api-retry.html           1.44x  async    503.2 /   724.9 ms
DartComparison/latency-percentiles.html       1.34x  sync     211.1 /   281.8 ms
DartComparison/rate-limited-import.html       1.31x  async    134.7 /   176.4 ms
DartComparison/ledger-diff.html               1.30x  sync     253.8 /   330.7 ms  <- was 1.41x
DartComparison/consecutive-over-limit.html    1.28x  sync      17.8 /    22.9 ms
DartComparison/concurrent-enrichment.html     1.28x  async    204.1 /   261.4 ms
DartComparison/budget-alerts.html             1.28x  sync      21.7 /    27.7 ms
DartComparison/paginated-products.html        1.25x  sync     103.0 /   128.4 ms  <- was 2.00x
DartComparison/leaderboard-ties.html          1.20x  sync     555.0 /   666.8 ms
DartComparison/weekly-sensor-averages.html    1.17x  sync      51.5 /    60.4 ms
DartComparison/stock-revaluation.html         1.16x  async    314.1 /   364.6 ms
DartComparison/sensor-anomalies.html          1.15x  sync      64.5 /    73.9 ms
DartComparison/bounded-concurrency.html       1.14x  async    312.4 /   356.2 ms
DartComparison/running-balance.html           1.13x  sync     242.1 /   273.9 ms
DartComparison/parallel-downloads.html        1.11x  async    365.7 /   407.8 ms
DartComparison/compound-interest.html         1.11x  sync     222.6 /   247.2 ms
DartComparison/invoice-summary.html           1.09x  sync      25.1 /    27.4 ms
DartComparison/food-spending.html             1.09x  sync      12.4 /    13.5 ms
