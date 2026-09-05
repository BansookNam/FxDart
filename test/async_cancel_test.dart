@TestOn('vm')
library;

import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:fxdart/src/async_iterable.dart'
    show
        DelegateAsyncIterator,
        IterResult,
        SerialAsyncIterator,
        StreamPullCancel,
        fxCancel,
        fxCancelAll;
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

/// A live source that reports whether its subscription was released.
///
/// This is the observable stand-in for `parallel`'s isolate pool: both hold
/// a resource behind [StreamPullCancel], and a leak in either has the same
/// cause — an operator between the consumer and the source that does not
/// forward `cancel`. A leaked pool only shows up as a process that never
/// exits, which a test runner cannot see; a leaked subscription is a bool.
class _LiveSource {
  _LiveSource() {
    _controller = StreamController<int>(onCancel: () => cancelled = true);
    _timer = Timer.periodic(const Duration(milliseconds: 2), (_) {
      if (!_controller.isClosed) _controller.add(_next++);
    });
  }

  late final StreamController<int> _controller;
  late final Timer _timer;
  int _next = 1;
  bool cancelled = false;

  FxAsync<int> get chain => fxAsync(fromStreamNext(_controller.stream));

  void dispose() {
    _timer.cancel();
    if (!_controller.isClosed) _controller.close();
  }
}

/// Runs [build] to completion and returns whether the source was released.
Future<bool> releasedBy(Future<void> Function(FxAsync<int> src) build) async {
  final live = _LiveSource();
  try {
    await build(live.chain);
    // Cancels are dispatched without being awaited, so give the microtask
    // and the subscription's own cancel a turn to run.
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return live.cancelled;
  } finally {
    live.dispose();
  }
}

