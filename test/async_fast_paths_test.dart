// White-box tests for the 0.7.4 async fast-pull machinery: fused stages,
// the Concurrent fallback, the stream bridge / subscription drive, and the
// fast paths of scan / flatMap / using / timeout. These pin behavior the
// per-operator tests reach only via one path.
import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:fxdart/src/async_iterable.dart' show FxFastIterator;
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

Future<T> delayed<T>(T value) async {
  await Future<void>.delayed(Duration.zero);
  return value;
}

/// A contract-violating stream whose subscription ignores pause: all values
/// are delivered on consecutive microtasks after listen, then done.
class _RudeStream extends Stream<int> {
  _RudeStream(this.values);
  final List<int> values;

  @override
  StreamSubscription<int> listen(
    void Function(int)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final sub = _RudeSubscription();
    // One burst: all values in a single microtask, ignoring pause entirely.
    Future.microtask(() {
      for (final v in values) {
        if (sub.cancelled) return;
        onData?.call(v);
      }
      if (!sub.cancelled) onDone?.call();
    });
    return sub;
  }
}

class _RudeSubscription implements StreamSubscription<int> {
  bool cancelled = false;

  @override
  Future<void> cancel() {
    cancelled = true;
    return Future.value();
  }

  @override
  void pause([Future<void>? resumeSignal]) {} // deliberately ignored

  @override
  void resume() {}

  @override
  bool get isPaused => false;

  @override
  Future<E> asFuture<E>([E? futureValue]) => Completer<E>().future;

  @override
  void onData(void Function(int data)? handleData) {}

  @override
  void onDone(void Function()? handleDone) {}

  @override
  void onError(Function? handleError) {}
}

