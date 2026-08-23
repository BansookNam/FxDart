import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('ReplayValue', () {
    test(
      'default size 1 keeps only the latest for a late subscriber',
      () async {
        final replay = ReplayValue<int>();
        replay.add(1);
        replay.add(2);
        final seen = <int>[];
        replay.stream.listen(seen.add);
        replay.add(3);
        await replay.close();
        await Future<void>.delayed(Duration.zero);
        expect(seen, equals([2, 3]));
      },
    );

    test('size 2 over many adds still replays only the last two', () async {
      final replay = ReplayValue<int>(size: 2);
      for (var i = 0; i < 20; i++) {
        replay.add(i);
      }
      final seen = <int>[];
      replay.stream.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([18, 19]));
      await replay.close();
    });

    test('size 2 replays the last two then follows', () async {
      final replay = ReplayValue<int>(size: 2);
      replay.add(1);
      replay.add(2);
      replay.add(3);
      final seen = <int>[];
      replay.stream.listen(seen.add);
      replay.add(4);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([2, 3, 4]));
      await replay.close();
    });

    test('null size is unbounded', () async {
      final replay = ReplayValue<int>(size: null);
      for (var i = 0; i < 5; i++) {
        replay.add(i);
      }
      final seen = <int>[];
      final sub = replay.stream.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([0, 1, 2, 3, 4]));
      await sub.cancel();
      await replay.close();
    });

    test('size less than 1 is unbounded', () async {
      final replay = ReplayValue<int>(size: 0);
      replay.add(1);
      replay.add(2);
      replay.add(3);
      final seen = <int>[];
      final sub = replay.stream.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1, 2, 3]));
      await sub.cancel();
      await replay.close();
    });

    test('maxAge drops values older than the window on subscribe', () async {
      final replay = ReplayValue<int>(
        size: 10,
        maxAge: const Duration(milliseconds: 40),
      );
      replay.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final seen = <int>[];
      replay.stream.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      expect(seen, hasLength(0));
      replay.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([2]));
      await replay.close();
    });

    test('maxAge drops expired values on add', () async {
      final replay = ReplayValue<int>(
        size: 10,
        maxAge: const Duration(milliseconds: 40),
      );
      replay.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      replay.add(2);
      replay.add(3);
      final seen = <int>[];
      final sub = replay.stream.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([2, 3]));
      await sub.cancel();
      await replay.close();
    });

    test('maxAge with nothing expired keeps the buffer', () async {
      final replay = ReplayValue<int>(
        size: 10,
        maxAge: const Duration(seconds: 5),
      );
      replay.add(1);
      replay.add(2);
      final seen = <int>[];
      final sub = replay.stream.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1, 2]));
      await sub.cancel();
      await replay.close();
    });

    test('late subscriber after close gets the buffer then done', () async {
      final replay = ReplayValue<String>(size: 2);
      replay.add('a');
      replay.add('b');
      replay.add('c');
      await replay.close();
      expect(replay.isClosed, isTrue);
      expect(await replay.stream.toList(), equals(['b', 'c']));
    });

    test('close with an empty buffer yields an empty stream', () async {
      final replay = ReplayValue<int>();
      await replay.close();
      expect(await replay.stream.toList(), hasLength(0));
    });

    test('add after close throws; addError after close throws', () async {
      final replay = ReplayValue<int>();
      replay.add(1);
      await replay.close();
      expect(() => replay.add(2), throwsStateError);
      expect(() => replay.addError(StateError('late')), throwsStateError);
    });

    test('close is idempotent', () async {
      final replay = ReplayValue<int>();
      await replay.close();
      await replay.close();
      expect(replay.isClosed, isTrue);
    });

    test('addError reaches current subscribers and is not replayed', () async {
      final replay = ReplayValue<int>();
      replay.add(1);
      final seen = <Object>[];
      final sub = replay.stream.listen(seen.add, onError: seen.add);
      await Future<void>.delayed(Duration.zero);
      replay.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1, isA<StateError>()]));

      final late = <Object>[];
      final lateSub = replay.stream.listen(late.add, onError: late.add);
      await Future<void>.delayed(Duration.zero);
      expect(late, equals([1]), reason: 'errors are not retained');
      await sub.cancel();
      await lateSub.cancel();
      await replay.close();
    });

    test('addError forwards a stack trace', () async {
      final replay = ReplayValue<int>();
      final seen = <StackTrace?>[];
      final sub = replay.stream.listen(
        (_) {},
        onError: (Object _, StackTrace st) => seen.add(st),
      );
      await Future<void>.delayed(Duration.zero);
      final st = StackTrace.current;
      replay.addError(StateError('traced'), st);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isNotEmpty);
      await sub.cancel();
      await replay.close();
    });

    test('a paused live subscriber buffers updates until resume', () async {
      final replay = ReplayValue<int>(size: 2);
      replay.add(1);
      final seen = <int>[];
      final sub = replay.stream.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      sub.pause();
      replay.add(2);
      replay.add(3);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1]));
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1, 2, 3]));
      await sub.cancel();
      await replay.close();
    });

    test(
      'pause/resume/cancel on a closed feed hit the null inner sub',
      () async {
        final replay = ReplayValue<int>();
        replay.add(1);
        await replay.close();
        final sub = replay.stream.listen((_) {});
        sub.pause();
        sub.resume();
        await sub.cancel();
      },
    );

    test('live chains into FxEvents operators', () async {
      final replay = ReplayValue<int>(size: 2);
      replay.add(1);
      final firstTwo = replay.live.map((v) => v * 10).stream.take(2).toList();
      replay.add(2);
      expect(await firstTwo, equals([10, 20]));
      await replay.close();
    });

    test('nullable values are retained', () async {
      final replay = ReplayValue<int?>(size: 2);
      replay.add(null);
      replay.add(1);
      final seen = <int?>[];
      final sub = replay.stream.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([null, 1]));
      await sub.cancel();
      await replay.close();
    });
  });

  group('CompletionValue', () {
    test('add is remembered and not emitted until close', () async {
      final last = CompletionValue<int>();
      expect(last.hasValue, isFalse);
      expect(() => last.value, throwsStateError);

      final seen = <int>[];
      last.stream.listen(seen.add);
      last.add(1);
      last.add(2);
      expect(last.hasValue, isTrue);
      expect(last.value, 2);
      await Future<void>.delayed(Duration.zero);
      expect(seen, hasLength(0), reason: 'nothing until close');

      await last.close();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([2]));
      expect(last.isClosed, isTrue);
      expect(last.value, 2, reason: 'readable after close');
    });

    test('subscriber after close gets the last value then done', () async {
      final last = CompletionValue<String>();
      last.add('keep');
      await last.close();
      expect(await last.stream.toList(), equals(['keep']));
    });

    test('close with no value produces just done', () async {
      final last = CompletionValue<int>();
      await last.close();
      expect(await last.stream.toList(), hasLength(0));
      expect(last.hasValue, isFalse);
      expect(() => last.value, throwsStateError);
    });

    test('add after close throws', () async {
      final last = CompletionValue<int>();
      await last.close();
      expect(() => last.add(1), throwsStateError);
      expect(() => last.addError(StateError('late')), throwsStateError);
    });

    test('close is idempotent', () async {
      final last = CompletionValue<int>();
      last.add(1);
      await last.close();
      await last.close();
      expect(last.isClosed, isTrue);
      expect(await last.stream.toList(), equals([1]));
    });

    test('addError delivers to current subscribers and closes', () async {
      final last = CompletionValue<int>();
      last.add(1);
      final seen = <Object>[];
      last.stream.listen(seen.add, onError: seen.add);
      await Future<void>.delayed(Duration.zero);
      last.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      expect(last.isClosed, isTrue);
      expect(last.hasValue, isTrue);
      expect(last.value, 1);
    });

    test('late subscriber after addError gets the error', () async {
      final last = CompletionValue<int>();
      last.add(1);
      last.addError(StateError('boom'), StackTrace.current);
      expect(last.stream.toList(), throwsStateError);
    });

    test(
      'addError with no stack trace still reaches a late listener',
      () async {
        final last = CompletionValue<int>();
        last.addError(StateError('boom'));
        expect(last.stream.toList(), throwsStateError);
      },
    );

    test('a paused open subscriber buffers the close emission', () async {
      final last = CompletionValue<int>();
      final seen = <int>[];
      final sub = last.stream.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      sub.pause();
      last.add(7);
      final closed = last.close();
      await Future<void>.delayed(Duration.zero);
      expect(seen, hasLength(0));
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([7]));
      await sub.cancel();
      await closed;
    });

    test(
      'pause/resume/cancel on a closed feed hit the null inner sub',
      () async {
        final last = CompletionValue<int>();
        last.add(1);
        await last.close();
        final sub = last.stream.listen((_) {});
        sub.pause();
        sub.resume();
        await sub.cancel();
      },
    );

    test('pause/resume/cancel after addError hit the null inner sub', () async {
      final last = CompletionValue<int>();
      last.addError(StateError('boom'));
      final sub = last.stream.listen((_) {}, onError: (_, __) {});
      sub.pause();
      sub.resume();
      await sub.cancel();
    });

    test('live chains into FxEvents operators', () async {
      final last = CompletionValue<int>();
      final out = last.live.map((v) => v * 10).toList();
      last.add(3);
      await last.close();
      expect(await out, equals([30]));
    });

    test('nullable last value is emitted on close', () async {
      final last = CompletionValue<int?>();
      last.add(null);
      expect(last.hasValue, isTrue);
      expect(last.value, equals(null));
      await last.close();
      expect(await last.stream.toList(), equals([null]));
    });

    test(
      'waiting subscriber cancelled before close does not get the value',
      () async {
        final last = CompletionValue<int>();
        final seen = <int>[];
        final sub = last.stream.listen(seen.add);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        last.add(1);
        await last.close();
        await Future<void>.delayed(Duration.zero);
        expect(seen, hasLength(0));
      },
    );
  });
}
