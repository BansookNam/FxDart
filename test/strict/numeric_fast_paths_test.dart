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
      expect(findIndex((int a) => a > 1, [1, 2, 3].where((_) => true)),
          equals(1));
    });

    test('map(f, list).toList() pre-sized path matches the generic path', () {
      final growable = map((int a) => a * 2, [1, 2, 3]).toList();
      expect(growable, equals([2, 4, 6]));
      growable.add(8); // stays growable
      expect(map((int a) => a * 2, [1, 2, 3]).toList(growable: false),
          equals([2, 4, 6]));
      expect(map((int a) => a * 2, <int>[]).toList(), equals(<int>[]));
      // Lazy source falls through to the inherited toList.
      expect(map((int a) => a * 2, [1, 2, 3].where((a) => a > 1)).toList(),
          equals([4, 6]));
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
}
