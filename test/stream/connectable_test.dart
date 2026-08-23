import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('connectable', () {
    test('does not listen to the source until connect', () async {
      var listened = false;
      final c = StreamController<int>(onListen: () => listened = true);
      final conn = fxEvents(c.stream).connectable();
      expect(listened, isFalse);

      final seen = <int>[];
      conn.events.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      expect(listened, isFalse, reason: 'listening to events is not connect');

      conn.connect();
      expect(listened, isTrue);
      c.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([2]));
      await c.close();
    });

    test('connect then source events reach every events listener', () async {
      final c = StreamController<int>();
      final conn = fxEvents(c.stream).connectable();
      final a = <int>[];
      final b = <int>[];
      conn.events.listen(a.add);
      conn.connect();
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      conn.events.listen(b.add);
      c.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(a, equals([1, 2]));
      expect(b, equals([2]), reason: 'late events-listener misses history');
      await c.close();
    });

    test('a second connect while connected is a no-op', () async {
      final c = StreamController<int>();
      final conn = fxEvents(c.stream).connectable();
      final first = conn.connect();
      final second = conn.connect();
      expect(identical(first, second), isTrue);
      await first.cancel();
      await c.close();
    });

    test('cancelling the connection stops forwarding', () async {
      var cancelled = false;
      final c = StreamController<int>(onCancel: () => cancelled = true);
      final conn = fxEvents(c.stream).connectable();
      final seen = <int>[];
      conn.events.listen(seen.add);
      final sub = conn.connect();
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1]));
      await sub.cancel();
      expect(cancelled, isTrue);
      await c.close();
    });

    test('source done closes events', () async {
      final conn = fxEvents(Stream.fromIterable([1, 2, 3])).connectable();
      final out = conn.events.toList();
      conn.connect();
      expect(await out, equals([1, 2, 3]));
    });

    test('source errors reach events listeners', () async {
      final c = StreamController<int>();
      final conn = fxEvents(c.stream).connectable();
      final seen = <Object>[];
      conn.events.listen(seen.add, onError: seen.add);
      conn.connect();
      c.addError(StateError('boom'), StackTrace.current);
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await c.close();
    });
  });

  group('refCount', () {
    test(
      'connects on the first listener and disconnects on the last',
      () async {
        var listens = 0;
        var cancels = 0;
        final c = StreamController<int>(
          onListen: () => listens++,
          onCancel: () => cancels++,
        );
        final shared = fxEvents(c.stream).connectable().refCount();
        expect(listens, 0);

        final a = shared.listen((_) {});
        await Future<void>.delayed(Duration.zero);
        expect(listens, 1);

        final b = shared.listen((_) {});
        await Future<void>.delayed(Duration.zero);
        expect(listens, 1, reason: 'second listener shares the connection');

        await a.cancel();
        expect(cancels, 0);
        await b.cancel();
        expect(cancels, 1);
        await c.close();
      },
    );

    test('forwards values and errors', () async {
      final c = StreamController<int>();
      final shared = fxEvents(c.stream).connectable().refCount();
      final seen = <Object>[];
      final sub = shared.listen(seen.add, onError: seen.add);
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      c.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1, isA<StateError>()]));
      await sub.cancel();
      await c.close();
    });

    test('a paused refCount subscriber buffers until resume', () async {
      final c = StreamController<int>();
      final shared = fxEvents(c.stream).connectable().refCount();
      final seen = <int>[];
      final sub = shared.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      sub.pause();
      c.add(1);
      c.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(seen, hasLength(0));
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1, 2]));
      await sub.cancel();
      await c.close();
    });

    test('source completing closes refCount listeners', () async {
      final shared = fxEvents(
        Stream.fromIterable([1, 2]),
      ).connectable().refCount();
      expect(await shared.toList(), equals([1, 2]));
    });
  });

  group('shareReplay', () {
    test('late subscriber sees history then follows', () async {
      final c = StreamController<int>();
      final shared = fxEvents(c.stream).shareReplay();
      final a = <int>[];
      shared.listen(a.add);
      c.add(1);
      c.add(2);
      await Future<void>.delayed(Duration.zero);
      final b = <int>[];
      shared.listen(b.add);
      await Future<void>.delayed(Duration.zero);
      expect(a, equals([1, 2]));
      expect(b, equals([1, 2]));
      c.add(3);
      await Future<void>.delayed(Duration.zero);
      expect(a, equals([1, 2, 3]));
      expect(b, equals([1, 2, 3]));
      await c.close();
    });

    test('size trims history for a late subscriber', () async {
      final c = StreamController<int>();
      final shared = fxEvents(c.stream).shareReplay(size: 2);
      shared.listen((_) {});
      c.add(1);
      c.add(2);
      c.add(3);
      await Future<void>.delayed(Duration.zero);
      final late = <int>[];
      shared.listen(late.add);
      await Future<void>.delayed(Duration.zero);
      expect(late, equals([2, 3]));
      await c.close();
    });

    test('maxAge expires history for a late subscriber', () async {
      final c = StreamController<int>();
      final shared = fxEvents(
        c.stream,
      ).shareReplay(maxAge: const Duration(milliseconds: 40));
      shared.listen((_) {});
      c.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      c.add(2);
      await Future<void>.delayed(Duration.zero);
      final late = <int>[];
      shared.listen(late.add);
      await Future<void>.delayed(Duration.zero);
      expect(late, equals([2]));
      await c.close();
    });

    test(
      'resetOnCancel true starts a fresh ReplayValue next generation',
      () async {
        var listens = 0;
        final source = Stream<int>.multi((listener) {
          listens++;
          listener
            ..add(listens * 10)
            ..add(listens * 10 + 1)
            ..close();
        });
        final shared = fxEvents(source).shareReplay(size: 2);
        expect(await shared.toList(), equals([10, 11]));
        expect(listens, 1);
        expect(await shared.toList(), equals([20, 21]));
        expect(listens, 2);
      },
    );

    test('resetOnCancel false keeps the source connected forever', () async {
      var cancels = 0;
      final c = StreamController<int>(onCancel: () => cancels++);
      final shared = fxEvents(c.stream).shareReplay(resetOnCancel: false);
      final sub = shared.listen((_) {});
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(cancels, 0);
      c.add(2);
      await Future<void>.delayed(Duration.zero);
      final late = <int>[];
      shared.listen(late.add);
      await Future<void>.delayed(Duration.zero);
      expect(late, equals([1, 2]));
      await c.close();
    });

    test('two listeners share one run; one leaving does not reset', () async {
      var listens = 0;
      final c = StreamController<int>(onListen: () => listens++);
      final shared = fxEvents(c.stream).shareReplay();
      final a = shared.listen((_) {});
      final b = shared.listen((_) {});
      await Future<void>.delayed(Duration.zero);
      expect(listens, 1);
      await a.cancel();
      expect(listens, 1);
      c.add(7);
      await Future<void>.delayed(Duration.zero);
      await b.cancel();
      await c.close();
    });

    test('source errors reach shareReplay listeners', () async {
      final c = StreamController<int>();
      final shared = fxEvents(c.stream).shareReplay();
      final seen = <Object>[];
      final sub = shared.listen(seen.add, onError: seen.add);
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      c.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1, isA<StateError>()]));
      await sub.cancel();
      await c.close();
    });

    test(
      'source completing closes shareReplay listeners with history',
      () async {
        final shared = fxEvents(Stream.fromIterable([1, 2, 3])).shareReplay();
        expect(await shared.toList(), equals([1, 2, 3]));
      },
    );

    test('a paused shareReplay subscriber buffers until resume', () async {
      final c = StreamController<int>();
      final shared = fxEvents(c.stream).shareReplay();
      final seen = <int>[];
      final sub = shared.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      sub.pause();
      c.add(1);
      c.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(seen, hasLength(0));
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1, 2]));
      await sub.cancel();
      await c.close();
    });

    test('shareReplay of an empty source is empty', () async {
      expect(
        await fxEvents(const Stream<int>.empty()).shareReplay().toList(),
        hasLength(0),
      );
    });
  });
}
