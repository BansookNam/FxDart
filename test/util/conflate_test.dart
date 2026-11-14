import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('fxConflate', () {
    test('one run at a time; only the newest held value runs next', () async {
      final started = <int>[];
      final gates = <Completer<void>>[];
      final c = fxConflate<int>((v) {
        started.add(v);
        final g = Completer<void>();
        gates.add(g);
        return g.future;
      });

      c(1);
      expect(c.isRunning, isTrue);
      c(2);
      c(3);
      c(4);
      expect(c.isPending, isTrue);
      expect(started, [1]);

      gates[0].complete();
      await pumpEventQueue();
      expect(started, [1, 4]);
      expect(c.isPending, isFalse);

      gates[1].complete();
      await c.idle;
      expect(c.isRunning, isFalse);
      expect(started, [1, 4]);
    });

    test('idle completes at once when nothing runs', () async {
      final c = fxConflate<int>((_) async {});
      await c.idle;
      c(1);
      await c.idle;
      expect(c.isRunning, isFalse);
    });

    test('cancel drops the held value but not the run in flight', () async {
      final started = <int>[];
      final gate = Completer<void>();
      final c = fxConflate<int>((v) {
        started.add(v);
        return v == 1 ? gate.future : Future.value();
      });
      c(1);
      c(2);
      c.cancel();
      expect(c.isPending, isFalse);
      gate.complete();
      await c.idle;
      expect(started, [1]);
    });

    test('an error goes to onError and later runs continue', () async {
      final errors = <Object>[];
      final ran = <int>[];
      final gate = Completer<void>();
      final c = fxConflate<int>((v) async {
        ran.add(v);
        if (v == 1) {
          await gate.future;
          throw StateError('boom');
        }
      }, onError: (e, _) => errors.add(e));
      c(1);
      c(2);
      gate.complete();
      await pumpEventQueue();
      await c.idle;
      expect(ran, [1, 2]);
      expect(errors.single, isA<StateError>());
    });

    test('without onError the error reaches the zone', () async {
      final errors = <Object>[];
      await runZonedGuarded(() async {
        final c = fxConflate<int>((_) => throw StateError('sync throw'));
        c(1);
        await c.idle;
      }, (e, _) => errors.add(e));
      await pumpEventQueue();
      expect(errors.single, isA<StateError>());
    });
  });
}
