@TestOn('vm')
library;

import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:fxdart/src/async_iterable.dart' show fxCancel;
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

    test('a full drain is unaffected', () async {
      final live = _LiveSource();
      addTearDown(live.dispose);
      final out = await live.chain.take(3).toList();
      expect(out.length, 3);
    });
  });

  group('fxCancel', () {
    test('is a no-op on something that cannot be cancelled', () {
      expect(() => fxCancel(42), returnsNormally);
      expect(() => fxCancel(null), returnsNormally);
      expect(() => fxCancel(<Object>[1, 'two']), returnsNormally);
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
