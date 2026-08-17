import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('uniqAdjacent', () {
    group('sync', () {
      test('should drop only adjacent duplicates', () {
        expect(toList(uniqAdjacent([1, 1, 2, 2, 2, 1])), equals([1, 2, 1]));
        expect(toList(uniqAdjacent(<int>[])), equals([]));
        expect(toList(uniqAdjacent([7])), equals([7]));
      });

      test('should compare by the given key', () {
        expect(
          toList(uniqAdjacentBy((int a) => a % 10, [1, 11, 21, 2, 1])),
          equals([1, 2, 1]),
        );
      });

      test('should differ from uniq on recurring values', () {
        final source = [1, 1, 2, 1, 1];
        expect(toList(uniq(source)), equals([1, 2]));
        expect(toList(uniqAdjacent(source)), equals([1, 2, 1]));
      });

      test('should stay lazy over an endless source', () {
        expect(toList(take(2, uniqAdjacent(cycle([1, 1, 2])))), equals([1, 2]));
      });

      test('should support repeated iteration', () {
        final res = uniqAdjacent([1, 1, 2]);
        expect(toList(res), toList(res));
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
          await toListAsync(uniqAdjacentAsync(toAsync([1, 1, 2, 2, 2, 1]))),
          equals([1, 2, 1]),
        );
        expect(
          await toListAsync(uniqAdjacentAsync(asyncEmpty<int>())),
          equals([]),
        );
      });

      test('should support an async key callback', () async {
        expect(
          await toListAsync(
            uniqAdjacentByAsync(
              (int a) => delay(const Duration(milliseconds: 10), a % 10),
              toAsync([1, 11, 21, 2, 1]),
            ),
          ),
          equals([1, 2, 1]),
        );
      });

      test('should be deduped after concurrent', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(toAsync([1, 1, 2, 2, 3, 3]))
            .map((a) => delay(const Duration(milliseconds: 100), a))
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
          fxAsync(toAsync([1, 1, 2]))
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
