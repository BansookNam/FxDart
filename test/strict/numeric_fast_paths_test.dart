import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('numeric fast paths', () {
    test('sum over a List<double> (indexed path)', () {
      expect(sum(<double>[1.5, 2.5, 3.0]), equals(7.0));
      expect(sum(<double>[]), equals(0));
      expect(sum(<double>[]), isA<int>());
    });

    test('sum over a plain iterable switching int → double', () {
      expect(sum([1, 2, 3.5].where((_) => true)), equals(6.5));
    });

    test('sumBy over a non-list iterable with double keys', () {
      final words = ['a', 'bb', 'ccc'].where((_) => true);
      expect(sumBy((String w) => w.length / 2, words), equals(3.0));
      expect(sumBy((String w) => w.length, words), equals(6));
    });

    test('average over a List<double> (indexed path)', () {
      expect(average(<double>[1.0, 2.0, 6.0]), equals(3.0));
      expect(average(<double>[]), isNaN);
    });

    test('min/max over a List<double> (indexed path)', () {
      expect(min(<double>[3.0, 1.5, 2.0]), equals(1.5));
      expect(max(<double>[3.0, 1.5, 2.0]), equals(3.0));
      expect(min(<double>[3.0, double.nan, 1.5]).isNaN, isTrue);
      expect(max(<double>[3.0, double.nan, 1.5]).isNaN, isTrue);
      expect(min(<double>[]), equals(double.infinity));
      expect(max(<double>[]), equals(-double.infinity));
    });

    test('min/max over a List<int> (indexed path)', () {
      expect(min(<int>[3, 1, 2]), equals(1));
      expect(min(<int>[3, 1, 2]), isA<int>());
      expect(max(<int>[3, 1, 2]), equals(3));
      expect(min(<int>[]), equals(double.infinity));
      expect(max(<int>[]), equals(-double.infinity));
    });

    test('min/max over a non-list iterable (generic path)', () {
      final xs = [3, 1.5, 2].where((_) => true);
      expect(min(xs), equals(1.5));
      expect(max(xs), equals(3));
      expect(min([1, double.nan].where((_) => true)).isNaN, isTrue);
    });
  });

  group('list fast paths', () {
    test('last/nth/size on a List vs a lazy iterable', () {
      expect(last([1, 2, 3]), equals(3));
      expect(last(<int>[]), equals(null));
      expect(last([1, 2, 3].where((_) => true)), equals(3));
      expect(nth(1, [1, 2, 3]), equals(2));
      expect(nth(5, [1, 2, 3]), equals(null));
      expect(nth(-1, [1, 2, 3]), equals(null));
      expect(size([1, 2, 3]), equals(3));
      expect(size({1, 2, 3}), equals(3));
      expect(size([1, 2, 3].where((a) => a > 1)), equals(2));
    });

    test('find/findIndex on a List vs a lazy iterable', () {
      expect(find((int a) => a > 1, [1, 2, 3]), equals(2));
      expect(find((int a) => a > 9, [1, 2, 3]), equals(null));
      expect(find((int a) => a > 1, [1, 2, 3].where((_) => true)), equals(2));
      expect(findIndex((int a) => a > 1, [1, 2, 3]), equals(1));
      expect(findIndex((int a) => a > 9, [1, 2, 3]), equals(-1));
      expect(
        findIndex((int a) => a > 1, [1, 2, 3].where((_) => true)),
        equals(1),
      );
    });

    test('scan(f, seed, list).toList() pre-sized path matches generic', () {
      final growable = scan((int acc, int a) => acc + a, 10, [
        1,
        2,
        3,
      ]).toList();
      expect(growable, equals([10, 11, 13, 16]));
      growable.add(0); // stays growable
      expect(
        scan((int acc, int a) => acc + a, 10, [
          1,
          2,
          3,
        ]).toList(growable: false),
        equals([10, 11, 13, 16]),
      );
      expect(
        scan((int acc, int a) => acc + a, 10, <int>[]).toList(),
        equals([10]),
      );
      // Lazy source falls through to the inherited toList.
      expect(
        scan(
          (int acc, int a) => acc + a,
          10,
          [1, 2, 3].where((a) => a > 1),
        ).toList(),
        equals([10, 12, 15]),
      );
    });

    test('scan1(f, list).toList() pre-sized path matches generic', () {
      final growable = scan1((int acc, int a) => acc + a, [1, 2, 3]).toList();
      expect(growable, equals([1, 3, 6]));
      growable.add(0); // stays growable
      expect(
        scan1((int acc, int a) => acc + a, [1, 2, 3]).toList(growable: false),
        equals([1, 3, 6]),
      );
      expect(
        scan1((int acc, int a) => acc + a, <int>[]).toList(),
        equals(<int>[]),
      );
      expect(scan1((int acc, int a) => acc + a, [5]).toList(), equals([5]));
      // Lazy source falls through to the inherited toList.
      expect(
        scan1(
          (int acc, int a) => acc + a,
          [1, 2, 3].where((a) => a > 1),
        ).toList(),
        equals([2, 5]),
      );
    });

    test('map(f, list).toList() pre-sized path matches the generic path', () {
      final growable = map((int a) => a * 2, [1, 2, 3]).toList();
      expect(growable, equals([2, 4, 6]));
      growable.add(8); // stays growable
      expect(
        map((int a) => a * 2, [1, 2, 3]).toList(growable: false),
        equals([2, 4, 6]),
      );
      expect(map((int a) => a * 2, <int>[]).toList(), equals(<int>[]));
      // Lazy source falls through to the inherited toList.
      expect(
        map((int a) => a * 2, [1, 2, 3].where((a) => a > 1)).toList(),
        equals([4, 6]),
      );
    });

    test('fx(list) delegates length/first/last/elementAt/contains', () {
      final chain = fx([1, 2, 3]);
      expect(chain.length, equals(3));
      expect(chain.first, equals(1));
      expect(chain.last, equals(3));
      expect(() => chain.single, throwsStateError);
      expect(chain.elementAt(1), equals(2));
      expect(chain.contains(2), isTrue);
      expect(chain.isEmpty, isFalse);
      expect(chain.isNotEmpty, isTrue);
    });
  });

  // Every terminal below grew an indexed branch beside its pulled one. The two
  // loops are written separately, so a divergence between them is exactly the
  // bug these cases catch.
  group('strict terminal list fast paths', () {
    final list = [1, 2, 3, 4];
    Iterable<int> lazy() => list.where((_) => true);

    test('each visits every element in order on both paths', () {
      final indexed = <int>[];
      each(indexed.add, list);
      final pulled = <int>[];
      each(pulled.add, lazy());
      expect(indexed, equals([1, 2, 3, 4]));
      expect(pulled, equals(indexed));
    });

    test('fold and foldWithIndex agree on both paths', () {
      expect(fold(0, (int acc, int a) => acc + a, list), equals(10));
      expect(fold(0, (int acc, int a) => acc + a, lazy()), equals(10));
      expect(
        foldWithIndex(0, (int acc, int a, int i) => acc + a * i, list),
        equals(20),
      );
      expect(
        foldWithIndex(0, (int acc, int a, int i) => acc + a * i, lazy()),
        equals(20),
      );
    });

    test('reduce agrees on both paths and still throws when empty', () {
      expect(reduce((int acc, int a) => acc + a, list), equals(10));
      expect(reduce((int acc, int a) => acc + a, lazy()), equals(10));
      expect(() => reduce((int a, int b) => a + b, <int>[]), throwsStateError);
      expect(
        () => reduce((int a, int b) => a + b, <int>[].where((_) => true)),
        throwsStateError,
      );
    });

    test('every and some short-circuit identically on both paths', () {
      final seen = <int>[];
      bool under3(int a) {
        seen.add(a);
        return a < 3;
      }

      expect(every(under3, list), isFalse);
      expect(seen, equals([1, 2, 3]));
      seen.clear();
      expect(every(under3, lazy()), isFalse);
      expect(seen, equals([1, 2, 3]));
      expect(every((int a) => a > 0, list), isTrue);
      expect(every((int a) => a > 0, lazy()), isTrue);
      expect(some((int a) => a > 3, list), isTrue);
      expect(some((int a) => a > 3, lazy()), isTrue);
      expect(some((int a) => a > 9, list), isFalse);
      expect(some((int a) => a > 9, lazy()), isFalse);
    });

    test('countWhere agrees on both paths', () {
      expect(countWhere((int a) => a.isEven, list), equals(2));
      expect(countWhere((int a) => a.isEven, lazy()), equals(2));
    });

    test(
      'groupBy, indexBy and countBy keep first-seen order on both paths',
      () {
        String key(int a) => a.isEven ? 'even' : 'odd';
        expect(
          groupBy(key, list),
          equals({
            'odd': [1, 3],
            'even': [2, 4],
          }),
        );
        expect(groupBy(key, lazy()), equals(groupBy(key, list)));
        expect(groupBy(key, list).keys.toList(), equals(['odd', 'even']));
        expect(indexBy(key, list), equals({'odd': 3, 'even': 4}));
        expect(indexBy(key, lazy()), equals(indexBy(key, list)));
        expect(indexBy(key, list).keys.toList(), equals(['odd', 'even']));
        expect(countBy(key, list), equals({'odd': 2, 'even': 2}));
        expect(countBy(key, lazy()), equals(countBy(key, list)));
        expect(countBy(key, list).keys.toList(), equals(['odd', 'even']));
      },
    );

    test('partition splits in source order on both paths', () {
      final (evens, odds) = partition((int a) => a.isEven, list);
      expect(evens, equals([2, 4]));
      expect(odds, equals([1, 3]));
      final (lazyEvens, lazyOdds) = partition((int a) => a.isEven, lazy());
      expect(lazyEvens, equals(evens));
      expect(lazyOdds, equals(odds));
    });

    // The indexed branch reads `length` once, so a source mutated mid-pass no
    // longer reports a concurrent modification. 0.8.6 documents this; pin both
    // directions so a future rewrite back to `for-in` cannot pass silently.
    test('mutating a List source mid-pass no longer reports it', () {
      final growing = [1, 2, 3];
      expect(
        fold(0, (int acc, int a) {
          if (growing.length < 6) growing.add(a);
          return acc + a;
        }, growing),
        equals(6),
      );
      expect(growing, equals([1, 2, 3, 1, 2, 3]));

      final shrinking = [1, 2, 3, 4];
      expect(
        () => each((int _) => shrinking.removeLast(), shrinking),
        throwsRangeError,
      );

      final pulled = [1, 2, 3];
      expect(
        () => each((int _) => pulled.add(0), pulled.where((_) => true)),
        throwsConcurrentModificationError,
      );
    });
  });
}
