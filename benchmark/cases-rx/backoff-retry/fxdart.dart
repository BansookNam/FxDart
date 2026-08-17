import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

final attemptsFor = <int, int>{};
int totalAttempts = 0;
final backoffMs = <int>[];

/// The FX rate service: ids with id % 7 == 3 are unavailable exactly twice,
/// then serve (the example's failure pattern, per id).
Future<String> fetchRates(int id) async {
  totalAttempts += 1;
  final attempt = (attemptsFor[id] ?? 0) + 1;
  attemptsFor[id] = attempt;
  await Future<void>.delayed(Duration.zero); // example: 10 ms
  if (id % 7 == 3 && attempt < 3) throw StateError('rate service unavailable');
  return 'rates #$id: EUR 0.85, GBP 0.74, JPY 148.20';
}

Future<void> main() async {
  await bench(
    slug: 'backoff-retry',
    impl: 'fxdart',
    n: n,
    run: () async {
      // reset so warmup iterations don't leak into measured ones
      attemptsFor.clear();
      totalAttempts = 0;
      backoffMs.clear();
      var served = 0;
      var last = '';
      for (final id in rateIds) {
        // Backoff is the delay hook: it receives the failure count (1, 2, …)
        // and returns how long to wait before the next attempt.
        final payload = await retry(
          3,
          () => fetchRates(id),
          delay: (failed) {
            final ms = 40 * failed;
            backoffMs.add(ms);
            // Chosen backoff recorded; the wait itself is zeroed (AUTHORING).
            return Duration.zero;
          },
        );
        served++;
        last = payload;
      }
      var backoffSum = 0;
      for (final ms in backoffMs) {
        backoffSum += ms;
      }
      return '$served|attempts=$totalAttempts|'
          'backoffs=${backoffMs.length}|sum=${backoffSum}ms|$last';
    },
  );
}
