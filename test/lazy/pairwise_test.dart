import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('pairwise', () {
    group('sync', () {
      test('should pair each element with its successor', () {
        expect(
          fxToList(fxPairwise([1, 2, 3, 4])),
          equals([(1, 2), (2, 3), (3, 4)]),
        );
      });

      test('should yield nothing for fewer than two elements', () {
        expect(fxToList(fxPairwise(<int>[])), equals([]));
        expect(fxToList(fxPairwise([1])), equals([]));
      });

      test('should stay lazy over an endless source', () {
        expect(
          fxToList(fxTake(3, fxPairwise(fxCycle([1, 2])))),
          equals([(1, 2), (2, 1), (1, 2)]),
        );
      });

      test('should support repeated iteration', () {
        final pairs = fxPairwise([1, 2, 3]);
        expect(fxToList(pairs), fxToList(pairs));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        expect(fx([1, 5, 3]).pairwise().toList(), equals([(1, 5), (5, 3)]));
        expect(
          fx([100, 120, 90]).pairwise().map((p) => p.$2 - p.$1).toList(),
          equals([20, -30]),
        );
      });
    });

    group('async', () {
      test('should pair like the sync form', () async {
        expect(
          await fxToListAsync(fxPairwiseAsync(fxToAsync([1, 2, 3, 4]))),
          equals([(1, 2), (2, 3), (3, 4)]),
        );
        expect(
          await fxToListAsync(fxPairwiseAsync(fxAsyncEmpty<int>())),
          equals([]),
        );
        expect(
          await fxToListAsync(fxPairwiseAsync(fxToAsync([1]))),
          equals([]),
        );
      });

      test('should be paired after concurrent', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(fxToAsync(fxRange(1, 7)))
            .map((a) => fxDelay(const Duration(milliseconds: 100), a))
            .concurrent(3)
            .pairwise()
            .toList();
        sw.stop();

        expect(res, equals([(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]));
        // Sequential would be ~600ms; concurrent(3) should be ~200ms.
        expect(sw.elapsedMilliseconds, lessThan(500));
      });

      test('should propagate an upstream error', () async {
        await expectLater(
          fxAsync(fxToAsync(fxRange(1, 10)))
              .map((a) {
                if (a == 4) return Future<int>.error(Exception('err'));
                return Future.value(a);
              })
              .pairwise()
              .toList(),
          throwsException,
        );
      });

      test(
        'should be able to be used as a chaining method in the `fx`',
        () async {
          expect(
            await fx([1, 5, 3]).toAsync().pairwise().toList(),
            equals([(1, 5), (5, 3)]),
          );
        },
      );
    });
  });
}
