import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('numeric fast paths', () {
    test('sum over a List<double> (indexed path)', () {
      expect(fxSum(<double>[1.5, 2.5, 3.0]), equals(7.0));
      expect(fxSum(<double>[]), equals(0));
      expect(fxSum(<double>[]), isA<int>());
    });

    test('sum over a plain iterable switching int → double', () {
      expect(fxSum([1, 2, 3.5].where((_) => true)), equals(6.5));
    });

    test('sumBy over a non-list iterable with double keys', () {
      final words = ['a', 'bb', 'ccc'].where((_) => true);
      expect(fxSumBy((String w) => w.length / 2, words), equals(3.0));
      expect(fxSumBy((String w) => w.length, words), equals(6));
    });

    test('average over a List<double> (indexed path)', () {
      expect(fxAverage(<double>[1.0, 2.0, 6.0]), equals(3.0));
      expect(fxAverage(<double>[]), isNaN);
    });

    test('min/max over a List<double> (indexed path)', () {
      expect(fxMin(<double>[3.0, 1.5, 2.0]), equals(1.5));
      expect(fxMax(<double>[3.0, 1.5, 2.0]), equals(3.0));
      expect(fxMin(<double>[3.0, double.nan, 1.5]).isNaN, isTrue);
      expect(fxMax(<double>[3.0, double.nan, 1.5]).isNaN, isTrue);
      expect(fxMin(<double>[]), equals(double.infinity));
      expect(fxMax(<double>[]), equals(-double.infinity));
    });

    test('min/max over a List<int> (indexed path)', () {
      expect(fxMin(<int>[3, 1, 2]), equals(1));
      expect(fxMin(<int>[3, 1, 2]), isA<int>());
      expect(fxMax(<int>[3, 1, 2]), equals(3));
      expect(fxMin(<int>[]), equals(double.infinity));
      expect(fxMax(<int>[]), equals(-double.infinity));
    });

    test('min/max over a non-list iterable (generic path)', () {
      final xs = [3, 1.5, 2].where((_) => true);
      expect(fxMin(xs), equals(1.5));
      expect(fxMax(xs), equals(3));
      expect(fxMin([1, double.nan].where((_) => true)).isNaN, isTrue);
    });
  });

  group('list fast paths', () {
    test('last/nth/size on a List vs a lazy iterable', () {
      expect(fxLast([1, 2, 3]), equals(3));
      expect(fxLast(<int>[]), equals(null));
      expect(fxLast([1, 2, 3].where((_) => true)), equals(3));
      expect(fxNth(1, [1, 2, 3]), equals(2));
      expect(fxNth(5, [1, 2, 3]), equals(null));
      expect(fxNth(-1, [1, 2, 3]), equals(null));
      expect(fxSize([1, 2, 3]), equals(3));
      expect(fxSize({1, 2, 3}), equals(3));
      expect(fxSize([1, 2, 3].where((a) => a > 1)), equals(2));
    });

    test('find/findIndex on a List vs a lazy iterable', () {
      expect(fxFind((int a) => a > 1, [1, 2, 3]), equals(2));
      expect(fxFind((int a) => a > 9, [1, 2, 3]), equals(null));
      expect(fxFind((int a) => a > 1, [1, 2, 3].where((_) => true)), equals(2));
      expect(fxFindIndex((int a) => a > 1, [1, 2, 3]), equals(1));
      expect(fxFindIndex((int a) => a > 9, [1, 2, 3]), equals(-1));
      expect(
        fxFindIndex((int a) => a > 1, [1, 2, 3].where((_) => true)),
        equals(1),
      );
    });

    test('scan(f, seed, list).toList() pre-sized path matches generic', () {
      final growable = fxScan((int acc, int a) => acc + a, 10, [
        1,
        2,
        3,
      ]).toList();
      expect(growable, equals([10, 11, 13, 16]));
      growable.add(0); // stays growable
      expect(
        fxScan((int acc, int a) => acc + a, 10, [
          1,
          2,
          3,
        ]).toList(growable: false),
        equals([10, 11, 13, 16]),
      );
      expect(
        fxScan((int acc, int a) => acc + a, 10, <int>[]).toList(),
        equals([10]),
      );
      // Lazy source falls through to the inherited toList.
      expect(
        fxScan(
          (int acc, int a) => acc + a,
          10,
          [1, 2, 3].where((a) => a > 1),
        ).toList(),
        equals([10, 12, 15]),
      );
    });

    test('scan1(f, list).toList() pre-sized path matches generic', () {
      final growable = fxScan1((int acc, int a) => acc + a, [1, 2, 3]).toList();
      expect(growable, equals([1, 3, 6]));
      growable.add(0); // stays growable
      expect(
        fxScan1((int acc, int a) => acc + a, [1, 2, 3]).toList(growable: false),
        equals([1, 3, 6]),
      );
      expect(
        fxScan1((int acc, int a) => acc + a, <int>[]).toList(),
        equals(<int>[]),
      );
      expect(fxScan1((int acc, int a) => acc + a, [5]).toList(), equals([5]));
      // Lazy source falls through to the inherited toList.
      expect(
        fxScan1(
          (int acc, int a) => acc + a,
          [1, 2, 3].where((a) => a > 1),
        ).toList(),
        equals([2, 5]),
      );
    });

    test('map(f, list).toList() pre-sized path matches the generic path', () {
      final growable = fxMap((int a) => a * 2, [1, 2, 3]).toList();
      expect(growable, equals([2, 4, 6]));
      growable.add(8); // stays growable
      expect(
        fxMap((int a) => a * 2, [1, 2, 3]).toList(growable: false),
        equals([2, 4, 6]),
      );
      expect(fxMap((int a) => a * 2, <int>[]).toList(), equals(<int>[]));
      // Lazy source falls through to the inherited toList.
      expect(
        fxMap((int a) => a * 2, [1, 2, 3].where((a) => a > 1)).toList(),
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
      fxEach(indexed.add, list);
      final pulled = <int>[];
      fxEach(pulled.add, lazy());
      expect(indexed, equals([1, 2, 3, 4]));
      expect(pulled, equals(indexed));
    });

    test('fold and foldWithIndex agree on both paths', () {
      expect(fxFold(0, (int acc, int a) => acc + a, list), equals(10));
      expect(fxFold(0, (int acc, int a) => acc + a, lazy()), equals(10));
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
      expect(fxReduce((int acc, int a) => acc + a, list), equals(10));
      expect(fxReduce((int acc, int a) => acc + a, lazy()), equals(10));
      expect(
        () => fxReduce((int a, int b) => a + b, <int>[]),
        throwsStateError,
      );
      expect(
        () => fxReduce((int a, int b) => a + b, <int>[].where((_) => true)),
        throwsStateError,
      );
    });

    test('every and some short-circuit identically on both paths', () {
      final seen = <int>[];
      bool under3(int a) {
        seen.add(a);
        return a < 3;
      }

      expect(fxEvery(under3, list), isFalse);
      expect(seen, equals([1, 2, 3]));
      seen.clear();
      expect(fxEvery(under3, lazy()), isFalse);
      expect(seen, equals([1, 2, 3]));
      expect(fxEvery((int a) => a > 0, list), isTrue);
      expect(fxEvery((int a) => a > 0, lazy()), isTrue);
      expect(fxSome((int a) => a > 3, list), isTrue);
      expect(fxSome((int a) => a > 3, lazy()), isTrue);
      expect(fxSome((int a) => a > 9, list), isFalse);
      expect(fxSome((int a) => a > 9, lazy()), isFalse);
    });

    test('countWhere agrees on both paths', () {
      expect(fxCountWhere((int a) => a.isEven, list), equals(2));
      expect(fxCountWhere((int a) => a.isEven, lazy()), equals(2));
    });

    test(
      'groupBy, indexBy and countBy keep first-seen order on both paths',
      () {
        String key(int a) => a.isEven ? 'even' : 'odd';
        expect(
          fxGroupBy(key, list),
          equals({
            'odd': [1, 3],
            'even': [2, 4],
          }),
        );
        expect(fxGroupBy(key, lazy()), equals(fxGroupBy(key, list)));
        expect(fxGroupBy(key, list).keys.toList(), equals(['odd', 'even']));
        expect(fxIndexBy(key, list), equals({'odd': 3, 'even': 4}));
        expect(fxIndexBy(key, lazy()), equals(fxIndexBy(key, list)));
        expect(fxIndexBy(key, list).keys.toList(), equals(['odd', 'even']));
        expect(fxCountBy(key, list), equals({'odd': 2, 'even': 2}));
        expect(fxCountBy(key, lazy()), equals(fxCountBy(key, list)));
        expect(fxCountBy(key, list).keys.toList(), equals(['odd', 'even']));
      },
    );

    test('partition splits in source order on both paths', () {
      final (evens, odds) = fxPartition((int a) => a.isEven, list);
      expect(evens, equals([2, 4]));
      expect(odds, equals([1, 3]));
      final (lazyEvens, lazyOdds) = fxPartition((int a) => a.isEven, lazy());
      expect(lazyEvens, equals(evens));
      expect(lazyOdds, equals(odds));
    });

    // The indexed branch reads `length` once, so a source mutated mid-pass no
    // longer reports a concurrent modification. 0.8.6 documents this; pin both
    // directions so a future rewrite back to `for-in` cannot pass silently.
    test('mutating a List source mid-pass no longer reports it', () {
      final growing = [1, 2, 3];
      expect(
        fxFold(0, (int acc, int a) {
          if (growing.length < 6) growing.add(a);
          return acc + a;
        }, growing),
        equals(6),
      );
      expect(growing, equals([1, 2, 3, 1, 2, 3]));

      final shrinking = [1, 2, 3, 4];
      expect(
        () => fxEach((int _) => shrinking.removeLast(), shrinking),
        throwsRangeError,
      );

      final pulled = [1, 2, 3];
      expect(
        () => fxEach((int _) => pulled.add(0), pulled.where((_) => true)),
        throwsConcurrentModificationError,
      );
    });
  });
}
