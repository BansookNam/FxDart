import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/join.spec.ts.
void main() {
  group('join', () {
    group('sync', () {
      test('should return an empty string if there are no iterable items', () {
        expect(join(', ', ''.split('')), equals(''));
        expect(join(', ', <int>[]), equals(''));
        expect(join(', ', const Iterable<int>.empty()), equals(''));
      });

      test('should be joined with separator', () {
        expect(join('_', [1]), equals('1'));
        expect(join(', ', 'hello'.split('')), equals('h, e, l, l, o'));
      });

      test('should work given it is initial value', () {
        expect(join('~', [1, 2, 3, 4, 5]), equals('1~2~3~4~5'));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe([
          1,
          2,
          3,
          4,
          5,
          6,
          7
        ], [
          (Iterable<int> a) => map((int n) => n + 10, a),
          (Iterable<int> a) => filter((int n) => n % 2 == 0, a),
          (Iterable<int> a) => join('-', a),
        ]);
        expect(res, equals('12-14-16'));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx([1, 2, 3, 4, 5, 6, 7])
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .join('-');
        expect(res, equals('12-14-16'));
      });

      test('should return an empty string when it is an empty array', () {
        expect(join('~', <int>[]), equals(''));
      });
    });

    group('async', () {
      test('should return an empty string if there are no iterable items',
          () async {
        expect(await joinAsync(', ', asyncEmpty<int>()), equals(''));
      });

      test('should join elements of the async iterable', () async {
        final res = await joinAsync('-', toAsync([1, 2, 3, 4, 5]));
        expect(res, equals('1-2-3-4-5'));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await pipe(toAsync([1, 2, 3, 4, 5, 6, 7]), [
          (FxAsyncIterable<int> a) => mapAsync((int n) => n + 10, a),
          (FxAsyncIterable<int> a) => filterAsync((int n) => n % 2 == 0, a),
          (FxAsyncIterable<int> a) => joinAsync('-', a),
        ]);
        expect(res, equals('12-14-16'));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res = await fx([1, 2, 3, 4, 5, 6, 7])
            .toAsync()
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .join('-');
        expect(res, equals('12-14-16'));
      });

      test('should be able to handle an error when asynchronous', () async {
        await expectLater(
          fxAsync(toAsync('marpple'.split('')))
              .filter((_) => throw Exception('err'))
              .join('!'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
