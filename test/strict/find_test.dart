import 'package:fxdart/fxdart.dart' hide fxIsNull;
import 'package:test/test.dart';

void main() {
  group('find', () {
    group('sync', () {
      test(
        "should return result when passed arguments are synchronous function and 'Iterable'",
        () {
          expect(
            fxFind((String a) => a == 'r', 'marpple'.split('')),
            equals('r'),
          );
          expect(fxFind((int a) => a == 2, [1, 2, 3, 4]), equals(2));
          expect(fxFind((int a) => a == 5, [1, 2, 3, 4]), isNull);
        },
      );

      test('should be able to be used in the pipeline', () {
        final res1 = fxFind(
          (int a) => a == 14,
          fxFilter(
            (int a) => a % 2 == 0,
            fxMap((int a) => a + 10, [1, 2, 3, 4]),
          ),
        );
        expect(res1, equals(14));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res1 = fx([
          1,
          2,
          3,
          4,
        ]).map((a) => a + 10).filter((a) => a % 2 == 0).find((a) => a == 14);
        expect(res1, equals(14));
      });
    });

    group('async', () {
      test(
        "should find out the result by the callback to given 'AsyncIterable'",
        () async {
          final res1 = await fxFindAsync(
            (int a) => a == 5,
            fxToAsync([1, 2, 3, 4, 5, 6]),
          );
          expect(res1, equals(5));

          final res2 = await fxFindAsync(
            (int a) => a == 7,
            fxToAsync([1, 2, 3, 4, 5, 6]),
          );
          expect(res2, isNull);
        },
      );

      test('should be able to be used in the pipeline', () async {
        final res1 = await fxFindAsync(
          (int a) => a == 14,
          fxFilterAsync(
            (int a) => a % 2 == 0,
            fxMapAsync((int a) => a + 10, fxToAsync([1, 2, 3, 4])),
          ),
        );
        expect(res1, equals(14));
      });

      test(
        'should be able to be used as a chaining method in the `fx`',
        () async {
          final res1 = await fx([1, 2, 3, 4])
              .toAsync()
              .map((a) => a + 10)
              .filter((a) => a % 2 == 0)
              .find((a) => a == 14);
          expect(res1, equals(14));
        },
      );
    });
  });
}
