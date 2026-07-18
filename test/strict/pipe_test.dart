import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/pipe.spec.ts, exercising the dynamic `pipe`.
void main() {
  group('pipe', () {
    group('sync', () {
      test('should return the value evaluated by the composed function', () {
        final res = pipe(0, [
          (int n) => '${n + 1}',
          (String n) => int.parse(n) + 1,
          (int n) => '${n + 1}',
        ]);
        expect(res, equals('3'));
      });

      test("should work when the composed function deals with 'Iterable'", () {
        final res = pipe([
          1,
          2,
          3,
          4,
          5
        ], [
          (Iterable<int> n) => map((int a) => a + 5, n),
          (Iterable<int> n) => filter((int a) => a % 2 == 0, n),
          (Iterable<int> n) => fold(0, (int a, int b) => a + b, n),
        ]);
        expect(res, equals(24));
      });
    });

    group('async', () {
      test("should work when the composed function deals with 'AsyncIterable'",
          () async {
        final res1 = await pipe(toAsync([1, 2, 3, 4, 5]), [
          (FxAsyncIterable<int> n) => mapAsync((int a) => a + 5, n),
          (FxAsyncIterable<int> n) => filterAsync((int a) => a % 2 == 0, n),
          (FxAsyncIterable<int> n) => foldAsync(0, (int a, int b) => a + b, n),
        ]);

        expect(res1, equals(24));

        final res2 = await pipe(toAsync([1, 2, 3, 4, 5]), [
          (FxAsyncIterable<int> n) => mapAsync((int a) => a + 5, n),
          (FxAsyncIterable<int> n) => filterAsync((int a) => a % 2 == 0, n),
          (FxAsyncIterable<int> n) => toArrayAsync(n),
          (List<int> n) => fold(0, (int a, int b) => a + b, n),
        ]);

        expect(res2, equals(24));
      });

      test('should make the chain async when a Future appears mid-chain',
          () async {
        final res = pipe([
          1,
          2,
          3
        ], [
          (List<int> v) => Future.value(v),
          (List<int> v) => toArray(map((int a) => a + 1, v)),
        ]);

        expect(res, isA<Future<dynamic>>());
        expect(await res, equals([2, 3, 4]));
      });

      test('should await an initial Future value', () async {
        final res = await pipe(Future.value(1), [
          (int n) => n + 10,
          (int n) => n * 2,
        ]);
        expect(res, equals(22));
      });

      test("should return rejected 'Future' if an error occurs in the callback",
          () async {
        await expectLater(
          pipe(toAsync(range(1, 10)), [
            (FxAsyncIterable<int> a) =>
                mapAsync((int _) => throw Exception('err'), a),
            (FxAsyncIterable<int> a) =>
                reduceAsync((int acc, int b) => acc + b, a),
          ]) as Future,
          throwsA(isA<Exception>()),
        );

        // Future.error
        await expectLater(
          pipe(toAsync(range(1, 10)), [
            (FxAsyncIterable<int> a) =>
                mapAsync((int _) => Future<int>.error(Exception('err')), a),
            (FxAsyncIterable<int> a) =>
                reduceAsync((int acc, int b) => acc + b, a),
          ]) as Future,
          throwsA(isA<Exception>()),
        );
      });

      test('should be able to run side effects with eachAsync', () async {
        var res = 0;

        await pipe([
          'a',
          'b',
          'c'
        ], [
          (List<String> v) => toAsync(v),
          (FxAsyncIterable<String> v) => eachAsync((_) async {
                await delay(Duration.zero, null);
                res++;
              }, v),
        ]);

        expect(res, equals(3));
      });
    });

    group('pipeLazy', () {
      test('should return a function piping its argument', () async {
        final f = pipeLazy([
          (Iterable<int> n) => map((int a) => a + 5, n),
          (Iterable<int> n) => filter((int a) => a % 2 == 0, n),
          (Iterable<int> n) => toArray(n),
        ]);
        expect(f([1, 2, 3, 4, 5]), equals([6, 8, 10]));
        expect(await f(Future.value([1, 2, 3, 4, 5])), equals([6, 8, 10]));
      });
    });
  });
}
