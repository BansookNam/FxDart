@TestOn('vm')
library;

import 'dart:async';
import 'dart:io' as io;
import 'dart:isolate';

import 'package:fxdart/fxdart.dart';
import 'package:fxdart/src/async_iterable.dart' show StreamPullCancel;
import 'package:test/test.dart';

int doubleIt(int x) => x * 2;

int addTen(int x) => x + 10;

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

int closePort(ReceivePort p) {
  p.close();
  return 1;
}

ReceivePort openPort(int x) => ReceivePort();

int? identityNullable(int? x) => x;

int throwsOnSeven(int x) {
  if (x == 7) throw StateError('seven');
  return x * 10;
}

int throwsOnFirst(int x) {
  if (x % 4 == 0) throw StateError('first of batch');
  return x;
}

int throwsUnsendableOnThree(int x) {
  if (x == 3) throw Unsendable(ReceivePort());
  return x;
}

int slowDouble(int x) {
  io.sleep(const Duration(milliseconds: 60));
  return x * 2;
}

int slowThrow(int x) {
  io.sleep(const Duration(milliseconds: 60));
  throw StateError('slow boom');
}

Future<int> laterDouble(int x) async {
  await Future<void>.delayed(Duration.zero);
  return x * 2;
}

Future<int> laterPause(int x) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  return x * 2;
}

Future<int> laterThrow(int x) async {
  await Future<void>.delayed(Duration.zero);
  if (x == 3) throw StateError('async three');
  return x * 2;
}

Future<int> laterThrowSlow(int x) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  throw StateError('async boom');
}

Future<ReceivePort> laterPort(int x) async {
  await Future<void>.delayed(Duration.zero);
  return ReceivePort();
}

