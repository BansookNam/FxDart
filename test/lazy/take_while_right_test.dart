import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// A non-List source, so the buffering path is exercised alongside the
/// List fast path.
Iterable<A> lazily<A>(List<A> xs) => xs.where((_) => true);

void main() {
  group('takeWhileRight', () {
    group('sync', () {
      test('returns the trailing run in source order', () {
        expect(
          toList(takeWhileRight((int a) => a > 2, [1, 4, 2, 3, 4])),
          equals([3, 4]),
        );
      });

      test('is empty when the last element already fails', () {
        expect(
          toList(takeWhileRight((int a) => a > 2, [3, 4, 1])),
          equals(<int>[]),
        );
      });

      test('takes everything when every element matches', () {
        expect(
          toList(takeWhileRight((int a) => a > 0, [1, 2, 3])),
          equals([1, 2, 3]),
        );
      });

      test('is empty for an empty source', () {
        expect(
          toList(takeWhileRight((int a) => true, <int>[])),
          equals(<int>[]),
        );
      });

      test('an earlier matching run does not survive a later failure', () {
        expect(
          toList(takeWhileRight((int a) => a.isEven, [2, 2, 1, 4])),
          equals([4]),
        );
      });

      test('the buffered path agrees with the List fast path', () {
        for (final source in [
          [1, 4, 2, 3, 4],
          [3, 4, 1],
          [1, 2, 3],
          <int>[],
          [2, 2, 1, 4],
        ]) {
          expect(
            toList(takeWhileRight((int a) => a > 2, lazily(source))),
            equals(toList(takeWhileRight((int a) => a > 2, source))),
            reason: '$source',
          );
        }
      });

      test('re-iterates from scratch', () {
        final it = takeWhileRight((int a) => a > 2, lazily([1, 3, 4]));
        expect(it.toList(), equals([3, 4]));
        expect(it.toList(), equals([3, 4]));
      });

      test('trims a trailing suffix, the usual use', () {
        expect(
          toList(
            takeWhileRight((String c) => c == ' ', ['a', 'b', ' ', ' ', ' ']),
          ),
          equals([' ', ' ', ' ']),
        );
      });

      test('is available as an fx chain method', () {
        expect(
          fx([1, 4, 2, 3, 4]).takeWhileRight((a) => a > 2).toList(),
          equals([3, 4]),
        );
      });

      test('partitions the source together with dropWhileRight', () {
        final source = [1, 4, 2, 3, 4];
        bool f(int a) => a > 2;
        expect([
          ...dropWhileRight(f, source),
          ...takeWhileRight(f, source),
        ], equals(source));
      });
    });

    group('async', () {
      test('returns the trailing run in source order', () async {
        final res = await toListAsync(
          takeWhileRightAsync((int a) => a > 2, toAsync([1, 4, 2, 3, 4])),
        );
        expect(res, equals([3, 4]));
      });

      test('is empty when the last value already fails', () async {
        final res = await toListAsync(
          takeWhileRightAsync((int a) => a > 2, toAsync([3, 4, 1])),
        );
        expect(res, equals(<int>[]));
      });

      test('is empty for an empty source', () async {
        final res = await toListAsync(
          takeWhileRightAsync((int a) => true, toAsync(<int>[])),
        );
        expect(res, equals(<int>[]));
      });

      test('agrees with the sync form', () async {
        final source = [2, 2, 1, 4, 4];
        expect(
          await toListAsync(
            takeWhileRightAsync((int a) => a.isEven, toAsync(source)),
          ),
          equals(toList(takeWhileRight((int a) => a.isEven, source))),
        );
      });

      test('is available as an fxAsync chain method', () async {
        final res = await fxAsync(
          toAsync([1, 4, 2, 3, 4]),
        ).takeWhileRight((a) => a > 2).toList();
        expect(res, equals([3, 4]));
      });

      test('works downstream of a concurrent stage', () async {
        final res = await fxAsync(toAsync([1, 4, 2, 3, 4]))
            .map((a) => delay(const Duration(milliseconds: 5), a))
            .concurrent(3)
            .takeWhileRight((a) => a > 2)
            .toList();
        expect(res, equals([3, 4]));
      });
    });
  });
}
