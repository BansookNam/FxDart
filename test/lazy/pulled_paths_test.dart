// The *pulled* paths of the dedup and set-op stages.
//
// 0.8.5 gave `uniq`/`uniqBy`/`differenceBy`/`intersectionBy` and the fused
// `filter`+`uniq(By)` stages a `toList` that runs one loop and indexes a
// `List` source. Every terminal in the suite goes through that, which left
// the lazy `Iterator` these stages still hand out — the one a plain `for-in`
// or a short-circuiting consumer uses — untested. It is public behaviour, so
// it is pinned here: same elements, same order, and the same laziness as the
// materialised path.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// A non-`List` source, so the stages cannot take their indexed fast path.
Iterable<int> pulled(List<int> xs) sync* {
  yield* xs;
}

void main() {
  group('pulled dedup paths', () {
    test('uniq iterated lazily matches uniq materialised', () {
      final chain = uniq([3, 1, 3, 2, 1]);
      expect([for (final v in chain) v], [3, 1, 2]);
      expect([for (final v in chain) v], chain.toList());
    });

    test('uniqBy iterated lazily matches uniqBy materialised', () {
      final chain = uniqBy((int a) => a % 3, [1, 4, 2, 5, 3]);
      expect([for (final v in chain) v], [1, 2, 3]);
      expect([for (final v in chain) v], chain.toList());
    });

    test('uniq over a pulled source stops when the consumer stops', () {
      final seen = <int>[];
      final chain = uniq(
        pulled([1, 1, 2, 3]).map((a) {
          seen.add(a);
          return a;
        }),
      );
      expect(chain.take(2).toList(), [1, 2]);
      expect(seen, [1, 1, 2], reason: 'the 3 is never pulled');
    });

    test('filter+uniq over a pulled source, iterated lazily', () {
      final chain = uniq(filter((int a) => a < 4, pulled([3, 1, 3, 5, 2, 1])));
      expect([for (final v in chain) v], [3, 1, 2]);
      expect([for (final v in chain) v], chain.toList());
    });

    test('filter+uniqBy over a pulled source, iterated lazily', () {
      final chain = uniqBy(
        (int a) => a % 3,
        filter((int a) => a < 9, pulled([1, 4, 2, 9, 5, 3])),
      );
      expect([for (final v in chain) v], [1, 2, 3]);
      expect([for (final v in chain) v], chain.toList());
    });

    test('filter+uniq(By) is lazy under a take', () {
      final seen = <int>[];
      final chain = uniqBy(
        (int a) => a,
        filter((int a) {
          seen.add(a);
          return true;
        }, [1, 1, 2, 3, 4]),
      );
      expect(chain.take(2).toList(), [1, 2]);
      expect(seen, [1, 1, 2]);
    });

    test('filter+uniqBy toList(growable: false) is fixed length', () {
      final r = uniqBy(
        (int a) => a,
        filter((int a) => a > 1, [1, 2, 2, 3]),
      ).toList(growable: false);
      expect(r, [2, 3]);
      expect(() => r.add(9), throwsUnsupportedError);
    });
  });

  group('pulled set-op paths', () {
    test('differenceBy iterated lazily matches it materialised', () {
      final chain = differenceBy((int a) => a, [1, 2], [2, 3, 4, 3]);
      expect([for (final v in chain) v], [3, 4]);
      expect([for (final v in chain) v], chain.toList());
    });

    test('intersectionBy iterated lazily matches it materialised', () {
      final chain = intersectionBy((int a) => a, [1, 2, 5], [2, 3, 5, 2]);
      expect([for (final v in chain) v], [2, 5]);
      expect([for (final v in chain) v], chain.toList());
    });

    test('the key set is built on the first pull, not on construction', () {
      var scanned = 0;
      final chain = difference(
        pulled([1, 2]).map((a) {
          scanned++;
          return a;
        }),
        [2, 3],
      );
      expect(scanned, 0, reason: 'nothing consumed yet');
      expect(chain.toList(), [3]);
      expect(scanned, 2);
    });

    test('a pulled second source takes the non-indexed branch', () {
      expect(differenceBy((int a) => a, [1, 2], pulled([2, 3, 4])).toList(), [
        3,
        4,
      ]);
      expect(
        intersectionBy((int a) => a, [1, 2], pulled([2, 3, 1])).toList(),
        [2, 1],
      );
    });

    test('set-op toList(growable: false) is fixed length', () {
      final r = differenceBy(
        (int a) => a,
        [1],
        [2, 3],
      ).toList(growable: false);
      expect(r, [2, 3]);
      expect(() => r.add(9), throwsUnsupportedError);
    });

    test('a lazy set-op stops when the consumer stops', () {
      final chain = differenceBy((int a) => a, [1], [2, 3, 4]);
      final it = chain.iterator;
      expect(it.moveNext(), isTrue);
      expect(it.current, 2);
      expect(it.moveNext(), isTrue);
      expect(it.current, 3);
    });
  });
}
