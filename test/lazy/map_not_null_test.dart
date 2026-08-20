import 'package:fxdart/fxdart.dart' hide isEmpty, isNull;
import 'package:test/test.dart';

// mapNotNull is a filter-map: `f` both transforms and selects, and a null
// projection means "skip", never "yield null". The list source and the pulled
// source are separate iterators, so both are driven here.
void main() {
  group('mapNotNull', () {
    group('sync', () {
      test('skips the elements f maps to null', () {
        expect(
          mapNotNull((String s) => int.tryParse(s), ['1', 'x', '3', 'y']),
          [1, 3],
        );
      });

      test('a null projection is skipped, not yielded as null', () {
        final out = mapNotNull((int a) => a.isEven ? a * 10 : null, [
          1,
          2,
          3,
          4,
        ]).toList();
        expect(out, [20, 40]);
        expect(out, isNot(contains(null)));
      });

      test('empty input yields nothing', () {
        expect(mapNotNull((int a) => a, <int>[]), isEmpty);
      });

      test('single element, kept and dropped', () {
        expect(mapNotNull((int a) => a * 2, [21]), [42]);
        expect(mapNotNull((int a) => null, [21]), isEmpty);
      });

      test('every projection null yields nothing', () {
        expect(mapNotNull((int a) => null, [1, 2, 3]), isEmpty);
      });

      test('a non-list source is pulled through its iterator', () {
        expect(
          mapNotNull(
            (int a) => a.isOdd ? 'o$a' : null,
            Iterable<int>.generate(5),
          ),
          ['o1', 'o3'],
        );
      });

      test('agrees with compact(map(f, xs)) on both source shapes', () {
        String? f(int a) => a % 3 == 0 ? 'x$a' : null;
        final list = [1, 2, 3, 4, 5, 6];
        expect(mapNotNull(f, list), compact(map(f, list)));
        final pulled = Iterable<int>.generate(7);
        expect(mapNotNull(f, pulled), compact(map(f, pulled)));
      });

      test('is lazy: f runs only for the elements consumed', () {
        var calls = 0;
        final it = mapNotNull((int a) {
          calls++;
          return a;
        }, [1, 2, 3, 4, 5]);
        expect(calls, 0);
        expect(take(2, it), [1, 2]);
        expect(calls, 2);
      });

      test('is re-iterable, and re-runs f per iteration', () {
        var calls = 0;
        final it = mapNotNull((int a) {
          calls++;
          return a.isEven ? a : null;
        }, [1, 2, 3, 4]);
        expect(it.toList(), [2, 4]);
        expect(it.toList(), [2, 4]);
        expect(calls, 8);
      });
    });

    group('async', () {
      test('agrees with the sync spelling', () async {
        int? f(String s) => int.tryParse(s);
        final input = ['1', 'x', '3', 'y'];
        expect(
          await toListAsync(mapNotNullAsync(f, toAsync(input))),
          mapNotNull(f, input),
        );
      });

      test('awaits an async projection and skips its nulls', () async {
        final res = await toListAsync(
          mapNotNullAsync(
            (int a) async => a.isEven ? a * 10 : null,
            toAsync([1, 2, 3, 4]),
          ),
        );
        expect(res, [20, 40]);
      });

      test('empty input yields nothing', () async {
        expect(
          await toListAsync(mapNotNullAsync((int a) => a, toAsync(<int>[]))),
          isEmpty,
        );
      });

      test('every projection null yields nothing', () async {
        expect(
          await toListAsync(
            mapNotNullAsync((int a) => null, toAsync([1, 2, 3])),
          ),
          isEmpty,
        );
      });
    });

    group('chain', () {
      test('Fx.mapNotNull agrees with the top-level function', () {
        int? f(String s) => int.tryParse(s);
        final input = ['1', 'x', '3'];
        expect(fx(input).mapNotNull(f).toList(), mapNotNull(f, input).toList());
      });

      test('FxAsync.mapNotNull agrees with the top-level function', () async {
        int? f(String s) => int.tryParse(s);
        final input = ['1', 'x', '3'];
        expect(
          await fxAsync(toAsync(input)).mapNotNull(f).toList(),
          mapNotNull(f, input).toList(),
        );
      });

      test('composes inside a chain', () {
        expect(
          fx([
            '1',
            'x',
            '2',
            'y',
            '3',
          ]).mapNotNull((s) => int.tryParse(s)).filter((a) => a.isOdd).toList(),
          [1, 3],
        );
      });
    });
  });
}
