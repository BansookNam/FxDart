import 'dart:math' as math;

import '../async_iterable.dart';
import '../strict/aggregate.dart' show fxToListAsync;

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
/// Port of FxTS `fxShuffle`.
List<T> fxShuffle<T>(Iterable<T> iterable, [int? seed]) =>
    _shuffle(iterable, seed);

// The extension members below share the top-level names, so inside their
// bodies a bare `fxShuffle(...)` would resolve to the member itself.
List<T> _shuffle<T>(Iterable<T> iterable, int? seed) {
  final random = seed != null
      ? createSeededRandom(seed)
      : math.Random().nextDouble;
  return _shuffleList(List.of(iterable), random);
}

/// Async counterpart of [fxShuffle].
Future<List<T>> fxShuffleAsync<T>(FxAsyncIterable<T> iterable, [int? seed]) =>
    _shuffleAsync(iterable, seed);

Future<List<T>> _shuffleAsync<T>(FxAsyncIterable<T> iterable, int? seed) async {
  final random = seed != null
      ? createSeededRandom(seed)
      : math.Random().nextDouble;
  return _shuffleList(await fxToListAsync(iterable), random);
}

/// Method spellings of [fxShuffle] and [fxShuffleAsync].
///
/// Named `fxShuffle`, not `fxShuffle`: `List.shuffle` already exists in
/// `dart:core` and shuffles **in place, returning void**. An extension can
/// never win against it, so a `List` receiver would silently call the wrong
/// one — the prefix makes the two impossible to confuse.
extension FxShuffleEntry<T> on Iterable<T> {
  /// A new list with these elements shuffled. See [fxShuffle].
  List<T> fxShuffle([int? seed]) => _shuffle(this, seed);
}

/// Async counterpart of [FxShuffleEntry].
extension FxShuffleAsyncEntry<T> on FxAsyncIterable<T> {
  /// A new list with these elements shuffled. See [fxShuffleAsync].
  Future<List<T>> fxShuffle([int? seed]) => _shuffleAsync(this, seed);
}
