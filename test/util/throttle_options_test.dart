import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

Future<void> wait(int ms) => Future.delayed(Duration(milliseconds: ms));

void main() {
  group('throttle options', () {
    test('should never invoke with leading and trailing both disabled',
        () async {
      var callCount = 0;
      final throttled = throttle<Object?>(
          (_) => callCount++, const Duration(milliseconds: 60),
          leading: false, trailing: false);

      throttled(null);
      expect(callCount, equals(0));

      throttled(null);
      throttled(null);
      await wait(120);
      expect(callCount, equals(0));
    });

    test('should stay disabled across successive wait periods', () async {
      var callCount = 0;
      final throttled = throttle<Object?>(
          (_) => callCount++, const Duration(milliseconds: 40),
          leading: false, trailing: false);

      throttled(null);
      await wait(80);
      throttled(null);
      await wait(80);
      expect(callCount, equals(0));
    });

    test('should throttle rather than debounce with leading disabled',
        () async {
      final received = <int>[];
      final throttled = throttle<int>(
          received.add, const Duration(milliseconds: 100),
          leading: false, trailing: true);

      // Keep calling inside every window. A debounce would reset the deadline
      // on each call and emit nothing until the calls stop.
      for (var i = 0; i < 5; i++) {
        throttled(i);
        await wait(40);
      }
      expect(received, isNotEmpty,
          reason: 'trailing edge must fire while calls are still arriving');
      expect(received.length, lessThanOrEqualTo(3),
          reason: 'at most one invocation per 100ms window over ~200ms');
    });

    test('should fire the trailing edge once per window, not once per call',
        () async {
      var callCount = 0;
      final throttled = throttle<Object?>(
          (_) => callCount++, const Duration(milliseconds: 100),
          leading: false, trailing: true);

      // Five calls bunched inside a single window.
      for (var i = 0; i < 5; i++) {
        throttled(null);
      }
      await wait(200);
      expect(callCount, equals(1));
    });

    test('should not extend the deadline when called mid-window', () async {
      final received = <int>[];
      final throttled = throttle<int>(
          received.add, const Duration(milliseconds: 100),
          leading: true, trailing: true);

      throttled(1); // t=0, leading
      expect(received, equals([1]));

      await wait(50);
      throttled(2); // t=50, mid-window — trailing stays due at t=100
      await wait(70); // t=120
      expect(received, equals([1, 2]));
    });

    test('cancel should be a no-op when nothing is pending', () {
      var callCount = 0;
      final throttled = throttle<Object?>(
          (_) => callCount++, const Duration(milliseconds: 40),
          leading: false, trailing: false);

      throttled(null);
      throttled.cancel();
      expect(callCount, equals(0));
    });
  });
}
