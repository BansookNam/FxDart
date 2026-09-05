// 4 of 5 — the same chain, one operator changed. The default form: every
// element crosses to a worker on its own.
//
// ~3.5 µs of work against a ~5 µs round trip — the trip costs more than the
// trip is for, and no number of workers fixes that. This row is expected to
// lose to the plain loop, and the next one is why that is a tuning problem
// rather than a verdict on the operator.
import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final lines = makeLines();
  await bench(
    slug: 'log-fingerprint',
    impl: 'fxdart-parallel',
    n: n,
    run: () async => checksum(
      await fx(lines).parallel(benchWorkers, fingerprint).toList(),
    ),
  );
}