void main() {
  group('fused stages (map/filter/takeWhile)', () {
    test('sync stages produce the layered result and effect order', () async {
      final log = <String>[];
      final out = await toListAsync(
        mapAsync(
          (int a) {
            log.add('m$a');
            return a * 10;
          },
          filterAsync((int a) {
            log.add('f$a');
            return a % 2 == 0;
          }, toAsync([1, 2, 3, 4])),
        ),
      );
      expect(out, equals([20, 40]));
      expect(log, equals(['f1', 'f2', 'm2', 'f3', 'f4', 'm4']));
    });

    test('async callbacks inside fused stages', () async {
      final out = await toListAsync(
        mapAsync(
          (int a) => delayed(a + 100),
          filterAsync((int a) => delayed(a > 1), toAsync([1, 2, 3])),
        ),
      );
      expect(out, equals([102, 103]));
    });

    test(
      'takeWhile stage ends the whole fused chain (sync and async)',
      () async {
        expect(
          await toListAsync(
            mapAsync(
              (int a) => a * 2,
              takeWhileAsync((int a) => a < 3, toAsync([1, 2, 3, 4])),
            ),
          ),
          equals([2, 4]),
        );
        expect(
          await toListAsync(
            mapAsync(
              (int a) => a * 2,
              takeWhileAsync((int a) => delayed(a < 3), toAsync([1, 2, 3, 4])),
            ),
          ),
          equals([2, 4]),
        );
      },
    );

    test('a sync callback throw rejects the pull', () async {
      await expectLater(
        toListAsync(
          mapAsync<int, int>((a) => throw StateError('boom'), toAsync([1, 2])),
        ),
        throwsStateError,
      );
    });

    test('filter-everything-out and empty sources drain to empty', () async {
      expect(
        await toListAsync(filterAsync((int a) => false, toAsync([1, 2]))),
        equals(<int>[]),
      );
      expect(
        await toListAsync(mapAsync((int a) => a, toAsync(<int>[]))),
        equals(<int>[]),
      );
    });

    test('fused chain under concurrent(n) matches serial output', () async {
      final out = await fxAsync(toAsync([1, 2, 3, 4, 5, 6]))
          .map((a) => delayed(a * 2))
          .filter((a) => a % 3 != 0)
          .concurrent(3)
          .toList();
      expect(out, equals([2, 4, 8, 10]));
    });

    test(
      'marked first pull then unmarked pulls (legacy fallback mix)',
      () async {
        // Covers fb.next(concurrent) with and without the marker on the same
        // iterator, for each fused/fast operator kind.
        Future<void> mix(FxAsyncIterable<int> chain, List<int> expected) async {
          final it = chain.iterator;
          final got = <int>[];
          var r = await it.next(Concurrent.of(2));
          while (!r.done) {
            got.add(r.value);
            r = await it.next();
          }
          expect(got, equals(expected));
        }

        await mix(mapAsync((int a) => a + 1, toAsync([1, 2, 3])), [2, 3, 4]);
        await mix(filterAsync((int a) => a != 2, toAsync([1, 2, 3])), [1, 3]);
        await mix(takeWhileAsync((int a) => a < 3, toAsync([1, 2, 3])), [1, 2]);
        await mix(
          scanAsync((int acc, int a) => acc + a, 0, toAsync([1, 2, 3])),
          [0, 1, 3, 6],
        );
        await mix(flatMapAsync((int a) => [a, -a], toAsync([1, 2])), [
          1,
          -1,
          2,
          -2,
        ]);
      },
    );
  });

  group('flatMap fast iterator', () {
    test('async source and async inner-iterable futures', () async {
      final out = await toListAsync(
        flatMapAsync(
          (int a) => delayed([a, a * 10]),
          mapAsync((int a) => delayed(a), toAsync([1, 2])),
        ),
      );
      expect(out, equals([1, 10, 2, 20]));
    });

    test('empty inner iterables are skipped', () async {
      final out = await toListAsync(
        flatMapAsync(
          (int a) => a % 2 == 0 ? [a] : <int>[],
          toAsync([1, 2, 3, 4]),
        ),
      );
      expect(out, equals([2, 4]));
    });

    test('under concurrent(n)', () async {
      final out = await fxAsync(
        toAsync([1, 2, 3]),
      ).map((a) => delayed(a)).flatMap((a) => [a, a]).concurrent(2).toList();
      expect(out, equals([1, 1, 2, 2, 3, 3]));
    });
  });

  group('scan fast iterator', () {
    test('future seed and async accumulator', () async {
      final out = await toListAsync(
        scanAsync(
          (int acc, int a) => delayed(acc + a),
          delayed(10),
          toAsync([1, 2]),
        ),
      );
      expect(out, equals([10, 11, 13]));
    });
  });

  group('stream bridge and subscription drive', () {
    test('fromStream + fused stages collects via the drive', () async {
      final out = await toListAsync(
        mapAsync(
          (String s) => s.toUpperCase(),
          filterAsync(
            (String s) => s.startsWith('w'),
            fromStream(Stream.fromIterable(['warn a', 'info b', 'warn c'])),
          ),
        ),
      );
      expect(out, equals(['WARN A', 'WARN C']));
    });

    test('drive with async stages pauses per element, order kept', () async {
      final out = await toListAsync(
        mapAsync(
          (int a) => delayed(a * 2),
          filterAsync(
            (int a) => delayed(a != 2),
            fromStream(Stream.fromIterable([1, 2, 3])),
          ),
        ),
      );
      expect(out, equals([2, 6]));
    });

    test('drive stops at a failing takeWhile (sync and async)', () async {
      expect(
        await toListAsync(
          takeWhileAsync(
            (int a) => a < 3,
            fromStream(Stream.fromIterable([1, 2, 3, 4])),
          ),
        ),
        equals([1, 2]),
      );
      expect(
        await toListAsync(
          takeWhileAsync(
            (int a) => delayed(a < 3),
            fromStream(Stream.fromIterable([1, 2, 3, 4])),
          ),
        ),
        equals([1, 2]),
      );
    });

    test('drive surfaces stage throws and stream errors', () async {
      await expectLater(
        toListAsync(
          mapAsync<int, int>(
            (a) => throw StateError('boom'),
            fromStream(Stream.fromIterable([1])),
          ),
        ),
        throwsStateError,
      );
      final controller = StreamController<int>();
      controller.add(1);
      controller.addError(StateError('stream boom'));
      unawaited(controller.close());
      await expectLater(
        toListAsync(mapAsync((int a) => a, fromStream(controller.stream))),
        throwsStateError,
      );
    });

    test('eachAsync drive pauses on an async callback', () async {
      final seen = <int>[];
      await eachAsync((int a) async {
        await Future<void>.delayed(Duration.zero);
        seen.add(a);
      }, fromStream(Stream.fromIterable([1, 2, 3])));
      expect(seen, equals([1, 2, 3]));
    });

    test(
      'foldAsync drives stream-sourced chains (sync and async fold)',
      () async {
        expect(
          await foldAsync(
            0,
            (int acc, int a) => acc + a,
            fromStream(Stream.fromIterable([1, 2, 3])),
          ),
          equals(6),
        );
        expect(
          await foldAsync(
            0,
            (int acc, int a) => delayed(acc + a),
            fromStream(Stream.fromIterable([1, 2, 3])),
          ),
          equals(6),
        );
      },
    );

    test('bridge buffers events from a pause-ignoring stream', () async {
      // SDK streams honor pause immediately; the bridge's buffer defends
      // against streams that do not. This one keeps delivering regardless.
      final it = fromStream(_RudeStream([1, 2, 3])).iterator;
      final r1 = await it.next();
      expect(r1.value, equals(1));
      // Values 2 and 3 were pushed while no pull was waiting → buffered.
      final it2 = it as FxFastIterator<int>;
      final r2 = it2.nextOr();
      expect(r2, isA<IterResult<int>>());
      expect((r2 as IterResult<int>).value, equals(2));
      final r3 = await it.next(); // buffered path through next()
      expect(r3.value, equals(3));
      expect((await it.next()).done, isTrue);
    });

    test(
      'bridge error answers the waiting pull and ends the iteration',
      () async {
        final controller = StreamController<int>();
        final it = fromStream(controller.stream).iterator;
        final f1 = it.next();
        controller.addError(StateError('bridge boom'));
        await expectLater(f1, throwsStateError);
        expect((await it.next()).done, isTrue);
      },
    );
  });

  group('using / timeout fast paths', () {
    test('usingAsync releases after a fast-pull drain', () async {
      var released = false;
      final out = await toListAsync(
        usingAsync(
          () => 'r',
          (r) => mapAsync((int a) => a * 2, toAsync([1, 2])),
          (r) => released = true,
        ),
      );
      expect(out, equals([2, 4]));
      expect(released, isTrue);
    });

    test(
      'usingAsync releases when a fused inner throws synchronously',
      () async {
        var released = false;
        await expectLater(
          toListAsync(
            usingAsync(
              () => 'r',
              (r) => mapAsync<int, int>(
                (a) => throw StateError('inner boom'),
                toAsync([1]),
              ),
              (r) => released = true,
            ),
          ),
          throwsStateError,
        );
        expect(released, isTrue);
      },
    );

    test(
      'timeoutAsync skips the timer for synchronously answered pulls',
      () async {
        // A sync source cannot stall: even a zero-ish limit never fires.
        final out = await toListAsync(
          timeoutAsync(
            const Duration(microseconds: 1),
            mapAsync((int a) => a + 1, toAsync([1, 2, 3])),
          ),
        );
        expect(out, equals([2, 3, 4]));
      },
    );

    test('timeoutAsync still fires on stalled asynchronous pulls', () async {
      await expectLater(
        toListAsync(
          timeoutAsync(
            const Duration(milliseconds: 5),
            mapAsync(
              (int a) =>
                  Future.delayed(const Duration(milliseconds: 50), () => a),
              toAsync([1]),
            ),
          ),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  group('classic terminal loops (non-fast iterators)', () {
    test(
      'fold/reduce/each over a concurrent chain use the classic loop',
      () async {
        final chain = concurrentAsync(
          2,
          mapAsync((int a) => delayed(a), toAsync([1, 2, 3, 4])),
        );
        expect(
          await foldAsync(0, (int acc, int a) => acc + a, chain),
          equals(10),
        );
        final chain2 = concurrentAsync(
          2,
          mapAsync((int a) => delayed(a), toAsync([1, 2, 3, 4])),
        );
        expect(
          await reduceAsync((int acc, int a) => acc + a, chain2),
          equals(10),
        );
        final chain3 = concurrentAsync(
          2,
          mapAsync((int a) => delayed(a), toAsync([1, 2])),
        );
        final seen = <int>[];
        await eachAsync(seen.add, chain3);
        expect(seen, equals([1, 2]));
      },
    );
  });

  group('remaining machinery branches', () {
    test('nextOr after a marked pull delegates to the fallback', () async {
      Future<void> viaFallback(
        FxAsyncIterable<int> chain,
        List<int> expected,
      ) async {
        final it = chain.iterator as FxFastIterator<int>;
        final got = <int>[(await it.next(Concurrent.of(2))).value];
        while (true) {
          final ro = it.nextOr();
          final r = ro is Future<IterResult<int>> ? await ro : ro;
          if (r.done) break;
          got.add(r.value);
        }
        expect(got, equals(expected));
      }

      await viaFallback(mapAsync((int a) => a + 1, toAsync([1, 2, 3])), [
        2,
        3,
        4,
      ]);
      await viaFallback(
        scanAsync((int acc, int a) => acc + a, 0, toAsync([1, 2])),
        [0, 1, 3],
      );
      await viaFallback(flatMapAsync((int a) => [a, -a], toAsync([1, 2])), [
        1,
        -1,
        2,
        -2,
      ]);
    });

    test('bridge nextOr with a pending stream and after done', () async {
      final controller = StreamController<int>();
      final it = fromStream(controller.stream).iterator as FxFastIterator<int>;
      final pending = it.nextOr(); // nothing buffered → future path
      expect(pending, isA<Future<IterResult<int>>>());
      controller.add(7);
      expect((await (pending as Future<IterResult<int>>)).value, equals(7));
      unawaited(controller.close());
      expect((await it.next()).done, isTrue);
      final afterDone = it.nextOr(); // synchronous done
      expect(afterDone, isA<IterResult<int>>());
      expect((afterDone as IterResult<int>).done, isTrue);
    });

    test(
      'bridge error with several waiters: first errors, rest are done',
      () async {
        final controller = StreamController<int>();
        final it = fromStream(controller.stream).iterator;
        final f1 = it.next();
        final f2 = it.next();
        controller.addError(StateError('boom'));
        await expectLater(f1, throwsStateError);
        expect((await f2).done, isTrue);
      },
    );

    test('toStream over a non-fast iterator uses the classic loop', () async {
      final out = await concurrentAsync(
        2,
        mapAsync((int a) => delayed(a * 2), toAsync([1, 2, 3])),
      ).toStream().toList();
      expect(out, equals([2, 4, 6]));
    });

    test('sync using releases when use() itself throws', () {
      var released = false;
      final it = using<String, int>(
        () => 'r',
        (r) => throw StateError('use boom'),
        (r) => released = true,
      ).iterator;
      expect(it.moveNext, throwsStateError);
      expect(released, isTrue);
    });

    test(
      'scan legacy under concurrent: future seed and async accumulator',
      () async {
        final it = scanAsync(
          (int acc, int a) => delayed(acc + a),
          delayed(10),
          toAsync([1, 2]),
        ).iterator;
        final got = <int>[(await it.next(Concurrent.of(2))).value];
        while (true) {
          final r = await it.next(Concurrent.of(2));
          if (r.done) break;
          got.add(r.value);
        }
        expect(got, equals([10, 11, 13]));
      },
    );

    test('scan manual unmarked pulls take the gated public path', () async {
      final it = scanAsync(
        (int acc, int a) => acc + a,
        0,
        toAsync([1, 2]),
      ).iterator;
      expect((await it.next()).value, equals(0));
      expect((await it.next()).value, equals(1));
      expect((await it.next()).value, equals(3));
      expect((await it.next()).done, isTrue);
    });

    test('scan1 with an async accumulator', () async {
      final out = await toListAsync(
        scan1Async((int acc, int a) => delayed(acc + a), toAsync([1, 2, 3])),
      );
      expect(out, equals([1, 3, 6]));
    });

    test('flatMap over an always-async source (stream bridge)', () async {
      final out = await toListAsync(
        flatMapAsync(
          (int a) => [a, a * 10],
          fromStream(Stream.fromIterable([1, 2])),
        ),
      );
      expect(out, equals([1, 10, 2, 20]));
    });

    test(
      'flatMap legacy under concurrent with async inner iterables',
      () async {
        final out = await fxAsync(
          toAsync([1, 2]),
        ).flatMap((a) => [a, a]).concurrent(2).toList();
        expect(out, equals([1, 1, 2, 2]));
        final it = flatMapAsync(
          (int a) => delayed([a, -a]),
          toAsync([1, 2]),
        ).iterator;
        final got = <int>[(await it.next(Concurrent.of(2))).value];
        while (true) {
          final r = await it.next(Concurrent.of(2));
          if (r.done) break;
          got.add(r.value);
        }
        expect(got, equals([1, -1, 2, -2]));
      },
    );

    test(
      'takeWhile legacy keeps answering done after the end under load',
      () async {
        final out = await fxAsync(
          toAsync([1, 2, 3, 4, 5, 6]),
        ).map((a) => delayed(a)).takeWhile((a) => a < 3).concurrent(3).toList();
        expect(out, equals([1, 2]));
      },
    );

    test(
      'takeWhile legacy answers done on a pull issued after the end',
      () async {
        // Pull past the end on the marked (legacy) path: the `end` short
        // circuit answers without touching the upstream.
        final it = takeWhileAsync(
          (int a) => a < 2,
          toAsync([1, 2, 3]),
        ).iterator;
        expect((await it.next(Concurrent.of(2))).value, equals(1));
        expect((await it.next(Concurrent.of(2))).done, isTrue);
        expect((await it.next(Concurrent.of(2))).done, isTrue);
      },
    );

    test('findIndex over a lazy (non-list) iterable counts positions', () {
      final lazy = [5, 6, 7].where((_) => true);
      expect(findIndex((int a) => a == 7, lazy), equals(2));
      expect(findIndex((int a) => a == 99, lazy), equals(-1));
    });
  });

  group('lazy reverse (non-list source)', () {
    test('materializes on the first pull only', () {
      var pulled = 0;
      final source = [1, 2, 3].map((a) {
        pulled++;
        return a;
      });
      final it = reverse(source).iterator;
      expect(pulled, equals(0));
      expect(it.moveNext(), isTrue);
      expect(pulled, equals(3));
      expect(it.current, equals(3));
      expect([it.moveNext(), it.current], equals([true, 2]));
      expect([it.moveNext(), it.current], equals([true, 1]));
      expect(it.moveNext(), isFalse);
      expect(it.moveNext(), isFalse);
    });
  });
}
