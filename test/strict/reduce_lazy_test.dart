import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/Lazy/reduceLazy.spec.ts. The Dart `reduceLazy`
// always takes a seed and works over sync iterables only, so the unseeded
// and async sections are not portable.
int addNumber(int a, int b) => a + b;

void main() {
  group('reduceLazy', () {
    group('sync', () {
      test('should return initial value when the given iterable is empty', () {
        final reduce = reduceLazy((String a, Object? b) => a, 'seed');
        expect(reduce(<Object?>[]), equals('seed'));
      });

      test('should work given it is initial value', () {
        final reduce = reduceLazy(addNumber, 10);
        expect(reduce(range(1, 6)), equals(25));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe([
          '1',
          '2',
          '3',
          '4',
          '5'
        ], [
          (Iterable<String> a) => map(int.parse, a),
          (Iterable<int> a) => filter((int n) => n % 2 == 1, a),
          reduceLazy(addNumber, 0),
        ]);
        expect(res, equals(1 + 3 + 5));
      });
    });
  });
}
