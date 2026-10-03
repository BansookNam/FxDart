import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  final cases = <(List<bool>, List<Object>, List<Object>)>[
    ([false, true, false, false, true], [1, 2, 3, 4, 5], [2, 5]),
    ([false, true, false, false, true], [1, 2, 3, 4, 5, 6], [2, 5]),
    ([false, true, false, false, true], [1, 2, 3, 4], [2]),
    ([true, false, false, true, false], 'abcde'.split(''), ['a', 'd']),
  ];

  group('compress', () {
    group('sync', () {
      for (var i = 0; i < cases.length; i++) {
        final (selectors, iterable, result) = cases[i];
        test(
          "should filter elements that have a corresponding element in 'selectors' #$i",
          () {
            final res = fxCompress(selectors, iterable);
            expect(fxToList(res), equals(result));
          },
        );
      }

      test('should be able to be used in the pipeline', () {
        final res = pipe(
          [1, 2, 3, 4, 5],
          [
            (v) => fxCompress([false, true, false, false, true], v),
            (v) => fxToList(v),
          ],
        );

        expect(res, equals([2, 5]));
      });
    });

    group('async', () {
      for (var i = 0; i < cases.length; i++) {
        final (selectors, iterable, result) = cases[i];
        test(
          "should filter elements that have a corresponding element in 'selectors' #$i",
          () async {
            final res = fxCompressAsync(selectors, fxToAsync(iterable));
            expect(await fxToListAsync(res), equals(result));
          },
        );
      }

      test('should be able to be used in the pipeline', () async {
        final res = await fxToListAsync(
          fxCompressAsync([
            false,
            true,
            false,
            false,
            true,
          ], fxToAsync([1, 2, 3, 4, 5])),
        );

        expect(res, equals([2, 5]));
      });
    });
  });
}
