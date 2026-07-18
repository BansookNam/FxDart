import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

bool _isEven(int a) => a % 2 == 0;

void main() {
  group('every', () {
    group('sync', () {
      test('should return result for each input', () {
        expect(every(_isEven, <int>[]), isTrue);
        expect(every(_isEven, [2, 4, 6, 8, 10]), isTrue);
        expect(every(_isEven, [1, 4, 6, 8, 10]), isFalse);
        expect(every(_isEven, [2, 4, 7, 8, 10]), isFalse);
        expect(every(_isEven, [2, 4, 6, 8, 11]), isFalse);
      });

      test('should be able to be used in the pipeline', () {
        final res1 =
            every(_isEven, filter(_isEven, [1, 2, 3, 4, 5, 6, 7, 8, 9]));
        expect(res1, isTrue);

        final res2 = every((int a) => a > 10,
            map((int a) => a + 10, [1, 2, 3, 4, 5, 6, 7, 8, 9]));
        expect(res2, isTrue);

        final res3 = every((int a) => a < 10,
            map((int a) => a + 10, [1, 2, 3, 4, 5, 6, 7, 8, 9]));
        expect(res3, isFalse);
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res1 =
            fx([1, 2, 3, 4, 5, 6, 7, 8, 9]).filter(_isEven).every(_isEven);
        expect(res1, isTrue);

        final res2 = fx([1, 2, 3, 4, 5, 6, 7, 8, 9])
            .map((a) => a + 10)
            .every((a) => a > 10);
        expect(res2, isTrue);

        final res3 = fx([1, 2, 3, 4, 5, 6, 7, 8, 9])
            .map((a) => a + 10)
            .every((a) => a < 10);
        expect(res3, isFalse);
      });
    });

    group('async', () {
      test(
          "should return result when passed arguments are synchronous function and 'AsyncIterable'",
          () async {
        expect(await everyAsync(_isEven, toAsync([2, 4, 6, 8, 10])), isTrue);
        expect(await everyAsync(_isEven, toAsync([1, 4, 6, 8, 10])), isFalse);
        expect(await everyAsync(_isEven, toAsync([2, 4, 7, 8, 10])), isFalse);
        expect(await everyAsync(_isEven, toAsync([2, 4, 6, 8, 11])), isFalse);
      });

      test('should be able to be used in the pipeline', () async {
        final res1 = await everyAsync(_isEven,
            filterAsync(_isEven, toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9])));
        expect(res1, isTrue);

        final res2 = await everyAsync((int a) => a > 10,
            mapAsync((int a) => a + 10, toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9])));
        expect(res2, isTrue);

        final res3 = await everyAsync((int a) => a < 10,
            mapAsync((int a) => a + 10, toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9])));
        expect(res3, isFalse);
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res1 = await fx([1, 2, 3, 4, 5, 6, 7, 8, 9])
            .toAsync()
            .filter(_isEven)
            .every(_isEven);
        expect(res1, isTrue);

        final res2 = await fx([1, 2, 3, 4, 5, 6, 7, 8, 9])
            .toAsync()
            .map((a) => a + 10)
            .every((a) => a > 10);
        expect(res2, isTrue);

        final res3 = await fx([1, 2, 3, 4, 5, 6, 7, 8, 9])
            .toAsync()
            .map((a) => a + 10)
            .every((a) => a < 10);
        expect(res3, isFalse);
      });
    });
  });
}
