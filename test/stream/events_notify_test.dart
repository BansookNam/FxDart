import 'dart:async';

import 'package:fxdart/fxdart.dart' hide isEmpty, isNull;
import 'package:test/test.dart';

Future<(List<Object?> events, bool done)> collect<T>(FxEvents<T> src) {
  final events = <Object?>[];
  final done = Completer<void>();
  src.listen((v) => events.add(v), onError: events.add, onDone: done.complete);
  return done.future.then((_) => (events, true));
}

void main() {
  group('StreamEvent', () {
    test('Next equality, hashCode, toString', () {
      const a = Next(1);
      const b = Next(1);
      expect(a, equals(b));
      expect(a == a, isTrue);
      expect(a, isNot(const Next(2)));
      expect(a, isNot(const Done<int>()));
      expect(a.hashCode, Next(1).hashCode);
      expect(a.toString(), 'Next(1)');
    });

    test('Err equality, hashCode, toString', () {
      const a = Err<int>('boom');
      const b = Err<int>('boom');
      expect(a, equals(b));
      expect(a == a, isTrue);
      expect(a, isNot(const Err<int>('other')));
      expect(a, isNot(Err<int>('boom', StackTrace.current)));
      expect(a, isNot(const Next(1)));
      expect(a.hashCode, const Err<int>('boom').hashCode);
      expect(a.toString(), 'Err(boom)');
    });

    test('Done equality, hashCode, toString', () {
      const a = Done<int>();
      expect(a, equals(const Done<int>()));
      expect(a == a, isTrue);
      expect(a, isNot(const Done<String>()));
      expect(a, isNot(const Next(1)));
      expect(a.hashCode, const Done<int>().hashCode);
      expect(a.toString(), 'Done()');
    });
  });

  group('materialize', () {
    test('wraps data as Next and close as Done', () async {
      final out = await fxEvents(
        Stream.fromIterable([1, 2]),
      ).materialize().toList();
      expect(out, equals([const Next(1), const Next(2), const Done<int>()]));
    });

    test('empty source is a single Done', () async {
      expect(
        await fxEvents(const Stream<int>.empty()).materialize().toList(),
        equals([const Done<int>()]),
      );
    });

    test(
      'error becomes Err then completes, does not error the output',
      () async {
        final events = <StreamEvent<int>>[];
        var errored = false;
        var done = false;
        fxEvents(Stream<int>.error(StateError('boom'))).materialize().listen(
          events.add,
          onError: (_) => errored = true,
          onDone: () => done = true,
        );
        await Future<void>.delayed(Duration.zero);
        expect(errored, isFalse);
        expect(done, isTrue);
        expect(events, hasLength(1));
        final err = events.single as Err<int>;
        expect(err.error, isA<StateError>());
      },
    );

    test('ignores further events after the source errors', () async {
      final c = StreamController<int>();
      final events = <StreamEvent<int>>[];
      var done = false;
      fxEvents(
        c.stream,
      ).materialize().listen(events.add, onDone: () => done = true);
      c.add(1);
      c.addError(StateError('boom'));
      c.add(2);
      c.addError(StateError('again'));
      await c.close();
      await Future<void>.delayed(Duration.zero);
      expect(done, isTrue);
      expect(events, hasLength(2));
      expect(events[0], const Next(1));
      expect(events[1], isA<Err<int>>());
    });

    test('cancel unsubscribes', () async {
      final c = StreamController<int>();
      var cancelled = false;
      c.onCancel = () => cancelled = true;
      final sub = fxEvents(c.stream).materialize().listen((_) {});
      await sub.cancel();
      expect(cancelled, isTrue);
      await c.close();
    });

    test('pause and resume', () async {
      final c = StreamController<int>();
      final events = <StreamEvent<int>>[];
      final sub = fxEvents(c.stream).materialize().listen(events.add);
      sub.pause();
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(events, isEmpty);
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(events, equals([const Next(1)]));
      await sub.cancel();
      await c.close();
    });
  });

  group('dematerialize', () {
    test('Next becomes a value and Done closes', () async {
      expect(
        await fxEvents(
          Stream<StreamEvent<int>>.fromIterable([
            const Next(1),
            const Next(2),
            const Done(),
          ]),
        ).dematerialize().toList(),
        equals([1, 2]),
      );
    });

    test('round-trips values through materialize', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2, 3]),
        ).materialize().dematerialize().toList(),
        equals([1, 2, 3]),
      );
    });

    test('Err becomes an error event', () async {
      final (events, done) = await collect(
        fxEvents(
          Stream<StreamEvent<int>>.fromIterable([
            const Next(1),
            Err<int>(StateError('boom')),
            const Next(2),
          ]),
        ).dematerialize(),
      );
      expect(done, isTrue);
      expect(events, hasLength(3));
      expect(events[0], 1);
      expect(events[1], isA<StateError>());
      expect(events[2], 2);
    });

    test('ignores everything after Done', () async {
      final (events, done) = await collect(
        fxEvents(
          Stream<StreamEvent<int>>.fromIterable([
            const Next(1),
            const Done(),
            const Next(2),
            Err<int>(StateError('late')),
          ]),
        ).dematerialize(),
      );
      expect(done, isTrue);
      expect(events, equals([1]));
    });

    test('source error is forwarded and the result closes', () async {
      final (events, done) = await collect(
        fxEvents(
          Stream<StreamEvent<int>>.error(StateError('boom')),
        ).dematerialize(),
      );
      expect(done, isTrue);
      expect(events.single, isA<StateError>());
    });

    test('source error after Done is ignored', () async {
      final c = StreamController<StreamEvent<int>>();
      final (future, doneFlag) = () {
        final events = <Object>[];
        final done = Completer<void>();
        fxEvents(c.stream).dematerialize().listen(
          events.add,
          onError: events.add,
          onDone: done.complete,
        );
        return (done.future.then((_) => events), done);
      }();
      c.add(const Next(1));
      c.add(const Done());
      c.addError(StateError('late'));
      await c.close();
      final events = await future;
      expect(doneFlag.isCompleted, isTrue);
      expect(events, equals([1]));
    });

    test('a notification stream that just closes yields nothing', () async {
      expect(
        await fxEvents(
          const Stream<StreamEvent<int>>.empty(),
        ).dematerialize().toList(),
        isEmpty,
      );
    });

    test('cancel unsubscribes', () async {
      final c = StreamController<StreamEvent<int>>();
      var cancelled = false;
      c.onCancel = () => cancelled = true;
      final sub = fxEvents(c.stream).dematerialize().listen((_) {});
      await sub.cancel();
      expect(cancelled, isTrue);
      await c.close();
    });

    test('pause and resume', () async {
      final c = StreamController<StreamEvent<int>>();
      final events = <int>[];
      final sub = fxEvents(c.stream).dematerialize().listen(events.add);
      sub.pause();
      c.add(const Next(1));
      await Future<void>.delayed(Duration.zero);
      expect(events, isEmpty);
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(events, equals([1]));
      await sub.cancel();
      await c.close();
    });
  });

  group('timestamped', () {
    test('pairs each event with now()', () async {
      var t = DateTime.utc(2020, 1, 1);
      final out = await fxEvents(Stream.fromIterable([1, 2]))
          .timestamped(
            now: () {
              final n = t;
              t = t.add(const Duration(seconds: 5));
              return n;
            },
          )
          .toList();
      expect(
        out,
        equals([
          (DateTime.utc(2020, 1, 1), 1),
          (DateTime.utc(2020, 1, 1, 0, 0, 5), 2),
        ]),
      );
    });

    test('defaults to DateTime.now', () async {
      final before = DateTime.now();
      final out = await fxEvents(Stream.value(7)).timestamped().toList();
      final after = DateTime.now();
      expect(out.single.$2, 7);
      expect(
        !out.single.$1.isBefore(before.subtract(const Duration(seconds: 2))),
        isTrue,
      );
      expect(
        !out.single.$1.isAfter(after.add(const Duration(seconds: 2))),
        isTrue,
      );
    });

    test('forwards errors and close', () async {
      final (events, done) = await collect(
        fxEvents(Stream<int>.error(StateError('boom'))).timestamped(),
      );
      expect(done, isTrue);
      expect(events.single, isA<StateError>());
    });

    test('pause, resume, cancel', () async {
      final c = StreamController<int>();
      var cancelled = false;
      c.onCancel = () => cancelled = true;
      final events = <(DateTime, int)>[];
      final sub = fxEvents(
        c.stream,
      ).timestamped(now: () => DateTime.utc(2020, 1, 1)).listen(events.add);
      sub.pause();
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(events, isEmpty);
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(events.single.$2, 1);
      await sub.cancel();
      expect(cancelled, isTrue);
      await c.close();
    });
  });

  group('intervals', () {
    test('first dt is zero, later dts are differences', () async {
      var t = DateTime.utc(2020, 1, 1);
      final out = await fxEvents(Stream.fromIterable(['a', 'b', 'c']))
          .intervals(
            now: () {
              final n = t;
              t = t.add(const Duration(milliseconds: 40));
              return n;
            },
          )
          .toList();
      expect(out[0], equals((Duration.zero, 'a')));
      expect(out[1], equals((const Duration(milliseconds: 40), 'b')));
      expect(out[2], equals((const Duration(milliseconds: 40), 'c')));
    });

    test('defaults to DateTime.now and first dt is zero', () async {
      final out = await fxEvents(Stream.value(1)).intervals().toList();
      expect(out.single.$1, Duration.zero);
      expect(out.single.$2, 1);
    });

    test('forwards errors', () async {
      final (events, done) = await collect(
        fxEvents(Stream<int>.error(StateError('boom'))).intervals(),
      );
      expect(done, isTrue);
      expect(events.single, isA<StateError>());
    });

    test('pause, resume, cancel', () async {
      final c = StreamController<int>();
      var cancelled = false;
      c.onCancel = () => cancelled = true;
      final events = <(Duration, int)>[];
      final sub = fxEvents(
        c.stream,
      ).intervals(now: () => DateTime.utc(2020, 1, 1)).listen(events.add);
      sub.pause();
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(events, isEmpty);
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(events.single, equals((Duration.zero, 1)));
      await sub.cancel();
      expect(cancelled, isTrue);
      await c.close();
    });
  });

  group('partition', () {
    test('splits by predicate over one source run', () async {
      var listens = 0;
      final c = StreamController<int>(onListen: () => listens++);
      final (matches, rest) = fxEvents(c.stream).partition((n) => n.isEven);
      final even = matches.toList();
      final odd = rest.toList();
      c
        ..add(1)
        ..add(2)
        ..add(3)
        ..add(4);
      await c.close();
      expect(await even, equals([2, 4]));
      expect(await odd, equals([1, 3]));
      expect(listens, 1);
    });

    test('listening to one side still delivers that side', () async {
      final (matches, rest) = fxEvents(
        Stream.fromIterable([1, 2, 3, 4]),
      ).partition((n) => n.isEven);
      expect(await matches.toList(), equals([2, 4]));
      // rest was never listened; its values were dropped, not buffered.
      expect(await rest.toList(), isEmpty);
    });

    test('listening to rest only', () async {
      final (matches, rest) = fxEvents(
        Stream.fromIterable([1, 2, 3, 4]),
      ).partition((n) => n.isEven);
      expect(await rest.toList(), equals([1, 3]));
      expect(await matches.toList(), isEmpty);
    });

    test('cancelling both cancels the source; one side keeps it', () async {
      var cancels = 0;
      final c = StreamController<int>(onCancel: () => cancels++);
      final (matches, rest) = fxEvents(c.stream).partition((n) => n.isEven);
      final s1 = matches.listen((_) {});
      final s2 = rest.listen((_) {});
      await s1.cancel();
      expect(cancels, 0);
      await s2.cancel();
      expect(cancels, 1);
    });

    test(
      'cancelling one side drops its values; the other still completes',
      () async {
        final c = StreamController<int>();
        final (matches, rest) = fxEvents(c.stream).partition((n) => n.isEven);
        final odds = <Object?>[];
        final restDone = Completer<void>();
        rest.listen(odds.add, onError: odds.add, onDone: restDone.complete);
        final mSub = matches.listen((_) {});
        c.add(1);
        c.add(2);
        await mSub.cancel();
        c.add(3);
        c.add(4);
        c.addError(StateError('boom'));
        await c.close();
        await restDone.future;
        expect(odds.first, 1);
        expect(odds[1], 3);
        expect(odds.last, isA<StateError>());
      },
    );

    test('forwards errors to listening sides', () async {
      final c = StreamController<int>();
      final (matches, rest) = fxEvents(c.stream).partition((n) => n.isEven);
      final even = collect(matches);
      final odd = collect(rest);
      c.add(1);
      c.addError(StateError('boom'));
      await c.close();
      final (eEvents, eDone) = await even;
      final (oEvents, oDone) = await odd;
      expect(eDone, isTrue);
      expect(oDone, isTrue);
      expect(oEvents.first, 1);
      expect(eEvents.single, isA<StateError>());
      expect(oEvents.last, isA<StateError>());
    });

    test('error with only one side listening', () async {
      final (matches, rest) = fxEvents(
        Stream<int>.error(StateError('boom')),
      ).partition((n) => n.isEven);
      final (events, done) = await collect(matches);
      expect(done, isTrue);
      expect(events.single, isA<StateError>());
      expect(await rest.toList(), isEmpty);
    });

    test('throwing predicate errors listening sides', () async {
      final (matches, rest) = fxEvents(Stream.fromIterable([1, 2, 3]))
          .partition((n) {
            if (n == 2) throw StateError('boom');
            return n.isEven;
          });
      final even = collect(matches);
      final odd = collect(rest);
      final (eEvents, _) = await even;
      final (oEvents, _) = await odd;
      expect(oEvents.first, 1);
      expect(eEvents.single, isA<StateError>());
      expect(oEvents[1], isA<StateError>());
      expect(oEvents.last, 3);
    });

    test('empty source closes both sides', () async {
      final (matches, rest) = fxEvents(
        const Stream<int>.empty(),
      ).partition((n) => n.isEven);
      expect(await matches.toList(), isEmpty);
      expect(await rest.toList(), isEmpty);
    });

    test('late listen after the run is an empty stream', () async {
      var cancels = 0;
      final c = StreamController<int>(onCancel: () => cancels++);
      final (matches, rest) = fxEvents(c.stream).partition((n) => n.isEven);
      final sub = matches.listen((_) {});
      await sub.cancel();
      expect(cancels, 1);
      expect(await rest.toList(), isEmpty);
    });
  });

  group('sequenceEqual (push)', () {
    test('true when both emit the same values and complete', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2, 3]),
        ).sequenceEqual(Stream.fromIterable([1, 2, 3])),
        isTrue,
      );
    });

    test('true for two empty streams', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).sequenceEqual(const Stream<int>.empty()),
        isTrue,
      );
    });

    test('false on the first value mismatch', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2, 3]),
        ).sequenceEqual(Stream.fromIterable([1, 9, 3])),
        isFalse,
      );
    });

    test('false when this is longer', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2, 3]),
        ).sequenceEqual(Stream.fromIterable([1, 2])),
        isFalse,
      );
    });

    test('false when other is longer', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2]),
        ).sequenceEqual(Stream.fromIterable([1, 2, 3])),
        isFalse,
      );
    });

    test('uses eq when provided', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, -2])).sequenceEqual(
          Stream.fromIterable([1, 2]),
          eq: (a, b) => a.abs() == b.abs(),
        ),
        isTrue,
      );
      expect(
        await fxEvents(Stream.fromIterable([1, -2])).sequenceEqual(
          Stream.fromIterable([1, 3]),
          eq: (a, b) => a.abs() == b.abs(),
        ),
        isFalse,
      );
    });

    test('an error from this fails the future', () async {
      expect(
        fxEvents(
          Stream<int>.error(StateError('boom')),
        ).sequenceEqual(Stream.value(1)),
        throwsStateError,
      );
    });

    test('an error from other fails the future', () async {
      expect(
        fxEvents(
          Stream.value(1),
        ).sequenceEqual(Stream<int>.error(StateError('boom'))),
        throwsStateError,
      );
    });
  });
}
