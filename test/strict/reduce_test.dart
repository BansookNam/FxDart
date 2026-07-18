import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/reduce.spec.ts. The seeded form is `fold` in Dart;
// unseeded `reduce` throws StateError on an empty iterable.
int addNumber(int a, int b) => a + b;
Future<int> addNumberAsync(int a, int b) async => a + b;

void main() {
  group('reduce', () {
    group('sync', () {
      test('should return initial value when the given iterable is empty', () {
        expect(fold('seed', (String a, Object? b) => a, <Object?>[]),
            equals('seed'));
      });

      test(
          'should throw when the given iterable is empty and initial value is absent',
          () {
        expect(() => reduce((int a, int b) => a, <int>[]), throwsStateError);
      });

      test('should work given it is initial value', () {
        expect(fold(10, addNumber, range(1, 6)), equals(25));
      });

      test(
          'should use the first value as the initial value if initial value is absent',
          () {
        expect(reduce(addNumber, range(1, 6)), equals(15));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe([
          '1',
          '2',
          '3',
          '4',
          '5'
        ], [
          (Iterable<String> a) => map(int.parse, a),
          (Iterable<int> a) => filter((int n) => n % 2 == 1, a),
          (Iterable<int> a) => reduce(addNumber, a),
        ]);
        expect(res, equals(1 + 3 + 5));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx(['1', '2', '3', '4', '5'])
            .map(int.parse)
            .filter((a) => a % 2 == 1)
            .reduce(addNumber);
        expect(res, equals(1 + 3 + 5));
      });
    });

    group('async', () {
      test('should fold the async iterable by the callback with a seed',
          () async {
        expect(
            await foldAsync(10, addNumber, toAsync(range(1, 6))), equals(25));
      });

      test(
          'should use the first value as the initial value if initial value is absent',
          () async {
        expect(await reduceAsync(addNumber, toAsync(range(1, 6))), equals(15));
      });

      test("should fold the 'AsyncIterable' by the async callback with a seed",
          () async {
        expect(await foldAsync(10, addNumberAsync, toAsync(range(1, 6))),
            equals(25));
      });

      test("should reduce 'AsyncIterable' by the async callback", () async {
        expect(await reduceAsync(addNumberAsync, toAsync(range(1, 6))),
            equals(15));
      });

      test(
          "should return rejected 'Future' if an error is thrown in the callback",
          () async {
        await expectLater(
          foldAsync<int, int>(
              0, (a, b) => throw Exception('err'), toAsync(range(1, 6))),
          throwsA(isA<Exception>()),
        );

        await expectLater(
          reduceAsync<int>(
              (a, b) => throw Exception('err'), toAsync(range(1, 6))),
          throwsA(isA<Exception>()),
        );
      });

      test(
          "should return rejected 'Future' if the callback returns a rejected 'Future'",
          () async {
        await expectLater(
          foldAsync<int, int>(0, (a, b) => Future.error(Exception('err')),
              toAsync(range(1, 6))),
          throwsA(isA<Exception>()),
        );

        await expectLater(
          reduceAsync<int>((a, b) => Future<int>.error(Exception('err')),
              toAsync(range(1, 6))),
          throwsA(isA<Exception>()),
        );
      });

      test('should be able to be used in the pipeline', () async {
        final res1 = await pipe(toAsync(['1', '2', '3', '4', '5']), [
          (FxAsyncIterable<String> a) => mapAsync(int.parse, a),
          (FxAsyncIterable<int> a) => filterAsync((int n) => n % 2 == 1, a),
          (FxAsyncIterable<int> a) => reduceAsync(addNumber, a),
        ]);
        // async callback
        final res2 = await pipe(toAsync(['1', '2', '3', '4', '5']), [
          (FxAsyncIterable<String> a) => mapAsync(int.parse, a),
          (FxAsyncIterable<int> a) => filterAsync((int n) => n % 2 == 1, a),
          (FxAsyncIterable<int> a) => reduceAsync(addNumberAsync, a),
        ]);
        expect(res1, equals(9));
        expect(res2, equals(9));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res1 = await fxAsync(toAsync(['1', '2', '3', '4', '5']))
            .map(int.parse)
            .filter((a) => a % 2 == 1)
            .reduce(addNumber);

        expect(res1, equals(9));
      });
    });
  });
}
