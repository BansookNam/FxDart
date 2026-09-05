// 4 of 5 — the same chain, one operator changed. The default form: every
// element crosses to a worker on its own.
//
// ~37 µs per tile against a ~5 µs round trip. The trip is about a tenth of
// the work: enough to notice, not enough to lose to.
import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final tiles = makeTiles();
  await bench(
    slug: 'image-tiles',
    impl: 'fxdart-parallel',
    n: n,
    run: () async => checksum(
      await fx(tiles).parallel(benchWorkers, sharpen).toList(),
    ),
  );
}
