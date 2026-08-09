import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('Phase 1: Extended Operators (14 essential methods)', () {
    group('Category A: Access Operators (5)', () {
      group('first', () {
        test('returns first element', () {
          expect(fx([1, 2, 3]).first, 1);
          expect(fx(['a', 'b', 'c']).first, 'a');
        });

        test('returns null when empty (lazy)', () {
          expect(fx<int>([]).first, null);
        });

        test('returns null when empty (fast)', () {
          expect(fx<int>([], strategy: FxStrategy.fast).first, null);
        });

        test('works with filter (lazy)', () {
          expect(fx([1, 2, 3, 4, 5]).filter((x) => x > 2).first, 3);
        });

        test('works with filter (fast)', () {
          expect(fx([1, 2, 3, 4, 5], strategy: FxStrategy.fast)
              .filter((x) => x > 2)
              .first, 3);
        });

        test('works with map (lazy)', () {
          expect(fx([1, 2, 3]).map((x) => x * 2).first, 2);
        });

        test('works with map (fast)', () {
          expect(fx([1, 2, 3], strategy: FxStrategy.fast)
              .map((x) => x * 2)
              .first, 2);
        });
      });

      group('last', () {
        test('returns last element', () {
          expect(fx([1, 2, 3]).last, 3);
          expect(fx(['a', 'b', 'c']).last, 'c');
        });

        test('returns null when empty', () {
          expect(fx<int>([]).last, null);
        });

        test('works with filter (lazy)', () {
          expect(fx([1, 2, 3, 4, 5]).filter((x) => x > 2).last, 5);
        });

        test('works with filter (fast)', () {
          expect(fx([1, 2, 3, 4, 5], strategy: FxStrategy.fast)
              .filter((x) => x > 2)
              .last, 5);
        });
      });

      group('length', () {
        test('counts elements', () {
          expect(fx([1, 2, 3]).length, 3);
          expect(fx([]).length, 0);
          expect(fx([1]).length, 1);
        });

        test('works with filter (lazy)', () {
          expect(fx([1, 2, 3, 4, 5]).filter((x) => x.isEven).length, 2);
        });

        test('works with filter (fast)', () {
          expect(fx([1, 2, 3, 4, 5], strategy: FxStrategy.fast)
              .filter((x) => x.isEven)
              .length, 2);
        });

        test('works with uniq (lazy)', () {
          expect(fx([1, 2, 2, 3, 3, 3]).uniq().length, 3);
        });

        test('works with uniq (fast)', () {
          expect(fx([1, 2, 2, 3, 3, 3], strategy: FxStrategy.fast)
              .uniq()
              .length, 3);
        });
      });

      group('isEmpty', () {
        test('returns true for empty', () {
          expect(fx<int>([]).isEmpty, true);
        });

        test('returns false for non-empty', () {
          expect(fx([1, 2, 3]).isEmpty, false);
        });

        test('works with filter', () {
          expect(fx([1, 2, 3]).filter((x) => x > 10).isEmpty, true);
          expect(fx([1, 2, 3]).filter((x) => x > 2).isEmpty, false);
        });
      });

      group('isNotEmpty', () {
        test('returns false for empty', () {
          expect(fx<int>([]).isNotEmpty, false);
        });

        test('returns true for non-empty', () {
          expect(fx([1, 2, 3]).isNotEmpty, true);
        });

        test('works with filter', () {
          expect(fx([1, 2, 3]).filter((x) => x > 10).isNotEmpty, false);
          expect(fx([1, 2, 3]).filter((x) => x > 2).isNotEmpty, true);
        });
      });
    });

    group('Category B: Aggregation Operators (5)', () {
      group('elementAt', () {
        test('returns element at index', () {
          expect(fx([10, 20, 30]).elementAt(0), 10);
          expect(fx([10, 20, 30]).elementAt(1), 20);
          expect(fx([10, 20, 30]).elementAt(2), 30);
        });

        test('returns null for out of bounds', () {
          expect(fx([1, 2, 3]).elementAt(-1), null);
          expect(fx([1, 2, 3]).elementAt(3), null);
          expect(fx([1, 2, 3]).elementAt(10), null);
        });

        test('works with filter', () {
          expect(fx([1, 2, 3, 4, 5]).filter((x) => x > 2).elementAt(0), 3);
          expect(fx([1, 2, 3, 4, 5]).filter((x) => x > 2).elementAt(1), 4);
        });
      });

      group('fold', () {
        test('accumulates values', () {
          expect(fx([1, 2, 3, 4, 5]).fold(0, (acc, x) => acc + x), 15);
          expect(fx([1, 2, 3, 4, 5]).fold(1, (acc, x) => acc * x), 120);
        });

        test('works with empty', () {
          expect(fx<int>([]).fold(10, (acc, x) => acc + x), 10);
        });

        test('parity with fx() lazy', () {
          final data = [1, 2, 3, 4, 5];
          final lazyResult = fx(data, strategy: FxStrategy.lazy)
              .filter((x) => x.isEven)
              .fold(0, (acc, x) => acc + x);
          final fastResult = fx(data, strategy: FxStrategy.fast)
              .filter((x) => x.isEven)
              .fold(0, (acc, x) => acc + x);
          expect(lazyResult, fastResult);
        });
      });

      group('reduce', () {
        test('reduces to single value', () {
          expect(fx([1, 2, 3, 4, 5]).reduce((acc, x) => acc + x), 15);
          expect(fx([1, 2, 3]).reduce((acc, x) => acc * x), 6);
        });

        test('throws when empty', () {
          expect(() => fx<int>([]).reduce((a, b) => a + b), throwsA(isA<StateError>()));
        });

        test('parity with fx() lazy and fast', () {
          final data = [1, 2, 3, 4, 5];
          final lazyResult = fx(data, strategy: FxStrategy.lazy)
              .filter((x) => x > 1)
              .reduce((a, b) => a + b);
          final fastResult = fx(data, strategy: FxStrategy.fast)
              .filter((x) => x > 1)
              .reduce((a, b) => a + b);
          expect(lazyResult, fastResult);
        });
      });

      group('firstWhere', () {
        test('finds first matching element', () {
          expect(fx([1, 2, 3, 4, 5]).firstWhere((x) => x > 3), 4);
          expect(fx([1, 2, 3, 4, 5]).firstWhere((x) => x.isEven), 2);
        });

        test('returns orElse when no match', () {
          final result = fx([1, 2, 3]).firstWhere(
            (x) => x > 10,
            orElse: () => -1,
          );
          expect(result, -1);
        });

        test('returns null when no orElse and no match', () {
          expect(fx([1, 2, 3]).firstWhere((x) => x > 10), null);
        });

        test('early exit optimization (only checks until match)', () {
          var count = 0;
          final data = [1, 2, 3, 4, 5];
          fx(data).firstWhere((x) {
            count++;
            return x > 2;
          });
          // Should stop at 3rd element
          expect(count, 3);
        });
      });

      group('lastWhere', () {
        test('finds last matching element', () {
          expect(fx([1, 2, 3, 4, 5]).lastWhere((x) => x > 2), 5);
          expect(fx([1, 2, 3, 4, 5]).lastWhere((x) => x.isEven), 4);
        });

        test('returns orElse when no match', () {
          final result = fx([1, 2, 3]).lastWhere(
            (x) => x > 10,
            orElse: () => -1,
          );
          expect(result, -1);
        });

        test('returns null when no orElse and no match', () {
          expect(fx([1, 2, 3]).lastWhere((x) => x > 10), null);
        });
      });
    });

    group('Category C: Numeric Aggregates (4)', () {
      group('sum', () {
        test('sums numeric elements', () {
          expect(fx<num>([1, 2, 3, 4, 5]).sum(), 15);
          expect(fx<num>([1.5, 2.5, 3.0]).sum(), 7.0);
        });

        test('returns 0 for empty', () {
          expect(fx<num>([]).sum(), 0);
        });

        test('works with filter', () {
          expect(fx<num>([1, 2, 3, 4, 5])
              .filter((x) => (x as int).isEven)
              .sum(), 6);
        });

        test('parity between lazy and fast', () {
          final data = <num>[1, 2, 3, 4, 5];
          final lazyResult = fx(data, strategy: FxStrategy.lazy).sum();
          final fastResult = fx(data, strategy: FxStrategy.fast).sum();
          expect(lazyResult, fastResult);
        });
      });

      group('average', () {
        test('calculates mean', () {
          expect(fx<num>([1, 2, 3, 4, 5]).average(), 3.0);
          expect(fx<num>([10.0, 20.0]).average(), 15.0);
        });

        test('returns NaN when empty', () {
          // Note: average() on empty iterable returns NaN (not an error)
          expect(fx<num>([]).average().isNaN, true);
        });

        test('works with filter', () {
          expect(fx<num>([1, 2, 3, 4, 5])
              .filter((x) => x > 2)
              .average(), 4.0);
        });
      });

      group('max', () {
        test('finds maximum without comparator (assumes Comparable)', () {
          expect(fx<int>([1, 5, 3, 2, 4]).max(), 5);
          expect(fx<String>(['apple', 'zebra', 'banana']).max(), 'zebra');
        });

        test('finds maximum with custom comparator', () {
          expect(
              fx<String>(['a', 'abc', 'ab']).max((a, b) => a.length.compareTo(b.length)),
              'abc');
        });

        test('works with filter', () {
          expect(fx<int>([1, 2, 3, 4, 5]).filter((x) => x < 4).max(), 3);
        });

        test('throws when empty', () {
          expect(() => fx<int>([]).max(), throwsA(isA<StateError>()));
        });
      });

      group('min', () {
        test('finds minimum without comparator', () {
          expect(fx<int>([5, 1, 3, 2, 4]).min(), 1);
          expect(fx<String>(['zebra', 'apple', 'banana']).min(), 'apple');
        });

        test('finds minimum with custom comparator', () {
          expect(
              fx<String>(['a', 'abc', 'ab']).min((a, b) => a.length.compareTo(b.length)),
              'a');
        });

        test('works with filter', () {
          expect(fx<int>([1, 2, 3, 4, 5]).filter((x) => x > 2).min(), 3);
        });

        test('throws when empty', () {
          expect(() => fx<int>([]).min(), throwsA(isA<StateError>()));
        });
      });
    });

    group('Category D: Predicates & String (3)', () {
      group('any', () {
        test('returns true if any match', () {
          expect(fx([1, 2, 3, 4, 5]).any((x) => x > 4), true);
          expect(fx([1, 2, 3, 4, 5]).any((x) => x.isEven), true);
        });

        test('returns false if none match', () {
          expect(fx([1, 2, 3, 4, 5]).any((x) => x > 10), false);
          expect(fx([1, 3, 5]).any((x) => x.isEven), false);
        });

        test('returns false for empty', () {
          expect(fx<int>([]).any((x) => true), false);
        });

        test('early exit optimization', () {
          var count = 0;
          fx([1, 2, 3, 4, 5]).any((x) {
            count++;
            return x > 2;
          });
          // Should stop after finding match
          expect(count, 3);
        });

        test('parity between lazy and fast', () {
          final data = [1, 2, 3, 4, 5];
          final lazyResult = fx(data, strategy: FxStrategy.lazy)
              .filter((x) => x > 2)
              .any((x) => x.isEven);
          final fastResult = fx(data, strategy: FxStrategy.fast)
              .filter((x) => x > 2)
              .any((x) => x.isEven);
          expect(lazyResult, fastResult);
        });
      });

      group('all', () {
        test('returns true if all match', () {
          expect(fx([2, 4, 6, 8]).all((x) => x.isEven), true);
          expect(fx([1, 2, 3, 4, 5]).all((x) => x > 0), true);
        });

        test('returns false if any don\'t match', () {
          expect(fx([1, 2, 3, 4, 5]).all((x) => x.isEven), false);
          expect(fx([1, 2, 3, 4, 5]).all((x) => x > 3), false);
        });

        test('returns true for empty', () {
          expect(fx<int>([]).all((x) => false), true);
        });

        test('early exit optimization', () {
          var count = 0;
          fx([1, 2, 3, 4, 5]).all((x) {
            count++;
            return x < 3;
          });
          // Should stop after finding first non-match
          expect(count, 3);
        });

        test('parity between lazy and fast', () {
          final data = [2, 4, 6, 8, 10];
          final lazyResult = fx(data, strategy: FxStrategy.lazy)
              .filter((x) => x > 0)
              .all((x) => x.isEven);
          final fastResult = fx(data, strategy: FxStrategy.fast)
              .filter((x) => x > 0)
              .all((x) => x.isEven);
          expect(lazyResult, fastResult);
        });
      });

      group('join', () {
        test('joins elements with separator', () {
          expect(fx(['a', 'b', 'c']).join('-'), 'a-b-c');
          expect(fx(['hello', 'world']).join(' '), 'hello world');
        });

        test('works with map', () {
          expect(fx([1, 2, 3]).map((x) => x.toString()).join(','), '1,2,3');
        });

        test('works with filter', () {
          expect(
              fx(['apple', 'a', 'banana']).filter((x) => x.length > 1).join(', '),
              'apple, banana');
        });

        test('joins empty list', () {
          expect(fx<String>([]).join('-'), '');
        });

        test('parity between lazy and fast', () {
          final data = [1, 2, 3, 4, 5];
          final lazyResult = fx(data, strategy: FxStrategy.lazy)
              .map((x) => x.toString())
              .join('-');
          final fastResult = fx(data, strategy: FxStrategy.fast)
              .map((x) => x.toString())
              .join('-');
          expect(lazyResult, fastResult);
        });
      });
    });

    group('Strategy propagation and integration', () {
      test('all operators work in fast strategy chain', () {
        final data = [1, 2, 3, 4, 5];
        final result = fx(data, strategy: FxStrategy.fast)
            .filter((x) => x > 1)
            .map((x) => x * 2)
            .toList();
        expect(result, [4, 6, 8, 10]);
      });

      test('access operators work after transformations', () {
        final result = fx([1, 2, 3, 4, 5], strategy: FxStrategy.fast)
            .filter((x) => x.isEven)
            .length;
        expect(result, 2);
      });

      test('aggregation operators work with uniq', () {
        final result = fx([1, 2, 2, 3, 3, 3], strategy: FxStrategy.fast)
            .uniq()
            .fold(0, (acc, x) => acc + x);
        expect(result, 6);
      });

      test('all operators preserve strategy through chain', () {
        final data = [1, 2, 3, 4, 5];

        // Multiple operations should all use fast path
        final fastChain = fx(data, strategy: FxStrategy.fast)
            .filter((x) => x > 1)
            .map((x) => x * 2)
            .uniq();

        expect(fastChain.length, 4); // [4, 6, 8, 10]
        expect(fastChain.first, 4);
        expect(fastChain.last, 10);
      });
    });

    group('Backward compatibility', () {
      test('all new operators work with default (lazy) strategy', () {
        final data = [1, 2, 3, 4, 5];

        expect(fx(data).first, 1);
        expect(fx(data).last, 5);
        expect(fx(data).length, 5);
        expect(fx(data).isEmpty, false);
        expect(fx(data).isNotEmpty, true);
      });

      test('numeric operators work on default strategy', () {
        expect(fx<num>([1, 2, 3, 4, 5]).sum(), 15);
        expect(fx<num>([2.0, 4.0]).average(), 3.0);
      });

      test('predicate operators work on default strategy', () {
        expect(fx([1, 2, 3, 4, 5]).any((x) => x > 4), true);
        expect(fx([2, 4, 6]).all((x) => x.isEven), true);
        expect(fx(['a', 'b', 'c']).join('-'), 'a-b-c');
      });
    });
  });
}
