// `takeAsync` and `uniqAsync`/`uniqByAsync` are fused stages (FxTakeStage,
// FxUniqByStage) rather than their own iterator layers. That is what keeps a
// stream-sourced chain on the subscription drive: before, `uniq` returned a
// DelegateAsyncIterable, which broke the fused run and dropped the whole
// chain onto the pull protocol (a Completer and a pause/resume per element).
//
// What is pinned here is behaviour the fusion could plausibly break: `take`
// must not pull the element after its last, the counter and the seen-set are
// per-iterator and one-per-run, a Concurrent marker still reaches the
// upstream, and a non-positive count stays off the fused path entirely.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

/// A source that records how many elements were actually pulled from it.
({FxAsyncIterable<int> iterable, List<int> pulled}) counted(int n) {
  final pulled = <int>[];
  final stream = Stream<int>.fromIterable(List<int>.generate(n, (i) => i)).map((
    v,
  ) {
    pulled.add(v);
    return v;
  });
  return (iterable: fromStream(stream), pulled: pulled);
}

void main() {
  group('take async fusion', () {
    test('never pulls the element after its last', () async {
      final src = counted(100);
      expect(await fxAsync(src.iterable).take(3).toList(), [0, 1, 2]);
      expect(src.pulled, [0, 1, 2], reason: 'take(3) pulls exactly 3');
    });

    test(
      'a later stage dropping the last element still ends the run',
      () async {
        final src = counted(100);
        final res = await fxAsync(
          src.iterable,
        ).take(3).filter((v) => v < 2).toList();

        expect(res, [0, 1]);
        expect(
          src.pulled,
          [0, 1, 2],
          reason: 'the count is met at 2, so the source is not pulled again',
        );
      },
    );

    test('counts what reaches it, not what the source produced', () async {
      final src = counted(100);
      final res = await fxAsync(
        src.iterable,
      ).filter((v) => v.isEven).take(3).toList();

      expect(res, [0, 2, 4]);
      expect(src.pulled, [0, 1, 2, 3, 4]);
    });

    test(
      'a second take starts a new run rather than sharing the counter',
      () async {
        expect(
          await fxAsync(
            toAsync([1, 2, 3, 4, 5, 6, 7]),
          ).take(5).take(3).toList(),
          [1, 2, 3],
        );
        expect(
          await fxAsync(
            toAsync([1, 2, 3, 4, 5, 6, 7]),
          ).take(3).take(5).toList(),
          [1, 2, 3],
        );
      },
    );

    test('a non-positive count yields nothing and pulls nothing', () async {
      final src = counted(100);
      expect(await fxAsync(src.iterable).take(0).toList(), <int>[]);
      expect(src.pulled, <int>[]);

      final src2 = counted(100);
      expect(await fxAsync(src2.iterable).take(-3).toList(), <int>[]);
      expect(src2.pulled, <int>[]);
    });

    test('a count past the end drains the source', () async {
      expect(await fxAsync(toAsync([1, 2, 3])).take(99).toList(), [1, 2, 3]);
    });

    test('the counter is per iterator, not per iterable', () async {
      final chain = fxAsync(toAsync([1, 2, 3, 4])).take(2);
      expect(await chain.toList(), [1, 2]);
      expect(await chain.toList(), [1, 2], reason: 'a fresh iterator restarts');
    });
  });

  group('uniq async fusion', () {
    test('uniq keeps the first of each value', () async {
      expect(await fxAsync(toAsync([1, 1, 2, 2, 3, 1])).uniq().toList(), [
        1,
        2,
        3,
      ]);
    });

    test('uniqBy compares the key', () async {
      expect(
        await fxAsync(
          toAsync([1, 11, 2, 21, 3]),
        ).uniqBy((a) => a % 10).toList(),
        [1, 2, 3],
      );
    });

    test('uniqBy awaits an asynchronous key', () async {
      expect(
        await fxAsync(
          toAsync([1, 11, 2, 21, 3]),
        ).uniqBy((a) async => a % 10).toList(),
        [1, 2, 3],
      );
    });

    test(
      'a second uniq starts a new run rather than sharing the seen-set',
      () async {
        expect(await fxAsync(toAsync([1, 1, 2])).uniq().uniq().toList(), [
          1,
          2,
        ]);
      },
    );

    test('the seen-set is per iterator, not per iterable', () async {
      final chain = fxAsync(toAsync([1, 1, 2])).uniq();
      expect(await chain.toList(), [1, 2]);
      expect(await chain.toList(), [1, 2], reason: 'a fresh iterator restarts');
    });
  });

  group('take and uniq fused into one run', () {
    test('a stream chain dedupes, truncates and stops pulling', () async {
      final src = counted(100);
      final res = await fxAsync(
        src.iterable,
      ).map((v) => v % 5).uniq().take(3).toList();

      expect(res, [0, 1, 2]);
      expect(src.pulled, [0, 1, 2], reason: 'take ends the run at its third');
    });

    test('the subscription-drive shape produces the same elements', () async {
      final res =
          await fxStream(
                Stream.fromIterable(['a', 'a', 'bb', 'cc', 'dd', 'ee']),
              )
              .filter((q) => q.length >= 2)
              .uniq()
              .take(2)
              .map((q) async => q.toUpperCase())
              .toList();

      expect(res, ['BB', 'CC']);
    });

    test('an error still reaches the terminal', () async {
      expect(
        fxAsync(
          fromStream(Stream<int>.error(StateError('x'))),
        ).uniq().take(3).toList(),
        throwsStateError,
      );
    });

    test('a Concurrent marker still reaches the source through take', () async {
      // The marker must abandon fusion for the layered form, which threads it
      // upstream — the contract filter/dropWhile already keep.
      final mock = ConcurrentMock<int>();
      final it = takeAsync(3, mock).iterator;
      await it.next(Concurrent.of(2));
      expect(mock.received, isA<Concurrent>());
    });

    test('a Concurrent marker still reaches the source through uniq', () async {
      final mock = ConcurrentMock<int>();
      final it = uniqAsync(mock).iterator;
      await it.next(Concurrent.of(2));
      expect(mock.received, isA<Concurrent>());
    });

    test('a concurrent chain still dedupes and truncates', () async {
      final res = await fxAsync(
        toAsync([1, 2, 3, 4, 5, 6, 7, 8]),
      ).concurrent(4).map((a) async => a * 2).uniq().take(4).toList();

      expect(res, [2, 4, 6, 8]);
    });
  });
}
