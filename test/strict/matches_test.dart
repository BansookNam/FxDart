import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart'
    hide isEmpty, isNull, isNotNull, isList, isMap, matches;

// Ported from FxTS test/matches.spec.ts (RegExp / Set-specific cases omitted;
// see is_match_test.dart).
void main() {
  group('matches', () {
    group('basic matching', () {
      test('should return true when all properties match', () {
        final matcher = fxMatches({'a': 1, 'b': '2', 'c': true});
        final input = {'a': 1, 'b': '2', 'c': true, 'd': <String, int>{}};
        expect(matcher(input), isTrue);
      });

      test('should return false when any property does not match', () {
        final matcher = fxMatches({'a': 1, 'b': '2', 'c': true});
        final input = {'a': 1, 'b': '2', 'c': false};
        expect(matcher(input), isFalse);
      });

      test('should return true for empty pattern', () {
        final matcher = fxMatches(<String, Object?>{});
        expect(matcher({'a': 1}), isTrue);
      });

      test('should return false for nil input', () {
        final matcher = fxMatches(<String, Object?>{});
        expect(matcher(null), isFalse);
      });

      test('should be able to be used in the pipeline', () {
        final result = pipe(
          {'a': 1, 'b': '2', 'c': true, 'd': null},
          [
            fxMatches({'a': 1, 'b': '2'}),
          ],
        );
        expect(result, isTrue);
      });
    });

    group('find', () {
      final users = [
        {'id': 1, 'name': 'John', 'age': 30},
        {'id': 2, 'name': 'Jane', 'age': 25},
        {'id': 3, 'name': 'Bob', 'age': 30},
      ];

      test('should work with find', () {
        final result = fxFind(fxMatches({'age': 30}), users);
        expect(result, equals({'id': 1, 'name': 'John', 'age': 30}));
      });

      test('should return null when not found', () {
        final result = fxFind(fxMatches({'age': 40}), users);
        expect(result, equals(null));
      });

      test('should be able to be used in the pipeline', () {
        final result = pipe(users, [
          (Iterable<Map<String, Object>> us) =>
              fxFind(fxMatches({'name': 'Jane'}), us),
        ]);
        expect(result, equals({'id': 2, 'name': 'Jane', 'age': 25}));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final result = fx(users).find(fxMatches({'id': 3}));
        expect(result, equals({'id': 3, 'name': 'Bob', 'age': 30}));
      });
    });

    group('filter', () {
      final users = [
        {'id': 1, 'name': 'John', 'age': 30, 'active': true},
        {'id': 2, 'name': 'Jane', 'age': 25, 'active': false},
        {'id': 3, 'name': 'Bob', 'age': 30, 'active': true},
      ];

      test('should work with filter in pipeline', () {
        final result = pipe(users, [
          (Iterable<Map<String, Object>> us) =>
              fxFilter(fxMatches({'age': 30}), us),
          (Iterable<Map<String, Object>> us) =>
              fxMap((Map<String, Object> u) => u['name'], us),
          (Iterable<Object?> names) => fxToList(names),
        ]);
        expect(result, equals(['John', 'Bob']));
      });

      test('should work with filter in fx chain', () {
        final result = fx(
          users,
        ).filter(fxMatches({'active': true})).map((u) => u['id']).toList();
        expect(result, equals([1, 3]));
      });
    });

    group('some', () {
      final users = [
        {'name': 'John', 'age': 30, 'active': true},
        {'name': 'Jane', 'age': 25, 'active': false},
        {'name': 'Bob', 'age': 30, 'active': true},
      ];

      test('should return true when at least one matches', () {
        expect(fxSome(fxMatches({'age': 25}), users), isTrue);
      });

      test('should return false when none match', () {
        expect(fxSome(fxMatches({'age': 40}), users), isFalse);
      });

      test('should work in pipeline', () {
        final result = pipe(users, [
          (Iterable<Map<String, Object>> us) =>
              fxSome(fxMatches({'name': 'Bob', 'active': true}), us),
        ]);
        expect(result, isTrue);
      });
    });

    group('every', () {
      final users = [
        {'name': 'John', 'age': 30, 'active': true},
        {'name': 'Jane', 'age': 25, 'active': true},
        {'name': 'Bob', 'age': 30, 'active': true},
      ];

      test('should return true when all match', () {
        expect(fxEvery(fxMatches({'active': true}), users), isTrue);
      });

      test('should return false when not all match', () {
        expect(fxEvery(fxMatches({'age': 30}), users), isFalse);
      });

      test('should work in pipeline', () {
        final result = pipe(users, [
          (Iterable<Map<String, Object>> us) =>
              fxEvery(fxMatches({'active': true}), us),
        ]);
        expect(result, isTrue);
      });
    });

    group('deep matching', () {
      test('should match nested maps', () {
        final data = [
          {
            'id': 1,
            'user': {
              'name': 'John',
              'profile': {'age': 30},
            },
          },
          {
            'id': 2,
            'user': {
              'name': 'Jane',
              'profile': {'age': 25},
            },
          },
          {
            'id': 3,
            'user': {
              'name': 'Bob',
              'profile': {'age': 30},
            },
          },
        ];

        final result = fxToList(
          fxFilter(
            fxMatches({
              'user': {
                'profile': {'age': 30},
              },
            }),
            data,
          ),
        );

        expect(result, equals([data[0], data[2]]));
      });

      test('should match lists', () {
        final data = [
          {
            'id': 1,
            'tags': ['a', 'b'],
          },
          {
            'id': 2,
            'tags': ['c', 'd'],
          },
          {
            'id': 3,
            'tags': ['a', 'b'],
          },
        ];

        final result = fxToList(
          fxFilter(
            fxMatches({
              'tags': ['a', 'b'],
            }),
            data,
          ),
        );

        expect(result, equals([data[0], data[2]]));
      });

      test('should match nested lists with maps', () {
        final data = [
          {
            'id': 1,
            'items': [
              {'x': 1},
              {'x': 2},
            ],
          },
          {
            'id': 2,
            'items': [
              {'x': 3},
              {'x': 4},
            ],
          },
          {
            'id': 3,
            'items': [
              {'x': 1},
              {'x': 2},
            ],
          },
        ];

        final result = fxToList(
          fxFilter(
            fxMatches({
              'items': [
                {'x': 1},
                {'x': 2},
              ],
            }),
            data,
          ),
        );

        expect(result, equals([data[0], data[2]]));
      });

      test('should return false for non-matching nested maps', () {
        final matcher = fxMatches({
          'user': {'name': 'John'},
        });
        expect(
          matcher({
            'user': {'name': 'Jane'},
          }),
          isFalse,
        );
      });

      test('should return false for non-matching lists', () {
        final matcher = fxMatches({
          'tags': ['a', 'b'],
        });
        expect(
          matcher({
            'tags': ['a', 'c'],
          }),
          isFalse,
        );
        expect(
          matcher({
            'tags': ['a'],
          }),
          isFalse,
        );
      });

      test('should match DateTime objects', () {
        final date = DateTime.parse('2024-01-01');
        final data = [
          {'id': 1, 'created': DateTime.parse('2024-01-01')},
          {'id': 2, 'created': DateTime.parse('2024-02-01')},
        ];

        final result = fxFind(fxMatches({'created': date}), data);

        expect(
          result,
          equals({'id': 1, 'created': DateTime.parse('2024-01-01')}),
        );
      });
    });

    group('top-level non-map patterns', () {
      test('should compare top-level DateTime patterns by value', () {
        final matcher = fxMatches(DateTime.parse('2024-01-01'));
        expect(matcher(DateTime.parse('2024-01-01')), isTrue);
        expect(matcher(DateTime.parse('2025-01-01')), isFalse);
      });

      test('should compare top-level primitive patterns by value', () {
        expect(fxMatches(1)(1), isTrue);
        expect(fxMatches(1)(2), isFalse);
        expect(fxMatches('a')('a'), isTrue);
        expect(fxMatches('a')('b'), isFalse);
      });

      test('should compare top-level list patterns by prefix', () {
        final matcher = fxMatches([1, 2]);
        expect(matcher([1, 2, 3]), isTrue);
        expect(matcher([1, 3]), isFalse);
      });

      test('should compare top-level map patterns by value', () {
        final matcher = fxMatches({'a': 1});
        expect(matcher({'a': 1, 'b': 2}), isTrue);
        expect(matcher({'a': 2}), isFalse);
      });

      test(
        'should return false when nil pattern is matched against non-nil',
        () {
          expect(fxMatches(null)({'a': 1}), isFalse);
        },
      );
    });

    group('consistency with isMatch', () {
      test('should produce the same result as isMatch(input, pattern)', () {
        final superset = {'a': 1, 'b': 2};
        expect(
          fxMatches({'a': 1})(superset),
          equals(fxIsMatch(superset, {'a': 1})),
        );
        expect(
          fxMatches({'a': 1})({'a': 2}),
          equals(fxIsMatch({'a': 2}, {'a': 1})),
        );
        expect(
          fxMatches(DateTime.parse('2024-01-01'))(DateTime.parse('2025-01-01')),
          equals(
            fxIsMatch(
              DateTime.parse('2025-01-01'),
              DateTime.parse('2024-01-01'),
            ),
          ),
        );
      });
    });
  });
}
