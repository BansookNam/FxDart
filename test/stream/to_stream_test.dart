import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// Counts how many elements the chain has actually produced, so tests can
/// assert that production tracks consumption instead of running ahead.
({FxAsync<int> chain, int Function() produced}) countingSource(int n) {
  var produced = 0;
  final chain = fx(List<int>.generate(n, (i) => i)).toAsync().map((i) {
    produced++;
    return i;
  });
  return (chain: chain, produced: () => produced);
}

void main() {
  group('toStream', () {
    test('emits every value in order and closes', () async {
      final acc = await fx([1, 2, 3]).toAsync().map((i) => i * 2).toStream().toList();
      expect(acc, equals([2, 4, 6]));
    });

    test('is empty for an empty source', () async {
      expect(await asyncEmpty<int>().toStream().toList(), equals(<int>[]));
    });

    test('produces one element per element consumed', () async {
      final src = countingSource(1000);
      final seen = <int>[];
      await for (final _ in src.chain.toStream()) {
        seen.add(src.produced());
        if (seen.length == 3) break;
      }
      // Lock-step: nothing is produced ahead of the listener.
      expect(seen, equals([1, 2, 3]));
    });

    test('stops producing when the listener breaks', () async {
      final src = countingSource(1000);
      var consumed = 0;
      await for (final _ in src.chain.toStream()) {
        consumed++;
        if (consumed == 3) break;
      }
      expect(src.produced(), equals(3));
    });

    test('never produces more than the listener has consumed', () async {
      // A synchronous chain with a synchronous listener delivers each element
      // inline, so it runs to completion — but never ahead of consumption,
      // which is what a sync controller buys and what buffering would break.
      final src = countingSource(500);
      var consumed = 0;
      final sub = src.chain.toStream().listen((_) {
        consumed++;
        expect(src.produced(), equals(consumed));
      });
      await sub.asFuture<void>();
      expect(consumed, equals(500));
    });

    test('a subscription paused before it starts pulls nothing', () async {
      final src = countingSource(1000);
      final sub = src.chain.toStream().listen((_) {});
      sub.pause();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(src.produced(), equals(0),
          reason: 'a paused subscription must not pull');
      sub.resume();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(src.produced(), greaterThan(0),
          reason: 'resuming must restart production');
      await sub.cancel();
    });

    test('pausing mid-stream stops production', () async {
      var produced = 0;
      final chain = fx(List<int>.generate(200, (i) => i)).toAsync().map((i) async {
        produced++;
        await Future<void>.delayed(const Duration(milliseconds: 1));
        return i;
      });
      final sub = chain.toStream().listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 10));
      sub.pause();
      // The pull already in flight may still land; nothing beyond it may.
      final ceiling = produced + 1;
      expect(produced, greaterThan(0), reason: 'it should have started');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(produced, lessThanOrEqualTo(ceiling),
          reason: 'a paused subscription must not keep pulling');
      final atRest = produced;
      sub.resume();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(produced, greaterThan(atRest),
          reason: 'resuming must restart production');
      await sub.cancel();
    });

    test('cancelling stops production for good', () async {
      final src = countingSource(1000);
      final sub = src.chain.toStream().listen((_) {});
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      final atCancel = src.produced();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(src.produced(), equals(atCancel));
    });

    test('an error reaches the listener and ends the stream', () async {
      final stream = fx([1, 2, 3])
          .toAsync()
          .map((i) => i == 2 ? throw StateError('boom') : i)
          .toStream();
      final seen = <int>[];
      await expectLater(
          stream.listen(seen.add).asFuture<void>(), throwsA(isA<StateError>()));
      expect(seen, equals([1]));
    });

    test('is single-subscription', () {
      final stream = fx([1, 2]).toAsync().toStream();
      stream.listen((_) {});
      expect(() => stream.listen((_) {}), throwsStateError);
    });

    test('does not pull before it is listened to', () async {
      final src = countingSource(10);
      src.chain.toStream();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(src.produced(), equals(0));
    });

    test('a synchronous chain still delivers every element', () async {
      // Exercises the FxFastIterator branch, where pulls answer without a
      // future and the loop runs until the listener pauses.
      final acc =
          await fx(List<int>.generate(200, (i) => i)).toAsync().toStream().toList();
      expect(acc.length, equals(200));
      expect(acc.first, equals(0));
      expect(acc.last, equals(199));
    });
  });

  group('concurrentPool terminals (push drive)', () {
    FxAsync<int> pool(int n, {int concurrency = 3}) => fx(
            List<int>.generate(n, (i) => i))
        .toAsync()
        .map((i) async => i)
        .concurrentPool(concurrency);

    test('toList collects every element', () async {
      final acc = await pool(200).toList();
      expect(acc.length, equals(200));
      expect(acc.toSet(), equals(List<int>.generate(200, (i) => i).toSet()));
    });

    test('each visits every element', () async {
      final seen = <int>[];
      await pool(100).each(seen.add);
      expect(seen.length, equals(100));
    });

    test('an asynchronous each callback keeps completion order', () async {
      final direct = await pool(50).toList();
      final seen = <int>[];
      await pool(50).each((v) async {
        await Future<void>.delayed(Duration.zero);
        seen.add(v);
      });
      expect(seen, equals(direct),
          reason: 'a slow consumer must not reorder or drop elements');
    });

    test('fold accumulates over every element', () async {
      final total = await pool(100).fold<int>(0, (acc, v) => acc + v);
      expect(total, equals(List<int>.generate(100, (i) => i).reduce((a, b) => a + b)));
    });

    test('an asynchronous fold accumulator sees every element', () async {
      final total = await pool(60).fold<int>(0, (acc, v) async {
        await Future<void>.delayed(Duration.zero);
        return acc + v;
      });
      expect(total, equals(List<int>.generate(60, (i) => i).reduce((a, b) => a + b)));
    });

    test('an upstream error fails the terminal', () async {
      final source = fx([1, 2, 3])
          .toAsync()
          .map((i) async => i == 2 ? throw StateError('boom') : i)
          .concurrentPool(2);
      await expectLater(source.toList(), throwsA(isA<StateError>()));
    });

    test('a throwing consumer callback fails the terminal', () async {
      await expectLater(
          pool(50).each((v) => v == 10 ? throw StateError('stop') : null),
          throwsA(isA<StateError>()));
    });

    test('an empty source completes', () async {
      expect(await pool(0).toList(), equals(<int>[]));
    });

    test('the manual pull path still works alongside the drive', () async {
      final it = pool(5).iterator;
      final seen = <int>[];
      while (true) {
        final r = await it.next();
        if (r.done) break;
        seen.add(r.value);
      }
      expect(seen.length, equals(5));
    });
  });
}
