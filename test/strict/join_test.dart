import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/join.spec.ts.
void main() {
  group('join', () {
    group('sync', () {
      test('should return an empty string if there are no iterable items', () {
        expect(fxJoin(', ', ''.split('')), equals(''));
        expect(fxJoin(', ', <int>[]), equals(''));
        expect(fxJoin(', ', const Iterable<int>.empty()), equals(''));
      });

      test('should be joined with separator', () {
        expect(fxJoin('_', [1]), equals('1'));
        expect(fxJoin(', ', 'hello'.split('')), equals('h, e, l, l, o'));
      });

      test('should work given it is initial value', () {
        expect(fxJoin('~', [1, 2, 3, 4, 5]), equals('1~2~3~4~5'));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe(
          [1, 2, 3, 4, 5, 6, 7],
          [
            (Iterable<int> a) => fxMap((int n) => n + 10, a),
            (Iterable<int> a) => fxFilter((int n) => n % 2 == 0, a),
            (Iterable<int> a) => fxJoin('-', a),
          ],
        );
        expect(res, equals('12-14-16'));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx([
          1,
          2,
          3,
          4,
          5,
          6,
          7,
        ]).map((a) => a + 10).filter((a) => a % 2 == 0).join('-');
        expect(res, equals('12-14-16'));
      });

      test('should default the separator to empty, as Iterable.join does', () {
        // Fx redeclares join, which on an extension type replaces rather than
        // overrides Iterable.join — so the default has to survive here.
        expect(fx([1, 2, 3]).join(), equals('123'));
        expect(fx(<int>[]).join(), equals(''));
        expect(fx(fxRepeat(4, '-')).join(), equals('----'));
      });

      test('should return an empty string when it is an empty array', () {
        expect(fxJoin('~', <int>[]), equals(''));
      });
    });

    group('async', () {
      test(
        'should return an empty string if there are no iterable items',
        () async {
          expect(await fxJoinAsync(', ', fxAsyncEmpty<int>()), equals(''));
        },
      );

      test('should join elements of the async iterable', () async {
        final res = await fxJoinAsync('-', fxToAsync([1, 2, 3, 4, 5]));
        expect(res, equals('1-2-3-4-5'));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await pipe(fxToAsync([1, 2, 3, 4, 5, 6, 7]), [
          (FxAsyncIterable<int> a) => fxMapAsync((int n) => n + 10, a),
          (FxAsyncIterable<int> a) => fxFilterAsync((int n) => n % 2 == 0, a),
          (FxAsyncIterable<int> a) => fxJoinAsync('-', a),
        ]);
        expect(res, equals('12-14-16'));
      });

      test(
        'should be able to be used as a chaining method in the `fx`',
        () async {
          final res = await fx([
            1,
            2,
            3,
            4,
            5,
            6,
            7,
          ]).toAsync().map((a) => a + 10).filter((a) => a % 2 == 0).join('-');
          expect(res, equals('12-14-16'));
        },
      );

      test('should be able to handle an error when asynchronous', () async {
        await expectLater(
          fxAsync(
            fxToAsync('marpple'.split('')),
          ).filter((_) => throw Exception('err')).join('!'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
