// 5 of 5 — the same operator, with `chunk` set.
//
// `chunk: k` puts k elements on one message instead of one each, so the
// round trip is paid once per batch. `length ~/ (workers * 16)` leaves every
// worker 16 turns, which is enough to balance uneven elements without
// paying per element.
//
// ~250 us per credential against a ~5 us round trip: the trip is already
// noise, so the default streaming form is the right one and a batch has
// almost nothing left to save. This row is here to show that.
import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final creds = makeCredentials();
  final chunk = (n ~/ (benchWorkers * 16)).clamp(1, 1 << 30);
  await bench(
    slug: 'password-rehash',
    impl: 'fxdart-parallel-chunk',
    n: n,
    run: () async => checksum(
      await fx(creds).parallel(benchWorkers, rehash, chunk: chunk).toList(),
    ),
  );
}
