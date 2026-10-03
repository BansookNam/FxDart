import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/isMatch.spec.ts.
// JS-specific cases are omitted: NaN sameValueZero equality (Dart `==` is
// used), RegExp structural equality (Dart RegExp has no value equality) and
// JS Set semantics (a Dart Set is an Iterable, matched pairwise).
void main() {
  group('isMatch', () {
    group('primitives', () {
      test('should return true for equal primitives', () {
        expect(fxIsMatch(1, 1), isTrue);
        expect(fxIsMatch('hello', 'hello'), isTrue);
        expect(fxIsMatch(true, true), isTrue);
      });

      test('should return false for different primitives', () {
        expect(fxIsMatch(1, 2), isFalse);
        expect(fxIsMatch('hello', 'world'), isFalse);
      });
    });

    group('partial object matching', () {
      test('should return true when map contains all source properties', () {
        expect(fxIsMatch({'a': 1, 'b': 2}, {'a': 1}), isTrue);
        expect(fxIsMatch({'a': 1, 'b': 2, 'c': 3}, {'a': 1, 'c': 3}), isTrue);
      });

      test('should return false when map is missing source properties', () {
        expect(fxIsMatch({'a': 1}, {'a': 1, 'b': 2}), isFalse);
      });

      test('should return false when property values differ', () {
        expect(fxIsMatch({'a': 1}, {'a': 2}), isFalse);
      });

      test('should match nested maps partially', () {
        final object = {
          'user': {'name': 'John', 'age': 30},
        };
        expect(
          fxIsMatch(object, {
            'user': {'name': 'John'},
          }),
          isTrue,
        );
      });

      test('should match deeply nested maps', () {
        final object = {
          'a': {
            'b': {'c': true},
          },
        };
        expect(
          fxIsMatch(object, {
            'a': {
              'b': {'c': true},
            },
          }),
          isTrue,
        );
        expect(
          fxIsMatch(object, {
            'a': {
              'b': {'c': false},
            },
          }),
          isFalse,
        );
      });
    });

    group('list matching', () {
      test('should compare lists by index for matching positions', () {
        expect(fxIsMatch([1, 2, 3], [1, 2, 3]), isTrue);
        expect(fxIsMatch([1, 2, 3], [1, 2, 4]), isFalse);
      });

      test('should partially match when source is a prefix of target', () {
        expect(fxIsMatch([1, 2, 3], [1, 2]), isTrue);
        expect(fxIsMatch([1, 2, 3], [1]), isTrue);
        expect(fxIsMatch([1, 2, 3], <int>[]), isTrue);
      });

      test('should return false when source is longer than target', () {
        expect(fxIsMatch([1, 2], [1, 2, 3]), isFalse);
      });

      test('should return false when prefix values differ', () {
        expect(fxIsMatch([1, 2, 3], [2, 3]), isFalse);
      });

      test('should match lists with maps partially (per-element)', () {
        expect(
          fxIsMatch(
            [
              {'a': 1},
            ],
            [
              {'a': 1},
            ],
          ),
          isTrue,
        );
        expect(
          fxIsMatch(
            [
              {'a': 1, 'b': 2},
            ],
            [
              {'a': 1},
            ],
          ),
          isTrue,
        );
      });

      test('should match lists with maps partially (prefix)', () {
        expect(
          fxIsMatch(
            [
              {'a': 1, 'b': 2},
              {'c': 3},
            ],
            [
              {'a': 1},
            ],
          ),
          isTrue,
        );
      });
    });

    group('DateTime matching', () {
      test('should match equal DateTime objects', () {
        expect(
          fxIsMatch(DateTime.parse('2024-01-01'), DateTime.parse('2024-01-01')),
          isTrue,
        );
      });

      test('should return false for different DateTime objects', () {
        expect(
          fxIsMatch(DateTime.parse('2024-01-01'), DateTime.parse('2024-02-01')),
          isFalse,
        );
      });

      test('should return false when comparing DateTime with non-DateTime', () {
        expect(
          fxIsMatch(DateTime.parse('2024-01-01'), <String, int>{}),
          isFalse,
        );
        expect(
          fxIsMatch(<String, int>{}, DateTime.parse('2024-01-01')),
          isFalse,
        );
      });
    });

    group('Map matching', () {
      test('should match equal maps', () {
        expect(fxIsMatch({'a': 1}, {'a': 1}), isTrue);
      });

      test('should partially match maps', () {
        expect(fxIsMatch({'a': 1, 'b': 2}, {'a': 1}), isTrue);
      });

      test('should return false for non-matching map values', () {
        expect(fxIsMatch({'a': 1, 'b': 2}, {'a': 1, 'b': 3}), isFalse);
      });

      test('should return false when source map has keys not in target', () {
        expect(fxIsMatch({'a': 1}, {'a': 1, 'b': 2}), isFalse);
      });
    });

    group('cross-type matching', () {
      test('should return false when comparing incompatible types', () {
        expect(
          fxIsMatch(DateTime.parse('2024-01-01'), <String, int>{}),
          isFalse,
        );
        expect(fxIsMatch(<String, int>{}, [1]), isFalse);
        expect(fxIsMatch([1], <String, int>{}), isFalse);
      });
    });

    group('null', () {
      test('should return false when target is null', () {
        expect(fxIsMatch(null, {'a': 1}), isFalse);
      });

      test('should return false when source is null', () {
        expect(fxIsMatch({'a': 1}, null), isFalse);
      });
    });

    group('empty pattern', () {
      test('should return true for empty source map', () {
        expect(fxIsMatch({'a': 1}, <String, int>{}), isTrue);
      });
    });
  });
}
