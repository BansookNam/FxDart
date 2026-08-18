// `dropWhileAsync` is a fused stage (FxDropWhileStage) rather than its own
// SerialAsyncIterator layer, and `windowedAsync`/`chunkAsync` answer on the
// internal fast-pull path instead of allocating a Future per element.
//
// What is pinned here is behaviour the fast paths could plausibly break: the
// latch is per-iterator and per-run, a Concurrent marker still reaches the
// upstream, and the window bookkeeping (partial tail, overlap, skip) is
// unchanged.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('dropWhile async fusion', () {
    test('drops the leading run, then stops testing', () async {
      final tested = <int>[];
      final res = await fxAsync(toAsync([1, 2, 3, 1, 2])).dropWhile((a) {
        tested.add(a);
        return a < 3;
      }).toList();

      expect(res, [3, 1, 2]);
      expect(tested, [1, 2, 3], reason: 'the latch stops the predicate');
    });

    test('fuses with the stages around it', () async {
      final res = await fxAsync(toAsync([1, 2, 3, 4, 5, 6]))
          .map((a) => a * 2)
          .dropWhile((a) => a < 6)
          .filter((a) => a % 4 == 0)
          .toList();
      expect(res, [8, 12]);
    });

    test('two dropWhiles in one chain each keep their own latch', () async {
      final res = await fxAsync(
        toAsync([1, 2, 3, 4, 1, 5]),
      ).dropWhile((a) => a < 3).dropWhile((a) => a < 4).toList();
      expect(res, [4, 1, 5]);
    });

    test(
      'the latch is per iterator, so the chain can be consumed twice',
      () async {
        final chain = fxAsync(toAsync([1, 2, 3, 1])).dropWhile((a) => a < 3);
        expect(await chain.toList(), [3, 1]);
        expect(await chain.toList(), [3, 1]);
      },
    );

    test('an async predicate is awaited', () async {
      final res = await fxAsync(
        toAsync([1, 2, 3, 1]),
      ).dropWhile((a) async => a < 3).toList();
      expect(res, [3, 1]);
    });

    test('drops everything when the predicate never fails', () async {
      expect(
        await fxAsync(toAsync([1, 2, 3])).dropWhile((a) => true).toList(),
        <int>[],
      );
    });

    test('a Concurrent marker still reaches the source', () async {
      // The marker must abandon fusion for the layered form, which threads it
      // upstream — the same contract filter/takeWhile already keep. The
      // marker the source sees is the layering's own, not this instance.
      final mock = ConcurrentMock<int>();
      final it = dropWhileAsync((int a) => a < 3, mock).iterator;
      await it.next(Concurrent.of(2));
      expect(mock.received, isA<Concurrent>());
    });

    test('an error from the predicate surfaces', () async {
      expect(
        fxAsync(
          toAsync([1, 2, 3]),
        ).dropWhile((a) => a == 2 ? throw StateError('boom') : true).toList(),
        throwsStateError,
      );
    });
  });

  group('windowed/chunk async fast pull', () {
    test('chunk splits into exact windows plus a partial tail', () async {
      expect(await fxAsync(toAsync([1, 2, 3, 4, 5])).chunk(2).toList(), [
        [1, 2],
        [3, 4],
        [5],
      ]);
    });

    test('windowed overlaps when step < size', () async {
      expect(await fxAsync(toAsync([1, 2, 3, 4])).windowed(2).toList(), [
        [1, 2],
        [2, 3],
        [3, 4],
      ]);
    });

    test('windowed skips when step > size', () async {
      // partial defaults to false, so the lone 7 left by the skip is dropped.
      expect(
        await fxAsync(
          toAsync([1, 2, 3, 4, 5, 6, 7]),
        ).windowed(2, step: 3).toList(),
        [
          [1, 2],
          [4, 5],
        ],
      );
      expect(
        await fxAsync(
          toAsync([1, 2, 3, 4, 5, 6, 7]),
        ).windowed(2, step: 3, partial: true).toList(),
        [
          [1, 2],
          [4, 5],
          [7],
        ],
      );
    });

    test('partial: false drops a short tail', () async {
      expect(await fxAsync(toAsync([1, 2, 3])).windowed(2, step: 2).toList(), [
        [1, 2],
      ]);
    });

    test('an empty source yields nothing', () async {
      expect(await fxAsync(toAsync(<int>[])).chunk(3).toList(), <List<int>>[]);
    });

    test('the same iterable can be consumed twice', () async {
      final chain = fxAsync(toAsync([1, 2, 3, 4])).chunk(2);
      expect(await chain.toList(), await chain.toList());
    });

    test('a Concurrent marker still reaches the source', () async {
      final mock = ConcurrentMock<int>();
      final it = chunkAsync(2, mock).iterator;
      await it.next(Concurrent.of(2));
      expect(mock.received, isA<Concurrent>());
    });

    test('an error from the source surfaces', () async {
      Stream<int> boom() async* {
        yield 1;
        throw StateError('boom');
      }

      expect(fxStream(boom()).chunk(2).toList(), throwsStateError);
    });
  });
}
