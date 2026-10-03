import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

bool _isEven(int a) => a % 2 == 0;

void main() {
  group('every', () {
    group('sync', () {
      test('should return result for each input', () {
        expect(fxEvery(_isEven, <int>[]), isTrue);
        expect(fxEvery(_isEven, [2, 4, 6, 8, 10]), isTrue);
        expect(fxEvery(_isEven, [1, 4, 6, 8, 10]), isFalse);
        expect(fxEvery(_isEven, [2, 4, 7, 8, 10]), isFalse);
        expect(fxEvery(_isEven, [2, 4, 6, 8, 11]), isFalse);
      });

      test('should be able to be used in the pipeline', () {
        final res1 = fxEvery(
          _isEven,
          fxFilter(_isEven, [1, 2, 3, 4, 5, 6, 7, 8, 9]),
        );
        expect(res1, isTrue);

        final res2 = fxEvery(
          (int a) => a > 10,
          fxMap((int a) => a + 10, [1, 2, 3, 4, 5, 6, 7, 8, 9]),
        );
        expect(res2, isTrue);

        final res3 = fxEvery(
          (int a) => a < 10,
          fxMap((int a) => a + 10, [1, 2, 3, 4, 5, 6, 7, 8, 9]),
        );
        expect(res3, isFalse);
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res1 = fx([
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9,
        ]).filter(_isEven).every(_isEven);
        expect(res1, isTrue);

        final res2 = fx([
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9,
        ]).map((a) => a + 10).every((a) => a > 10);
        expect(res2, isTrue);

        final res3 = fx([
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9,
        ]).map((a) => a + 10).every((a) => a < 10);
        expect(res3, isFalse);
      });
    });

    group('async', () {
      test(
        "should return result when passed arguments are synchronous function and 'AsyncIterable'",
        () async {
          expect(
            await fxEveryAsync(_isEven, fxToAsync([2, 4, 6, 8, 10])),
            isTrue,
          );
          expect(
            await fxEveryAsync(_isEven, fxToAsync([1, 4, 6, 8, 10])),
            isFalse,
          );
          expect(
            await fxEveryAsync(_isEven, fxToAsync([2, 4, 7, 8, 10])),
            isFalse,
          );
          expect(
            await fxEveryAsync(_isEven, fxToAsync([2, 4, 6, 8, 11])),
            isFalse,
          );
        },
      );

      test('should be able to be used in the pipeline', () async {
        final res1 = await fxEveryAsync(
          _isEven,
          fxFilterAsync(_isEven, fxToAsync([1, 2, 3, 4, 5, 6, 7, 8, 9])),
        );
        expect(res1, isTrue);

        final res2 = await fxEveryAsync(
          (int a) => a > 10,
          fxMapAsync((int a) => a + 10, fxToAsync([1, 2, 3, 4, 5, 6, 7, 8, 9])),
        );
        expect(res2, isTrue);

        final res3 = await fxEveryAsync(
          (int a) => a < 10,
          fxMapAsync((int a) => a + 10, fxToAsync([1, 2, 3, 4, 5, 6, 7, 8, 9])),
        );
        expect(res3, isFalse);
      });

      test(
        'should be able to be used as a chaining method in the `fx`',
        () async {
          final res1 = await fx([
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
          ]).toAsync().filter(_isEven).every(_isEven);
          expect(res1, isTrue);

          final res2 = await fx([
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
          ]).toAsync().map((a) => a + 10).every((a) => a > 10);
          expect(res2, isTrue);

          final res3 = await fx([
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
          ]).toAsync().map((a) => a + 10).every((a) => a < 10);
          expect(res3, isFalse);
        },
      );
    });
  });
}
