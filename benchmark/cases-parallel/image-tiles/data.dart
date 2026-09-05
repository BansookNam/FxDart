// Deterministic tile set. Sized so the plain loop runs ~5 s.
import 'dart:typed_data';

import '../../harness.dart';
import 'work.dart';

final n = caseN(147000);

List<Tile> makeTiles() {
  final rng = Lcg(13);
  return List.generate(n, (i) {
    final px = Uint8List(tileSide * tileSide);
    // A soft gradient with noise on top, so the Sobel pass has real edges to
    // find rather than a constant field it could be optimised away over.
    for (var y = 0; y < tileSide; y++) {
      for (var x = 0; x < tileSide; x++) {
        final base = (x * 5 + y * 3 + i) & 0xFF;
        px[y * tileSide + x] = (base + rng.nextInt(24)) & 0xFF;
      }
    }
    return Tile(i, px);
  });
}

/// One number all five variants must agree on.
int checksum(List<TileStats> out) {
  var acc = 0;
  for (final s in out) {
    acc = (acc * 31 + s.edgeEnergy + s.mean) & 0x1FFFFFFFFFFFFF;
  }
  return acc;
}
