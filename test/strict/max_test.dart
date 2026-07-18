import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/max.spec.ts.
void main() {
  final cases = <(List<num>, num)>[
    ([3, 4, 5, 1, 6], 6),
    ([0, double.infinity, 3], double.infinity),
    ([0, double.infinity, 3, double.nan], double.nan),
    ([0, 2, 3, double.nan], double.nan),
    (<num>[], -double.infinity),
  ];

  group('max', () {
    group('sync', () {
      for (final (input, result) in cases) {
        test('should return the largest of given iterable $input', () {
          if (result.isNaN) {
            expect(max(input).isNaN, isTrue);
          } else {
            expect(max(input), equals(result));
          }
        });
      }
    });

    group('async', () {
      for (final (input, result) in cases) {
        test('should return the largest of given asyncIterable $input',
            () async {
          final res = await maxAsync(toAsync(input));
          if (result.isNaN) {
            expect(res.isNaN, isTrue);
          } else {
            expect(res, equals(result));
          }
        });
      }
    });
  });
}
