// Paths through the fused async machinery that the ordinary terminals never
// reach.
//
// `toList()` over a fused chain runs the *drive* — the stages execute inside
// one loop and never answer a pull. The pull path (`_FusedIterator.nextOr`)
// only runs when something actually pulls element by element, so these tests
// drain the iterator by hand. The asynchronous branch of each stage needs the
// same treatment: a stage that answers synchronously never builds the future
// its `then` continuation lives on.
import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

/// Drains [iterable] one pull at a time, which is what the terminals do not do.
Future<List<T>> pullAll<T>(FxAsyncIterable<T> iterable) async {
  final out = <T>[];
  final it = iterable.iterator;
  while (true) {
    final r = await it.next();
    if (r.done) return out;
    out.add(r.value);
  }
}

void main() {
  group('pull path — one stage per element', () {
    test('map only (the one-to-one shortcut)', () async {
      expect(await pullAll(fxAsync(toAsync([1, 2, 3])).map((a) => a * 2)), [
        2,
        4,
        6,
      ]);
    });

    test('map only, asynchronous transform', () async {
      expect(
        await pullAll(fxAsync(toAsync([1, 2, 3])).map((a) async => a * 2)),
        [2, 4, 6],
      );
    });

    test('filter then an asynchronous map', () async {
      expect(
        await pullAll(
          fxAsync(
            toAsync([1, 2, 3, 4]),
          ).filter((a) => a.isEven).map((a) async => a * 10),
        ),
        [20, 40],
      );
    });

    test('uniqBy with a synchronous key', () async {
      expect(
        await pullAll(
          fxAsync(toAsync([1, 11, 2, 21, 3])).uniqBy((a) => a % 10),
        ),
        [1, 2, 3],
      );
    });

    test('uniqBy with an asynchronous key', () async {
      expect(
        await pullAll(
          fxAsync(toAsync([1, 11, 2, 21, 3])).uniqBy((a) async => a % 10),
        ),
        [1, 2, 3],
      );
    });

    test('uniq with no key at all', () async {
      expect(await pullAll(fxAsync(toAsync([1, 1, 2, 2, 3])).uniq()), [
        1,
        2,
        3,
      ]);
    });

    test('take ends the run without pulling past its last', () async {
      expect(await pullAll(fxAsync(toAsync([1, 2, 3, 4])).take(2)), [1, 2]);
    });

    test('takeWhile with an asynchronous predicate', () async {
      expect(
        await pullAll(
          fxAsync(toAsync([1, 2, 3, 1])).takeWhile((a) async => a < 3),
        ),
        [1, 2],
      );
    });

    test('dropWhile with an asynchronous predicate', () async {
      expect(
        await pullAll(
          fxAsync(toAsync([1, 2, 3, 1])).dropWhile((a) async => a < 3),
        ),
        [3, 1],
      );
    });

    test('scan emits its seed, then each accumulation', () async {
      expect(
        await pullAll(fxAsync(toAsync([1, 2, 3])).scan((a, b) => a + b, 10)),
        [10, 11, 13, 16],
      );
    });

    test('scan with an asynchronous seed', () async {
      expect(
        await pullAll(
          fxAsync(
            toAsync([1, 2, 3]),
          ).scan((a, b) => a + b, Future<int>.value(10)),
        ),
        [10, 11, 13, 16],
      );
    });

    test('scan with an asynchronous fold', () async {
      expect(
        await pullAll(
          fxAsync(toAsync([1, 2, 3])).scan((a, b) async => a + b, 10),
        ),
        [10, 11, 13, 16],
      );
    });

    test('scan with an asynchronous seed and a following stage', () async {
      expect(
        await pullAll(
          fxAsync(
            toAsync([1, 2]),
          ).scan((int a, int b) => a + b, 10).map((a) async => a * 2),
        ),
        [20, 22, 26],
      );
    });

    test('an asynchronous source result still runs the stages', () async {
      Stream<int> slow() async* {
        for (final v in [1, 2, 3, 4]) {
          await Future<void>.delayed(Duration.zero);
          yield v;
        }
      }

      expect(
        await pullAll(fxAsync(fromStream(slow())).filter((a) => a.isOdd)),
        [1, 3],
      );
    });
  });

  group('subscription drive — uniqBy with a key', () {
    test('a synchronous key', () async {
      expect(
        await fxStream(
          Stream.fromIterable([1, 11, 2, 21, 3]),
        ).uniqBy((a) => a % 10).toList(),
        [1, 2, 3],
      );
    });

    test('an asynchronous key', () async {
      expect(
        await fxStream(
          Stream.fromIterable([1, 11, 2, 21, 3]),
        ).uniqBy((a) async => a % 10).toList(),
        [1, 2, 3],
      );
    });
  });

  group('fused drive — take ends the loop', () {
    test('after an element the stages finished synchronously', () async {
      expect(
        await fxAsync(toAsync([1, 2, 3, 4])).map((a) => a * 2).take(2).toList(),
        [2, 4],
      );
    });

    test('after an element an asynchronous stage held', () async {
      expect(
        await fxAsync(
          toAsync([1, 2, 3, 4]),
        ).map((a) async => a * 2).take(2).toList(),
        [2, 4],
      );
    });

    test('after an asynchronous uniq key dropped one', () async {
      expect(
        await fxAsync(
          toAsync([1, 1, 2, 3]),
        ).uniqBy((a) async => a).take(2).toList(),
        [1, 2],
      );
    });
  });

  group('concurrent fallback keeps the legacy layering', () {
    test('take over a concurrent chain yields in order', () async {
      expect(
        await fxAsync(
          toAsync([1, 2, 3, 4, 5, 6]),
        ).concurrent(3).map((a) async => a * 2).take(4).toList(),
        [2, 4, 6, 8],
      );
    });

    test('uniqBy appended to an existing fused run falls back too', () async {
      final mock = ConcurrentMock<int>();
      final it = fxAsync(mock).map((a) => a).uniqBy((a) => a).iterator;
      await it.next(Concurrent.of(2));
      expect(mock.received, isA<Concurrent>());
    });

    test('the legacy uniqBy awaits an asynchronous key', () async {
      expect(
        await fxAsync(
          toAsync([1, 11, 2, 21, 3]),
        ).concurrent(2).uniqBy((a) async => a % 10).toList(),
        [1, 2, 3],
      );
    });

    test('take pulls through the legacy iterator', () async {
      expect(
        await fxAsync(toAsync([1, 2, 3, 4, 5])).concurrent(2).take(3).toList(),
        [1, 2, 3],
      );
    });
  });

  group('zip3 + filter fusion — which side is shortest', () {
    final xs = List<int>.generate(9, (i) => i);

    test('the first side is the shortest', () {
      expect(filter((t) => true, zip3([0, 1], xs, xs)).toList(), [
        (0, 0, 0),
        (1, 1, 1),
      ]);
    });

    test('the third side is the shortest, with the first shorter than the '
        'second', () {
      expect(filter((t) => true, zip3([0, 1, 2, 3], xs, [7, 8])).toList(), [
        (0, 0, 7),
        (1, 1, 8),
      ]);
    });

    test('the second side is the shortest', () {
      expect(filter((t) => true, zip3(xs, [5], xs)).toList(), [(0, 5, 0)]);
    });
  });

  group('a source that is not a fast iterator', () {
    test('one-to-one run pulls it and maps each element', () async {
      expect(await pullAll(fxAsync(SlowSource([1, 2, 3])).map((a) => a * 2)), [
        2,
        4,
        6,
      ]);
    });

    test('one-to-one run ends when it reports done', () async {
      expect(
        await pullAll(fxAsync(SlowSource(<int>[])).map((a) => a)),
        <int>[],
      );
    });

    test('a dropping run pulls it and holds on an async stage', () async {
      expect(
        await pullAll(
          fxAsync(
            SlowSource([1, 2, 3, 4]),
          ).filter((a) => a.isEven).map((a) async => a * 10),
        ),
        [20, 40],
      );
    });
  });

  group('scan that is not first in its run', () {
    test('a stage before it, pulled', () async {
      expect(
        await pullAll(
          fxAsync(
            toAsync([1, 2, 3, 4]),
          ).filter((a) => a.isOdd).scan((int acc, int a) => acc + a, 100),
        ),
        [100, 101, 104],
      );
    });

    test('a stage before it and an asynchronous fold', () async {
      expect(
        await pullAll(
          fxAsync(
            toAsync([1, 2, 3, 4]),
          ).filter((a) => a.isOdd).scan((int acc, int a) async => acc + a, 100),
        ),
        [100, 101, 104],
      );
    });

    test('a following stage can drop the seed itself', () async {
      // The seed is emitted before the source is pulled; a filter after the
      // scan sees it first and can reject it, which sends the run straight
      // back to the source.
      expect(
        await pullAll(
          fxAsync(
            toAsync([1, 2, 3]),
          ).scan((int acc, int a) => acc + a, 0).filter((a) => a > 0),
        ),
        [1, 3, 6],
      );
    });
  });

  group('legacy uniqBy with an asynchronous key', () {
    test('reached when a Concurrent marker lands on uniqBy itself', () async {
      final chain = fxAsync(
        toAsync([1, 11, 2, 21, 3]),
      ).uniqBy((a) async => a % 10);
      final it = chain.iterator;
      final out = <int>[];
      while (true) {
        final r = await it.next(Concurrent.of(2));
        if (r.done) break;
        out.add(r.value);
      }
      expect(out, [1, 2, 3]);
    });
  });

  group('fused drive — take ends the loop from a held continuation', () {
    test('the terminal callback itself is asynchronous', () async {
      final seen = <int>[];
      await fxAsync(toAsync([1, 2, 3, 4])).take(2).each((a) async {
        await Future<void>.delayed(Duration.zero);
        seen.add(a);
      });

      expect(seen, [1, 2], reason: 'the loop ends once the emit future lands');
    });

    test('an asynchronous uniq key drops take\'s last element', () async {
      // take passes its third element and marks the run spent; the uniq key
      // then answers asynchronously and drops it as a duplicate, so the run
      // ends from inside that continuation rather than after an emit.
      expect(
        await fxAsync(
          toAsync([1, 2, 2]),
        ).take(3).uniqBy((a) async => a).toList(),
        [1, 2],
      );
    });
  });
}

/// An async source whose iterator is deliberately *not* an `FxFastIterator`,
/// so a fused run has to take its `next()` branch and answer through a future.
class SlowSource<T> implements FxAsyncIterable<T> {
  SlowSource(this._values);
  final List<T> _values;
  @override
  FxAsyncIterator<T> get iterator => _SlowIterator(_values);
}

class _SlowIterator<T> implements FxAsyncIterator<T> {
  _SlowIterator(this._values);
  final List<T> _values;
  int _i = 0;
  @override
  Future<IterResult<T>> next([Concurrent? concurrent]) async {
    await Future<void>.delayed(Duration.zero);
    if (_i >= _values.length) return IterResult<T>.done();
    return IterResult<T>.value(_values[_i++]);
  }
}
