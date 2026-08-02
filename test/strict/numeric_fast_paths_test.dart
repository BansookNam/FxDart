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
  });
}