Future<int> nestedDoubleSum(int x) async {
  final parts = await fx([x, x]).parallel(2, doubleIt).toList();
  return parts[0] + parts[1];
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

    test('a non-List iterable still runs', () async {
      expect(
        await fx(
          Iterable<int>.generate(4, (i) => i + 1),
        ).parallel(2, doubleIt).toList(),
        equals([2, 4, 6, 8]),
      );
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
        await expectLater(
          fx([1, 2, 3]).parallel(2, (x) {
            port.toString();
            return x;
          }).toList(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('failed to spawn'),
            ),
          ),
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

    test('an empty async source completes empty', () async {
      expect(
        await fx(<int>[]).toAsync().parallel(2, doubleIt).toList(),
        equals(<int>[]),
      );
    });

    test('cancel during the first async pull, before spawn', () async {
      final it = parallelAsync(
        2,
        doubleIt,
        toAsync<int>([
          Future<int>.delayed(const Duration(milliseconds: 50), () => 1),
          2,
          3,
        ]),
      ).iterator;
      final pull = it.next();
      await (it as StreamPullCancel).cancel();
      expect((await pull).done, isTrue);
    });

    test('an unsendable input fails that pull', () async {
      final port = ReceivePort();
      try {
        await expectLater(
          fx([port]).parallel(1, closePort).toList(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('not sendable'),
            ),
          ),
        );
      } finally {
        port.close();
      }
    });

    test('an unsendable result fails that pull, not hang', () async {
      await expectLater(
        fx([1]).parallel(1, openPort).toList(),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('result is not sendable'),
          ),
        ),
      );
    });

    test('parallelWorkers is a valid pool size', () async {
      expect(parallelWorkers, greaterThanOrEqualTo(1));
      expect(
        await fx([1, 2, 3]).parallel(parallelWorkers, doubleIt).toList(),
        equals([2, 4, 6]),
      );
    });

    test('a throwing source shuts the pool', () async {
      // `_fill` used to let a source throw escape without [_shutdown], so
      // the worker ReceivePorts kept the process alive. Same probe as
      // nested-cancel: pings freeze after the error.
      final ping = ReceivePort();
      addTearDown(ping.close);
      var n = 0;
      ping.listen((_) => n++);
      final pingPort = ping.sendPort;

      int pingWork(int x) {
        pingPort.send(x);
        io.sleep(const Duration(milliseconds: 40));
        pingPort.send(x);
        return x;
      }

      Iterable<int> bad() sync* {
        yield 1;
        yield 2;
        yield 3;
        throw StateError('source boom');
      }

      final it = fx(bad()).parallel(2, pingWork).iterator;
      try {
        while (true) {
          final r = await it.next();
          if (r.done) break;
        }
        fail('expected throw');
      } on StateError catch (e) {
        expect(e.message, 'source boom');
      }
      expect((await it.next()).done, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final frozen = n;
      expect(frozen, greaterThan(0));
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(n, frozen);
    });

    test('a throwing source shuts a chunked pool', () async {
      Iterable<int> bad() sync* {
        yield 1;
        yield 2;
        yield 3;
        yield 4;
        throw StateError('chunked source boom');
      }

      final it = fx(bad()).parallel(2, doubleIt, chunk: 2).iterator;
      try {
        while (true) {
          final r = await it.next();
          if (r.done) break;
        }
        fail('expected throw');
      } on StateError catch (e) {
        expect(e.message, 'chunked source boom');
      }
      expect((await it.next()).done, isTrue);
    });

    test('a throwing async source shuts the pool', () async {
      Stream<int> bad() async* {
        yield 1;
        yield 2;
        yield 3;
        throw StateError('async source boom');
      }

      final it = parallelAsync(2, doubleIt, fromStreamNext(bad())).iterator;
      try {
        while (true) {
          final r = await it.next();
          if (r.done) break;
        }
        fail('expected throw');
      } on StateError catch (e) {
        expect(e.message, 'async source boom');
      }
      expect((await it.next()).done, isTrue);
    });

    test('a null element is an element, not the end of the source', () async {
      // `null` used to double as "the source is exhausted", so a nullable
      // [A] silently dropped its nulls.
      const src = <int?>[1, null, 3, null, 5];
      expect(await fx(src).parallel(2, identityNullable).toList(), equals(src));
      expect(
        await fx(src).parallel(2, identityNullable, chunk: 2).toList(),
        equals(src),
      );
      expect(
        await toListAsync(parallelAsync(2, identityNullable, toAsync(src))),
        equals(src),
      );
    });

    test('mapParallel is parallel under the mapConcurrent name', () async {
      expect(
        await fx([1, 2, 3]).mapParallel(2, doubleIt).toList(),
        equals([2, 4, 6]),
      );
      expect(
        await toListAsync(mapParallel(2, doubleIt, [1, 2])),
        equals([2, 4]),
      );
      expect(
        await fx([1, 2]).toAsync().mapParallel(1, doubleIt).toList(),
        equals([2, 4]),
      );
      expect(
        await toListAsync(mapParallelAsync(1, doubleIt, toAsync([3]))),
        equals([6]),
      );
      expect(() => mapParallel(0, doubleIt, [1]), throwsRangeError);
      expect(
        () => mapParallelAsync(0, doubleIt, toAsync([1])),
        throwsRangeError,
      );
    });
  });

  group('parallel chunk', () {
    final src = List<int>.generate(37, (i) => i);
    final want = [for (final x in src) x * 2];

    test('every chunk size yields the same values in the same order', () async {
      for (final k in [1, 2, 5, 36, 37, 38, 1000]) {
        expect(
          await fx(src).parallel(3, doubleIt, chunk: k).toList(),
          equals(want),
          reason: 'chunk: $k',
        );
      }
    });

    test('a ragged final batch is not dropped or padded', () async {
      // 37 over 5 is seven batches of five and one of two.
      expect(await fx(src).parallel(4, doubleIt, chunk: 5).toList(), want);
      expect(
        await fx([1, 2, 3]).parallel(4, doubleIt, chunk: 2).toList(),
        equals([2, 4, 6]),
      );
    });

    test('an empty source spawns nothing', () async {
      expect(
        await fx(<int>[]).parallel(4, doubleIt, chunk: 8).toList(),
        equals(<int>[]),
      );
    });

    test('chunk < 1 throws', () {
      expect(() => fx([1]).parallel(2, doubleIt, chunk: 0), throwsRangeError);
      expect(() => parallel(2, doubleIt, [1], chunk: -1), throwsRangeError);
      expect(
        () => parallelAsync(2, doubleIt, toAsync([1]), chunk: 0),
        throwsRangeError,
      );
      expect(
        () => fx([1]).toAsync().parallel(2, doubleIt, chunk: 0),
        throwsRangeError,
      );
      expect(() => mapParallel(2, doubleIt, [1], chunk: 0), throwsRangeError);
      expect(
        () => mapParallelAsync(2, doubleIt, toAsync([1]), chunk: 0),
        throwsRangeError,
      );
    });

    test('an async source batches too', () async {
      expect(
        await toListAsync(parallelAsync(3, doubleIt, toAsync(src), chunk: 4)),
        equals(want),
      );
      expect(
        await fx(src).toAsync().parallel(3, doubleIt, chunk: 4).toList(),
        equals(want),
      );
      expect(
        await toListAsync(
          parallelAsync(2, doubleIt, toAsync(<int>[]), chunk: 4),
        ),
        equals(<int>[]),
      );
    });

    test('an error lands on the element that threw, not the batch', () async {
      // The whole point of carrying partial results back: batching must not
      // move where the raise happens, or swallow the elements before it.
      for (final k in [1, 4, 16]) {
        final seen = <int>[];
        await expectLater(
          () async {
            await for (final v in fx(
              List<int>.generate(10, (i) => i),
            ).parallel(2, throwsOnSeven, chunk: k).toStream()) {
              seen.add(v);
            }
          }(),
          throwsStateError,
          reason: 'chunk: $k',
        );
        expect(seen, equals([0, 10, 20, 30, 40, 50, 60]), reason: 'chunk: $k');
      }
    });

    test('an error on a batch first element has no prefix to emit', () async {
      // Element 4 opens the second batch of four, so the failure arrives
      // with an empty partial list.
      final seen = <int>[];
      await expectLater(() async {
        await for (final v in fx(
          List<int>.generate(9, (i) => i + 1),
        ).parallel(1, throwsOnFirst, chunk: 4).toStream()) {
          seen.add(v);
        }
      }(), throwsStateError);
      expect(seen, equals([1, 2, 3]));
    });

    test('an unsendable error in a batch arrives as its text', () async {
      await expectLater(
        fx([
          1,
          2,
          3,
          4,
        ]).parallel(1, throwsUnsendableOnThree, chunk: 4).toList(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('unsendable boom'),
          ),
        ),
      );
    });

    test('an unsendable result fails the batch, not hangs', () async {
      await expectLater(
        fx([1, 2]).parallel(1, openPort, chunk: 2).toList(),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('chunked batch'),
          ),
        ),
      );
    });

    test('an unsendable input fails the batch', () async {
      final port = ReceivePort();
      try {
        await expectLater(
          fx([port]).parallel(1, closePort, chunk: 4).toList(),
          throwsA(isA<ArgumentError>()),
        );
      } finally {
        port.close();
      }
    });

    test('an early stop shuts the pool mid-batch', () async {
      expect(
        await fx(
          List<int>.generate(64, (i) => i),
        ).parallel(3, slowDouble, chunk: 8).take(2).toList(),
        equals([0, 2]),
      );
    });

    test('cancel with batches queued ends as done, not a throw', () async {
      final it = fx(
        List<int>.generate(64, (i) => i),
      ).parallel(2, slowDouble, chunk: 8).iterator;
      final pull = it.next();
      await (it as StreamPullCancel).cancel();
      expect((await pull).done, isTrue);
      expect((await it.next()).done, isTrue);
    });

    test('cancel while a batch is in flight ends as done', () async {
      // Distinct from the queued case above: the delay lets the pool finish
      // spawning and hand the batch to a worker, so the pull is parked on
      // the batch future when the kill errors it.
      final it = fx(
        List<int>.generate(16, (i) => i),
      ).parallel(2, slowDouble, chunk: 8).iterator;
      final pull = it.next();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await (it as StreamPullCancel).cancel();
      expect((await pull).done, isTrue);
    });

    test('cancel during an async batch pull', () async {
      final controller = StreamController<int>();
      addTearDown(controller.close);
      final it = fxAsync(
        parallelAsync(2, doubleIt, fromStreamNext(controller.stream), chunk: 4),
      ).iterator;
      final pull = it.next();
      controller.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await (it as StreamPullCancel).cancel();
      expect((await pull).done, isTrue);
    });

    test('overlapping pulls under concurrent keep source order', () async {
      expect(
        await fx(src).parallel(3, doubleIt, chunk: 4).concurrent(3).toList(),
        equals(want),
      );
    });

    test('the pool is sized to the batch count, not the length', () async {
      // 4 items at chunk 4 is one message, so eight workers would be seven
      // idle isolates. Observable only as "this still works".
      expect(
        await fx([1, 2, 3, 4]).parallel(8, doubleIt, chunk: 4).toList(),
        equals([2, 4, 6, 8]),
      );
    });

    test('mapParallel carries chunk through', () async {
      expect(
        await fx(src).mapParallel(2, doubleIt, chunk: 8).toList(),
        equals(want),
      );
      expect(
        await toListAsync(mapParallel(2, doubleIt, src, chunk: 8)),
        equals(want),
      );
      expect(
        await fx(src).toAsync().mapParallel(2, doubleIt, chunk: 8).toList(),
        equals(want),
      );
      expect(
        await toListAsync(
          mapParallelAsync(2, doubleIt, toAsync(src), chunk: 8),
        ),
        equals(want),
      );
    });
  });

  group('parallel FutureOr worker', () {
    test('an async worker yields in order', () async {
      expect(
        await fx([1, 2, 3, 4]).parallel(2, laterDouble).toList(),
        equals([2, 4, 6, 8]),
      );
    });

    test('an async worker error surfaces as itself', () async {
      await expectLater(
        fx([1, 2, 3, 4]).parallel(2, laterThrow).toList(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('async three'),
          ),
        ),
      );
    });

    test('an async unsendable result fails that pull', () async {
      await expectLater(
        fx([1]).parallel(1, laterPort).toList(),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('chunked async workers keep order', () async {
      expect(
        await fx([1, 2, 3, 4]).parallel(2, laterDouble, chunk: 2).toList(),
        equals([2, 4, 6, 8]),
      );
    });

    test('chunked async worker error emits the prefix then throws', () async {
      final it = fx([1, 2, 3, 4]).parallel(1, laterThrow, chunk: 4).iterator;
      expect((await it.next()).value, 2);
      expect((await it.next()).value, 4);
      await expectLater(it.next(), throwsA(isA<StateError>()));
    });

    test('cancel during an async worker ends as done', () async {
      final it = fx([1, 2, 3]).parallel(1, laterPause).iterator;
      final pull = it.next();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await (it as StreamPullCancel).cancel();
      expect((await pull).done, isTrue);
    });

    test('cancel during an async worker error ends as done', () async {
      final it = fx([1, 2, 3]).parallel(1, laterThrowSlow).iterator;
      final pull = it.next();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await (it as StreamPullCancel).cancel();
      expect((await pull).done, isTrue);
    });

    test('cancel during a chunked async worker ends as done', () async {
      final it = fx([1, 2, 3, 4]).parallel(1, laterPause, chunk: 4).iterator;
      final pull = it.next();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await (it as StreamPullCancel).cancel();
      expect((await pull).done, isTrue);
    });

    test('cancel during a chunked async worker error ends as done', () async {
      final it = fx([
        1,
        2,
        3,
        4,
      ]).parallel(1, laterThrowSlow, chunk: 4).iterator;
      final pull = it.next();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await (it as StreamPullCancel).cancel();
      expect((await pull).done, isTrue);
    });

    test('nested parallel runs the inner pool to completion', () async {
      expect(
        await fx([1, 2, 3]).parallel(2, nestedDoubleSum).toList(),
        equals([4, 8, 12]),
      );
    });

    test('cancel reaps nested worker isolates', () async {
      // Two-level nested `parallel` is the contract [_killNested] pins.
      // A third nested pool would be SIGKILL'd with the inner workers
      // and is not asserted here.
      final ping = ReceivePort();
      addTearDown(ping.close);
      var n = 0;
      ping.listen((_) => n++);
      final pingPort = ping.sendPort;

      int pingLoop(int x) {
        for (var i = 0; i < 40; i++) {
          pingPort.send(x);
          io.sleep(const Duration(milliseconds: 25));
        }
        return x;
      }

      Future<int> outer(int x) async {
        final parts = await fx([x, x + 1]).parallel(2, pingLoop).toList();
        return parts[0];
      }

      final it = fx([1, 2]).parallel(1, outer).iterator;
      final pull = it.next();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(n, greaterThan(0));
      await (it as StreamPullCancel).cancel();
      expect((await pull).done, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final frozen = n;
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(n, frozen);
    });
  });

  group('parallel chunked: true', () {
    test('sizes k from length and workers', () async {
      // 20 items, 2 workers: 20 ~/ 8 = 2. Same values as chunk: 2.
      final src = [for (var i = 1; i <= 20; i++) i];
      final want = [for (final x in src) x * 2];
      expect(
        await fx(src).parallel(2, doubleIt, chunked: true).toList(),
        equals(want),
      );
      expect(
        await fx(src).parallel(2, doubleIt, chunk: 2).toList(),
        equals(want),
      );
    });

    test('a short list falls back to chunk 1', () async {
      expect(
        await fx([1, 2, 3]).parallel(8, doubleIt, chunked: true).toList(),
        equals([2, 4, 6]),
      );
    });

    test('chunked: true with chunk: k throws', () {
      expect(
        () => fx([1, 2, 3, 4]).parallel(2, doubleIt, chunk: 2, chunked: true),
        throwsArgumentError,
      );
    });

    test('chunked: true on a non-List throws', () {
      expect(
        () => fx(
          Iterable<int>.generate(8, (i) => i),
        ).parallel(2, doubleIt, chunked: true),
        throwsStateError,
      );
    });

    test('chunked: true on an async source throws', () {
      expect(
        () => fx([1, 2, 3, 4]).toAsync().parallel(2, doubleIt, chunked: true),
        throwsStateError,
      );
    });

    test('mapParallel carries chunked', () async {
      final src = [for (var i = 1; i <= 16; i++) i];
      expect(
        await fx(src).mapParallel(2, doubleIt, chunked: true).toList(),
        equals([for (final x in src) x * 2]),
      );
    });

    test('an empty list still spawns nothing', () async {
      expect(
        await fx(<int>[]).parallel(4, doubleIt, chunked: true).toList(),
        equals(<int>[]),
      );
    });
  });

  group('isolateMap2', () {
    test('runs both workers in one hop', () async {
      expect(
        await fx([1, 2, 3]).parallel(2, isolateMap2(doubleIt, addTen)).toList(),
        equals([12, 14, 16]),
      );
    });

    test('composes under chunk', () async {
      expect(
        await fx([
          1,
          2,
          3,
          4,
        ]).parallel(2, isolateMap2(doubleIt, addTen), chunk: 2).toList(),
        equals([12, 14, 16, 18]),
      );
    });

    test('isolateMap3..5 compose on the worker', () async {
      expect(
        await fx([
          1,
          2,
        ]).parallel(1, isolateMap3(doubleIt, addTen, doubleIt)).toList(),
        equals([24, 28]),
      );
      expect(
        await fx(
          [1],
        ).parallel(1, isolateMap4(doubleIt, addTen, doubleIt, addTen)).toList(),
        equals([34]),
      );
      expect(
        await fx([1])
            .parallel(
              1,
              isolateMap5(doubleIt, addTen, doubleIt, addTen, doubleIt),
            )
            .toList(),
        equals([68]),
      );
    });
  });

  group('IsolatePool', () {
    test('reuses isolates across two chains', () async {
      await IsolatePool.using(2, (pool) async {
        expect(
          await fx([1, 2, 3, 4]).parallelOn(pool, doubleIt).toList(),
          equals([2, 4, 6, 8]),
        );
        expect(
          await fx([5, 6]).parallelOn(pool, doubleIt, chunk: 2).toList(),
          equals([10, 12]),
        );
        expect(pool.isClosed, isFalse);
      });
    });

    test('kill rejects a later parallelOn', () async {
      final pool = await IsolatePool.spawn(1);
      pool.kill();
      expect(() => fx([1]).parallelOn(pool, doubleIt), throwsStateError);
    });

    test('using kills the pool even when body throws', () async {
      IsolatePool? seen;
      try {
        await IsolatePool.using(1, (pool) async {
          seen = pool;
          await fx([1]).parallelOn(pool, doubleIt).toList();
          throw StateError('boom');
        });
      } on StateError catch (e) {
        expect(e.message, 'boom');
      }
      expect(seen!.isClosed, isTrue);
    });

    test('cancel of one chain leaves the pool for the next', () async {
      await IsolatePool.using(2, (pool) async {
        final it = fx([1, 2, 3, 4, 5, 6]).parallelOn(pool, slowDouble).iterator;
        expect((await it.next()).value, 2);
        await (it as StreamPullCancel).cancel();
        expect((await it.next()).done, isTrue);
        expect(
          await fx([7, 8]).parallelOn(pool, doubleIt).toList(),
          equals([14, 16]),
        );
      });
    });

    test(
      'two chains on one worker queue instead of over-subscribing',
      () async {
        await IsolatePool.using(1, (pool) async {
          final a = fx([1, 2]).parallelOn(pool, slowDouble).toList();
          final b = fx([3, 4]).parallelOn(pool, slowDouble).toList();
          final results = await Future.wait([a, b]);
          expect(results[0], equals([2, 4]));
          expect(results[1], equals([6, 8]));
        });
      },
    );

    test('parallelOn chunked: true uses the pool size', () async {
      final src = [for (var i = 1; i <= 20; i++) i];
      await IsolatePool.using(2, (pool) async {
        expect(
          await fx(src).parallelOn(pool, doubleIt, chunked: true).toList(),
          equals([for (final x in src) x * 2]),
        );
      });
    });

    test('async source via parallelOn', () async {
      await IsolatePool.using(2, (pool) async {
        expect(
          await fx([1, 2, 3]).toAsync().parallelOn(pool, doubleIt).toList(),
          equals([2, 4, 6]),
        );
      });
    });

    test('spawn rejects workers < 1', () {
      expect(() => IsolatePool.spawn(0), throwsRangeError);
    });

    test('a chunked worker error emits the prefix', () async {
      await IsolatePool.using(1, (pool) async {
        final it = fx([
          1,
          2,
          3,
          4,
        ]).parallelOn(pool, throwsOnThree, chunk: 4).iterator;
        expect((await it.next()).value, 1);
        expect((await it.next()).value, 2);
        await expectLater(it.next(), throwsA(isA<StateError>()));
      });
    });

    test('a worker error leaves the pool usable', () async {
      await IsolatePool.using(1, (pool) async {
        await expectLater(
          fx([1, 2, 3]).parallelOn(pool, throwsOnThree).toList(),
          throwsA(isA<StateError>()),
        );
        expect(await fx([4]).parallelOn(pool, doubleIt).toList(), equals([8]));
      });
    });

    test('an unsendable result fails that pull', () async {
      await IsolatePool.using(1, (pool) async {
        await expectLater(
          fx([1]).parallelOn(pool, openPort).toList(),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    test('kill during an in-flight job fails the pull', () async {
      final pool = await IsolatePool.spawn(1);
      final it = fx([1, 2, 3]).parallelOn(pool, slowDouble).iterator;
      final pull = it.next();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      pool.kill();
      try {
        await pull;
      } on StateError catch (e) {
        expect(e.message, contains('closed'));
        return;
      }
      // The first result may already have been in hand.
      expect((await it.next()).done, isTrue);
    });
  });
}
