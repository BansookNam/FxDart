import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/Util/shuffle.spec.ts. Seeded assertions check
// determinism and element preservation rather than exact JS sequences (the
// PRNG's integer semantics may differ between JS and Dart).
void main() {
  group('shuffle', () {
    group('sync', () {
      test('should return the given list elements in shuffled order', () {
        final input = [1, 2, 3, 4];
        final result = fxShuffle(input);
        expect(result.length, equals(4));
        expect(fxToList(result)..sort(), equals([1, 2, 3, 4]));
      });

      test('should return the given string chars in shuffled order', () {
        final input = 'abcd'.split('');
        final result = fxShuffle(input);
        expect(result.length, equals(4));
        expect(fxToList(result)..sort(), equals(['a', 'b', 'c', 'd']));
      });

      test('should handle empty array', () {
        expect(fxShuffle(<int>[]), equals(<int>[]));
      });

      test('should be immutable', () {
        final obj = [1, 2, 3, 4];
        final result = fxShuffle(obj);
        expect(identical(obj, result), isFalse);
        expect(obj, equals([1, 2, 3, 4]));
      });

      test('should handle single element', () {
        expect(fxShuffle([42]), equals([42]));
      });

      test('should be able to be used in the pipeline', () {
        final res =
            pipe(
                  [1, 2, 3, 4, 5, 6],
                  [(List<int> a) => fxShuffle(a), (List<int> a) => fxToList(a)],
                )
                as List;
        expect(res.length, equals(6));
        expect(fxToList(res)..sort(), equals([1, 2, 3, 4, 5, 6]));
      });

      test(
        'should produce different results on multiple calls (statistical test)',
        () {
          final input = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
          final results = [for (var i = 0; i < 50; i++) fxShuffle(input)];

          final first = results.first.join(',');
          final allIdentical = results.every(
            (result) => result.join(',') == first,
          );
          expect(allIdentical, isFalse);
        },
      );

      test('should return consistent results with the same seed', () {
        final input = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        const seed = 42;

        final result1 = fxShuffle(input, seed);
        final result2 = fxShuffle(input, seed);
        final result3 = fxShuffle(input, seed);

        expect(result1, equals(result2));
        expect(result2, equals(result3));
      });

      test('should return different results with different seeds', () {
        final input = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

        final result1 = fxShuffle(input, 42);
        final result2 = fxShuffle(input, 123);
        final result3 = fxShuffle(input, 999);

        expect(result1, isNot(equals(result2)));
        expect(result2, isNot(equals(result3)));
        expect(result1, isNot(equals(result3)));
      });

      test('should reorder elements relative to the input for some seeds', () {
        final input = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        // At least one of a few seeds must produce an order different from
        // the original (all identical is astronomically unlikely).
        final anyReordered = [
          42,
          123,
          999,
        ].any((seed) => fxShuffle(input, seed).join(',') != input.join(','));
        expect(anyReordered, isTrue);
      });

      test('should maintain all elements with seeded shuffle', () {
        final input = [1, 2, 3, 4, 5];
        final result = fxShuffle(input, 42);

        expect(result.length, equals(5));
        expect(fxToList(result)..sort(), equals([1, 2, 3, 4, 5]));
      });

      test('should work with seed 0', () {
        final input = [1, 2, 3, 4];
        expect(fxShuffle(input, 0), equals(fxShuffle(input, 0)));
      });

      test('should be able to be used with seed in pipeline', () {
        final input = [1, 2, 3, 4, 5, 6];
        const seed = 42;

        final res1 =
            pipe(input, [
                  (List<int> arr) => fxShuffle(arr, seed),
                  (List<int> arr) => fxToList(arr),
                ])
                as List;
        final res2 =
            pipe(input, [
                  (List<int> arr) => fxShuffle(arr, seed),
                  (List<int> arr) => fxToList(arr),
                ])
                as List;

        expect(res1, equals(res2));
        expect(res1.length, equals(6));
        expect(fxToList(res1)..sort(), equals([1, 2, 3, 4, 5, 6]));
      });
    });

    group('async', () {
      test('should return the given list elements in shuffled order', () async {
        final result = await fxShuffleAsync(fxToAsync([1, 2, 3, 4]));
        expect(result.length, equals(4));
        expect(fxToList(result)..sort(), equals([1, 2, 3, 4]));
      });

      test('should return the given string chars in shuffled order', () async {
        final result = await fxShuffleAsync(fxToAsync('abcd'.split('')));
        expect(result.length, equals(4));
        expect(fxToList(result)..sort(), equals(['a', 'b', 'c', 'd']));
      });

      test('should handle empty async array', () async {
        expect(await fxShuffleAsync(fxToAsync(<int>[])), equals(<int>[]));
      });

      test('should be able to be used in the pipeline', () async {
        final res =
            await pipe(
                  [1, 2, 3, 4, 5, 6],
                  [
                    (List<int> a) => fxToAsync(a),
                    (FxAsyncIterable<int> a) => fxShuffleAsync(a),
                    (List<int> a) => fxToList(a),
                  ],
                )
                as List;
        expect(res.length, equals(6));
        expect(fxToList(res)..sort(), equals([1, 2, 3, 4, 5, 6]));
      });

      test(
        'should produce different results on multiple calls (statistical test)',
        () async {
          final input = [1, 2, 3, 4, 5, 6, 7, 8];
          final results = <List<int>>[];
          for (var i = 0; i < 20; i++) {
            results.add(await fxShuffleAsync(fxToAsync(input)));
          }

          final first = results.first.join(',');
          final allIdentical = results.every(
            (result) => result.join(',') == first,
          );
          expect(allIdentical, isFalse);
        },
      );

      test('should return consistent results with the same seed', () async {
        final input = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        const seed = 42;

        final result1 = await fxShuffleAsync(fxToAsync(input), seed);
        final result2 = await fxShuffleAsync(fxToAsync(input), seed);
        final result3 = await fxShuffleAsync(fxToAsync(input), seed);

        expect(result1, equals(result2));
        expect(result2, equals(result3));
      });

      test('should match the sync seeded order', () async {
        final input = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        expect(
          await fxShuffleAsync(fxToAsync(input), 42),
          equals(fxShuffle(input, 42)),
        );
      });

      test('should return different results with different seeds', () async {
        final input = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

        final result1 = await fxShuffleAsync(fxToAsync(input), 42);
        final result2 = await fxShuffleAsync(fxToAsync(input), 123);
        final result3 = await fxShuffleAsync(fxToAsync(input), 999);

        expect(result1, isNot(equals(result2)));
        expect(result2, isNot(equals(result3)));
        expect(result1, isNot(equals(result3)));
      });

      test('should maintain all elements with seeded shuffle', () async {
        final input = [1, 2, 3, 4, 5];
        final result = await fxShuffleAsync(fxToAsync(input), 42);

        expect(result.length, equals(5));
        expect(fxToList(result)..sort(), equals([1, 2, 3, 4, 5]));
      });

      test('should be able to be used with seed in pipeline', () async {
        final input = [1, 2, 3, 4, 5, 6];
        const seed = 42;

        final res1 =
            await pipe(input, [
                  (List<int> a) => fxToAsync(a),
                  (FxAsyncIterable<int> a) => fxShuffleAsync(a, seed),
                  (List<int> a) => fxToList(a),
                ])
                as List;
        final res2 =
            await pipe(input, [
                  (List<int> a) => fxToAsync(a),
                  (FxAsyncIterable<int> a) => fxShuffleAsync(a, seed),
                  (List<int> a) => fxToList(a),
                ])
                as List;

        expect(res1, equals(res2));
        expect(res1.length, equals(6));
        expect(fxToList(res1)..sort(), equals([1, 2, 3, 4, 5, 6]));
      });
    });
  });
}
