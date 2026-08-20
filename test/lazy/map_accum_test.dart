import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// mapAccum is scan without the seed in the output: n values in, n values
// out. The distinction from scan / runningFold is the whole point of the
// operator, so it is pinned directly rather than implied.
//
// A List source fills a pre-sized list in toList; anything else goes through
// the iterator. Both paths are driven.
int _add(int acc, int a) => acc + a;

void main() {
  group('mapAccum', () {
    test('emits one value per input, never the seed', () {
      expect(mapAccum(_add, 0, [1, 2, 3]).toList(), [1, 3, 6]);
    });

    test('emits exactly as many values as the input has', () {
      expect(mapAccum(_add, 0, [1, 2, 3, 4, 5]).length, 5);
    });

    test('scan emits the seed and one more value; mapAccum does not', () {
      expect(scan(_add, 0, [1, 2, 3]).toList(), [0, 1, 3, 6]);
      expect(mapAccum(_add, 0, [1, 2, 3]).toList(), [1, 3, 6]);
    });

    test('is the seed-free spelling of scan().drop(1)', () {
      expect(
        mapAccum(_add, 10, [1, 2, 3]).toList(),
        drop(1, scan(_add, 10, [1, 2, 3])).toList(),
      );
    });

    test('an empty source emits nothing — not even the seed', () {
      expect(mapAccum(_add, 99, <int>[]).toList(), <int>[]);
    });

    test('a single element is the seed folded once', () {
      expect(mapAccum(_add, 10, [5]).toList(), [15]);
    });

    test('a pulled source goes through the iterator', () {
      expect(mapAccum(_add, 0, [1, 2, 3].map((a) => a)).toList(), [1, 3, 6]);
    });

    test('accumulates into a different type than it consumes', () {
      expect(
        mapAccum((String acc, int a) => '$acc$a', '', [1, 2, 3]).toList(),
        ['1', '12', '123'],
      );
    });

    test('is lazy — the callback runs only for the values pulled', () {
      var calls = 0;
      final accumulated = mapAccum(
        (int acc, int a) {
          calls++;
          return acc + a;
        },
        0,
        [1, 2, 3],
      );
      expect(calls, 0);
      expect(accumulated.take(2).toList(), [1, 3]);
      expect(calls, 2);
    });

    test('a second iteration restarts from the seed', () {
      final accumulated = mapAccum(_add, 0, [1, 2, 3].map((a) => a));
      expect(accumulated.toList(), [1, 3, 6]);
      expect(accumulated.toList(), [1, 3, 6]);
    });

    test('a fixed-length toList holds the same values', () {
      expect(mapAccum(_add, 0, [1, 2, 3]).toList(growable: false), [1, 3, 6]);
    });

    test('Fx.mapAccum agrees with the top-level function', () {
      final Fx<int> chained = fx([1, 2, 3]).mapAccum(_add, 0);
      expect(chained.toList(), mapAccum(_add, 0, [1, 2, 3]).toList());
    });
  });

  group('mapAccumAsync', () {
    test('agrees with the sync spelling', () async {
      expect(
        await toListAsync(mapAccumAsync(_add, 0, toAsync([1, 2, 3]))),
        mapAccum(_add, 0, [1, 2, 3]).toList(),
      );
    });

    test('an empty source emits nothing', () async {
      expect(
        await toListAsync(mapAccumAsync(_add, 99, toAsync(<int>[]))),
        <int>[],
      );
    });

    test('awaits an async accumulator step', () async {
      expect(
        await toListAsync(
          mapAccumAsync(
            (int acc, int a) async => acc + a,
            0,
            toAsync([1, 2, 3]),
          ),
        ),
        [1, 3, 6],
      );
    });

    test('awaits a future seed before the first fold', () async {
      expect(
        await toListAsync(
          mapAccumAsync<int, int>(_add, Future.value(10), toAsync([1, 2, 3])),
        ),
        [11, 13, 16],
      );
    });

    test('folds in order even when pulls overlap', () async {
      expect(
        await fxAsync(
          toAsync([1, 2, 3, 4]),
        ).mapAccum((int acc, int a) async => acc + a, 0).concurrent(2).toList(),
        [1, 3, 6, 10],
      );
    });

    test('a second iteration restarts from the seed', () async {
      final accumulated = mapAccumAsync(_add, 0, toAsync([1, 2, 3]));
      expect(await toListAsync(accumulated), [1, 3, 6]);
      expect(await toListAsync(accumulated), [1, 3, 6]);
    });

    test('FxAsync.mapAccum agrees with the top-level function', () async {
      expect(
        await fxAsync(toAsync([1, 2, 3])).mapAccum(_add, 0).toList(),
        mapAccum(_add, 0, [1, 2, 3]).toList(),
      );
    });
  });
}
