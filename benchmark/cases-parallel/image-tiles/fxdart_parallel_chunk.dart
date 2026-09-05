// 5 of 5 — the same operator, with `chunk` set.
//
// `chunk: k` puts k elements on one message instead of one each, so the
// round trip is paid once per batch. `length ~/ (workers * 16)` leaves every
// worker 16 turns, which is enough to balance uneven elements without
// paying per element.
//
// ~37 us per tile against a ~5 us round trip: the trip is about a tenth of
// the work, so batching has something to take but the default already wins.
import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final tiles = makeTiles();
  final chunk = (n ~/ (benchWorkers * 16)).clamp(1, 1 << 30);
  await bench(
    slug: 'image-tiles',
    impl: 'fxdart-parallel-chunk',
    n: n,
    run: () async => checksum(
      await fx(tiles).parallel(benchWorkers, sharpen, chunk: chunk).toList(),
    ),
  );
}
