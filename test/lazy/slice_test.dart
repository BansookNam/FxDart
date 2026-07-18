import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('slice', () {
    group('sync', () {
      test('should return elements from startIndex to endIndex', () {
        expect(toArray(slice(1, [1, 2, 3, 4, 5], 3)), equals([2, 3]));
        expect(toArray(slice(-1, [1, 2, 3, 4, 5], 3)), equals([1, 2, 3]));
        expect(toArray(slice(2, [1, 2, 3, 4, 5])), equals([3, 4, 5]));
        expect(toArray(slice(7, [1, 2, 3, 4, 5], 3)), equals([]));
        expect(toArray(slice(1, 'abcde'.split(''), 3)), equals(['b', 'c']));
      });

      test('should return elements from startIndex to end', () {
        expect(toArray(slice(1, [1, 2, 3, 4, 5])), equals([2, 3, 4, 5]));
        expect(toArray(slice(-1, [1, 2, 3, 4, 5])), equals([1, 2, 3, 4, 5]));
        expect(toArray(slice(2, [1, 2, 3, 4, 5])), equals([3, 4, 5]));
        expect(toArray(slice(7, [1, 2, 3, 4, 5])), equals([]));
        expect(
            toArray(slice(1, 'abcde'.split(''))), equals(['b', 'c', 'd', 'e']));
      });

      test('should be able to be used in the pipeline', () {
        final res1 = pipe([
          1,
          2,
          3,
          4,
          5
        ], [
          (v) => slice(2, v),
          (v) => toArray(v),
        ]);
        expect(res1, equals([3, 4, 5]));

        final res2 = pipe([
          1,
          2,
          3,
          4,
          5
        ], [
          (v) => slice(1, v, 3),
          (v) => toArray(v),
        ]);
        expect(res2, equals([2, 3]));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res1 = fx([1, 2, 3, 4, 5]).slice(2).toArray();
        expect(res1, equals([3, 4, 5]));

        final res2 = fx([1, 2, 3, 4, 5]).slice(1, 3).toArray();
        expect(res2, equals([2, 3]));
      });
    });

    group('async', () {
      test('should return elements from startIndex to endIndex', () async {
        expect(await toArrayAsync(sliceAsync(1, toAsync([1, 2, 3, 4, 5]), 3)),
            equals([2, 3]));
        expect(await toArrayAsync(sliceAsync(-1, toAsync([1, 2, 3, 4, 5]), 3)),
            equals([1, 2, 3]));
        expect(await toArrayAsync(sliceAsync(2, toAsync([1, 2, 3, 4, 5]))),
            equals([3, 4, 5]));
        expect(await toArrayAsync(sliceAsync(7, toAsync([1, 2, 3, 4, 5]), 3)),
            equals([]));
        expect(await toArrayAsync(sliceAsync(1, toAsync('abcde'.split('')), 3)),
            equals(['b', 'c']));
      });

      test('should return elements from startIndex to end', () async {
        expect(await toArrayAsync(sliceAsync(1, toAsync([1, 2, 3, 4, 5]))),
            equals([2, 3, 4, 5]));
        expect(await toArrayAsync(sliceAsync(-1, toAsync([1, 2, 3, 4, 5]))),
            equals([1, 2, 3, 4, 5]));
        expect(await toArrayAsync(sliceAsync(2, toAsync([1, 2, 3, 4, 5]))),
            equals([3, 4, 5]));
        expect(await toArrayAsync(sliceAsync(7, toAsync([1, 2, 3, 4, 5]))),
            equals([]));
        expect(await toArrayAsync(sliceAsync(1, toAsync('abcde'.split('')))),
            equals(['b', 'c', 'd', 'e']));
      });

      test('should be able to be used in the pipeline', () async {
        final res1 =
            await toArrayAsync(sliceAsync(2, toAsync([1, 2, 3, 4, 5])));
        expect(res1, equals([3, 4, 5]));

        final res2 =
            await toArrayAsync(sliceAsync(1, toAsync([1, 2, 3, 4, 5]), 3));
        expect(res2, equals([2, 3]));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res1 = await fx([1, 2, 3, 4, 5]).toAsync().slice(2).toArray();
        expect(res1, equals([3, 4, 5]));

        final res2 = await fx([1, 2, 3, 4, 5]).toAsync().slice(1, 3).toArray();
        expect(res2, equals([2, 3]));
      });
    });
  });
}
