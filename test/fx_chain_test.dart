import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Covers the thin delegating members of the `fx` / `fxAsync` chains that the
// per-operator test files exercise only through their top-level functions.
void main() {
  group('Fx chain', () {
    test('to should apply a converter to the whole chain', () {
      final res = fx([1, 2, 3]).to((it) => it.toArray().length);
      expect(res, equals(3));
    });

    test('mapEffect should map like map', () {
      final seen = <int>[];
      final res = fx([1, 2, 3]).mapEffect((a) {
        seen.add(a);
        return a * 2;
      }).toArray();
      expect(res, equals([2, 4, 6]));
      expect(seen, equals([1, 2, 3]));
    });

    test('expand should behave like flatMap', () {
      expect(
        fx([1, 2, 3]).expand((a) => [a, a]).toArray(),
        equals([1, 1, 2, 2, 3, 3]),
      );
    });

    test('where should behave like filter', () {
      expect(fx([1, 2, 3, 4]).where((a) => a.isEven).toArray(), equals([2, 4]));
    });

    test('reject should drop matching elements', () {
      expect(fx([1, 2, 3, 4]).reject((a) => a.isEven).toArray(), equals([1, 3]));
    });

    test('takeRight should keep the last n elements', () {
      expect(fx([1, 2, 3, 4, 5]).takeRight(2).toArray(), equals([4, 5]));
    });

    test('skip should behave like drop', () {
      expect(fx([1, 2, 3, 4]).skip(2).toArray(), equals([3, 4]));
    });

    test('dropRight should drop the last n elements', () {
      expect(fx([1, 2, 3, 4, 5]).dropRight(2).toArray(), equals([1, 2, 3]));
    });

    test('dropWhile should drop the leading matches', () {
      expect(fx([1, 2, 3, 1]).dropWhile((a) => a < 3).toArray(), equals([3, 1]));
    });

    test('skipWhile should behave like dropWhile', () {
      expect(
          fx([1, 2, 3, 1]).skipWhile((a) => a < 3).toArray(), equals([3, 1]));
    });

    test('dropUntil should drop through the first match', () {
      expect(fx([1, 2, 3, 4]).dropUntil((a) => a == 2).toArray(), equals([3, 4]));
    });

    test('zipWithIndex should pair each element with its index', () {
      expect(
        fx(['a', 'b']).zipWithIndex().toArray(),
        equals([(0, 'a'), (1, 'b')]),
      );
    });

    test('scan should emit the seed then the running accumulator', () {
      expect(
        fx([1, 2, 3]).scan<int>((acc, a) => acc + a, 0).toArray(),
        equals([0, 1, 3, 6]),
      );
    });

    test('sort should sort with the comparator', () {
      expect(
        fx([3, 1, 2]).sort((a, b) => a.compareTo(b)).toArray(),
        equals([1, 2, 3]),
      );
    });

    test('sortBy should sort by the selected key', () {
      expect(
        fx([
          {'n': 3},
          {'n': 1},
        ]).sortBy((a) => a['n']).toArray(),
        equals([
          {'n': 1},
          {'n': 3},
        ]),
      );
    });

    test('size should count the elements', () {
      expect(fx([1, 2, 3]).size(), equals(3));
    });

    group('FxNum', () {
      test('sum should add the elements', () {
        expect(fx(<num>[1, 2, 3]).sum(), equals(6));
      });

      test('average should average the elements', () {
        expect(fx(<num>[1, 2, 3]).average(), equals(2));
      });

      test('min should return the smallest element', () {
        expect(fx(<num>[3, 1, 2]).min(), equals(1));
      });

      test('max should return the largest element', () {
        expect(fx(<num>[3, 1, 2]).max(), equals(3));
      });
    });
  });

  group('FxAsync chain', () {
    test('fxStream should wrap a Stream', () async {
      final res = await fxStream(Stream.fromIterable([1, 2, 3]))
          .map((a) => a * 2)
          .toArray();
      expect(res, equals([2, 4, 6]));
    });

    test('to should apply a converter to the whole chain', () async {
      final res = await fxAsync(toAsync([1, 2, 3])).to((it) => it.size());
      expect(res, equals(3));
    });

    test('mapEffect should map like map', () async {
      final seen = <int>[];
      final res = await fxAsync(toAsync([1, 2, 3])).mapEffect((a) {
        seen.add(a);
        return a * 2;
      }).toArray();
      expect(res, equals([2, 4, 6]));
      expect(seen, equals([1, 2, 3]));
    });

    test('zipWithIndex should pair each element with its index', () async {
      expect(
        await fxAsync(toAsync(['a', 'b'])).zipWithIndex().toArray(),
        equals([(0, 'a'), (1, 'b')]),
      );
    });

    test('scan should emit the seed then the running accumulator', () async {
      expect(
        await fxAsync(toAsync([1, 2, 3]))
            .scan<int>((acc, a) => acc + a, 0)
            .toArray(),
        equals([0, 1, 3, 6]),
      );
    });

    test('toStream should emit the chain as a Stream', () async {
      final stream = fxAsync(toAsync([1, 2, 3])).map((a) => a + 1).toStream();
      expect(await stream.toList(), equals([2, 3, 4]));
    });

    test('fold should reduce with a seed', () async {
      final res = await fxAsync(toAsync([1, 2, 3]))
          .fold<int>(10, (acc, a) => acc + a);
      expect(res, equals(16));
    });

    test('last should return the final element', () async {
      expect(await fxAsync(toAsync([1, 2, 3])).last(), equals(3));
      expect(await fxAsync(toAsync(<int>[])).last(), isNull);
    });

    test('sort should sort with the comparator', () async {
      expect(
        await fxAsync(toAsync([3, 1, 2])).sort((a, b) => a.compareTo(b)),
        equals([1, 2, 3]),
      );
    });

    test('sortBy should sort by the selected key', () async {
      expect(
        await fxAsync(toAsync([
          {'n': 3},
          {'n': 1},
        ])).sortBy((a) => a['n']),
        equals([
          {'n': 1},
          {'n': 3},
        ]),
      );
    });

    test('size should count the elements', () async {
      expect(await fxAsync(toAsync([1, 2, 3])).size(), equals(3));
    });

    group('FxAsyncNum', () {
      test('sum should add the elements', () async {
        expect(await fxAsync(toAsync(<num>[1, 2, 3])).sum(), equals(6));
      });

      test('average should average the elements', () async {
        expect(await fxAsync(toAsync(<num>[1, 2, 3])).average(), equals(2));
      });

      test('min should return the smallest element', () async {
        expect(await fxAsync(toAsync(<num>[3, 1, 2])).min(), equals(1));
      });

      test('max should return the largest element', () async {
        expect(await fxAsync(toAsync(<num>[3, 1, 2])).max(), equals(3));
      });
    });
  });
}
