import 'package:fxdart/fxdart.dart' hide isNull;
import 'package:test/test.dart';

void main() {
  group('head', () {
    group('sync', () {
      test("should return first item of the given 'Iterable'", () {
        final result = head(range(5));
        expect(result, equals(0));
      });

      test("should return first item of the given 'Iterable' - array", () {
        final res = head([1, 2, 3, 4]);
        expect(res, equals(1));
      });

      test("should return first item of the given 'Iterable' - string chars",
          () {
        final result = head('marpple'.split(''));
        expect(result, equals('m'));
      });

      test('should be able to be used in the pipeline', () {
        final res1 = head(filter(
            (int a) => a % 2 == 0, map((int a) => a + 10, [1, 2, 3, 4])));
        expect(res1, equals(12));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res1 = fx([1, 2, 3]).head();
        expect(res1, equals(1));

        final res2 = fx(<int>[]).head();
        expect(res2, isNull);
      });
    });

    group('async', () {
      test("should return first item of the given 'AsyncIterable'", () async {
        final res = await headAsync(toAsync([1, 2, 3, 4]));
        expect(res, equals(1));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await headAsync(filterAsync((int a) => a % 2 == 0,
            mapAsync((int a) => a + 10, toAsync([1, 2, 3, 4]))));
        expect(res, equals(12));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res1 = await fx([1, 2, 3]).toAsync().head();
        expect(res1, equals(1));

        final res2 = await fx(<int>[]).toAsync().head();
        expect(res2, isNull);
      });
    });
  });
}
