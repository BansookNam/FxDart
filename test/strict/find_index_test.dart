import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('findIndex', () {
    group('sync', () {
      test(
          "should return result when passed arguments are synchronous function and 'Iterable'",
          () {
        expect(
            findIndex((String a) => a == 'r', 'marpple'.split('')), equals(2));
        expect(findIndex((int a) => a == 2, [1, 2, 3, 4]), equals(1));
        expect(findIndex((int a) => a == 5, [1, 2, 3, 4]), equals(-1));
      });

      test('should be able to be used in the pipeline', () {
        final res1 = findIndex(
            (int a) => a == 14,
            filter(
                (int a) => a % 2 == 0, map((int a) => a + 10, [1, 2, 3, 4])));
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
        final res1 = await findIndexAsync(
            (int a) => a == 5, toAsync([1, 2, 3, 4, 5, 6]));
        expect(res1, equals(4));

        final res2 = await findIndexAsync(
            (int a) => a == 7, toAsync([1, 2, 3, 4, 5, 6]));
        expect(res2, equals(-1));
      });

      test('should be able to be used in the pipeline', () async {
        final res1 = await findIndexAsync(
            (int a) => a == 14,
            filterAsync((int a) => a % 2 == 0,
                mapAsync((int a) => a + 10, toAsync([1, 2, 3, 4]))));
        expect(res1, equals(1));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res1 = await fx([1, 2, 3, 4])
            .toAsync()
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .findIndex((a) => a == 14);
        expect(res1, equals(1));
      });
    });
  });
}
