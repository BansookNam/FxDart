import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// Emits each (offsetMs, value) pair at its offset, closing at [closeMs].
Stream<T> timed<T>(List<(int, T)> events, int closeMs) {
  final c = StreamController<T>();
  for (final (ms, v) in events) {
    Timer(Duration(milliseconds: ms), () => c.add(v));
  }
  Timer(Duration(milliseconds: closeMs), c.close);
  return c.stream;
}

void main() {
  group('share', () {
    test('two listeners see one run of the chain', () async {
      var runs = 0;
      final shared = fxEvents(timed([(0, 1), (60, 2)], 150)).map((v) {
        runs++;
        return v;
      }).share();
      final a = shared.toList();
      final b = shared.toList();
      expect(await a, equals([1, 2]));
      expect(await b, equals([1, 2]));
      expect(
        runs,
        2,
        reason: 'the map ran once per event, not once per listener',
      );
    });

    test(
      'a listener arriving after the run is handed a closed stream',
      () async {
        final shared = fxEvents(Stream.fromIterable([1, 2, 3])).share();
        expect(await shared.toList(), equals([1, 2, 3]));
        expect(await shared.toList(), hasLength(0));
      },
    );

    test('share forwards errors', () async {
      final shared = fxEvents(Stream<int>.error(StateError('boom'))).share();
      expect(shared.toList(), throwsStateError);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });

    test(
      'default reset: a new listen after the last listener left resubscribes',
      () async {
        var listens = 0;
        final ticks = StreamController<int>.broadcast();
        final source = Stream<int>.multi((controller) {
          listens++;
          final sub = ticks.stream.listen(
            controller.add,
            onError: controller.addError,
            onDone: controller.close,
          );
          controller.onCancel = () => sub.cancel();
        });
        final shared = fxEvents(source).share();
        final first = <int>[];
        final sub = shared.listen(first.add);
        ticks.add(1);
        await Future<void>.delayed(Duration.zero);
        expect(first, equals([1]));
        await sub.cancel();

        ticks.add(99);
        await Future<void>.delayed(Duration.zero);

        final later = <int>[];
        final sub2 = shared.listen(later.add);
        ticks.add(2);
        await Future<void>.delayed(Duration.zero);
        expect(listens, 2, reason: 'reset:true starts a fresh subscribe');
        expect(
          later,
          equals([2]),
          reason: 'later events reach the new listener',
        );
        await sub2.cancel();
        await ticks.close();
      },
    );

    test(
      'share(reset: false) closes for good when the last listener leaves',
      () async {
        var listens = 0;
        final source = Stream<int>.multi((controller) {
          listens++;
        });
        final shared = fxEvents(source).share(reset: false);
        final sub = shared.listen((_) {});
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        expect(await shared.toList(), hasLength(0));
        expect(listens, 1, reason: 'the closed broadcast never reconnects');
      },
    );

    test(
      'reset: true cancels a source that keeps ticking after its error',
      () async {
        var live = 0;
        final ticks = StreamController<int>.broadcast();
        final source = Stream<int>.multi((controller) {
          live++;
          final sub = ticks.stream.listen(
            controller.add,
            onError: controller.addError,
          );
          controller.onCancel = () {
            live--;
            return sub.cancel();
          };
        });
        final shared = fxEvents(source).share();
        final first = <Object>[];
        final sub = shared.listen(first.add, onError: first.add);
        ticks.addError(StateError('boom'));
        await Future<void>.delayed(Duration.zero);
        expect(first.whereType<StateError>(), hasLength(1));
        await sub.cancel();
        expect(live, 0, reason: 'error must cancel the source, not just drop it');

        ticks.add(99);
        await Future<void>.delayed(Duration.zero);

        final later = <Object>[];
        final sub2 = shared.listen(later.add, onError: later.add);
        ticks.add(2);
        await Future<void>.delayed(Duration.zero);
        expect(live, 1);
        expect(later, equals([2]));
        expect(later, isNot(contains(99)));
        await sub2.cancel();
        expect(live, 0);
        await ticks.close();
      },
    );

    test(
      'reset: true lets a later listener resubscribe after a source error',
      () async {
        var attempt = 0;
        final source = Stream<int>.multi((controller) {
          attempt++;
          if (attempt == 1) {
            controller.addError(StateError('boom'));
          } else {
            controller.add(1);
            controller.close();
          }
        });
        final shared = fxEvents(source).share();
        expect(shared.toList(), throwsStateError);
        await Future<void>.delayed(Duration.zero);
        expect(await shared.toList(), equals([1]));
        expect(attempt, 2);
      },
    );

    test(
      'share(reset: false) closes for good when the source errors',
      () async {
        var attempt = 0;
        final source = Stream<int>.multi((controller) {
          attempt++;
          controller.addError(StateError('boom'));
        });
        final shared = fxEvents(source).share(reset: false);
        expect(shared.toList(), throwsStateError);
        await Future<void>.delayed(Duration.zero);
        expect(await shared.toList(), hasLength(0));
        expect(attempt, 1);
      },
    );

    test('share(reset: true) is the same reconnecting default', () async {
      var listens = 0;
      final source = Stream<int>.multi((controller) {
        listens++;
      });
      final shared = fxEvents(source).share(reset: true);
      final sub = shared.listen((_) {});
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      final sub2 = shared.listen((_) {});
      await Future<void>.delayed(Duration.zero);
      expect(listens, 2);
      await sub2.cancel();
    });
  });
}
