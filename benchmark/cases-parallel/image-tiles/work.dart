// The per-element job, shared verbatim by all four variants.
//
// The middle of the three: ~40 µs per tile, so the round trip is a tenth of
// the work rather than all of it or none of it.

import 'dart:typed_data';

/// One 32×32 greyscale tile of a larger image.
class Tile {
  const Tile(this.index, this.pixels);
  final int index;
  final Uint8List pixels;
}

/// What the filter produced: the tile's index and its summary statistics.
class TileStats {
  const TileStats(this.index, this.edgeEnergy, this.mean);
  final int index;
  final int edgeEnergy;
  final int mean;
}

const tileSide = 32;

/// How many filter passes each tile gets. A sharpen stage runs a stack of
/// them in any real pipeline; eight puts one tile at ~42 µs, which is the
/// middle of the three cases — several times the ~5 µs isolate round trip,
/// but not the 100x that [password-rehash] has.
const passes = 8;

/// A 3×3 Sobel pass over the tile, reduced to two numbers. Real image work:
/// every output pixel reads nine inputs, so it is memory-bound in a way a
/// synthetic spin loop is not.
TileStats sharpen(Tile tile) {
  final p = tile.pixels;
  var energy = 0;
  var sum = 0;
  for (var pass = 0; pass < passes; pass++) {
    (energy, sum) = _pass(p, energy, sum);
  }
  final inner = (tileSide - 2) * (tileSide - 2);
  return TileStats(tile.index, energy, sum ~/ (inner * passes));
}

(int, int) _pass(Uint8List p, int energy, int sum) {
  for (var y = 1; y < tileSide - 1; y++) {
    final row = y * tileSide;
    for (var x = 1; x < tileSide - 1; x++) {
      final i = row + x;
      final gx =
          -p[i - tileSide - 1] +
          p[i - tileSide + 1] -
          2 * p[i - 1] +
          2 * p[i + 1] -
          p[i + tileSide - 1] +
          p[i + tileSide + 1];
      final gy =
          -p[i - tileSide - 1] -
          2 * p[i - tileSide] -
          p[i - tileSide + 1] +
          p[i + tileSide - 1] +
          2 * p[i + tileSide] +
          p[i + tileSide + 1];
      energy += (gx < 0 ? -gx : gx) + (gy < 0 ? -gy : gy);
      sum += p[i];
    }
  }
  return (energy, sum);
}

/// The same job over a slice, for the hand-rolled isolate variant.
List<TileStats> sharpenAll(List<Tile> batch) => [
  for (final t in batch) sharpen(t),
];
