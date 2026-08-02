import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

final attemptsFor = <int, int>{};
int totalAttempts = 0;

/// The release manifest endpoint: ids with id % 7 == 3 reset the connection
/// exactly twice, then serve the payload (the example's failure pattern,
/// per id).
Future<String> fetchManifest(int id) async {
  totalAttempts += 1;
  final attempt = (attemptsFor[id] ?? 0) + 1;
  attemptsFor[id] = attempt;
  await Future<void>.delayed(Duration.zero); // example: 15 ms
  if (id % 7 == 3 && attempt < 3) throw StateError('connection reset');
  return 'manifest #$id (12 entries)';
}

Future<void> main() async {
  await bench(
    slug: 'retry-the-fetch',
    impl: 'fxdart',
    n: n,
    run: () async {
      // reset so warmup iterations don't leak into measured ones
      attemptsFor.clear();
      totalAttempts = 0;
      var fetched = 0;
      var last = '';
      for (final id in manifestIds) {
        // retry re-runs the function — up to 3 attempts in total, rethrowing
        // the last error once the budget is spent.
        final payload = await retry(3, () => fetchManifest(id));
        fetched++;
        last = payload;
      }
      return '$fetched|attempts=$totalAttempts|$last';
    },
  );
}
