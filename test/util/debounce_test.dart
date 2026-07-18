import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/Util/debounce.spec.ts, using real timers with
// generous bounds instead of jest fake timers.
Future<void> wait(int ms) => Future.delayed(Duration(milliseconds: ms));

void main() {
  group('debounce', () {
    test('should delay the function call', () async {
      var callCount = 0;
      final debounced = debounce<Object?>(
          (_) => callCount++, const Duration(milliseconds: 60));

      debounced(null);
      expect(callCount, equals(0));

      await wait(20);
      expect(callCount, equals(0));

      await wait(100);
      expect(callCount, equals(1));
    });

    test('should reset delay if called again before wait time', () async {
      var callCount = 0;
      final debounced = debounce<Object?>(
          (_) => callCount++, const Duration(milliseconds: 60));

      debounced(null);
      await wait(30);
      debounced(null);
      await wait(30);
      // Second call reset the timer, so nothing has fired yet.
      expect(callCount, equals(0));

      await wait(80);
      expect(callCount, equals(1));
    });

    test('should call immediately if leading is true', () async {
      var callCount = 0;
      final debounced = debounce<Object?>(
          (_) => callCount++, const Duration(milliseconds: 60),
          leading: true);

      debounced(null);
      expect(callCount, equals(1));

      debounced(null);
      debounced(null);
      expect(callCount, equals(1));

      await wait(120);

      debounced(null);
      expect(callCount, equals(2));
    });

    test('should use latest arguments', () async {
      final received = <int>[];
      final debounced =
          debounce<int>(received.add, const Duration(milliseconds: 60));

      debounced(1);
      debounced(2);
      debounced(3);

      await wait(120);
      expect(received, equals([3]));
    });

    test('should cancel the delayed execution', () async {
      var callCount = 0;
      final debounced = debounce<Object?>(
          (_) => callCount++, const Duration(milliseconds: 60));

      debounced(null);
      debounced.cancel();

      await wait(120);
      expect(callCount, equals(0));
    });
  });
}
