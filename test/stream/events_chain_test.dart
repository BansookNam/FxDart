import 'dart:async';

import 'package:fxdart/fxdart.dart' hide isEmpty, isNull;
import 'package:test/test.dart';

Future<List<Object>> collect(FxEvents<dynamic> events) {
  final seen = <Object>[];
  final done = Completer<List<Object>>();
  events.listen(
    (e) => seen.add(e as Object),
    onError: (e, _) => seen.add(e as Object),
    onDone: () => done.complete(seen),
  );
  return done.future;
}

Future<void> expectCancelDrops(
  FxEvents<int> Function(Stream<int>) build,
) async {
  final c = StreamController<int>();
  final seen = <int>[];
  final sub = build(c.stream).listen(seen.add);
  await sub.cancel();
  c.add(1);
  await Future<void>.delayed(Duration.zero);
  expect(seen, isEmpty);
  await c.close();
}

void main() {
  group('peek', () {
    test('passes events through and runs the data side effect', () async {
      final peeked = <int>[];
      expect(
        await fxEvents(Stream.fromIterable([1, 2])).peek(peeked.add).toList(),
        equals([1, 2]),
      );
      expect(peeked, equals([1, 2]));
    });

    test('empty source still runs onDone', () async {
      var done = false;
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).peek(null, onDone: () => done = true).toList(),
        isEmpty,
      );
      expect(done, isTrue);
    });

    test('one event with no callbacks is identity', () async {
      expect(await fxEvents(Stream.value(7)).peek(null).toList(), equals([7]));
    });

    test('forwards source errors and runs onError', () async {
      Object? seenError;
      final seen = await collect(
        fxEvents(
          Stream<int>.error(StateError('boom')),
        ).peek(null, onError: (e, _) => seenError = e),
      );
      expect(seen.single, isA<StateError>());
      expect(seenError, isA<StateError>());
    });

    test('a throwing onData becomes an error and drops that event', () async {
      final seen = await collect(
        fxEvents(Stream.fromIterable([1, 2])).peek((v) {
          if (v == 1) throw StateError('peeked');
        }),
      );
      expect(seen.first, isA<StateError>());
      expect(seen.last, 2);
    });

    test(
      'a throwing onError becomes an error and swallows the original',
      () async {
        final seen = await collect(
          fxEvents(
            Stream<int>.error(ArgumentError('src')),
          ).peek(null, onError: (_, _) => throw StateError('tap')),
        );
        expect(seen.single, isA<StateError>());
      },
    );

    test('a throwing onDone becomes an error, then the chain closes', () async {
      final seen = await collect(
        fxEvents(
          Stream.value(1),
        ).peek(null, onDone: () => throw StateError('done')),
      );
      expect(seen.first, 1);
      expect(seen.last, isA<StateError>());
    });

    test('cancel unsubscribes', () async {
      await expectCancelDrops((s) => fxEvents(s).peek((_) {}));
    });

    test('is single-subscription even when the source is broadcast', () {
      final b = StreamController<int>.broadcast();
      expect(fxEvents(b.stream).peek(null).stream.isBroadcast, isFalse);
      b.close();
    });
  });

  group('takeWhile', () {
    test('empty source stays empty', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).takeWhile((_) => true).toList(),
        isEmpty,
      );
    });

    test('one matching event is emitted', () async {
      expect(
        await fxEvents(Stream.value(1)).takeWhile((v) => v < 10).toList(),
        equals([1]),
      );
    });

    test('stops before the failing event', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2, 3, 4]),
        ).takeWhile((v) => v < 3).toList(),
        equals([1, 2]),
      );
    });

    test('forwards source errors', () async {
      final seen = await collect(
        fxEvents(Stream<int>.error(StateError('boom'))).takeWhile((_) => true),
      );
      expect(seen.single, isA<StateError>());
    });

    test('cancel unsubscribes', () async {
      await expectCancelDrops((s) => fxEvents(s).takeWhile((_) => true));
    });
  });

  group('dropWhile', () {
    test('empty source stays empty', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).dropWhile((_) => true).toList(),
        isEmpty,
      );
    });

    test('one failing event is kept', () async {
      expect(
        await fxEvents(Stream.value(5)).dropWhile((v) => v < 3).toList(),
        equals([5]),
      );
    });

    test('skips a prefix then mirrors the rest', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2, 3, 1]),
        ).dropWhile((v) => v < 3).toList(),
        equals([3, 1]),
      );
    });

    test('skipWhile is the same operator', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2, 3]),
        ).skipWhile((v) => v < 2).toList(),
        equals([2, 3]),
      );
    });

    test('forwards source errors', () async {
      final seen = await collect(
        fxEvents(Stream<int>.error(StateError('boom'))).dropWhile((_) => true),
      );
      expect(seen.single, isA<StateError>());
    });

    test('cancel unsubscribes', () async {
      await expectCancelDrops((s) => fxEvents(s).dropWhile((_) => false));
    });
  });

  group('takeUntilInclusive', () {
    test('empty source stays empty', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).takeUntilInclusive((_) => true).toList(),
        isEmpty,
      );
    });

    test('emits the matching event then closes', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2, 3, 4]),
        ).takeUntilInclusive((v) => v == 3).toList(),
        equals([1, 2, 3]),
      );
    });

    test('one matching event is emitted', () async {
      expect(
        await fxEvents(
          Stream.value(1),
        ).takeUntilInclusive((_) => true).toList(),
        equals([1]),
      );
    });

    test('never matching mirrors the source', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2]),
        ).takeUntilInclusive((_) => false).toList(),
        equals([1, 2]),
      );
    });

    test('cancels the source once the match is emitted', () async {
      var cancelled = false;
      final c = StreamController<int>(onCancel: () => cancelled = true);
      final collected = fxEvents(
        c.stream,
      ).takeUntilInclusive((v) => v == 2).toList();
      c
        ..add(1)
        ..add(2)
        ..add(3);
      expect(await collected, equals([1, 2]));
      await Future<void>.delayed(Duration.zero);
      expect(cancelled, isTrue);
      await c.close();
    });

    test('a throwing test becomes an error and the chain continues', () async {
      final seen = await collect(
        fxEvents(Stream.fromIterable([1, 2, 3])).takeUntilInclusive((v) {
          if (v == 2) throw StateError('boom');
          return false;
        }),
      );
      expect(seen[0], 1);
      expect(seen[1], isA<StateError>());
      expect(seen[2], 3);
    });

    test('forwards source errors', () async {
      final seen = await collect(
        fxEvents(
          Stream<int>.error(StateError('boom')),
        ).takeUntilInclusive((_) => true),
      );
      expect(seen.single, isA<StateError>());
    });

    test('cancel unsubscribes', () async {
      await expectCancelDrops(
        (s) => fxEvents(s).takeUntilInclusive((_) => false),
      );
    });

    test('is single-subscription even when the source is broadcast', () {
      final b = StreamController<int>.broadcast();
      expect(
        fxEvents(b.stream).takeUntilInclusive((_) => true).stream.isBroadcast,
        isFalse,
      );
      b.close();
    });
  });

  group('takeRight', () {
    test('empty source stays empty', () async {
      expect(
        await fxEvents(const Stream<int>.empty()).takeRight(3).toList(),
        isEmpty,
      );
    });

    test('one event is kept when count is at least 1', () async {
      expect(
        await fxEvents(Stream.value(7)).takeRight(3).toList(),
        equals([7]),
      );
    });

    test('keeps the last count events of a closing source', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2, 3, 4, 5]),
        ).takeRight(2).toList(),
        equals([4, 5]),
      );
    });

    test('emits nothing until the source closes', () async {
      final c = StreamController<int>();
      final seen = <int>[];
      fxEvents(c.stream).takeRight(2).listen(seen.add);
      c
        ..add(1)
        ..add(2)
        ..add(3);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
      await c.close();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([2, 3]));
    });

    test('a count below 1 is empty without subscribing', () async {
      for (final count in [0, -1]) {
        var listened = false;
        final c = StreamController<int>(onListen: () => listened = true);
        expect(await fxEvents(c.stream).takeRight(count).toList(), isEmpty);
        expect(listened, isFalse);
        unawaited(c.close());
      }
    });

    test(
      'forwards source errors then still flushes the buffer on close',
      () async {
        final c = StreamController<int>();
        final seen = collect(fxEvents(c.stream).takeRight(2));
        c
          ..add(1)
          ..add(2)
          ..add(3)
          ..addError(StateError('boom'));
        await c.close();
        final out = await seen;
        expect(out[0], isA<StateError>());
        expect(out.sublist(1), equals([2, 3]));
      },
    );

    test('cancel unsubscribes and drops the buffer', () async {
      await expectCancelDrops((s) => fxEvents(s).takeRight(2));
    });
  });

  group('dropRight', () {
    test('empty source stays empty', () async {
      expect(
        await fxEvents(const Stream<int>.empty()).dropRight(2).toList(),
        isEmpty,
      );
    });

    test('one event with count 1 is dropped', () async {
      expect(await fxEvents(Stream.value(7)).dropRight(1).toList(), isEmpty);
    });

    test('skips the last count events of a closing source', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2, 3, 4, 5]),
        ).dropRight(2).toList(),
        equals([1, 2, 3]),
      );
    });

    test('delays each event until count more have arrived', () async {
      final c = StreamController<int>();
      final seen = <int>[];
      final done = Completer<void>();
      fxEvents(c.stream).dropRight(2).listen(seen.add, onDone: done.complete);
      c
        ..add(1)
        ..add(2);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
      c.add(3);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1]));
      await c.close();
      await done.future;
      expect(seen, equals([1]));
    });

    test('a count below 1 is a no-op', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2])).dropRight(0).toList(),
        equals([1, 2]),
      );
      expect(
        await fxEvents(Stream.fromIterable([1, 2])).dropRight(-1).toList(),
        equals([1, 2]),
      );
    });

    test('forwards source errors', () async {
      final c = StreamController<int>();
      final seen = collect(fxEvents(c.stream).dropRight(1));
      c
        ..add(1)
        ..addError(StateError('boom'))
        ..add(2);
      await c.close();
      final out = await seen;
      expect(out[0], isA<StateError>());
      expect(out.last, 1);
    });

    test('cancel unsubscribes', () async {
      await expectCancelDrops((s) => fxEvents(s).dropRight(2));
    });
  });

  group('whereType', () {
    test('keeps matching events and re-types them', () async {
      expect(
        await fxEvents(
          Stream<Object>.fromIterable([1, 'a', 2, true, 3]),
        ).whereType<int>().toList(),
        equals([1, 2, 3]),
      );
    });

    test('empty source stays empty', () async {
      expect(
        await fxEvents(const Stream<Object>.empty()).whereType<int>().toList(),
        isEmpty,
      );
    });

    test('one non-matching event is dropped', () async {
      expect(
        await fxEvents(Stream<Object>.value('x')).whereType<int>().toList(),
        isEmpty,
      );
    });

    test('forwards source errors', () async {
      final seen = await collect(
        fxEvents(Stream<Object>.error(StateError('boom'))).whereType<int>(),
      );
      expect(seen.single, isA<StateError>());
    });

    test('cancel unsubscribes', () async {
      await expectCancelDrops((s) => fxEvents(s).whereType<int>());
    });
  });

  group('nonNulls', () {
    test('drops nulls and types the rest as T', () async {
      final FxEvents<int> out = fxEvents(
        Stream<int?>.fromIterable([1, null, 2, null, 3]),
      ).nonNulls;
      expect(await out.toList(), equals([1, 2, 3]));
    });

    test('empty source stays empty', () async {
      expect(
        await fxEvents(const Stream<int?>.empty()).nonNulls.toList(),
        isEmpty,
      );
    });

    test('one null is dropped', () async {
      expect(
        await fxEvents(Stream<int?>.value(null)).nonNulls.toList(),
        isEmpty,
      );
    });

    test('forwards source errors', () async {
      final seen = await collect(
        fxEvents(Stream<int?>.error(StateError('boom'))).nonNulls,
      );
      expect(seen.single, isA<StateError>());
    });

    test('cancel unsubscribes', () async {
      final c = StreamController<int?>();
      final seen = <int>[];
      final sub = fxEvents(c.stream).nonNulls.listen(seen.add);
      await sub.cancel();
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
      await c.close();
    });
  });

  group('cast', () {
    test('re-types matching events', () async {
      expect(
        await fxEvents(Stream<num>.fromIterable([1, 2])).cast<int>().toList(),
        equals([1, 2]),
      );
    });

    test('empty source stays empty', () async {
      expect(
        await fxEvents(const Stream<num>.empty()).cast<int>().toList(),
        isEmpty,
      );
    });

    test('a mismatched event becomes an error', () async {
      final seen = await collect(
        fxEvents(Stream<num>.fromIterable([1, 2.5])).cast<int>(),
      );
      expect(seen.first, 1);
      expect(seen.last, isA<TypeError>());
    });

    test('forwards source errors', () async {
      final seen = await collect(
        fxEvents(Stream<num>.error(StateError('boom'))).cast<int>(),
      );
      expect(seen.single, isA<StateError>());
    });

    test('cancel unsubscribes', () async {
      await expectCancelDrops((s) => fxEvents(s).cast<int>());
    });
  });

  group('expand', () {
    test('flattens each iterable in order', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2]),
        ).expand((n) => [n, n * 10]).toList(),
        equals([1, 10, 2, 20]),
      );
    });

    test('an empty iterable contributes nothing', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2]),
        ).expand((_) => <int>[]).toList(),
        isEmpty,
      );
    });

    test('empty source stays empty', () async {
      expect(
        await fxEvents(const Stream<int>.empty()).expand((n) => [n]).toList(),
        isEmpty,
      );
    });

    test('one event expands to several', () async {
      expect(
        await fxEvents(Stream.value(3)).expand((n) => [n, n]).toList(),
        equals([3, 3]),
      );
    });

    test('forwards source errors', () async {
      final seen = await collect(
        fxEvents(Stream<int>.error(StateError('boom'))).expand((n) => [n]),
      );
      expect(seen.single, isA<StateError>());
    });

    test('cancel unsubscribes', () async {
      await expectCancelDrops((s) => fxEvents(s).expand((n) => [n]));
    });
  });

  group('handleError', () {
    test('swallows a matching error and continues', () async {
      final c = StreamController<int>();
      final out = fxEvents(
        c.stream,
      ).handleError((Object _) {}, test: (e) => e is StateError).toList();
      c
        ..add(1)
        ..addError(StateError('boom'))
        ..add(2);
      await c.close();
      expect(await out, equals([1, 2]));
    });

    test('forwards an error the test rejects', () async {
      final c = StreamController<int>();
      final seen = collect(
        fxEvents(
          c.stream,
        ).handleError((Object _) {}, test: (e) => e is StateError),
      );
      c.addError(ArgumentError('nope'));
      await c.close();
      expect((await seen).single, isA<ArgumentError>());
    });

    test('without a test, every error is handled', () async {
      final c = StreamController<int>();
      final out = fxEvents(c.stream).handleError((Object _) {}).toList();
      c
        ..addError(StateError('a'))
        ..add(1);
      await c.close();
      expect(await out, equals([1]));
    });

    test('empty source stays empty', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).handleError((Object _) {}).toList(),
        isEmpty,
      );
    });

    test('cancel unsubscribes', () async {
      await expectCancelDrops((s) => fxEvents(s).handleError((Object _) {}));
    });
  });

  group('timeout', () {
    test('fires a TimeoutException when nothing arrives', () async {
      final c = StreamController<int>();
      final seen = <Object>[];
      final sub = fxEvents(c.stream)
          .timeout(const Duration(milliseconds: 20))
          .listen(seen.add, onError: seen.add);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(seen.single, isA<TimeoutException>());
      await sub.cancel();
      await c.close();
    });

    test('an event within the limit is kept', () async {
      expect(
        await fxEvents(
          Stream.value(1),
        ).timeout(const Duration(seconds: 2)).toList(),
        equals([1]),
      );
    });

    test('empty close before the limit stays empty', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).timeout(const Duration(seconds: 2)).toList(),
        isEmpty,
      );
    });

    test('orElse switches on TimeoutException', () async {
      final c = StreamController<int>();
      final out = fxEvents(c.stream)
          .timeout(
            const Duration(milliseconds: 20),
            orElse: () => Stream.fromIterable([9, 8]),
          )
          .toList();
      expect(await out, equals([9, 8]));
      await c.close();
    });

    test('orElse is not used for a non-timeout error', () async {
      final c = StreamController<int>();
      final seen = collect(
        fxEvents(
          c.stream,
        ).timeout(const Duration(seconds: 2), orElse: () => Stream.value(9)),
      );
      c.addError(StateError('boom'));
      await c.close();
      expect((await seen).single, isA<StateError>());
    });

    test('a throwing orElse becomes an error and closes', () async {
      final c = StreamController<int>();
      final seen = collect(
        fxEvents(c.stream).timeout(
          const Duration(milliseconds: 20),
          orElse: () => throw ArgumentError('nope'),
        ),
      );
      expect((await seen).single, isA<ArgumentError>());
      await c.close();
    });

    test(
      'a TimeoutException from the fallback is forwarded, not switched',
      () async {
        final c = StreamController<int>();
        final seen = collect(
          fxEvents(c.stream).timeout(
            const Duration(milliseconds: 20),
            orElse: () => Stream<int>.error(TimeoutException('again')),
          ),
        );
        expect((await seen).single, isA<TimeoutException>());
        await c.close();
      },
    );

    test('orElse forwards pause, resume and cancel', () async {
      final c = StreamController<int>();
      final fallback = StreamController<int>();
      final seen = <int>[];
      final sub = fxEvents(c.stream)
          .timeout(
            const Duration(milliseconds: 20),
            orElse: () => fallback.stream,
          )
          .listen(seen.add);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      sub.pause();
      fallback.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1]));
      await sub.cancel();
      fallback.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1]));
      await c.close();
      await fallback.close();
    });

    test('cancel unsubscribes before the timer fires', () async {
      await expectCancelDrops(
        (s) => fxEvents(s).timeout(const Duration(seconds: 2)),
      );
    });
  });

  group('startWithAll', () {
    test('prepends the values', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([3, 4]),
        ).startWithAll([1, 2]).toList(),
        equals([1, 2, 3, 4]),
      );
    });

    test('empty values is identity', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1]),
        ).startWithAll(const []).toList(),
        equals([1]),
      );
    });

    test('empty source still emits the prefix', () async {
      expect(
        await fxEvents(const Stream<int>.empty()).startWithAll([1, 2]).toList(),
        equals([1, 2]),
      );
    });

    test('one source event follows the prefix', () async {
      expect(
        await fxEvents(Stream.value(9)).startWithAll([1]).toList(),
        equals([1, 9]),
      );
    });

    test('forwards source errors', () async {
      final seen = await collect(
        fxEvents(Stream<int>.error(StateError('boom'))).startWithAll([1]),
      );
      expect(seen.first, 1);
      expect(seen.last, isA<StateError>());
    });

    test('cancel unsubscribes', () async {
      await expectCancelDrops((s) => fxEvents(s).startWithAll([0]));
    });
  });

  group('endWith', () {
    test('appends the value when the source closes', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2])).endWith(0).toList(),
        equals([1, 2, 0]),
      );
    });

    test('endWithAll appends every value', () async {
      expect(
        await fxEvents(Stream.fromIterable([1])).endWithAll([8, 9]).toList(),
        equals([1, 8, 9]),
      );
    });

    test('empty source still emits the suffix', () async {
      expect(
        await fxEvents(const Stream<int>.empty()).endWith(7).toList(),
        equals([7]),
      );
    });

    test('empty suffix is identity', () async {
      expect(
        await fxEvents(Stream.value(1)).endWithAll(const []).toList(),
        equals([1]),
      );
    });

    test('forwards source errors then still appends on close', () async {
      final c = StreamController<int>();
      final seen = collect(fxEvents(c.stream).endWith(0));
      c.addError(StateError('boom'));
      await c.close();
      final out = await seen;
      expect(out.first, isA<StateError>());
      expect(out.last, 0);
    });

    test('cancel drops the suffix', () async {
      await expectCancelDrops((s) => fxEvents(s).endWith(0));
    });
  });

  group('ifEmpty', () {
    test('emits the fallback only when zero events arrived', () async {
      var calls = 0;
      expect(
        await fxEvents(const Stream<int>.empty()).ifEmpty(() {
          calls++;
          return 7;
        }).toList(),
        equals([7]),
      );
      expect(calls, 1);
    });

    test('does not fire when any event was emitted', () async {
      var calls = 0;
      expect(
        await fxEvents(Stream.fromIterable([1, 2])).ifEmpty(() {
          calls++;
          return 0;
        }).toList(),
        equals([1, 2]),
      );
      expect(calls, 0);
    });

    test('one event is enough to suppress the fallback', () async {
      expect(
        await fxEvents(Stream.value(1)).ifEmpty(() => 0).toList(),
        equals([1]),
      );
    });

    test('defaultIfEmpty is the constant form', () async {
      expect(
        await fxEvents(const Stream<int>.empty()).defaultIfEmpty(0).toList(),
        equals([0]),
      );
      expect(
        await fxEvents(Stream.value(1)).defaultIfEmpty(0).toList(),
        equals([1]),
      );
    });

    test('a throwing fallback becomes an error', () async {
      final seen = await collect(
        fxEvents(
          const Stream<int>.empty(),
        ).ifEmpty(() => throw StateError('x')),
      );
      expect(seen.single, isA<StateError>());
    });

    test(
      'forwards source errors and still fires when no data arrived',
      () async {
        final c = StreamController<int>();
        final seen = collect(fxEvents(c.stream).ifEmpty(() => 0));
        c.addError(StateError('boom'));
        await c.close();
        final out = await seen;
        expect(out.first, isA<StateError>());
        expect(out.last, 0);
      },
    );

    test('cancel unsubscribes', () async {
      await expectCancelDrops((s) => fxEvents(s).ifEmpty(() => 0));
    });
  });

  group('throwIfEmpty', () {
    test('errors when the source closes without emitting', () async {
      await expectLater(
        fxEvents(const Stream<int>.empty()).throwIfEmpty().toList(),
        throwsStateError,
      );
    });

    test('mirrors a non-empty source', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2])).throwIfEmpty().toList(),
        equals([1, 2]),
      );
    });

    test('one event is enough', () async {
      expect(
        await fxEvents(Stream.value(1)).throwIfEmpty().toList(),
        equals([1]),
      );
    });

    test('uses the factory when provided', () async {
      await expectLater(
        fxEvents(
          const Stream<int>.empty(),
        ).throwIfEmpty(() => ArgumentError('none')).toList(),
        throwsArgumentError,
      );
    });

    test('a throwing factory becomes that error', () async {
      await expectLater(
        fxEvents(
          const Stream<int>.empty(),
        ).throwIfEmpty(() => throw ArgumentError('factory')).toList(),
        throwsArgumentError,
      );
    });

    test('forwards source errors', () async {
      final c = StreamController<int>();
      final seen = collect(fxEvents(c.stream).throwIfEmpty());
      c.addError(StateError('boom'));
      await c.close();
      final out = await seen;
      expect(out.first, isA<StateError>());
      expect(out.last, isA<StateError>());
    });

    test('cancel unsubscribes', () async {
      await expectCancelDrops((s) => fxEvents(s).throwIfEmpty());
    });
  });

  group('uniq', () {
    test('drops non-adjacent duplicates too', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2, 1, 3, 2])).uniq().toList(),
        equals([1, 2, 3]),
      );
    });

    test('empty source stays empty', () async {
      expect(
        await fxEvents(const Stream<int>.empty()).uniq().toList(),
        isEmpty,
      );
    });

    test('one event is kept', () async {
      expect(await fxEvents(Stream.value(1)).uniq().toList(), equals([1]));
    });

    test('custom equals compares by the provided relation', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, -1, 2, -2, 3]),
        ).uniq((a, b) => a.abs() == b.abs()).toList(),
        equals([1, 2, 3]),
      );
    });

    test(
      'a throwing equals becomes an error and does not record the value',
      () async {
        final seen = await collect(
          fxEvents(Stream.fromIterable([1, 2, 2])).uniq((a, b) {
            if (b == 2) throw StateError('eq');
            return a == b;
          }),
        );
        expect(seen.first, 1);
        expect(seen.whereType<StateError>(), isNotEmpty);
        expect(seen.last, isA<StateError>());
      },
    );

    test('forwards source errors', () async {
      final seen = await collect(
        fxEvents(Stream<int>.error(StateError('boom'))).uniq(),
      );
      expect(seen.single, isA<StateError>());
    });

    test('cancel unsubscribes', () async {
      await expectCancelDrops((s) => fxEvents(s).uniq());
    });
  });

  group('drain', () {
    test('drops values and completes on close', () async {
      await fxEvents(Stream.fromIterable([1, 2, 3])).drain();
    });

    test('empty source completes', () async {
      await fxEvents(const Stream<int>.empty()).drain();
    });

    test('one event is dropped', () async {
      await fxEvents(Stream.value(1)).drain();
    });

    test('a source error completes the future as an error', () async {
      await expectLater(
        fxEvents(Stream<int>.error(StateError('boom'))).drain(),
        throwsStateError,
      );
    });
  });

  group('terminals', () {
    test('last answers the last event or null if empty', () async {
      expect(await fxEvents(Stream.fromIterable([1, 2, 3])).last(), 3);
      expect(await fxEvents(Stream.value(7)).last(), 7);
      expect(await fxEvents(const Stream<int>.empty()).last(), isNull);
    });

    test('last forwards a source error', () async {
      await expectLater(
        fxEvents(Stream<int>.error(StateError('boom'))).last(),
        throwsStateError,
      );
    });

    test('nth is 0-based and null if missing', () async {
      expect(await fxEvents(Stream.fromIterable([10, 20, 30])).nth(0), 10);
      expect(await fxEvents(Stream.fromIterable([10, 20, 30])).nth(2), 30);
      expect(await fxEvents(Stream.fromIterable([10, 20])).nth(5), isNull);
      expect(await fxEvents(const Stream<int>.empty()).nth(0), isNull);
    });

    test('nth of a negative index is null without subscribing', () async {
      var listened = false;
      final c = StreamController<int>(onListen: () => listened = true);
      expect(await fxEvents(c.stream).nth(-1), isNull);
      expect(listened, isFalse);
      unawaited(c.close());
    });

    test('nth cancels once the index is found', () async {
      var cancelled = false;
      final c = StreamController<int>(onCancel: () => cancelled = true);
      final value = fxEvents(c.stream).nth(1);
      c
        ..add(1)
        ..add(2)
        ..add(3);
      expect(await value, 2);
      expect(cancelled, isTrue);
      await c.close();
    });

    test('nth forwards a source error', () async {
      await expectLater(
        fxEvents(Stream<int>.error(StateError('boom'))).nth(0),
        throwsStateError,
      );
    });

    test('length counts events', () async {
      expect(await fxEvents(Stream.fromIterable([1, 2, 3])).length, 3);
      expect(await fxEvents(const Stream<int>.empty()).length, 0);
    });

    test('isEmpty reports whether anything was emitted', () async {
      expect(await fxEvents(const Stream<int>.empty()).isEmpty, isTrue);
      expect(await fxEvents(Stream.value(1)).isEmpty, isFalse);
    });

    test('any and every are empty-safe', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2, 3])).any((v) => v == 2),
        isTrue,
      );
      expect(
        await fxEvents(Stream.fromIterable([1, 2, 3])).any((v) => v == 9),
        isFalse,
      );
      expect(
        await fxEvents(const Stream<int>.empty()).any((_) => true),
        isFalse,
      );
      expect(
        await fxEvents(Stream.fromIterable([2, 4])).every((v) => v.isEven),
        isTrue,
      );
      expect(
        await fxEvents(Stream.fromIterable([2, 3])).every((v) => v.isEven),
        isFalse,
      );
      expect(
        await fxEvents(const Stream<int>.empty()).every((_) => false),
        isTrue,
      );
    });

    test('fold combines from the seed', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2, 3]),
        ).fold(10, (a, b) => a + b),
        16,
      );
      expect(
        await fxEvents(const Stream<int>.empty()).fold(10, (a, b) => a + b),
        10,
      );
    });

    test('reduce combines, and throws on empty', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2, 3])).reduce((a, b) => a + b),
        6,
      );
      await expectLater(
        fxEvents(const Stream<int>.empty()).reduce((a, b) => a + b),
        throwsStateError,
      );
    });

    test('forEach visits every event', () async {
      final seen = <int>[];
      await fxEvents(Stream.fromIterable([1, 2])).forEach(seen.add);
      expect(seen, equals([1, 2]));
      await fxEvents(const Stream<int>.empty()).forEach(seen.add);
      expect(seen, equals([1, 2]));
    });

    test('forEach forwards a source error', () async {
      await expectLater(
        fxEvents(Stream<int>.error(StateError('boom'))).forEach((_) {}),
        throwsStateError,
      );
    });
  });

  test('operators keep the chain unbroken', () async {
    expect(
      await fxEvents(
        Stream.fromIterable([1, 2, 3, 2, 1]),
      ).peek((_) {}).uniq().takeRight(2).endWith(0).toList(),
      equals([2, 3, 0]),
    );
  });
}
