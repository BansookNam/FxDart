# Cases where fxdart is slower than native

Ordered by fxdart/native median at the headline scale, slowest first.
Source: benchmark/results/results.json.

Resolved cases (tie or fxdart-faster) have moved to enhancement_example.md.

Note: the ~5% run-to-run noise floor means the tail below ~1.15x is not
reliably ordered. The async cases are bounded by one future per element (see
the 0.7.4 changelog) and are not expected to reach parity on time.

DartComparison/paginated-products.html        2.00x  sync     102.5 /   204.7 ms
DartComparison/paged-feeds-dedupe.html        1.93x  async     82.1 /   158.7 ms
DartComparison/first-visit-merchants.html     1.80x  sync      25.7 /    46.3 ms
DartComparison/anomaly-context.html           1.66x  sync      12.0 /    20.0 ms  <- was 4.00x
DartComparison/recent-errors.html             1.61x  sync      10.2 /    16.6 ms  <- was 2.50x
DartComparison/monthly-category-report.html   1.49x  sync      11.4 /    17.0 ms  <- was 2.17x
DartComparison/stream-windowed-alerts.html    1.48x  async     32.5 /    48.2 ms
DartComparison/live-search.html               1.46x  async     46.9 /    68.6 ms
DartComparison/alert-digest.html              1.44x  sync     174.7 /   251.3 ms  <- was 1.54x
DartComparison/flaky-api-retry.html           1.41x  async    504.5 /   713.3 ms
DartComparison/ledger-diff.html               1.41x  sync     228.9 /   323.5 ms
DartComparison/latency-percentiles.html       1.39x  sync     203.2 /   283.2 ms
DartComparison/consecutive-over-limit.html    1.34x  sync      17.3 /    23.1 ms
DartComparison/rate-limited-import.html       1.29x  async    132.6 /   171.3 ms
DartComparison/budget-alerts.html             1.25x  sync      21.9 /    27.4 ms
DartComparison/concurrent-enrichment.html     1.24x  async    203.6 /   252.3 ms
DartComparison/leaderboard-ties.html          1.21x  sync     544.4 /   661.2 ms
DartComparison/sensor-anomalies.html          1.18x  sync      62.5 /    73.8 ms
DartComparison/parallel-downloads.html        1.17x  async    344.5 /   401.6 ms
DartComparison/running-balance.html           1.14x  sync     238.8 /   271.4 ms
DartComparison/stock-revaluation.html         1.13x  async    321.7 /   363.9 ms
DartComparison/bounded-concurrency.html       1.12x  async    312.8 /   351.8 ms  <- was 1.26x
DartComparison/invoice-summary.html           1.07x  sync      24.9 /    26.6 ms
