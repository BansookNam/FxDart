import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('uniqAdjacent', () {
    group('sync', () {
      test('should drop only adjacent duplicates', () {
        expect(fxToList(fxUniqAdjacent([1, 1, 2, 2, 2, 1])), equals([1, 2, 1]));
        expect(fxToList(fxUniqAdjacent(<int>[])), equals([]));
        expect(fxToList(fxUniqAdjacent([7])), equals([7]));
      });

      test('should compare by the given key', () {
        expect(
          fxToList(uniqAdjacentBy((int a) => a % 10, [1, 11, 21, 2, 1])),
          equals([1, 2, 1]),
        );
      });

      test('should differ from uniq on recurring values', () {
        final source = [1, 1, 2, 1, 1];
        expect(fxToList(fxUniq(source)), equals([1, 2]));
        expect(fxToList(fxUniqAdjacent(source)), equals([1, 2, 1]));
      });

      test('should stay lazy over an endless source', () {
        expect(
          fxToList(fxTake(2, fxUniqAdjacent(fxCycle([1, 1, 2])))),
          equals([1, 2]),
        );
      });

      test('should support repeated iteration', () {
        final res = fxUniqAdjacent([1, 1, 2]);
        expect(fxToList(res), fxToList(res));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        expect(fx([1, 1, 2, 2, 1]).uniqAdjacent().toList(), equals([1, 2, 1]));
        expect(
          fx(['a', 'A', 'b']).uniqAdjacentBy((s) => s.toLowerCase()).toList(),
          equals(['a', 'b']),
        );
      });
    });

    group('async', () {
      test('should drop like the sync form', () async {
        expect(
          await fxToListAsync(
            fxUniqAdjacentAsync(fxToAsync([1, 1, 2, 2, 2, 1])),
          ),
          equals([1, 2, 1]),
        );
        expect(
          await fxToListAsync(fxUniqAdjacentAsync(fxAsyncEmpty<int>())),
          equals([]),
        );
      });

      test('should support an async key callback', () async {
        expect(
          await fxToListAsync(
            uniqAdjacentByAsync(
              (int a) => fxDelay(const Duration(milliseconds: 10), a % 10),
              fxToAsync([1, 11, 21, 2, 1]),
            ),
          ),
          equals([1, 2, 1]),
        );
      });

      test('should be deduped after concurrent', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(fxToAsync([1, 1, 2, 2, 3, 3]))
            .map((a) => fxDelay(const Duration(milliseconds: 100), a))
            .concurrent(3)
            .uniqAdjacent()
            .toList();
        sw.stop();

        expect(res, equals([1, 2, 3]));
        // Sequential would be ~600ms; concurrent(3) should be ~200ms.
        expect(sw.elapsedMilliseconds, lessThan(500));
      });

      test('should propagate an upstream error', () async {
        await expectLater(
          fxAsync(fxToAsync([1, 1, 2]))
              .map((a) {
                if (a == 2) return Future<int>.error(Exception('err'));
                return Future.value(a);
              })
              .uniqAdjacent()
              .toList(),
          throwsException,
        );
      });

      test(
        'should be able to be used as a chaining method in the `fx`',
        () async {
          expect(
            await fx([1, 1, 2]).toAsync().uniqAdjacent().toList(),
            equals([1, 2]),
          );
          expect(
            await fx([
              'a',
              'A',
              'b',
            ]).toAsync().uniqAdjacentBy((s) => s.toLowerCase()).toList(),
            equals(['a', 'b']),
          );
        },
      );
    });
  });
}
