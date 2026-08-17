import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

bool isEven(int n) => n % 2 == 0;
bool isPositive(int n) => n > 0;

void main() {
  group('predicate combinators', () {
    test('negate flips the predicate', () {
      final isOdd = isEven.negate;
      expect(isOdd(3), isTrue);
      expect(isOdd(4), isFalse);
    });

    test('negate getter matches the top-level negate', () {
      final viaGetter = isEven.negate;
      final viaFunction = negate(isEven);
      for (final n in [-2, -1, 0, 1, 2]) {
        expect(viaGetter(n), equals(viaFunction(n)));
      }
    });

    test('and requires both', () {
      final f = isEven.and(isPositive);
      expect(f(4), isTrue);
      expect(f(3), isFalse);
      expect(f(-4), isFalse);
    });

    test('or requires either', () {
      final f = isEven.or(isPositive);
      expect(f(-4), isTrue);
      expect(f(3), isTrue);
      expect(f(-3), isFalse);
    });

    test('xor requires exactly one', () {
      final f = isEven.xor(isPositive);
      expect(f(-4), isTrue);
      expect(f(3), isTrue);
      expect(f(4), isFalse);
      expect(f(-3), isFalse);
    });

    test('and short-circuits when the left side fails', () {
      var calls = 0;
      bool counted(int n) {
        calls++;
        return true;
      }

      final f = isEven.and(counted);
      expect(f(3), isFalse);
      expect(calls, equals(0));
      expect(f(4), isTrue);
      expect(calls, equals(1));
    });

    test('or short-circuits when the left side succeeds', () {
      var calls = 0;
      bool counted(int n) {
        calls++;
        return false;
      }

      final f = isEven.or(counted);
      expect(f(4), isTrue);
      expect(calls, equals(0));
      expect(f(3), isFalse);
      expect(calls, equals(1));
    });

    test('xor calls both sides', () {
      var calls = 0;
      bool counted(int n) {
        calls++;
        return false;
      }

      expect(isEven.xor(counted)(4), isTrue);
      expect(calls, equals(1));
    });

    test('contramap moves a predicate onto another type', () {
      final hasEvenLength = isEven.contramap<String>((s) => s.length);
      expect(hasEvenLength('abcd'), isTrue);
      expect(hasEvenLength('abc'), isFalse);
    });

    test('combinators are lazy — nothing runs until the result is called', () {
      var calls = 0;
      bool counted(int n) {
        calls++;
        return true;
      }

      counted.and(counted).or(counted).xor(counted).negate;
      expect(calls, equals(0));
    });

    test('composes in an fx chain', () {
      final res = fx([
        -4,
        -3,
        -2,
        1,
        2,
        3,
        4,
      ]).filter(isEven.and(isPositive)).toList();
      expect(res, equals([2, 4]));
    });

    test('composes in reject / takeWhile / dropWhile', () {
      expect(
        fx([1, 2, 3, 4]).reject(isEven.or(isPositive)).toList(),
        equals(<int>[]),
      );
      expect(
        fx([2, 4, 5, 6]).takeWhile(isEven.and(isPositive)).toList(),
        equals([2, 4]),
      );
      expect(
        fx([2, 4, 5, 6]).dropWhile(isEven.and(isPositive)).toList(),
        equals([5, 6]),
      );
    });

    test('works with the top-level operators', () {
      final res = toList(
        filter(isEven.contramap<String>((s) => s.length), [
          'a',
          'ab',
          'abc',
          'abcd',
        ]),
      );
      expect(res, equals(['ab', 'abcd']));
    });
  });
}
