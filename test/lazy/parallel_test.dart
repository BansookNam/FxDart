@TestOn('vm')
library;

import 'dart:async';
import 'dart:io' as io;
import 'dart:isolate';

import 'package:fxdart/fxdart.dart';
import 'package:fxdart/src/async_iterable.dart' show StreamPullCancel;
import 'package:test/test.dart';

int doubleIt(int x) => x * 2;

int throwsOnThree(int x) {
  if (x == 3) throw StateError('three');
  return x;
}

/// Blocks the worker isolate for a fixed span — the pool's overlap is what
/// is under test, not the machine's core count.
int naps(int x) {
  io.sleep(const Duration(milliseconds: 120));
  return x;
}

/// Throws something that cannot cross a [SendPort]: the isolate boundary
/// falls back to sending the message text.
class Unsendable implements Exception {
  Unsendable(this.port);
  final ReceivePort port;
  @override
  String toString() => 'unsendable boom';
}

int throwsUnsendable(int x) => throw Unsendable(ReceivePort());

int slowDouble(int x) {
  io.sleep(const Duration(milliseconds: 60));
  return x * 2;
}

int slowThrow(int x) {
  io.sleep(const Duration(milliseconds: 60));
  throw StateError('slow boom');
}

void main() {
  group('parallel', () {
    test('yields every element, in order', () async {
      expect(
        await fx([1, 2, 3, 4]).parallel(2, doubleIt).toList(),
        equals([2, 4, 6, 8]),
      );
    });

    test('workers == 1 still runs off-isolate and keeps order', () async {
      expect(
        await fx([1, 2, 3]).parallel(1, doubleIt).toList(),
        equals([2, 4, 6]),
      );
    });

    test('an empty source completes empty', () async {
      expect(await fx(<int>[]).parallel(2, doubleIt).toList(), equals(<int>[]));
    });

    test('a single element', () async {
      expect(await fx([7]).parallel(4, doubleIt).toList(), equals([14]));
    });

    test('workers < 1 throws', () {
      expect(() => parallel(0, doubleIt, [1]), throwsRangeError);
    });

    test('propagates a worker error as itself', () async {
      try {
        await fx([1, 2, 3, 4, 5, 6]).parallel(3, throwsOnThree).toList();
        fail('expected throw');
      } on StateError catch (e) {
        expect(e.message, 'three');
      }
    });

    test('a worker error does not leak unhandled async errors', () async {
      var unhandled = 0;
      await runZonedGuarded(
        () async {
          try {
            await fx([1, 2, 3, 4, 5, 6]).parallel(3, throwsOnThree).toList();
          } catch (_) {}
          await Future<void>.delayed(Duration.zero);
        },
        (e, st) {
          unhandled++;
        },
      );
      expect(unhandled, 0);
    });

    test('take shuts the pool', () async {
      expect(
        await fx([
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ]).parallel(4, doubleIt).take(2).toList(),
        equals([2, 4]),
      );
    });

    test('cancel on the iterator ends further pulls', () async {
      final it = parallel(4, doubleIt, [1, 2, 3, 4, 5, 6, 7, 8]).iterator;
      expect((await it.next()).value, 2);
      await (it as StreamPullCancel).cancel();
      expect((await it.next()).done, isTrue);
    });

    test('head shuts the pool', () async {
      expect(await fx([1, 2, 3, 4]).parallel(2, doubleIt).head(), 2);
    });

    test('overlapping next() keeps source order', () async {
      final it = parallel(2, doubleIt, [1, 2, 3, 4, 5, 6]).iterator;
      final marker = Concurrent.of(3);
      final results = await Future.wait([
        it.next(marker),
        it.next(marker),
        it.next(marker),
      ]);
      expect(
        results.map((r) => r.done ? 'done' : r.value).toList(),
        equals([2, 4, 6]),
      );
    });

    test('parallel then concurrent does not crash and keeps order', () async {
      expect(
        await fx([
          1,
          2,
          3,
          4,
          5,
          6,
        ]).parallel(2, doubleIt).concurrent(3).toList(),
        equals([2, 4, 6, 8, 10, 12]),
      );
    });

    test('a capturing closure of a sendable int runs', () async {
      const factor = 3;
      expect(
        await fx([1, 2, 3]).parallel(2, (int x) => x * factor).toList(),
        equals([3, 6, 9]),
      );
    });

    test('a closure that captures a ReceivePort throws at spawn', () async {
      final port = ReceivePort();
      try {
        expect(
          fx([1, 2, 3]).parallel(2, (x) {
            port.toString();
            return x;
          }).toList(),
          throwsA(isA<ArgumentError>()),
        );
      } finally {
        port.close();
      }
    });

    test('two workers overlap, one does not', () async {
      // Was a CPU-bound stopwatch race, which is a benchmark rather than a
      // test: at ~2ms of work per item the signal sat inside the noise, and
      // it failed under coverage instrumentation on a shared runner
      // (serial 8ms, paired 8ms, needed < 6.8ms). A blocking `sleep` in the
      // worker measures the pool's dispatch instead of the machine's cores,
      // so it neither competes for CPU nor depends on how many cores exist.
      final serial = Stopwatch()..start();
      await fx([1, 2, 3, 4]).parallel(1, naps).toList();
      final serialMs = serial.elapsedMilliseconds;

      final paired = Stopwatch()..start();
      final out = await fx([1, 2, 3, 4]).parallel(2, naps).toList();
      final pairedMs = paired.elapsedMilliseconds;

      expect(out.length, 4);
      // Four 120ms naps: ~480ms one at a time, ~240ms two at a time. The
      // gap is 240ms of wall clock that no amount of scheduler jitter or
      // isolate-spawn overhead closes.
      expect(pairedMs, lessThan(serialMs * 0.7));
    });

    test('async source via parallelAsync', () async {
      expect(
        await fx([1, 2, 3]).toAsync().parallel(2, doubleIt).toList(),
        equals([2, 4, 6]),
      );
    });

    test('parallelAsync rejects workers < 1', () {
      expect(() => parallelAsync(0, doubleIt, toAsync([1])), throwsRangeError);
    });

    test('a worker error that cannot be sent arrives as its text', () async {
      // The isolate entry tries the error object first (same isolate group,
      // so most errors travel as themselves) and falls back to the message
      // text when `send` refuses it. The main side re-wraps a String.
      await expectLater(
        fx([1]).parallel(1, throwsUnsendable).toList(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('unsendable boom'),
          ),
        ),
      );
    });

    test('cancel during a worker error ends as done, not a throw', () async {
      // The worker is still running when the cancel lands, so the error
      // surfaces *after* it — the pull must answer done rather than throw
      // an error nobody is waiting for any more.
      final it = parallel(1, slowThrow, [1, 2, 3]).iterator;
      final pull = it.next();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await (it as StreamPullCancel).cancel();
      expect((await pull).done, isTrue);
    });

    test('cancel while the pool is still spawning kills it', () async {
      // `cancel` lands inside `_ensurePool`'s await, so the pool is born
      // already unwanted and must be killed rather than stored.
      final it = parallel(2, slowDouble, [1, 2, 3, 4]).iterator;
      final pull = it.next();
      await (it as StreamPullCancel).cancel();
      expect((await pull).done, isTrue);
      expect((await it.next()).done, isTrue);
    });

    test('cancel with items queued behind the workers', () async {
      // One worker and several slow items, so an item is waiting for a
      // worker rather than running on one when the pool is killed. Its
      // completer must be settled, not abandoned.
      final it = parallel(1, slowDouble, [1, 2, 3, 4, 5, 6]).iterator;
      expect((await it.next()).value, 2);
      final pending = it.next();
      await (it as StreamPullCancel).cancel();
      expect((await pending).done, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 120));
    });
  });
}
