// 4 of 5 — the same chain, one operator changed. The default form: every
// element crosses to a worker on its own.
//
// ~250 µs per credential dwarfs the ~5 µs round trip, so streaming is
// already the right call here — the trip is noise against the work, and
// every worker stays busy without waiting for a batch to fill.
import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final creds = makeCredentials();
  await bench(
    slug: 'password-rehash',
    impl: 'fxdart-parallel',
    n: n,
    run: () async =>
        checksum(await fx(creds).parallel(benchWorkers, rehash).toList()),
  );
}
