import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('slice', () {
    group('sync', () {
      test('should return elements from startIndex to endIndex', () {
        expect(fxToList(fxSlice(1, [1, 2, 3, 4, 5], 3)), equals([2, 3]));
        expect(fxToList(fxSlice(-1, [1, 2, 3, 4, 5], 3)), equals([1, 2, 3]));
        expect(fxToList(fxSlice(2, [1, 2, 3, 4, 5])), equals([3, 4, 5]));
        expect(fxToList(fxSlice(7, [1, 2, 3, 4, 5], 3)), equals([]));
        expect(fxToList(fxSlice(1, 'abcde'.split(''), 3)), equals(['b', 'c']));
      });

      test('should return elements from startIndex to end', () {
        expect(fxToList(fxSlice(1, [1, 2, 3, 4, 5])), equals([2, 3, 4, 5]));
        expect(fxToList(fxSlice(-1, [1, 2, 3, 4, 5])), equals([1, 2, 3, 4, 5]));
        expect(fxToList(fxSlice(2, [1, 2, 3, 4, 5])), equals([3, 4, 5]));
        expect(fxToList(fxSlice(7, [1, 2, 3, 4, 5])), equals([]));
        expect(
          fxToList(fxSlice(1, 'abcde'.split(''))),
          equals(['b', 'c', 'd', 'e']),
        );
      });

      test('should stop pulling the source at the end index', () {
        var pulled = 0;
        Iterable<int> counted() sync* {
          for (var i = 0; i < 100; i++) {
            pulled++;
            yield i;
          }
        }

        expect(fxToList(fxSlice(0, counted(), 3)), equals([0, 1, 2]));
        expect(pulled, equals(3));

        pulled = 0;
        expect(fxToList(fxSlice(2, counted(), 5)), equals([2, 3, 4]));
        expect(pulled, equals(5));

        // end below start yields nothing, and stops at end rather than
        // draining the source looking for a window that cannot open.
        pulled = 0;
        expect(fxToList(fxSlice(3, counted(), 1)), equals(<int>[]));
        expect(pulled, equals(1));
      });

      test('should be able to be used in the pipeline', () {
        final res1 = pipe(
          [1, 2, 3, 4, 5],
          [(v) => fxSlice(2, v), (v) => fxToList(v)],
        );
        expect(res1, equals([3, 4, 5]));

        final res2 = pipe(
          [1, 2, 3, 4, 5],
          [(v) => fxSlice(1, v, 3), (v) => fxToList(v)],
        );
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
        expect(
          await fxToListAsync(fxSliceAsync(1, fxToAsync([1, 2, 3, 4, 5]), 3)),
          equals([2, 3]),
        );
        expect(
          await fxToListAsync(fxSliceAsync(-1, fxToAsync([1, 2, 3, 4, 5]), 3)),
          equals([1, 2, 3]),
        );
        expect(
          await fxToListAsync(fxSliceAsync(2, fxToAsync([1, 2, 3, 4, 5]))),
          equals([3, 4, 5]),
        );
        expect(
          await fxToListAsync(fxSliceAsync(7, fxToAsync([1, 2, 3, 4, 5]), 3)),
          equals([]),
        );
        expect(
          await fxToListAsync(fxSliceAsync(1, fxToAsync('abcde'.split('')), 3)),
          equals(['b', 'c']),
        );
      });

      test('should stop pulling the source at the end index', () async {
        var pulled = 0;
        Stream<int> counted() async* {
          for (var i = 0; i < 100; i++) {
            pulled++;
            yield i;
          }
        }

        expect(
          await fxToListAsync(fxSliceAsync(0, fxFromStream(counted()), 3)),
          equals([0, 1, 2]),
        );
        expect(pulled, equals(3));

        pulled = 0;
        expect(
          await fxToListAsync(fxSliceAsync(2, fxFromStream(counted()), 5)),
          equals([2, 3, 4]),
        );
        expect(pulled, equals(5));
      });

      test('should return elements from startIndex to end', () async {
        expect(
          await fxToListAsync(fxSliceAsync(1, fxToAsync([1, 2, 3, 4, 5]))),
          equals([2, 3, 4, 5]),
        );
        expect(
          await fxToListAsync(fxSliceAsync(-1, fxToAsync([1, 2, 3, 4, 5]))),
          equals([1, 2, 3, 4, 5]),
        );
        expect(
          await fxToListAsync(fxSliceAsync(2, fxToAsync([1, 2, 3, 4, 5]))),
          equals([3, 4, 5]),
        );
        expect(
          await fxToListAsync(fxSliceAsync(7, fxToAsync([1, 2, 3, 4, 5]))),
          equals([]),
        );
        expect(
          await fxToListAsync(fxSliceAsync(1, fxToAsync('abcde'.split('')))),
          equals(['b', 'c', 'd', 'e']),
        );
      });

      test('should be able to be used in the pipeline', () async {
        final res1 = await fxToListAsync(
          fxSliceAsync(2, fxToAsync([1, 2, 3, 4, 5])),
        );
        expect(res1, equals([3, 4, 5]));

        final res2 = await fxToListAsync(
          fxSliceAsync(1, fxToAsync([1, 2, 3, 4, 5]), 3),
        );
        expect(res2, equals([2, 3]));
      });

      test(
        'should be able to be used as a chaining method in the `fx`',
        () async {
          final res1 = await fx([1, 2, 3, 4, 5]).toAsync().slice(2).toList();
          expect(res1, equals([3, 4, 5]));

          final res2 = await fx([1, 2, 3, 4, 5]).toAsync().slice(1, 3).toList();
          expect(res2, equals([2, 3]));
        },
      );
    });
  });
}
