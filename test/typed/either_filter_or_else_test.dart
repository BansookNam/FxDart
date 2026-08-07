import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('Either.filterOrElse', () {
    test('keeps a Right whose value passes', () {
      final res =
          Right<String, int>(4).filterOrElse((n) => n.isEven, (n) => 'odd: $n');
      expect(res, equals(Right<String, int>(4)));
    });

    test('demotes a Right whose value fails', () {
      final res =
          Right<String, int>(3).filterOrElse((n) => n.isEven, (n) => 'odd: $n');
      expect(res, equals(Left<String, int>('odd: 3')));
    });

    test('passes a Left through untouched', () {
      var predicateCalls = 0;
      var onFalseCalls = 0;
      final res = Left<String, int>('boom').filterOrElse((n) {
        predicateCalls++;
        return false;
      }, (n) {
        onFalseCalls++;
        return 'unused';
      });
      expect(res, equals(Left<String, int>('boom')));
      expect(predicateCalls, equals(0));
      expect(onFalseCalls, equals(0));
    });

    test('onFalse is not called when the predicate holds', () {
      var calls = 0;
      Right<String, int>(4).filterOrElse((n) => n.isEven, (n) {
        calls++;
        return 'unused';
      });
      expect(calls, equals(0));
    });

    test('onFalse sees the value that failed', () {
      final res = Right<String, int>(200)
          .filterOrElse((n) => n < 150, (n) => 'age $n is implausible');
      expect(res, equals(Left<String, int>('age 200 is implausible')));
    });

    test('chains, stopping at the first failing check', () {
      Either<String, int> validate(int n) => Right<String, int>(n)
          .filterOrElse((v) => v >= 0, (v) => 'age cannot be $v')
          .filterOrElse((v) => v < 150, (v) => 'age $v is implausible');

      expect(validate(30), equals(Right<String, int>(30)));
      expect(validate(-1), equals(Left<String, int>('age cannot be -1')));
      expect(validate(200), equals(Left<String, int>('age 200 is implausible')));
    });

    test('composes with the predicate combinators', () {
      bool isEven(int n) => n % 2 == 0;
      bool isPositive(int n) => n > 0;

      final res = Right<String, int>(-4)
          .filterOrElse(isEven.and(isPositive), (n) => 'rejected: $n');
      expect(res, equals(Left<String, int>('rejected: -4')));
    });

    test('agrees with Raise.ensure inside an either builder', () {
      Either<String, int> viaFilter(int n) =>
          Right<String, int>(n).filterOrElse((v) => v > 0, (v) => 'not positive');
      Either<String, int> viaEnsure(int n) => either((r) {
            r.ensure(n > 0, () => 'not positive');
            return n;
          });

      expect(viaFilter(5), equals(viaEnsure(5)));
      expect(viaFilter(-5), equals(viaEnsure(-5)));
    });
  });
}
