import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

int pollsMade = 0;

/// Deterministically flaky, like the example's "ready on the fifth poll":
/// jobs with id % 7 == 3 answer 'pending' until attempt 5; all other jobs
/// are ready on the first poll.
Future<String> pollJob(int id, int attempt) async {
  pollsMade++;
  await Future<void>.delayed(Duration.zero);
  return (id % 7 == 3 && attempt < 5) ? 'pending' : 'ready';
}

Future<void> main() async {
  await bench(
    slug: 'flaky-api-retry',
    impl: 'fxdart',
    n: n,
    run: () async {
      pollsMade = 0; // reset so warmup iterations don't leak into measured ones
      final log = <String>[];
      var attemptSum = 0;
      var ready = 0;
      for (final id in jobIds) {
        final winner = await fx(range(1, 11))
            .toAsync()
            .map((attempt) async => (attempt, await pollJob(id, attempt)))
            .peek((r) => log.add('  poll ${r.$1}: ${r.$2}'))
            .dropWhile((r) => r.$2 != 'ready')
            .head();
        attemptSum += winner!.$1;
        ready++;
      }
      return '$ready/${jobIds.length}|attempts=$attemptSum|'
          'polls=$pollsMade|log=${log.length}';
    },
  );
}
