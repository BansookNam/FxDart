import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/memoize.spec.ts. Dart's memoize is unary-only, so
// the variadic first-argument test becomes a call-count test; the
// `resolver` and WeakMap/`cache` reassignment tests have no Dart equivalent.
void main() {
  group('memoize', () {
    test('should memoize results based on the argument given', () {
      var callCount = 0;
      final memoized = memoize<int, int>((a) {
        callCount++;
        return a + 50;
      });

      expect(memoized(10), equals(60));
      expect(callCount, equals(1));
      // Same argument: cached, not recomputed.
      expect(memoized(10), equals(60));
      expect(callCount, equals(1));
      // Different argument: recomputed.
      expect(memoized(20), equals(70));
      expect(callCount, equals(2));
    });

    test('should cache per object argument (identity/equality keyed)', () {
      var callCount = 0;
      final memoized = memoize<Map<String, String>, String>((obj) {
        callCount++;
        return '${obj['key']} world';
      });

      final obj = {'key': 'hello'};
      expect(memoized(obj), equals('hello world'));
      expect(memoized(obj), equals('hello world'));
      expect(callCount, equals(1));
    });
  });
}
