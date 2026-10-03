import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/juxt.spec.ts (Dart's juxt is unary — the variadic
// call sites take a single iterable argument instead).
void main() {
  group('juxt', () {
    test(
      'should return an empty array when the list of functions is absent',
      () {
        final res = fxJuxt<int, Object?>([])(0);
        expect(res, equals(<Object?>[]));
      },
    );

    test('should apply a list of functions to a value', () {
      final res = fxJuxt<Iterable<num>, num>([fxMin, fxMax])([
        1,
        2,
        3,
        -4,
        5,
        6,
        7,
      ]);
      expect(res, equals([-4, 7]));
    });

    test('should be able to be used in the pipeline', () {
      List<(Object?, Object?)> entriesOf(Map<String, int> obj) {
        final r = fxJuxt<Map<String, int>, List<Object?>>([
          (m) => fxToList(fxKeys(m)),
          (m) => fxToList(fxValues(m)),
        ])(obj);
        return fxToList(fxZip(r[0], r[1]));
      }

      final res = entriesOf({'a': 1, 'b': 2});
      expect(res, equals([('a', 1), ('b', 2)]));
    });
  });
}
