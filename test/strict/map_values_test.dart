import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('mapValues', () {
    test('runs every value through the callback', () {
      expect(
        mapValues((int n) => n * 2, {'a': 1, 'b': 2}),
        equals({'a': 2, 'b': 4}),
      );
    });

    test('can change the value type', () {
      expect(
        mapValues((int n) => 'v$n', {'a': 1, 'b': 2}),
        equals({'a': 'v1', 'b': 'v2'}),
      );
    });

    test('leaves the keys alone and keeps insertion order', () {
      final res = mapValues((int n) => n, {'b': 1, 'a': 2, 'c': 3});
      expect(res.keys.toList(), equals(['b', 'a', 'c']));
    });

    test('returns a new map — the source is untouched', () {
      final source = {'a': 1};
      final res = mapValues((int n) => n * 2, source);
      expect(source, equals({'a': 1}));
      expect(identical(res, source), isFalse);
    });

    test('handles an empty map', () {
      expect(
        mapValues((int n) => n * 2, <String, int>{}),
        equals(<String, int>{}),
      );
    });
  });

  group('mapKeys', () {
    test('runs every key through the callback', () {
      expect(
        mapKeys((String k) => k.toUpperCase(), {'a': 1, 'b': 2}),
        equals({'A': 1, 'B': 2}),
      );
    });

    test('can change the key type', () {
      expect(
        mapKeys((String k) => k.length, {'a': 1, 'bb': 2}),
        equals({1: 1, 2: 2}),
      );
    });

    test('on a collision the last key in iteration order wins', () {
      final res = mapKeys((String k) => k[0], {'ax': 1, 'ay': 2, 'b': 3});
      expect(res, equals({'a': 2, 'b': 3}));
      expect(res.keys.toList(), equals(['a', 'b']));
    });
  });

  group('mapEntries', () {
    test('transforms key and value together', () {
      final res = mapEntries((e) => (e.$1.toUpperCase(), e.$2 * 2), {
        'a': 1,
        'b': 2,
      });
      expect(res, equals({'A': 2, 'B': 4}));
    });

    test('can derive a key from the value and vice versa', () {
      final res = mapEntries((e) => (e.$2, e.$1), {'a': 1, 'b': 2});
      expect(res, equals({1: 'a', 2: 'b'}));
    });

    test('collides last-one-wins, like mapKeys', () {
      final res = mapEntries((e) => ('k', e.$2), {'a': 1, 'b': 2});
      expect(res, equals({'k': 2}));
    });

    test('generalises mapValues and mapKeys', () {
      final source = {'a': 1, 'b': 2};
      expect(
        mapEntries((e) => (e.$1, e.$2 * 2), source),
        equals(mapValues((int n) => n * 2, source)),
      );
      expect(
        mapEntries((e) => (e.$1.toUpperCase(), e.$2), source),
        equals(mapKeys((String k) => k.toUpperCase(), source)),
      );
    });
  });

  group('pickBy as the key-aware filter', () {
    test('filters by value or by key through the same record', () {
      expect(pickBy((e) => e.$2 > 1, {'a': 1, 'b': 2}), equals({'b': 2}));
      expect(
        pickBy((e) => e.$1.startsWith('a'), {'a': 1, 'b': 2}),
        equals({'a': 1}),
      );
    });

    test('composes with mapValues', () {
      final res = mapValues(
        (int n) => n * 10,
        pickBy((e) => e.$2.isEven, {'a': 1, 'b': 2, 'c': 3, 'd': 4}),
      );
      expect(res, equals({'b': 20, 'd': 40}));
    });
  });
}
