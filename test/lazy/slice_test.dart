import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('slice', () {
    group('sync', () {
      test('should return elements from startIndex to endIndex', () {
        expect(toList(slice(1, [1, 2, 3, 4, 5], 3)), equals([2, 3]));
        expect(toList(slice(-1, [1, 2, 3, 4, 5], 3)), equals([1, 2, 3]));
        expect(toList(slice(2, [1, 2, 3, 4, 5])), equals([3, 4, 5]));
        expect(toList(slice(7, [1, 2, 3, 4, 5], 3)), equals([]));
        expect(toList(slice(1, 'abcde'.split(''), 3)), equals(['b', 'c']));
      });

      test('should return elements from startIndex to end', () {
        expect(toList(slice(1, [1, 2, 3, 4, 5])), equals([2, 3, 4, 5]));
        expect(toList(slice(-1, [1, 2, 3, 4, 5])), equals([1, 2, 3, 4, 5]));
        expect(toList(slice(2, [1, 2, 3, 4, 5])), equals([3, 4, 5]));
        expect(toList(slice(7, [1, 2, 3, 4, 5])), equals([]));
        expect(
            toList(slice(1, 'abcde'.split(''))), equals(['b', 'c', 'd', 'e']));
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
          (v) => toList(v),
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
          (v) => toList(v),
        ]);
        expect(res2, equals([2, 3]));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res1 = fx([1, 2, 3, 4, 5]).slice(2).toList();
        expect(res1, equals([3, 4, 5]));

        final res2 = fx([1, 2, 3, 4, 5]).slice(1, 3).toList();
        expect(res2, equals([2, 3]));
      });
    });

    group('async', () {
      test('should return elements from startIndex to endIndex', () async {
        expect(await toListAsync(sliceAsync(1, toAsync([1, 2, 3, 4, 5]), 3)),
            equals([2, 3]));
        expect(await toListAsync(sliceAsync(-1, toAsync([1, 2, 3, 4, 5]), 3)),
            equals([1, 2, 3]));
        expect(await toListAsync(sliceAsync(2, toAsync([1, 2, 3, 4, 5]))),
            equals([3, 4, 5]));
        expect(await toListAsync(sliceAsync(7, toAsync([1, 2, 3, 4, 5]), 3)),
            equals([]));
        expect(await toListAsync(sliceAsync(1, toAsync('abcde'.split('')), 3)),
            equals(['b', 'c']));
      });

      test('should return elements from startIndex to end', () async {
        expect(await toListAsync(sliceAsync(1, toAsync([1, 2, 3, 4, 5]))),
            equals([2, 3, 4, 5]));
        expect(await toListAsync(sliceAsync(-1, toAsync([1, 2, 3, 4, 5]))),
            equals([1, 2, 3, 4, 5]));
        expect(await toListAsync(sliceAsync(2, toAsync([1, 2, 3, 4, 5]))),
            equals([3, 4, 5]));
        expect(await toListAsync(sliceAsync(7, toAsync([1, 2, 3, 4, 5]))),
            equals([]));
        expect(await toListAsync(sliceAsync(1, toAsync('abcde'.split('')))),
            equals(['b', 'c', 'd', 'e']));
      });

      test('should be able to be used in the pipeline', () async {
        final res1 =
            await toListAsync(sliceAsync(2, toAsync([1, 2, 3, 4, 5])));
        expect(res1, equals([3, 4, 5]));

        final res2 =
            await toListAsync(sliceAsync(1, toAsync([1, 2, 3, 4, 5]), 3));
        expect(res2, equals([2, 3]));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res1 = await fx([1, 2, 3, 4, 5]).toAsync().slice(2).toList();
        expect(res1, equals([3, 4, 5]));

        final res2 = await fx([1, 2, 3, 4, 5]).toAsync().slice(1, 3).toList();
        expect(res2, equals([2, 3]));
      });
    });
  });
}
