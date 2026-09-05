// 5 of 5 — the same operator, with `chunk` set.
//
// `chunk: k` puts k elements on one message instead of one each, so the
// round trip is paid once per batch. `length ~/ (workers * 4)` leaves every
// worker 4 turns, which is enough to balance uneven elements without
// paying per element.
//
// ~3.5 us per line against a ~5 us round trip. This is the row the page is
// about: the batch is the difference between losing to a plain loop and
// beating it several times over.
import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final lines = makeLines();
  final chunk = (n ~/ (benchWorkers * 4)).clamp(1, 1 << 30);
  await bench(
    slug: 'log-fingerprint',
    impl: 'fxdart-parallel-chunk',
    n: n,
    run: () async => checksum(
      await fx(lines).parallel(benchWorkers, fingerprint, chunk: chunk).toList(),
    ),
  );
}
