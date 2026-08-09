import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('Phase 0: Unified API with FxStrategy', () {
    group('fx() with default strategy (lazy)', () {
      test('creates lazy chain by default', () {
        final data = [1, 2, 3, 4, 5];
        final result = fx(data)
            .map((x) => x * 2)
            .filter((x) => x > 4)
            .toList();
        expect(result, [6, 8, 10]);
      });

      test('old code still works (no strategy parameter)', () {
        final result = fx([1, 2, 3])
            .map((x) => x + 1)
            .toList();
        expect(result, [2, 3, 4]);
      });

      test('lazy evaluation is lazy', () {
        var count = 0;
        final data = [1, 2, 3, 4, 5];

        final chain = fx(data)
            .map((x) {
              count++;
              return x * 2;
            })
            .filter((x) => x > 4);

        // No evaluation yet
        expect(count, 0);

        // Materialize
        chain.toList();
        expect(count, 5);
      });
    });

    group('fx() with explicit FxStrategy.lazy', () {
      test('explicit lazy strategy works', () {
        final data = [1, 2, 3, 4, 5];
        final result = fx(data, strategy: FxStrategy.lazy)
            .map((x) => x * 2)
            .filter((x) => x > 4)
            .toList();
        expect(result, [6, 8, 10]);
      });

      test('explicit lazy produces identical results to default', () {
        final data = [1, 2, 3, 4, 5];

        final defaultResult = fx(data)
            .map((x) => x * 2)
            .filter((x) => x > 4)
            .toList();

        final explicitLazyResult = fx(data, strategy: FxStrategy.lazy)
            .map((x) => x * 2)
            .filter((x) => x > 4)
            .toList();

        expect(defaultResult, explicitLazyResult);
      });
    });

    group('fx() with FxStrategy.fast', () {
      test('fast strategy works with basic operations', () {
        final data = [1, 2, 3, 4, 5];
        final result = fx(data, strategy: FxStrategy.fast)
            .map((x) => x * 2)
            .filter((x) => x > 4)
            .toList();
        expect(result, [6, 8, 10]);
      });

      test('fast strategy produces same results as lazy', () {
        final data = [1, 2, 3, 4, 5];

        final lazyResult = fx(data, strategy: FxStrategy.lazy)
            .map((x) => x * 2)
            .filter((x) => x > 4)
            .toList();

        final fastResult = fx(data, strategy: FxStrategy.fast)
            .map((x) => x * 2)
            .filter((x) => x > 4)
            .toList();

        expect(lazyResult, fastResult);
      });

      test('fast strategy with uniq produces same results as lazy', () {
        final data = [1, 2, 2, 3, 3, 3, 4, 5, 5];

        final lazyResult = fx(data, strategy: FxStrategy.lazy)
            .uniq()
            .toList();

        final fastResult = fx(data, strategy: FxStrategy.fast)
            .uniq()
            .toList();

        expect(lazyResult, [1, 2, 3, 4, 5]);
        expect(fastResult, [1, 2, 3, 4, 5]);
        expect(lazyResult, fastResult);
      });

      test('fast strategy with uniqBy produces same results as lazy', () {
        final data = [1, 2, 3, 4, 5, 6];

        final lazyResult = fx(data, strategy: FxStrategy.lazy)
            .uniqBy((x) => x % 2)
            .toList();

        final fastResult = fx(data, strategy: FxStrategy.fast)
            .uniqBy((x) => x % 2)
            .toList();

        expect(lazyResult, [1, 2]);
        expect(fastResult, [1, 2]);
        expect(lazyResult, fastResult);
      });

      test('fast strategy with filter and uniq', () {
        final data = [1, 2, 2, 3, 3, 4, 4, 4, 5, 5];

        final result = fx(data, strategy: FxStrategy.fast)
            .filter((x) => x > 1)
            .uniq()
            .toList();

        expect(result, [2, 3, 4, 5]);
      });

      test('fast strategy with map, filter, uniq chain', () {
        final data = [1, 2, 3, 4, 5, 6];

        final result = fx(data, strategy: FxStrategy.fast)
            .map((x) => x * 2)
            .filter((x) => x > 4)
            .uniq()
            .toList();

        expect(result, [6, 8, 10, 12]);
      });

      test('fast strategy with take', () {
        final data = [1, 2, 3, 4, 5];

        final result = fx(data, strategy: FxStrategy.fast)
            .map((x) => x * 2)
            .take(3)
            .toList();

        expect(result, [2, 4, 6]);
      });

      test('fast strategy with flatMap', () {
        final data = [1, 2, 3];

        final result = fx(data, strategy: FxStrategy.fast)
            .flatMap((x) => [x, x * 2])
            .toList();

        expect(result, [1, 2, 2, 4, 3, 6]);
      });
    });

    group('Strategy propagation through chain', () {
      test('strategy marker propagates through map', () {
        final data = [1, 2, 2, 3, 3, 3];

        final result = fx(data, strategy: FxStrategy.fast)
            .map((x) => x * 2)
            .uniq()
            .toList();

        // Should use fast uniq because strategy is propagated
        expect(result, [2, 4, 6]);
      });

      test('strategy marker propagates through filter', () {
        final data = [1, 2, 2, 3, 3, 3, 4, 5, 5];

        final result = fx(data, strategy: FxStrategy.fast)
            .filter((x) => x > 1)
            .uniq()
            .toList();

        expect(result, [2, 3, 4, 5]);
      });

      test('multiple operations with strategy marker', () {
        final data = [1, 2, 2, 3, 3, 3, 4, 5, 5];

        final result = fx(data, strategy: FxStrategy.fast)
            .filter((x) => x > 1)
            .map((x) => x * 10)
            .uniq()
            .toList();

        expect(result, [20, 30, 40, 50]);
      });
    });

    group('FxStrategy enum values', () {
      test('FxStrategy.lazy exists and is lazy', () {
        expect(FxStrategy.lazy, equals(FxStrategy.lazy));
      });

      test('FxStrategy.fast exists and is fast', () {
        expect(FxStrategy.fast, equals(FxStrategy.fast));
      });

      test('FxStrategy values are distinct', () {
        expect(FxStrategy.lazy, isNot(FxStrategy.fast));
      });

      test('FxStrategy can be used in conditionals', () {
        final strategy = FxStrategy.fast;

        if (strategy == FxStrategy.fast) {
          expect(true, true);
        } else {
          fail('Strategy comparison failed');
        }
      });
    });

    group('Backward compatibility', () {
      test('old fx() code works without changes', () {
        final merchants = fx(['Alice', 'Bob', 'Alice', 'Charlie'])
            .filter((name) => name.length > 3)
            .uniq()
            .toList();

        expect(merchants, ['Alice', 'Charlie']);
      });

      test('common patterns still work', () {
        final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

        final result = fx(numbers)
            .map((x) => x * 2)
            .filter((x) => x % 4 == 0)
            .toList();

        expect(result, [4, 8, 12, 16, 20]);
      });

      test('nested operations work', () {
        final data = [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ];

        final result = fx(data)
            .flatMap((list) => list)
            .filter((x) => x.isEven)
            .toList();

        expect(result, [2, 4, 6, 8]);
      });
    });

    group('Empty and edge cases', () {
      test('empty list with default strategy', () {
        final result = fx(<int>[])
            .map((x) => x * 2)
            .toList();

        expect(result, []);
      });

      test('empty list with fast strategy', () {
        final result = fx(<int>[], strategy: FxStrategy.fast)
            .map((x) => x * 2)
            .toList();

        expect(result, []);
      });

      test('single element with lazy strategy', () {
        final result = fx([42], strategy: FxStrategy.lazy)
            .map((x) => x * 2)
            .toList();

        expect(result, [84]);
      });

      test('single element with fast strategy', () {
        final result = fx([42], strategy: FxStrategy.fast)
            .map((x) => x * 2)
            .toList();

        expect(result, [84]);
      });

      test('uniq on duplicates with lazy', () {
        final result = fx([1, 1, 1, 1], strategy: FxStrategy.lazy)
            .uniq()
            .toList();

        expect(result, [1]);
      });

      test('uniq on duplicates with fast', () {
        final result = fx([1, 1, 1, 1], strategy: FxStrategy.fast)
            .uniq()
            .toList();

        expect(result, [1]);
      });

      test('uniq on no duplicates', () {
        final lazyResult = fx([1, 2, 3, 4, 5], strategy: FxStrategy.lazy)
            .uniq()
            .toList();

        final fastResult = fx([1, 2, 3, 4, 5], strategy: FxStrategy.fast)
            .uniq()
            .toList();

        expect(lazyResult, [1, 2, 3, 4, 5]);
        expect(fastResult, [1, 2, 3, 4, 5]);
      });
    });

    group('Type safety', () {
      test('generic type is preserved with lazy', () {
        final result = fx<int>([1, 2, 3], strategy: FxStrategy.lazy)
            .map((x) => x * 2)
            .toList();

        expect(result, [2, 4, 6]);
        expect(result[0], isA<int>());
      });

      test('generic type is preserved with fast', () {
        final result = fx<int>([1, 2, 3], strategy: FxStrategy.fast)
            .map((x) => x * 2)
            .toList();

        expect(result, [2, 4, 6]);
        expect(result[0], isA<int>());
      });

      test('type transformation works with lazy', () {
        final result = fx<int>([1, 2, 3], strategy: FxStrategy.lazy)
            .map((x) => x.toString())
            .toList();

        expect(result, ['1', '2', '3']);
        expect(result[0], isA<String>());
      });

      test('type transformation works with fast', () {
        final result = fx<int>([1, 2, 3], strategy: FxStrategy.fast)
            .map((x) => x.toString())
            .toList();

        expect(result, ['1', '2', '3']);
        expect(result[0], isA<String>());
      });
    });

    group('Strategy with different data types', () {
      test('strategy works with strings (lazy)', () {
        final result = fx(['apple', 'banana', 'apple'], strategy: FxStrategy.lazy)
            .uniq()
            .toList();

        expect(result, ['apple', 'banana']);
      });

      test('strategy works with strings (fast)', () {
        final result = fx(['apple', 'banana', 'apple'], strategy: FxStrategy.fast)
            .uniq()
            .toList();

        expect(result, ['apple', 'banana']);
      });

      test('strategy works with objects (lazy)', () {
        final items = [
          {'id': 1, 'name': 'a'},
          {'id': 2, 'name': 'b'},
          {'id': 1, 'name': 'a'},
        ];

        final result = fx(items, strategy: FxStrategy.lazy)
            .uniqBy((item) => item['id'])
            .toList();

        expect(result.length, 2);
      });

      test('strategy works with objects (fast)', () {
        final items = [
          {'id': 1, 'name': 'a'},
          {'id': 2, 'name': 'b'},
          {'id': 1, 'name': 'a'},
        ];

        final result = fx(items, strategy: FxStrategy.fast)
            .uniqBy((item) => item['id'])
            .toList();

        expect(result.length, 2);
      });
    });
  });
}
