import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

Either<String, int> ok(int n) => Right(n);
Either<String, int> err(String e) => Left(e);

void main() {
  group('Either.map2', () {
    test('combines two successes', () {
      expect(ok(1).map2(ok(2), (a, b) => a + b), equals(Right<String, int>(3)));
    });

    test('keeps the first failure', () {
      expect(err('a').map2(ok(2), (a, b) => a + b),
          equals(Left<String, int>('a')));
      expect(ok(1).map2(err('b'), (a, b) => a + b),
          equals(Left<String, int>('b')));
    });

    test('the leftmost failure wins', () {
      expect(err('a').map2(err('b'), (a, b) => a + b),
          equals(Left<String, int>('a')));
    });

    test('combine does not run when a branch failed', () {
      var calls = 0;
      err('a').map2(ok(2), (a, b) {
        calls++;
        return a + b;
      });
      expect(calls, equals(0));
    });

    test('can change the success type', () {
      final res = ok(1).map2(Right<String, String>('x'), (a, b) => '$b$a');
      expect(res, equals(Right<String, String>('x1')));
    });
  });

  group('Either.map3', () {
    test('combines three successes', () {
      expect(ok(1).map3(ok(2), ok(3), (a, b, c) => a + b + c),
          equals(Right<String, int>(6)));
    });

    test('keeps the first failure in position order', () {
      expect(err('a').map3(err('b'), err('c'), (a, b, c) => a + b + c),
          equals(Left<String, int>('a')));
      expect(ok(1).map3(err('b'), err('c'), (a, b, c) => a + b + c),
          equals(Left<String, int>('b')));
      expect(ok(1).map3(ok(2), err('c'), (a, b, c) => a + b + c),
          equals(Left<String, int>('c')));
    });
  });

  group('Either.map4', () {
    test('combines four successes', () {
      expect(ok(1).map4(ok(2), ok(3), ok(4), (a, b, c, d) => a + b + c + d),
          equals(Right<String, int>(10)));
    });

    test('keeps the first failure in position order', () {
      expect(ok(1).map4(ok(2), err('c'), err('d'), (a, b, c, d) => a + b + c + d),
          equals(Left<String, int>('c')));
      expect(ok(1).map4(ok(2), ok(3), err('d'), (a, b, c, d) => a + b + c + d),
          equals(Left<String, int>('d')));
    });
  });

  group('Either.map5', () {
    test('combines five successes', () {
      final res = ok(1).map5(
          ok(2), ok(3), ok(4), ok(5), (a, b, c, d, e) => a + b + c + d + e);
      expect(res, equals(Right<String, int>(15)));
    });

    test('keeps the first failure in position order', () {
      expect(
          ok(1).map5(ok(2), ok(3), err('d'), err('e'),
              (a, b, c, d, e) => a + b + c + d + e),
          equals(Left<String, int>('d')));
      expect(
          ok(1).map5(ok(2), ok(3), ok(4), err('e'),
              (a, b, c, d, e) => a + b + c + d + e),
          equals(Left<String, int>('e')));
    });

    test('combine does not run when a branch failed', () {
      var calls = 0;
      ok(1).map5(ok(2), ok(3), ok(4), err('e'), (a, b, c, d, e) {
        calls++;
        return 0;
      });
      expect(calls, equals(0));
    });
  });

  group('type inference', () {
    // A nested-flatMap implementation of the higher arities erased `L` to
    // `dynamic` in the intermediate closures and blew up at runtime; the
    // arities are written as flat `is Left` checks for that reason.
    test('the higher arities survive inferred type arguments', () {
      expect(
          Right<String, int>(1)
              .map4(Right(2), Right(3), Right(4), (a, b, c, d) => a + b + c + d),
          equals(Right<String, int>(10)));
      expect(
          Right<String, int>(1).map5(Right(2), Right(3), Right(4), Right(5),
              (a, b, c, d, e) => a + b + c + d + e),
          equals(Right<String, int>(15)));
    });
  });

  group('fail-fast vs accumulate', () {
    test('map2 reports one error where zipOrAccumulate2 reports both', () {
      final failFast = err('name').map2(err('age'), (a, b) => a + b);
      expect(failFast, equals(Left<String, int>('name')));

      final accumulated = either<Nel<String>, int>((r) =>
          r.zipOrAccumulate2<int, int, int>((r) => r.raise('name'),
              (r) => r.raise('age'), (a, b) => a + b));
      expect(accumulated.leftOrNull()?.toList(), equals(['name', 'age']));
    });
  });
}
