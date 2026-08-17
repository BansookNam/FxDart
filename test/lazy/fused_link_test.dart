// White-box tests for the compiled stage chain (FxLink) — the asynchronous
// branches of the fused run, where a stage answers with a Future and the loop
// has to resume at `link.next` instead of falling through.
//
// Each case is paired with the equivalent unfused expectation, so what is
// pinned is behaviour, not the representation.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// A source whose pulls are genuinely asynchronous, so the fused run takes
/// its Future-resuming path rather than the synchronous fast path.
FxAsyncIterable<int> asyncSource(List<int> values) =>
    fromStream(Stream.fromIterable(values).asyncMap((v) async => v));

void main() {
  group('async scan inside a fused run', () {
    test('a Future seed is emitted before anything is pulled', () async {
      final result = await fxAsync(
        toAsync([1, 2, 3]),
      ).scan((int acc, int a) => acc + a, Future.value(100)).toList();

      expect(result, [100, 101, 103, 106]);
    });

    test('a Future seed flows through the stages after the scan', () async {
      final result = await fxAsync(toAsync([1, 2, 3]))
          .scan((int acc, int a) => acc + a, Future.value(100))
          .map((a) => a * 2)
          .toList();

      expect(result, [200, 202, 206, 212]);
    });

    test(
      'a Future seed dropped by a later filter still starts the run',
      () async {
        final result = await fxAsync(toAsync([1, 2, 3]))
            .scan((int acc, int a) => acc + a, Future.value(100))
            .filter((a) => a.isOdd)
            .toList();

        expect(result, [101, 103]);
      },
    );

    test('an asynchronous accumulator resumes the run', () async {
      final result = await fxAsync(
        toAsync([1, 2, 3]),
      ).scan((int acc, int a) async => acc + a, 0).toList();

      expect(result, [0, 1, 3, 6]);
    });

    test(
      'an asynchronous accumulator resumes a run that can also drop',
      () async {
        // filter makes the run non-one-to-one, so this exercises the dropping
        // loop's scan branch rather than the map-only one.
        final result = await fxAsync(toAsync([1, 2, 3, 4]))
            .scan((int acc, int a) async => acc + a, 0)
            .filter((a) => a.isEven)
            .toList();

        expect(result, [0, 6, 10]);
      },
    );

    test('an asynchronous map resumes a run that can also drop', () async {
      final result = await fxAsync(
        toAsync([1, 2, 3, 4]),
      ).filter((a) => a.isEven).map((a) async => a * 10).toList();

      expect(result, [20, 40]);
    });
  });

  group('async takeWhile inside a fused run', () {
    test('ends the run when the predicate fails asynchronously', () async {
      final result = await fxAsync(
        toAsync([1, 2, 3, 4, 1]),
      ).takeWhile((a) async => a < 3).toList();

      expect(result, [1, 2]);
    });

    test('ends the run after a filter, over an asynchronous source', () async {
      final result = await fxAsync(
        asyncSource([2, 4, 5, 6]),
      ).filter((a) => a.isEven).takeWhile((a) async => a < 6).toList();

      expect(result, [2, 4]);
    });

    test('a failing takeWhile stops pulling the source', () async {
      var pulled = 0;
      final result = await fxAsync(
        toAsync([1, 2, 3, 4, 5]),
      ).peek((_) => pulled++).takeWhile((a) async => a < 3).toList();

      expect(result, [1, 2]);
      expect(pulled, 3, reason: 'stops at the element that failed');
    });
  });

  group('fused drive error paths', () {
    test('a throwing source fails the terminal', () async {
      Stream<int> boom() async* {
        yield 1;
        throw StateError('source');
      }

      expect(
        fxAsync(fromStream(boom())).map((a) => a).toList(),
        throwsStateError,
      );
    });

    test('a stage throwing synchronously fails the terminal', () async {
      expect(
        fxAsync(
          asyncSource([1, 2, 3]),
        ).map((a) => a == 2 ? throw StateError('stage') : a).toList(),
        throwsStateError,
      );
    });

    test('a stage throwing asynchronously fails the terminal', () async {
      expect(
        fxAsync(asyncSource([1, 2, 3]))
            .map((a) async => a == 2 ? throw StateError('async stage') : a)
            .toList(),
        throwsStateError,
      );
    });

    test('a throwing scan accumulator fails the terminal', () async {
      expect(
        fxAsync(
          asyncSource([1, 2, 3]),
        ).scan((int acc, int a) async => throw StateError('acc'), 0).toList(),
        throwsStateError,
      );
    });

    test('a throwing seed fails the terminal', () async {
      expect(
        fxAsync(toAsync([1, 2]))
            .scan(
              (int acc, int a) => acc + a,
              Future<int>.error(StateError('seed')),
            )
            .toList(),
        throwsStateError,
      );
    });

    test('a throwing filter predicate fails the terminal', () async {
      expect(
        fxAsync(
          asyncSource([1, 2, 3]),
        ).filter((a) async => throw StateError('pred')).toList(),
        throwsStateError,
      );
    });
  });

  // `take` is not a fused stage, so it wraps the run: the terminal no longer
  // owns a fused iterable and cannot use the push drive, which puts the chain
  // on _FusedIterator's pull loops instead. These are the same behaviours as
  // the groups above, re-run on that path.
  group('the pull path (a run wrapped by take)', () {
    test('emits a Future seed, then the source', () async {
      final result = await fxAsync(
        toAsync([1, 2, 3]),
      ).scan((int acc, int a) => acc + a, Future.value(100)).take(3).toList();

      expect(result, [100, 101, 103]);
    });

    test('emits a synchronous seed, then the source', () async {
      final result = await fxAsync(
        toAsync([1, 2, 3]),
      ).scan((int acc, int a) => acc + a, 0).take(3).toList();

      expect(result, [0, 1, 3]);
    });

    test(
      'runs a synchronous accumulator in a run that can also drop',
      () async {
        final result = await fxAsync(toAsync([1, 2, 3, 4]))
            .scan((int acc, int a) => acc + a, 0)
            .filter((a) => a.isEven)
            .take(5)
            .toList();

        expect(result, [0, 6, 10]);
      },
    );

    test('pulls the source when a later stage drops the seed', () async {
      // The seed is filtered out, so emitting it must fall through to the
      // first real pull rather than answering with nothing.
      final result = await fxAsync(toAsync([1, 2, 3]))
          .scan((int acc, int a) => acc + a, 0)
          .filter((a) => a > 0)
          .take(3)
          .toList();

      expect(result, [1, 3, 6]);
    });

    test('carries a Future seed through an asynchronous later stage', () async {
      final result = await fxAsync(toAsync([1, 2]))
          .scan((int acc, int a) => acc + a, Future.value(100))
          .map((a) async => a * 2)
          .take(3)
          .toList();

      expect(result, [200, 202, 206]);
    });

    test('runs an asynchronous accumulator in a map-only run', () async {
      final result = await fxAsync(asyncSource([1, 2, 3]))
          .scan((int acc, int a) async => acc + a, 0)
          .map((a) => a * 2)
          .take(4)
          .toList();

      expect(result, [0, 2, 6, 12]);
    });

    test('ends a map-only run when the asynchronous source runs out', () async {
      final result = await fxAsync(
        asyncSource([1, 2]),
      ).map((a) => a * 2).take(10).toList();

      expect(result, [2, 4]);
    });

    test('drops and maps asynchronously over an asynchronous source', () async {
      final result = await fxAsync(
        asyncSource([1, 2, 3, 4]),
      ).filter((a) => a.isEven).map((a) async => a * 10).take(5).toList();

      expect(result, [20, 40]);
    });

    test(
      'runs an asynchronous accumulator in a run that can also drop',
      () async {
        final result = await fxAsync(asyncSource([1, 2, 3, 4]))
            .scan((int acc, int a) async => acc + a, 0)
            .filter((a) => a.isEven)
            .take(5)
            .toList();

        expect(result, [0, 6, 10]);
      },
    );

    test('ends the run on an asynchronous takeWhile after a filter', () async {
      final result = await fxAsync(
        asyncSource([2, 4, 5, 6]),
      ).filter((a) => a.isEven).takeWhile((a) async => a < 6).take(10).toList();

      expect(result, [2, 4]);
    });
  });

  // A second scan cannot join the first one's run (one accumulator slot), so
  // it starts a new run *over* the first — which makes the outer run's source
  // another fused run, the only shape whose pull can throw synchronously into
  // the drive's own try blocks.
  group('fused drive synchronous-throw paths', () {
    test(
      'a synchronous throw from the upstream run fails the terminal',
      () async {
        expect(
          fxAsync(toAsync([1, 2]))
              .scan((int acc, int a) => throw StateError('upstream'), 0)
              .scan((int acc, int a) => acc + a, 0)
              .toList(),
          throwsStateError,
        );
      },
    );

    test('a synchronous throw from a stage fails the terminal', () async {
      expect(
        fxAsync(toAsync([1, 2]))
            .scan((int acc, int a) => acc + a, 0)
            .scan((int acc, int a) => throw StateError('stage'), 0)
            .toList(),
        throwsStateError,
      );
    });

    test(
      'a synchronous throw while emitting the seed fails the terminal',
      () async {
        expect(
          fxAsync(toAsync([1, 2]))
              .scan((int acc, int a) => acc + a, 0)
              .map((a) => throw StateError('seed stage'))
              .toList(),
          throwsStateError,
        );
      },
    );
  });

  group('the compiled chain is equivalent to the unfused layering', () {
    test(
      'a Concurrent marker falls back and agrees element for element',
      () async {
        final fused = await fxAsync(
          toAsync([1, 2, 3, 4, 5, 6]),
        ).filter((a) async => a.isEven).map((a) async => a * 10).toList();
        final concurrent = await fxAsync(toAsync([1, 2, 3, 4, 5, 6]))
            .filter((a) async => a.isEven)
            .map((a) async => a * 10)
            .concurrent(3)
            .toList();

        expect(concurrent, fused);
      },
    );

    test('each terminal sees exactly what toList sees', () async {
      FxAsync<int> chain() => fxAsync(
        toAsync([1, 2, 3, 4]),
      ).scan((int acc, int a) async => acc + a, 0).filter((a) => a.isEven);

      final viaList = await chain().toList();
      final viaEach = <int>[];
      await chain().each(viaEach.add);
      final viaFold = await chain().fold(
        <int>[],
        (List<int> acc, int a) => acc..add(a),
      );

      expect(viaEach, viaList);
      expect(viaFold, viaList);
    });
  });
}
