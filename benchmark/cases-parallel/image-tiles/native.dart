// 1 of 5 — a plain loop. One isolate, no chain. The baseline.
import '../../harness.dart';
import 'data.dart';
import 'work.dart';

Future<void> main() async {
  final tiles = makeTiles();
  await bench(
    slug: 'image-tiles',
    impl: 'native',
    n: n,
    run: () {
      final out = <TileStats>[];
      for (final t in tiles) {
        out.add(sharpen(t));
      }
      return checksum(out);
    },
  );
}
