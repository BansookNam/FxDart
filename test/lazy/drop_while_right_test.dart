import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// A non-List source, so the streaming path is exercised alongside the
/// List fast path.
Iterable<A> lazily<A>(List<A> xs) => xs.where((_) => true);

void main() {
  group('dropWhileRight', () {
    group('sync', () {
      test('drops the trailing run', () {
        expect(toList(dropWhileRight((int a) => a == 0, [1, 2, 0, 0])),
            equals([1, 2]));
      });

      test('drops nothing when the last element already fails', () {
        expect(toList(dropWhileRight((int a) => a == 0, [0, 0, 1])),
            equals([0, 0, 1]));
      });

      test('drops everything when every element matches', () {
        expect(toList(dropWhileRight((int a) => a > 0, [1, 2, 3])),
            equals(<int>[]));
      });

      test('is empty for an empty source', () {
        expect(toList(dropWhileRight((int a) => true, <int>[])),
            equals(<int>[]));
      });

      test('an interior matching run is kept, not dropped', () {
        expect(toList(dropWhileRight((int a) => a.isEven, [2, 2, 1, 4])),
            equals([2, 2, 1]));
      });

      test('the streaming path agrees with the List fast path', () {
        for (final source in [
          [1, 2, 0, 0],
          [0, 0, 1],
          [1, 2, 3],
          <int>[],
          [2, 2, 1, 4],
          [0],
        ]) {
          expect(toList(dropWhileRight((int a) => a == 0, lazily(source))),
              equals(toList(dropWhileRight((int a) => a == 0, source))),
              reason: '$source');
        }
      });

      test('releases a held-back run as soon as an element fails', () {
        final pulled = <int>[];
        final source = lazily([1, 1, 2, 1, 1]).map((a) {
          pulled.add(a);
          return a;
        });
        final it = dropWhileRight((int a) => a == 1, source).iterator;

        // Nothing can be emitted until the 2 proves the leading 1s were not
        // the suffix — but that is 3 pulls, not the whole source.
        expect(it.moveNext(), isTrue);
        expect(it.current, equals(1));
        expect(pulled, equals([1, 1, 2]));
      });

      test('re-iterates from scratch', () {
        final it = dropWhileRight((int a) => a == 0, lazily([1, 2, 0]));
        expect(it.toList(), equals([1, 2]));
        expect(it.toList(), equals([1, 2]));
      });

      test('trims a trailing suffix, the usual use', () {
        final res = toList(
            dropWhileRight((String c) => c == ' ', ['a', 'b', ' ', ' ', ' ']));
        expect(res, equals(['a', 'b']));
      });

      test('is available as an fx chain method', () {
        expect(fx([1, 2, 0, 0]).dropWhileRight((a) => a == 0).toList(),
            equals([1, 2]));
      });
    });

    group('async', () {
      test('drops the trailing run', () async {
        final res = await toListAsync(
            dropWhileRightAsync((int a) => a == 0, toAsync([1, 2, 0, 0])));
        expect(res, equals([1, 2]));
      });

      test('drops nothing when the last value already fails', () async {
        final res = await toListAsync(
            dropWhileRightAsync((int a) => a == 0, toAsync([0, 0, 1])));
        expect(res, equals([0, 0, 1]));
      });

      test('is empty for an empty source', () async {
        final res = await toListAsync(
            dropWhileRightAsync((int a) => true, toAsync(<int>[])));
        expect(res, equals(<int>[]));
      });

      test('agrees with the sync form', () async {
        final source = [2, 2, 1, 4, 4];
        expect(
            await toListAsync(
                dropWhileRightAsync((int a) => a.isEven, toAsync(source))),
            equals(toList(dropWhileRight((int a) => a.isEven, source))));
      });

      test('is available as an fxAsync chain method', () async {
        final res = await fxAsync(toAsync([1, 2, 0, 0]))
            .dropWhileRight((a) => a == 0)
            .toList();
        expect(res, equals([1, 2]));
      });

      test('works downstream of a concurrent stage', () async {
        final res = await fxAsync(toAsync([1, 2, 0, 0]))
            .map((a) => delay(const Duration(milliseconds: 5), a))
            .concurrent(3)
            .dropWhileRight((a) => a == 0)
            .toList();
        expect(res, equals([1, 2]));
      });
    });
  });
}
