import 'dart:math' as math;

import '../async_iterable.dart';
import '../strict/aggregate.dart' show toArrayAsync;

/// Mulberry32-style seeded PRNG — port of FxTS `_internal/seededRandom.ts`
/// so seeded shuffles are reproducible.
double Function() createSeededRandom(int seed) {
  var state = seed & 0xFFFFFFFF;
  int imul(int a, int b) => ((a & 0xFFFFFFFF) * (b & 0xFFFFFFFF)) & 0xFFFFFFFF;
  return () {
    state = (state + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = imul(state ^ (state >> 15), 1 | state);
    t = (t + imul(t ^ (t >> 7), 61 | t)) ^ t;
    t &= 0xFFFFFFFF;
    return ((t ^ (t >> 14)) & 0xFFFFFFFF) / 4294967296;
  };
}

List<T> _shuffleList<T>(List<T> result, double Function() random) {
  for (var i = result.length - 1; i > 0; i--) {
    final j = (random() * (i + 1)).floor();
    final tmp = result[i];
    result[i] = result[j];
    result[j] = tmp;
  }
  return result;
}

/// Returns a new list with the elements of [iterable] shuffled
/// (Fisher-Yates). Pass [seed] for a reproducible order.
///
/// Port of FxTS `shuffle`.
List<T> shuffle<T>(Iterable<T> iterable, [int? seed]) {
  final random =
      seed != null ? createSeededRandom(seed) : math.Random().nextDouble;
  return _shuffleList(List.of(iterable), random);
}

/// Async counterpart of [shuffle].
Future<List<T>> shuffleAsync<T>(FxAsyncIterable<T> iterable,
    [int? seed]) async {
  final random =
      seed != null ? createSeededRandom(seed) : math.Random().nextDouble;
  return _shuffleList(await toArrayAsync(iterable), random);
}
