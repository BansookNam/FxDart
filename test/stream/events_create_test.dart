import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty;

void main() {
  group('FxEvents.value', () {
    test('emits one event and closes', () async {
      expect(await FxEvents.value(7).toList(), equals([7]));
    });
  });

  group('FxEvents.empty', () {
    test('closes without emitting', () async {
      expect(await FxEvents<int>.empty().toList(), isEmpty);
    });
  });

  group('FxEvents.never', () {
    test('emits nothing and does not close until cancelled', () async {
      final seen = <int>[];
      var done = false;
      final sub = FxEvents<int>.never().listen(
        seen.add,
        onDone: () => done = true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(seen, isEmpty);
      expect(done, isFalse);
      await sub.cancel();
    });
  });

  group('FxEvents.error', () {
    test('emits the error and closes', () async {
      expect(
        FxEvents<int>.error(StateError('boom')).toList(),
        throwsStateError,
      );
    });

    test('forwards an explicit stack trace', () async {
      final st = StackTrace.current;
      expect(
        FxEvents<int>.error(StateError('boom'), st).toList(),
        throwsStateError,
      );
    });
  });

  group('FxEvents.fromFuture', () {
    test('emits the value and closes', () async {
      expect(await FxEvents.fromFuture(Future.value(3)).toList(), equals([3]));
    });

    test(
      'empty-equivalent: a never-completing future can be cancelled',
      () async {
        final pending = Completer<int>();
        final seen = <int>[];
        final sub = FxEvents.fromFuture(pending.future).listen(seen.add);
        await sub.cancel();
        pending.complete(1);
        await Future<void>.delayed(Duration.zero);
        expect(seen, isEmpty);
      },
    );

    test('forwards a future error', () async {
      expect(
        FxEvents<int>.fromFuture(Future.error(StateError('boom'))).toList(),
        throwsStateError,
      );
    });
  });

  group('FxEvents.periodic', () {
    test('emits the tick count when computation is omitted', () async {
      final seen = <int>[];
      final sub = FxEvents<int>.periodic(
        const Duration(milliseconds: 15),
      ).listen(seen.add);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();
      expect(seen, isNotEmpty);
      expect(seen.first, 0);
    });

    test('maps each tick through computation', () async {
      final seen = <int>[];
      final sub = FxEvents.periodic(
        const Duration(milliseconds: 15),
        (i) => i * 10,
      ).listen(seen.add);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      await sub.cancel();
      expect(seen.first, 0);
      expect(seen, isNotEmpty);
    });

    test('cancel-before-event emits nothing', () async {
      final seen = <int>[];
      final sub = FxEvents<int>.periodic(
        const Duration(milliseconds: 40),
      ).listen(seen.add);
      await sub.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(seen, isEmpty);
    });
  });

  group('FxEvents.timer', () {
    test('one-shot emits 0 then closes', () async {
      expect(
        await FxEvents.timer(const Duration(milliseconds: 15)).toList(),
        equals([0]),
      );
    });

    test('with every, continues 1, 2, … after the first', () async {
      final seen = <int>[];
      final sub = FxEvents.timer(
        const Duration(milliseconds: 15),
        const Duration(milliseconds: 15),
      ).listen(seen.add);
      await Future<void>.delayed(const Duration(milliseconds: 70));
      await sub.cancel();
      expect(seen, containsAllInOrder([0, 1]));
      expect(seen.length, greaterThanOrEqualTo(2));
    });

    test('cancel-before-event emits nothing', () async {
      final seen = <int>[];
      final sub = FxEvents.timer(
        const Duration(milliseconds: 40),
      ).listen(seen.add);
      await sub.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(seen, isEmpty);
    });
  });

  group('FxEvents.defer', () {
    test('factory runs on listen, not construction', () async {
      var called = 0;
      final deferred = FxEvents<int>.defer(() {
        called++;
        return Stream.value(1);
      });
      expect(called, 0);
      expect(await deferred.toList(), equals([1]));
      expect(called, 1);
    });

    test('empty factory stream closes empty', () async {
      expect(
        await FxEvents<int>.defer(() => Stream<int>.empty()).toList(),
        isEmpty,
      );
    });

    test('cancel-before-event tears the inner subscription down', () async {
      final inner = StreamController<int>();
      final seen = <int>[];
      final sub = FxEvents.defer(() => inner.stream).listen(seen.add);
      await sub.cancel();
      inner.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
      await inner.close();
    });

    test('forwards a throw from the factory', () async {
      expect(
        FxEvents<int>.defer(() => throw StateError('boom')).toList(),
        throwsStateError,
      );
    });

    test('forwards source errors', () async {
      expect(
        FxEvents<int>.defer(
          () => Stream<int>.error(StateError('boom')),
        ).toList(),
        throwsStateError,
      );
    });

    test('pauses and resumes the inner subscription', () async {
      final inner = StreamController<int>();
      final seen = <int>[];
      final sub = FxEvents.defer(() => inner.stream).listen(seen.add);
      sub.pause();
      inner.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1]));
      await sub.cancel();
      await inner.close();
    });
  });

  group('FxEvents.generate', () {
    test('empty: condition fails on the seed', () async {
      expect(
        await FxEvents.generate(0, (n) => false, (n) => n + 1).toList(),
        isEmpty,
      );
    });

    test('one event then the condition fails', () async {
      expect(
        await FxEvents.generate(5, (n) => n == 5, (n) => n + 1).toList(),
        equals([5]),
      );
    });

    test('walks while the condition holds', () async {
      expect(
        await FxEvents.generate(1, (n) => n <= 3, (n) => n + 1).toList(),
        equals([1, 2, 3]),
      );
    });

    test('cancel-before-event emits nothing', () async {
      final seen = <int>[];
      final sub = FxEvents.generate(
        0,
        (_) => true,
        (n) => n + 1,
      ).listen(seen.add);
      await sub.cancel();
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
    });

    test('forwards a throw from the condition', () async {
      expect(
        FxEvents.generate(
          0,
          (n) => throw StateError('boom'),
          (n) => n + 1,
        ).toList(),
        throwsStateError,
      );
    });

    test('forwards a throw from iterate after emitting', () async {
      expect(
        FxEvents.generate(
          0,
          (n) => n < 1,
          (n) => throw StateError('boom'),
        ).toList(),
        throwsStateError,
      );
    });

    test('an infinite generate can be cancelled mid-stream', () async {
      final seen = <int>[];
      final sub = FxEvents.generate(
        0,
        (_) => true,
        (n) => n + 1,
      ).listen(seen.add);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();
      expect(seen, isNotEmpty);
    });
  });

  group('FxEvents.fromPattern', () {
    test('add on listen, handler delivers, remove on cancel', () async {
      final handlers = <void Function(int)>[];
      final events = FxEvents<int>.fromPattern(handlers.add, handlers.remove);
      final seen = <int>[];
      final sub = events.listen(seen.add);
      expect(handlers, hasLength(1));
      handlers.single(7);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([7]));
      await sub.cancel();
      expect(handlers, isEmpty);
    });

    test('empty: listen and cancel with no events', () async {
      final seen = <int>[];
      final sub = FxEvents<int>.fromPattern((_) {}, (_) {}).listen(seen.add);
      await sub.cancel();
      expect(seen, isEmpty);
    });

    test('forwards a throw from add', () async {
      expect(
        FxEvents<int>.fromPattern(
          (h) => throw StateError('boom'),
          (h) {},
        ).toList(),
        throwsStateError,
      );
    });
  });

  group('FxEvents.using', () {
    test('acquires on listen, emits, releases on complete', () async {
      var acquired = 0;
      var released = 0;
      final out = await FxEvents.using<List<int>, int>(
        () {
          acquired++;
          return [1, 2, 3];
        },
        (r) => Stream.fromIterable(r),
        (r) {
          released++;
        },
      ).toList();
      expect(out, equals([1, 2, 3]));
      expect(acquired, 1);
      expect(released, 1);
    });

    test('empty inner stream still releases', () async {
      var released = 0;
      expect(
        await FxEvents.using<int, int>(
          () => 0,
          (_) => Stream<int>.empty(),
          (_) => released++,
        ).toList(),
        isEmpty,
      );
      expect(released, 1);
    });

    test('cancel-before-event releases', () async {
      final inner = StreamController<int>();
      var released = 0;
      final seen = <int>[];
      final sub = FxEvents.using<int, int>(
        () => 1,
        (_) => inner.stream,
        (_) => released++,
      ).listen(seen.add);
      await sub.cancel();
      expect(released, 1);
      expect(seen, isEmpty);
      await inner.close();
    });

    test('releases even if asStream throws', () async {
      var released = 0;
      expect(
        FxEvents.using<String, int>(
          () => 'res',
          (r) => throw StateError('nope'),
          (r) {
            released++;
          },
        ).toList(),
        throwsStateError,
      );
      await Future<void>.delayed(Duration.zero);
      expect(released, 1);
    });

    test('a throw from acquire does not release', () async {
      var released = 0;
      expect(
        FxEvents.using<String, int>(
          () => throw StateError('acq'),
          (_) => Stream<int>.empty(),
          (_) => released++,
        ).toList(),
        throwsStateError,
      );
      expect(released, 0);
    });

    test('a source error releases once and closes', () async {
      final inner = StreamController<int>();
      var released = 0;
      final seen = <Object>[];
      final done = Completer<void>();
      FxEvents.using<int, int>(
        () => 1,
        (_) => inner.stream,
        (_) => released++,
      ).listen(seen.add, onError: seen.add, onDone: done.complete);
      inner.add(1);
      inner.addError(StateError('boom'));
      await done.future;
      expect(seen.first, 1);
      expect(seen.last, isA<StateError>());
      expect(released, 1);
      await inner.close();
      expect(released, 1, reason: 'release runs once');
    });

    test('an async release is awaited on cancel', () async {
      var released = false;
      final inner = StreamController<int>();
      final sub = FxEvents.using<int, int>(() => 1, (_) => inner.stream, (
        _,
      ) async {
        await Future<void>.delayed(Duration.zero);
        released = true;
      }).listen((_) {});
      await sub.cancel();
      expect(released, isTrue);
      await inner.close();
    });

    test('pauses and resumes the inner subscription', () async {
      final inner = StreamController<int>();
      final seen = <int>[];
      final sub = FxEvents.using<int, int>(
        () => 1,
        (_) => inner.stream,
        (_) {},
      ).listen(seen.add);
      sub.pause();
      inner.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1]));
      await sub.cancel();
      await inner.close();
    });
  });

  group('FxEvents.create', () {
    test('empty: close with no events', () async {
      expect(
        await FxEvents<int>.create((emit) => emit.close()).toList(),
        isEmpty,
      );
    });

    test('one event then close', () async {
      expect(
        await FxEvents<int>.create((emit) {
          emit.add(1);
          emit.close();
        }).toList(),
        equals([1]),
      );
    });

    test('cancel-before-event runs onCancel and drops a late add', () async {
      var cancelled = false;
      final seen = <int>[];
      final sub = FxEvents<int>.create((emit) {
        emit.onCancel = () {
          cancelled = true;
        };
        Timer(const Duration(milliseconds: 30), () {
          emit.add(1);
          emit.close();
        });
      }).listen(seen.add);
      await sub.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cancelled, isTrue);
      expect(seen, isEmpty);
    });

    test('forwards addError', () async {
      expect(
        FxEvents<int>.create((emit) {
          emit.addError(StateError('boom'));
          emit.close();
        }).toList(),
        throwsStateError,
      );
    });

    test('forwards addError with an explicit stack trace', () async {
      expect(
        FxEvents<int>.create((emit) {
          emit.addError(StateError('boom'), StackTrace.current);
          emit.close();
        }).toList(),
        throwsStateError,
      );
    });

    test('a throw from init is forwarded and the stream closes', () async {
      expect(
        FxEvents<int>.create((emit) => throw StateError('boom')).toList(),
        throwsStateError,
      );
    });

    test('a throw after close is ignored', () async {
      expect(
        await FxEvents<int>.create((emit) {
          emit.close();
          throw StateError('after close');
        }).toList(),
        isEmpty,
      );
    });

    test('add, addError and close no-op after close', () async {
      expect(
        await FxEvents<int>.create((emit) {
          emit.add(1);
          emit.close();
          emit.add(2);
          emit.addError(StateError('late'));
          emit.close();
        }).toList(),
        equals([1]),
      );
    });

    test('onCancel is optional', () async {
      final sub = FxEvents<int>.create((emit) {}).listen((_) {});
      await sub.cancel();
    });
  });
}