void main() {
  group('early stop releases the source', () {
    // Every operator here sits between the consumer and the resource. One
    // that drops `cancel` on the floor is a hole: `parallel` behind it keeps
    // its isolates and the program never exits.
    final chains = <String, Future<void> Function(FxAsync<int>)>{
      'take': (s) => s.take(2).toList(),
      'takeWhile': (s) => s.takeWhile((v) => v < 3).toList(),
      'takeUntilInclusive': (s) => s.takeUntilInclusive((v) => v > 1).toList(),
      'slice': (s) => s.slice(0, 2).toList(),
      'head': (s) => s.head(),
      'find': (s) => s.find((v) => v == 2),
      'some': (s) => s.some((v) => v == 2),
      'every': (s) => s.every((v) => v < 2),
      'none': (s) => s.none((v) => v == 2),
      'map + take': (s) => s.map((v) => v).take(2).toList(),
      'filter + take': (s) => s.filter((v) => v.isOdd).take(2).toList(),
      'drop + take': (s) => s.drop(1).take(2).toList(),
      'dropWhile + take': (s) => s.dropWhile((v) => v < 2).take(2).toList(),
      'scan + take': (s) => s.scan((a, v) => a + v, 0).take(2).toList(),
      'chunk + take': (s) => s.chunk(2).take(1).toList(),
      'windowed + take': (s) => s.windowed(2).take(1).toList(),
      'pairwise + take': (s) => s.pairwise().take(1).toList(),
      'flatMap + take': (s) => s.flatMap((v) => [v]).take(2).toList(),
      'flat + take': (s) => s.map((v) => [v]).flat().take(2).toList(),
      'expand + take': (s) => s.expand((v) => [v]).take(2).toList(),
      'concat + take': (s) => s.concat(fx([0]).toAsync()).take(2).toList(),
      'append + take': (s) => s.append(0).take(2).toList(),
      'prepend + take': (s) => s.prepend(0).take(2).toList(),
      'indexed + take': (s) => s.indexed().take(2).toList(),
      'uniq + take': (s) => s.uniq().take(2).toList(),
      'uniqAdjacent + take': (s) => s.uniqAdjacent().take(2).toList(),
      'timeout + take': (s) =>
          s.timeout(const Duration(seconds: 5)).take(2).toList(),
      'concurrent + take': (s) => s.concurrent(2).take(2).toList(),
      'concurrentPool + take': (s) => s.concurrentPool(2).take(2).toList(),
      'mapConcurrent + take': (s) =>
          s.mapConcurrent(2, (v) async => v).take(2).toList(),
      'toStream + cancelled listener': (s) async {
        final sub = s.toStream().listen(null);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await sub.cancel();
      },
    };

    for (final entry in chains.entries) {
      test(entry.key, () async {
        expect(await releasedBy(entry.value), isTrue);
      });
    }

    // zip and zip3 end with their shortest side, so they must release the
    // longer one themselves — no downstream operator sends them a cancel.
    test('zip releases the longer side', () async {
      expect(
        await releasedBy((s) => s.zip(fx([1, 2]).toAsync()).toList()),
        isTrue,
      );
    });

    test('zip3 releases the longer sides', () async {
      expect(
        await releasedBy(
          (s) => s.zip3(fx([1, 2]).toAsync(), fx([1, 2]).toAsync()).toList(),
        ),
        isTrue,
      );
    });
  });

  group('cancel does not truncate work already in flight', () {
    test('take(n) under concurrent still delivers its n values', () async {
      // `take`'s count runs out on an overlapping pull while earlier pulls
      // are still upstream. Releasing then would abort the values they are
      // about to deliver.
      final out = await fx([1, 2, 3, 4, 5, 6, 7, 8])
          .toAsync()
          .map((a) async {
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return a * 10;
          })
          .take(3)
          .concurrent(4)
          .toList();
      expect(out, equals([10, 20, 30]));
    });

    test('an eager release under concurrent keeps every value', () async {
      // `zip`, `slice` and `takeUntilInclusive` release the source the
      // moment they know they are done, with no in-flight guard of `take`'s.
      // That is only safe because the pull protocol answers in order, so an
      // overlapping pull cannot reach the release before the pulls issued
      // ahead of it have their values. Pinned, because nothing else states it.
      FxAsync<int> slow(List<int> xs, int ms) =>
          fx(xs).toAsync().map((a) async {
            await Future<void>.delayed(Duration(milliseconds: ms));
            return a;
          });

      expect(
        await slow([1, 2, 3, 4, 5, 6], 20)
            .zip(slow([1, 2, 3], 5))
            .concurrent(4)
            .toList(),
        equals([(1, 1), (2, 2), (3, 3)]),
      );
      expect(
        await slow([1, 2, 3, 4, 5, 6], 20).slice(0, 3).concurrent(4).toList(),
        equals([1, 2, 3]),
      );
      expect(
        await slow([1, 2, 3, 4, 5, 6], 20)
            .takeUntilInclusive((v) => v == 3)
            .concurrent(4)
            .toList(),
        equals([1, 2, 3]),
      );
    });

    test('a full drain is unaffected', () async {
      final live = _LiveSource();
      addTearDown(live.dispose);
      final out = await live.chain.take(3).toList();
      expect(out.length, 3);
    });
  });

  group('operators with their own teardown', () {
    test('using releases the resource on an early stop', () async {
      var released = 0;
      final out = await fxAsync(
        usingAsync<String, int>(
          () => 'db',
          (r) => fx([1, 2, 3, 4]).toAsync(),
          (r) => released++,
        ),
      ).take(2).toList();
      expect(out, equals([1, 2]));
      expect(released, 1);
    });

    test('using cancelled before the first pull releases nothing', () async {
      var released = 0;
      var acquired = 0;
      final it = usingAsync<String, int>(
        () {
          acquired++;
          return 'db';
        },
        (r) => fx([1, 2]).toAsync(),
        (r) => released++,
      ).iterator;
      // Nothing was acquired, so there is nothing to release — and the
      // release callback must not run for a resource that never existed.
      await (it as StreamPullCancel).cancel();
      expect(acquired, 0);
      expect(released, 0);
      expect((await it.next()).done, isTrue);
    });

    test('difference releases its source on an early stop', () async {
      expect(
        await releasedBy(
          (s) => s.difference(fx([99]).toAsync()).take(2).toList(),
        ),
        isTrue,
      );
    });

    test('intersection releases its source on an early stop', () async {
      expect(
        await releasedBy(
          (s) => s.intersection(fx([1, 2, 3, 4]).toAsync()).take(2).toList(),
        ),
        isTrue,
      );
    });

    test('take under concurrent forwards a cancel it is handed', () async {
      // `take` fuses by default; a Concurrent marker drops it to the
      // unfused layering, and that spelling has its own cancel to forward.
      expect(await releasedBy((s) => s.take(5).concurrent(2).head()), isTrue);
    });

    test('take forwards a cancel it is handed', () async {
      // `take` behind another early stop: the outer one cancels the inner
      // take, which must pass it on rather than swallow it.
      expect(await releasedBy((s) => s.take(5).head()), isTrue);
      expect(await releasedBy((s) => s.take(5).take(2).toList()), isTrue);
    });
  });

  group('an error releases the source too', () {
    FxAsync<int> throwingAfter(int n, _LiveSource live) => live.chain.map((v) {
      if (v > n) throw StateError('boom');
      return v;
    });

    test('head', () async {
      final live = _LiveSource();
      addTearDown(live.dispose);
      await expectLater(throwingAfter(0, live).head(), throwsStateError);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(live.cancelled, isTrue);
    });

    test('every', () async {
      final live = _LiveSource();
      addTearDown(live.dispose);
      await expectLater(
        throwingAfter(1, live).every((v) => true),
        throwsStateError,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(live.cancelled, isTrue);
    });

    test('some', () async {
      final live = _LiveSource();
      addTearDown(live.dispose);
      await expectLater(
        throwingAfter(1, live).some((v) => false),
        throwsStateError,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(live.cancelled, isTrue);
    });

    test('none', () async {
      final live = _LiveSource();
      addTearDown(live.dispose);
      await expectLater(
        throwingAfter(1, live).none((v) => false),
        throwsStateError,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(live.cancelled, isTrue);
    });
  });

  group('a terminal that stops early releases the source', () {
    // Every one of these ends the drain with the source still live. The
    // observable stand-in is a subscription; behind a `parallel` the same
    // hole is a pool of isolates that keeps the process alive forever.
    test('nth', () async {
      expect(await releasedBy((s) => nthAsync(1, s)), isTrue);
    });

    test('firstNotNullOf', () async {
      expect(
        await releasedBy((s) => s.firstNotNullOf((v) => v == 2 ? 'two' : null)),
        isTrue,
      );
    });

    test('consume with a count', () async {
      expect(await releasedBy((s) => s.consume(2)), isTrue);
    });

    test('consume with no count drains and needs no release', () async {
      // The counted form stops early; the uncounted one runs the source out,
      // so there is nothing left holding anything.
      await expectLater(fx([1, 2, 3]).toAsync().consume(), completes);
    });
  });

  group('a throwing callback releases the source', () {
    // The pull itself is fine here — it is the terminal's own callback that
    // ends the drain, so nothing downstream will send a cancel.
    Future<bool> releasedByThrow(
      Future<void> Function(FxAsync<int> src) build,
    ) => releasedBy((s) async {
      await expectLater(build(s), throwsStateError);
    });

    test('each', () async {
      expect(
        await releasedByThrow((s) {
          return s.each((v) {
            if (v > 1) throw StateError('boom');
          });
        }),
        isTrue,
      );
    });

    test('fold', () async {
      expect(
        await releasedByThrow((s) {
          return s.fold<int>(0, (acc, v) {
            if (v > 1) throw StateError('boom');
            return acc + v;
          });
        }),
        isTrue,
      );
    });

    test('reduce', () async {
      expect(
        await releasedByThrow((s) {
          return s.reduce((acc, v) {
            if (v > 1) throw StateError('boom');
            return acc + v;
          });
        }),
        isTrue,
      );
    });

    test('firstNotNullOf', () async {
      expect(
        await releasedByThrow(
          (s) => s.firstNotNullOf<String>((v) => throw StateError('boom')),
        ),
        isTrue,
      );
    });

    test('nth', () async {
      expect(
        await releasedByThrow((s) async {
          await nthAsync(
            3,
            s.map((v) {
              if (v > 1) throw StateError('boom');
              return v;
            }),
          );
        }),
        isTrue,
      );
    });

    test('consume', () async {
      expect(
        await releasedByThrow(
          (s) => s.map<int>((v) {
            if (v > 1) throw StateError('boom');
            return v;
          }).consume(4),
        ),
        isTrue,
      );
    });

    test('toList', () async {
      expect(
        await releasedByThrow(
          (s) => s.map<int>((v) {
            if (v > 1) throw StateError('boom');
            return v;
          }).toList(),
        ),
        isTrue,
      );
    });
  });

  group('cancel is awaitable, and a failing release is reported', () {
    test('await cancel() waits for an async release', () async {
      // The release future used to be dropped on the way up, so `cancel`
      // resolved while the resource was still open.
      var released = false;
      final it = fxAsync(
        usingAsync<String, int>(
          () => 'db',
          (r) => fx([1, 2, 3, 4]).toAsync(),
          (r) async {
            await Future<void>.delayed(const Duration(milliseconds: 20));
            released = true;
          },
        ),
      ).map((v) => v).iterator;
      await it.next();
      await (it as StreamPullCancel).cancel();
      expect(released, isTrue);
    });

    test('a release that throws on an early stop reaches the caller', () async {
      // It used to kill the program: the failed release future had no
      // listener, so it surfaced as an unhandled async error *after* the
      // caller had already been handed its result.
      await expectLater(
        fxAsync(
          usingAsync<String, int>(
            () => 'db',
            (r) => fx([1, 2, 3, 4]).toAsync(),
            (r) => throw StateError('release boom'),
          ),
        ).take(2).toList(),
        throwsStateError,
      );
      // A turn for anything unobserved to blow up in, had it been left so.
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });

    test('an error keeps its own identity over a failing release', () async {
      // On the failure path the error already in hand wins; the release is
      // still run, and its own failure must not replace it.
      await expectLater(
        fxAsync(
          usingAsync<String, int>(
            () => 'db',
            (r) => fx([1, 2, 3]).toAsync(),
            (r) => throw StateError('release boom'),
          ),
        ).map<int>((v) => throw FormatException('pull boom')).toList(),
        throwsFormatException,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
  });

  group('fxCancel', () {
    test('is a no-op on something that cannot be cancelled', () {
      expect(() => fxCancel(42), returnsNormally);
      expect(() => fxCancel(null), returnsNormally);
      expect(() => fxCancel(<Object>[1, 'two']), returnsNormally);
    });

    test('fxCancelAll joins an upstream with an owned release', () async {
      // No operator in the library passes both halves today — `take` owns a
      // release, the rest forward an upstream — but the join is what makes
      // `cancel()` mean "everything under me", so it is pinned here.
      final live = _LiveSource();
      addTearDown(live.dispose);
      final upstream = live.chain.iterator;
      await upstream.next();
      var ownRan = false;
      final it = DelegateAsyncIterator<int>(
        (_) => Future.value(IterResult<int>.done()),
        upstream: upstream,
        cancel: () async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          ownRan = true;
        },
      );
      await it.cancel();
      expect(ownRan, isTrue);
      expect(live.cancelled, isTrue);
    });

    test('a serialized operator forwards a multi-source upstream', () async {
      // `SerialAsyncIterator` takes the same `upstream:` as the delegate
      // form, including the list shape the multi-source operators hold.
      final a = _LiveSource();
      final b = _LiveSource();
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      final ita = a.chain.iterator;
      final itb = b.chain.iterator;
      await ita.next();
      await itb.next();
      final it = SerialAsyncIterator<int>(
        (_) => Future.value(IterResult<int>.done()),
        upstream: [ita, itb],
      );
      await it.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(a.cancelled, isTrue);
      expect(b.cancelled, isTrue);
    });

    test('fxCancelAll with nothing to release still resolves', () async {
      await expectLater(fxCancelAll(null), completes);
    });

    test('reaches every element of an iterable', () async {
      final a = _LiveSource();
      final b = _LiveSource();
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      final ita = a.chain.iterator;
      final itb = b.chain.iterator;
      await ita.next();
      await itb.next();
      fxCancel([ita, itb]);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(a.cancelled, isTrue);
      expect(b.cancelled, isTrue);
    });
  });
}
