import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('findIndex', () {
    group('sync', () {
      test(
        "should return result when passed arguments are synchronous function and 'Iterable'",
        () {
          expect(
            fxFindIndex((String a) => a == 'r', 'marpple'.split('')),
            equals(2),
          );
          expect(fxFindIndex((int a) => a == 2, [1, 2, 3, 4]), equals(1));
          expect(fxFindIndex((int a) => a == 5, [1, 2, 3, 4]), equals(-1));
        },
      );

      test('should be able to be used in the pipeline', () {
        final res1 = fxFindIndex(
          (int a) => a == 14,
          fxFilter(
            (int a) => a % 2 == 0,
            fxMap((int a) => a + 10, [1, 2, 3, 4]),
          ),
        );
        expect(res1, equals(1));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res1 = fx([1, 2, 3, 4])
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .findIndex((a) => a == 14);
        expect(res1, equals(1));
      });
    });

    group('async', () {
      test(
        "should findIndex out the result by the callback to given 'AsyncIterable'",
        () async {
          final res1 = await fxFindIndexAsync(
            (int a) => a == 5,
            fxToAsync([1, 2, 3, 4, 5, 6]),
          );
          expect(res1, equals(4));

          final res2 = await fxFindIndexAsync(
            (int a) => a == 7,
            fxToAsync([1, 2, 3, 4, 5, 6]),
          );
          expect(res2, equals(-1));
        },
      );

      test('should be able to be used in the pipeline', () async {
        final res1 = await fxFindIndexAsync(
          (int a) => a == 14,
          fxFilterAsync(
            (int a) => a % 2 == 0,
            fxMapAsync((int a) => a + 10, fxToAsync([1, 2, 3, 4])),
          ),
        );
        expect(res1, equals(1));
      });

      test(
        'should be able to be used as a chaining method in the `fx`',
        () async {
          final res1 = await fx([1, 2, 3, 4])
              .toAsync()
              .map((a) => a + 10)
              .filter((a) => a % 2 == 0)
              .findIndex((a) => a == 14);
          expect(res1, equals(1));
        },
      );
    });
  });
}
