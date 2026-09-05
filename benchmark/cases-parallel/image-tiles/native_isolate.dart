// 2 of 5 — hand-rolled isolates: one Isolate.run per slice.
import 'dart:isolate';

import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final tiles = makeTiles();
  await bench(
    slug: 'image-tiles',
    impl: 'native-isolate',
    n: n,
    run: () async {
      final slices = sliceEvenly(tiles, benchWorkers);
      final parts = await Future.wait([
        for (final s in slices) Isolate.run(() => sharpenAll(s)),
      ]);
      return checksum([for (final p in parts) ...p]);
    },
  );
}
