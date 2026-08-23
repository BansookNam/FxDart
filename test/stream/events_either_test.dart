import 'dart:async';

import 'package:fxdart/fxdart.dart' hide isEmpty, isNotNull, isNull;
import 'package:test/test.dart';

/// A delivered notification tagged with the channel it arrived on, so a test
/// can tell a value from an error instead of collecting both into one list.
typedef Signal = (String channel, Object? value);

Signal data(Object? value) => ('data', value);

Signal err(Object? value) => ('error', value);

Future<List<Signal>> drain<T>(FxEvents<T> src) {
  final signals = <Signal>[];
  final done = Completer<void>();
  src.listen(
    (v) => signals.add(data(v)),
    onError: (Object e, StackTrace st) => signals.add(err(e)),
    onDone: done.complete,
  );
  return done.future.then((_) => signals);
}

void main() {
  group('attempt', () {
    test('data becomes Right, error becomes Left', () async {
      final c = StreamController<int>();
      final out = fxEvents(c.stream).attempt<String>((e, _) => 'E:$e').toList();
      c
        ..add(1)
        ..addError('boom')
        ..add(2);
      await c.close();
      expect(
        await out,
        equals([
          const Right<String, int>(1),
          const Left<String, int>('E:boom'),
          const Right<String, int>(2),
        ]),
      );
    });

    test(
      'a source that keeps ticking after its error stays subscribed',
      () async {
        final c = StreamController<int>();
        final out = fxEvents(
          c.stream,
        ).attempt<String>((e, _) => 'E:$e').toList();
        c.addError('first');
        c.add(7);
        c.addError('second');
        await c.close();
        expect(
          await out,
          equals([
            const Left<String, int>('E:first'),
            const Right<String, int>(7),
            const Left<String, int>('E:second'),
          ]),
        );
      },
    );

    test('empty source closes without a value', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).attempt<String>((e, _) => 'E:$e').toList(),
        equals(<Either<String, int>>[]),
      );
    });

    test(
      'a throwing onThrow errors the output and the chain continues',
      () async {
        final c = StreamController<int>();
        final signals = drain(
          fxEvents(
            c.stream,
          ).attempt<String>((e, _) => throw ArgumentError('mapper: $e')),
        );
        c
          ..addError('a')
          ..add(7)
          ..addError('b');
        await c.close();
        final out = await signals;
        expect(out.map((s) => s.$1), equals(['error', 'data', 'error']));
        expect(out[0].$2, isA<ArgumentError>());
        expect(out[1].$2, equals(const Right<String, int>(7)));
        expect(out[2].$2, isA<ArgumentError>());
      },
    );

    test('pause and resume reach the source', () async {
      var paused = false;
      var resumed = false;
      final c = StreamController<int>(
        onPause: () => paused = true,
        onResume: () => resumed = true,
      );
      final sub = fxEvents(
        c.stream,
      ).attempt<String>((e, _) => 'E:$e').listen((_) {});
      sub.pause();
      await Future<void>.delayed(Duration.zero);
      expect(paused, isTrue);
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(resumed, isTrue);
      await sub.cancel();
      await c.close();
    });

    test('cancel reaches the source and drops later events', () async {
      var cancelled = false;
      final c = StreamController<int>(onCancel: () => cancelled = true);
      final seen = <Either<String, int>>[];
      final sub = fxEvents(
        c.stream,
      ).attempt<String>((e, _) => 'E:$e').listen(seen.add);
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      c.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(cancelled, isTrue);
      expect(seen, equals([const Right<String, int>(1)]));
    });

    test('is single-subscription even from a broadcast source', () async {
      final c = StreamController<int>.broadcast();
      addTearDown(c.close);
      expect(c.stream.isBroadcast, isTrue);
      expect(
        fxEvents(c.stream).attempt<String>((e, _) => 'E:$e').stream.isBroadcast,
        isFalse,
      );
    });

    test('stays cold until someone listens', () {
      var listened = false;
      final c = StreamController<int>(onListen: () => listened = true);
      // close() on a single-subscription controller nobody listened to only
      // completes once a listener drains it, so awaiting it here would hang.
      addTearDown(() => unawaited(c.close()));
      fxEvents(c.stream).attempt<String>((e, _) => 'E:$e');
      expect(listened, isFalse);
    });

    test('onThrow receives the stack trace the source sent', () async {
      final trace = StackTrace.current;
      StackTrace? seen;
      final c = StreamController<int>();
      final out = fxEvents(c.stream).attempt<String>((e, st) {
        seen = st;
        return 'E:$e';
      }).toList();
      c.addError('boom', trace);
      await c.close();
      await out;
      expect(seen, same(trace));
    });

    test('a leaked raise signal becomes a Left like any other error', () async {
      final leaked = RaiseLeakedError();
      final c = StreamController<int>();
      final out = fxEvents(c.stream).attempt<Object>((e, _) => e).toList();
      c.addError(leaked);
      await c.close();
      expect(await out, equals([Left<Object, int>(leaked)]));
    });

    test('a nullable event type keeps a null success', () async {
      final out = await fxEvents(
        Stream<int?>.fromIterable([1, null]),
      ).attempt<String>((e, _) => 'E:$e').toList();
      expect(
        out,
        equals([const Right<String, int?>(1), const Right<String, int?>(null)]),
      );
    });

    test('placed after a retry it converts a retried failure; placed before '
        'one there is nothing left to retry', () async {
      var listens = 0;
      Stream<int> flaky() {
        listens++;
        return listens < 3
            ? Stream<int>.error('boom $listens')
            : Stream.value(7);
      }

      final retriedThenConverted = await FxEvents.retry(
        flaky,
        5,
      ).attempt<String>((e, _) => 'E:$e').toList();
      expect(listens, equals(3));
      expect(retriedThenConverted, equals([const Right<String, int>(7)]));

      listens = 0;
      final convertedThenRetried = await fxEvents(
        flaky(),
      ).attempt<String>((e, _) => 'E:$e').retryOnError(count: 5).toList();
      expect(listens, equals(1));
      expect(
        convertedThenRetried,
        equals([const Left<String, int>('E:boom 1')]),
      );

      // The doc states the rule against retryOnError, so pin that operator in
      // the working direction too, not only the retry constructor.
      listens = 0;
      final relistenable = Stream<int>.multi((c) {
        listens++;
        if (listens < 3) {
          c.addError('boom $listens');
        } else {
          c.add(7);
        }
        c.close();
      });
      final retryOnErrorThenConverted = await fxEvents(
        relistenable,
      ).retryOnError(count: 5).attempt<String>((e, _) => 'E:$e').toList();
      expect(listens, equals(3));
      expect(retryOnErrorThenConverted, equals([const Right<String, int>(7)]));
    });
  });

  group('mapEither', () {
    FxEvents<Either<String, int>> parsed(Stream<String> source) =>
        fxEvents(source).mapEither<String, int>(
          (r, s) => r.ensureNotNull(int.tryParse(s), () => 'bad: $s'),
        );

    test('a raise becomes Left, a return becomes Right', () async {
      expect(
        await parsed(Stream.fromIterable(['1', 'x', '3'])).toList(),
        equals([
          const Right<String, int>(1),
          const Left<String, int>('bad: x'),
          const Right<String, int>(3),
        ]),
      );
    });

    test('a source error passes through untouched', () async {
      final c = StreamController<String>();
      final signals = drain(parsed(c.stream));
      c
        ..add('1')
        ..addError('boom')
        ..add('2');
      await c.close();
      expect(
        await signals,
        equals([
          data(const Right<String, int>(1)),
          err('boom'),
          data(const Right<String, int>(2)),
        ]),
      );
    });

    test('empty source closes without a value', () async {
      expect(await parsed(const Stream<String>.empty()).toList(), isEmpty);
    });

    test('a thrown exception stays on the error channel', () async {
      final signals = await drain(
        fxEvents(Stream.fromIterable([1, 2])).mapEither<String, int>((r, v) {
          if (v == 1) throw StateError('boom');
          return v;
        }),
      );
      expect(signals.map((s) => s.$1), equals(['error', 'data']));
      expect(signals.first.$2, isA<StateError>());
      expect(signals.last.$2, equals(const Right<String, int>(2)));
    });

    test('attempt after mapEither catches the throw, nested', () async {
      final out = await fxEvents(Stream.fromIterable([1, 2]))
          .mapEither<String, int>((r, v) {
            if (v == 1) throw StateError('boom');
            return r.ensureNotNull(v, () => 'null');
          })
          .attempt<String>((e, _) => 'thrown')
          .toList();
      expect(out, hasLength(2));
      expect(
        out.first,
        equals(const Left<String, Either<String, int>>('thrown')),
      );
      expect(
        out.last,
        equals(const Right<String, Either<String, int>>(Right<String, int>(2))),
      );
    });
  });

  group('mapEitherAsync', () {
    test('a raise after an await becomes Left', () async {
      final out = await fxEvents(Stream.fromIterable([1, -2]))
          .mapEitherAsync<String, int>((r, v) async {
            await Future<void>.delayed(Duration.zero);
            r.ensure(v > 0, () => 'negative: $v');
            return v * 2;
          })
          .toList();
      expect(
        out,
        equals([
          const Right<String, int>(2),
          const Left<String, int>('negative: -2'),
        ]),
      );
    });

    test(
      'a thrown exception errors the output and the chain continues',
      () async {
        final signals = await drain(
          fxEvents(Stream.fromIterable([1, 2])).mapEitherAsync<String, int>((
            r,
            v,
          ) async {
            if (v == 1) throw StateError('boom');
            return v;
          }),
        );
        expect(signals.map((s) => s.$1), equals(['error', 'data']));
        expect(signals.first.$2, isA<StateError>());
        expect(signals.last.$2, equals(const Right<String, int>(2)));
      },
    );

    test('a source error passes through untouched', () async {
      final c = StreamController<int>();
      final signals = drain(
        fxEvents(c.stream).mapEitherAsync<String, int>((r, v) async => v),
      );
      c
        ..add(1)
        ..addError('boom')
        ..add(2);
      await c.close();
      expect(
        await signals,
        equals([
          data(const Right<String, int>(1)),
          err('boom'),
          data(const Right<String, int>(2)),
        ]),
      );
    });

    test('empty source closes without a value', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).mapEitherAsync<String, int>((r, v) async => v).toList(),
        isEmpty,
      );
    });

    test('runs one callback at a time', () async {
      var inFlight = 0;
      var peak = 0;
      final out = await fxEvents(Stream.fromIterable([1, 2, 3]))
          .mapEitherAsync<String, int>((r, v) async {
            inFlight++;
            if (inFlight > peak) peak = inFlight;
            await Future<void>.delayed(Duration.zero);
            inFlight--;
            return v;
          })
          .toList();
      expect(out, hasLength(3));
      expect(peak, equals(1));
    });

    test('cancelling while a callback is in flight delivers nothing', () async {
      final c = StreamController<int>();
      final gate = Completer<void>();
      final seen = <Either<String, int>>[];
      final sub = fxEvents(c.stream)
          .mapEitherAsync<String, int>((r, v) async {
            await gate.future;
            return v;
          })
          .listen(seen.add);
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      final cancelled = sub.cancel();
      gate.complete();
      await cancelled;
      await c.close();
      expect(seen, isEmpty);
    });

    test('a synchronous callback keeps order and can raise', () async {
      final out = await fxEvents(Stream.fromIterable([1, -2, 3]))
          .mapEitherAsync<String, int>((r, v) {
            if (v < 0) r.raise('negative: $v');
            return v;
          })
          .toList();
      expect(
        out,
        equals([
          const Right<String, int>(1),
          const Left<String, int>('negative: -2'),
          const Right<String, int>(3),
        ]),
      );
    });
  });

  group('rights / lefts', () {
    final source = <Either<String, int>>[
      const Right(1),
      const Left('a'),
      const Right(2),
      const Left('b'),
    ];

    test('rights keeps only the successes', () async {
      expect(
        await fxEvents(Stream.fromIterable(source)).rights().toList(),
        equals([1, 2]),
      );
    });

    test('lefts keeps only the failures', () async {
      expect(
        await fxEvents(Stream.fromIterable(source)).lefts().toList(),
        equals(['a', 'b']),
      );
    });

    test('an all-Right source has no lefts', () async {
      expect(
        await fxEvents(
          Stream.fromIterable(<Either<String, int>>[const Right(1)]),
        ).lefts().toList(),
        equals(<String>[]),
      );
    });

    test('an empty source closes both filters', () async {
      const empty = Stream<Either<String, int>>.empty();
      expect(await fxEvents(empty).rights().toList(), isEmpty);
      expect(await fxEvents(empty).lefts().toList(), isEmpty);
    });

    test('a source error passes through both filters', () async {
      for (final build
          in <FxEvents<Object?> Function(FxEvents<Either<String, int>>)>[
            (c) => c.rights(),
            (c) => c.lefts(),
          ]) {
        final c = StreamController<Either<String, int>>();
        final signals = drain(build(fxEvents(c.stream)));
        c
          ..add(const Right(1))
          ..addError('boom')
          ..add(const Left('a'));
        await c.close();
        expect(await signals, contains(err('boom')));
      }
    });

    test('an all-Left source has no rights', () async {
      expect(
        await fxEvents(
          Stream.fromIterable(<Either<String, int>>[const Left('a')]),
        ).rights().toList(),
        equals(<int>[]),
      );
    });

    test('rights unwraps a null success', () async {
      expect(
        await fxEvents(
          Stream.fromIterable(<Either<String, int?>>[
            const Right(null),
            const Left('a'),
            const Right(3),
          ]),
        ).rights().toList(),
        equals([null, 3]),
      );
    });

    test(
      'cancel reaches the source through each unwrapping operator',
      () async {
        for (final build
            in <FxEvents<Object?> Function(FxEvents<Either<String, int>>)>[
              (c) => c.rights(),
              (c) => c.lefts(),
              (c) => c.raiseLefts(),
            ]) {
          var cancelled = false;
          final c = StreamController<Either<String, int>>(
            onCancel: () => cancelled = true,
          );
          final sub = build(fxEvents(c.stream)).listen((_) {}, onError: (_) {});
          await sub.cancel();
          expect(cancelled, isTrue);
        }
      },
    );

    test('map-based operators keep broadcast, separated does not', () {
      final c = StreamController<Either<String, int>>.broadcast();
      addTearDown(c.close);
      final chain = fxEvents(c.stream);
      expect(chain.rights().stream.isBroadcast, isTrue);
      expect(chain.lefts().stream.isBroadcast, isTrue);
      expect(chain.raiseLefts().stream.isBroadcast, isTrue);
      final (failures, successes) = chain.separated();
      expect(failures.stream.isBroadcast, isFalse);
      expect(successes.stream.isBroadcast, isFalse);
    });

    test('lefts unwraps a null failure', () async {
      expect(
        await fxEvents(
          Stream.fromIterable(<Either<String?, int>>[
            const Left(null),
            const Right(1),
            const Left('a'),
          ]),
        ).lefts().toList(),
        equals([null, 'a']),
      );
    });
  });

  group('separated', () {
    test('each side gets its own half', () async {
      final (failures, successes) = fxEvents(
        Stream.fromIterable(<Either<String, int>>[
          const Right(1),
          const Left('a'),
          const Right(2),
        ]),
      ).separated();
      final f = failures.toList();
      final s = successes.toList();
      expect(await f, equals(['a']));
      expect(await s, equals([1, 2]));
    });

    test('a side nobody listens to is dropped', () async {
      final c = StreamController<Either<String, int>>();
      final (_, successes) = fxEvents(c.stream).separated();
      final s = successes.toList();
      c
        ..add(const Left('a'))
        ..add(const Right(1));
      await c.close();
      expect(await s, equals([1]));
    });

    test('a source error reaches both halves and both still close', () async {
      final c = StreamController<Either<String, int>>();
      final (failures, successes) = fxEvents(c.stream).separated();
      final f = drain(failures);
      final s = drain(successes);
      c
        ..add(const Right(1))
        ..addError('boom')
        ..add(const Left('a'));
      await c.close();
      expect(await f, equals([err('boom'), data('a')]));
      expect(await s, equals([data(1), err('boom')]));
    });

    test('an empty source closes both halves', () async {
      final (failures, successes) = fxEvents(
        const Stream<Either<String, int>>.empty(),
      ).separated();
      expect(await failures.toList(), isEmpty);
      expect(await successes.toList(), isEmpty);
    });

    test('cancelling both sides cancels the source', () async {
      var cancelled = false;
      final c = StreamController<Either<String, int>>(
        onCancel: () => cancelled = true,
      );
      final (failures, successes) = fxEvents(c.stream).separated();
      final fSub = failures.listen((_) {});
      final sSub = successes.listen((_) {});
      await fSub.cancel();
      await sSub.cancel();
      expect(cancelled, isTrue);
    });

    test(
      'attempt upstream counts a failure once, on the failures half',
      () async {
        final c = StreamController<int>();
        final (failures, successes) = fxEvents(
          c.stream,
        ).attempt<String>((e, _) => 'E:$e').separated();
        final f = drain(failures);
        final s = drain(successes);
        c
          ..add(1)
          ..addError('boom')
          ..add(2);
        await c.close();
        expect(await f, equals([data('E:boom')]));
        expect(await s, equals([data(1), data(2)]));
      },
    );
  });

  group('raiseLefts', () {
    test(
      'Right is a value, Left is an error event, the chain continues',
      () async {
        final signals = await drain(
          fxEvents(
            Stream.fromIterable(<Either<String, int>>[
              const Right(1),
              const Left('boom'),
              const Right(2),
            ]),
          ).raiseLefts(),
        );
        expect(signals, equals([data(1), err('boom'), data(2)]));
      },
    );

    test('a source error passes through untouched', () async {
      final c = StreamController<Either<String, int>>();
      final signals = drain(fxEvents(c.stream).raiseLefts());
      c
        ..add(const Right(1))
        ..addError('upstream')
        ..add(const Left('boom'));
      await c.close();
      expect(await signals, equals([data(1), err('upstream'), err('boom')]));
    });

    test('empty source closes without a value', () async {
      expect(
        await fxEvents(
          const Stream<Either<String, int>>.empty(),
        ).raiseLefts().toList(),
        isEmpty,
      );
    });

    test('cancelOnError stops at the first Left', () async {
      final seen = <int>[];
      final errored = Completer<Object>();
      fxEvents(
        Stream.fromIterable(<Either<String, int>>[
          const Right(1),
          const Left('boom'),
          const Right(2),
        ]),
      ).raiseLefts().listen(
        seen.add,
        onError: (Object e) => errored.complete(e),
        cancelOnError: true,
      );
      expect(await errored.future, equals('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1]));
    });

    test(
      'round-trips with attempt, carrying the value not the trace',
      () async {
        final c = StreamController<int>();
        final signals = drain(
          fxEvents(c.stream).attempt<String>((e, _) => 'E:$e').raiseLefts(),
        );
        c
          ..add(1)
          ..addError('boom');
        await c.close();
        expect(await signals, equals([data(1), err('E:boom')]));
      },
    );

    test('a Left arrives with a non-empty stack trace', () async {
      StackTrace? seen;
      final done = Completer<void>();
      fxEvents(
        Stream.fromIterable(<Either<String, int>>[const Left('boom')]),
      ).raiseLefts().listen(
        (_) {},
        onError: (Object e, StackTrace st) => seen = st,
        onDone: done.complete,
      );
      await done.future;
      expect(seen, isNotNull);
      expect(seen, isNot(StackTrace.empty));
    });
  });
}
