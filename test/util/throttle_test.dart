import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/Util/throttle.spec.ts, using real timers with
// generous bounds instead of jest fake timers.
Future<void> wait(int ms) => Future.delayed(Duration(milliseconds: ms));

void main() {
  group('throttle', () {
    group('basic throttle behavior', () {
      test('should throttle function calls within wait period', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60));

        throttled(null);
        expect(callCount, equals(1)); // Leading edge

        throttled(null);
        throttled(null);
        throttled(null);
        expect(callCount, equals(1)); // Still only 1 call

        await wait(120);
        expect(callCount, equals(2)); // Trailing edge
      });

      test('should allow call after throttle period expires', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60));

        throttled(null);
        expect(callCount, equals(1));

        await wait(120);
        expect(callCount, equals(1)); // No trailing call (single invocation)

        throttled(null);
        expect(callCount, equals(2));
      });

      test(
          'should not reset timer on subsequent calls (key difference from debounce)',
          () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60));

        throttled(null);
        expect(callCount, equals(1));

        await wait(25);
        throttled(null); // This should NOT reset the timer

        await wait(75); // Total: 100ms from first call, > 60ms wait
        expect(callCount, equals(2)); // Trailing edge fires
      });

      test('should handle multiple consecutive throttle periods', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60));

        // First period
        throttled(null);
        expect(callCount, equals(1));

        await wait(120);

        // Second period
        throttled(null);
        expect(callCount, equals(2));

        await wait(120);

        // Third period
        throttled(null);
        expect(callCount, equals(3));
      });
    });

    group('leading edge', () {
      test('should call immediately when leading is true (default)', () {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60));

        throttled(null);
        expect(callCount, equals(1));

        throttled.cancel();
      });

      test('should not call immediately when leading is false', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60),
            leading: false, trailing: true);

        throttled(null);
        expect(callCount, equals(0));

        await wait(120);
        expect(callCount, equals(1));
      });

      test('should handle leading only option', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60),
            leading: true, trailing: false);

        throttled(null);
        expect(callCount, equals(1));

        throttled(null);
        throttled(null);

        await wait(120);
        expect(callCount, equals(1)); // No trailing call
      });
    });

    group('trailing edge', () {
      test('should call at end of period when trailing is true (default)',
          () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60));

        throttled(null);
        throttled(null);
        throttled(null);

        await wait(120);
        expect(callCount, equals(2)); // Leading + trailing
      });

      test('should not call at end when trailing is false', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60),
            leading: true, trailing: false);

        throttled(null);
        throttled(null);

        await wait(120);
        expect(callCount, equals(1)); // Only leading
      });

      test('should use latest arguments for trailing call', () async {
        final received = <int>[];
        final throttled =
            throttle<int>(received.add, const Duration(milliseconds: 60));

        throttled(1);
        throttled(2);
        throttled(3);

        expect(received, equals([1])); // Leading call

        await wait(120);
        expect(received, equals([1, 3])); // Trailing call with latest args
      });

      test('should handle trailing only option', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60),
            leading: false, trailing: true);

        throttled(null);
        expect(callCount, equals(0));

        throttled(null);
        throttled(null);

        await wait(120);
        expect(callCount, equals(1)); // Only trailing
      });
    });

    group('leading and trailing combined', () {
      test('should call on both edges when both true', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60),
            leading: true, trailing: true);

        throttled(null);
        expect(callCount, equals(1)); // Leading

        throttled(null);
        throttled(null);

        await wait(120);
        expect(callCount, equals(2)); // Trailing
      });

      test('should not call twice if only one call made', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60),
            leading: true, trailing: true);

        throttled(null);
        expect(callCount, equals(1));

        await wait(120);
        expect(callCount, equals(1)); // Still only 1 (no duplicate)
      });

      test('should execute leading then trailing with different args',
          () async {
        final received = <int>[];
        final throttled = throttle<int>(
            received.add, const Duration(milliseconds: 60),
            leading: true, trailing: true);

        throttled(1);
        expect(received, equals([1]));

        throttled(2);
        throttled(3);

        await wait(120);
        expect(received, equals([1, 3]));
      });
    });

    group('cancel', () {
      test('should cancel pending trailing execution', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60));

        throttled(null);
        throttled(null);

        throttled.cancel();

        await wait(120);
        expect(callCount, equals(1)); // Only the leading call
      });

      test('should allow fresh start after cancel', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60));

        throttled(null);
        expect(callCount, equals(1));

        throttled(null);
        throttled.cancel();

        // Should be able to call immediately after cancel
        throttled(null);
        expect(callCount, equals(2));

        throttled.cancel();
      });
    });

    group('edge cases', () {
      test('should handle rapid successive calls', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60));

        for (var i = 0; i < 10; i++) {
          throttled(null);
        }

        expect(callCount, equals(1)); // Leading only

        await wait(120);
        expect(callCount, equals(2)); // Leading + trailing
      });

      test('should handle wait time of 0', () async {
        var callCount = 0;
        final throttled = throttle<Object?>((_) => callCount++, Duration.zero);

        throttled(null);
        expect(callCount, equals(1));

        throttled(null);

        await wait(20);
        expect(callCount, equals(2));
      });

      test('should handle calls during and after throttle period', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60));

        throttled(null); // t=0, leading call
        expect(callCount, equals(1));

        await wait(25);
        throttled(null); // t=25, within period

        await wait(75); // t=100, trailing has fired at t=60
        expect(callCount, equals(2));

        await wait(50); // well past the period
        throttled(null); // After period, should call immediately
        expect(callCount, equals(3));
      });

      test('should work with no options provided', () async {
        var callCount = 0;
        final throttled = throttle<Object?>(
            (_) => callCount++, const Duration(milliseconds: 60));

        throttled(null);
        expect(callCount, equals(1));

        throttled(null);

        await wait(120);
        expect(callCount, equals(2));
      });
    });
  });
}
