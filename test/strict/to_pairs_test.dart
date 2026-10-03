import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// toPairs is the inverse fromEntries never had. It exists so that the four
// Map-returning operators (groupBy, countBy, foldBy, indexBy) can be
// continued as a chain without re-entering through `fx(m.entries)` and then
// converting MapEntry back into a record by hand.
void main() {
  group('toPairs', () {
    test('returns the (key, value) records in the map iteration order', () {
      expect(fxToPairs({'a': 1, 'b': 2}).toList(), [('a', 1), ('b', 2)]);
    });

    test('an empty map yields nothing', () {
      expect(fxToPairs(<String, int>{}).toList(), <(String, int)>[]);
    });

    test('a single entry yields one record', () {
      expect(fxToPairs({'only': 7}).toList(), [('only', 7)]);
    });

    test('round-trips through fromEntries', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      expect(fxFromEntries(fxToPairs(map)), map);
    });

    test('is a lazy view, not a copy', () {
      final map = {'a': 1};
      final pairs = fxToPairs(map);
      map['b'] = 2;
      expect(pairs.toList(), [('a', 1), ('b', 2)]);
    });

    test('structural mutation during iteration throws', () {
      final map = {'a': 1};
      final iterator = fxToPairs(map).iterator;
      expect(iterator.moveNext(), isTrue);
      map['b'] = 2;
      expect(iterator.moveNext, throwsA(isA<ConcurrentModificationError>()));
    });

    test('enters a chain without a MapEntry conversion stage', () {
      final counts = fxCountBy((String s) => s.length, [
        'aa',
        'b',
        'ccc',
        'dd',
        'e',
      ]);
      expect(fx(fxToPairs(counts)).topBy(1, (p) => p.$2).toList(), [(2, 2)]);
    });

    test('keeps a nullable value type', () {
      expect(fxToPairs(<String, int?>{'a': null}).toList(), [('a', null)]);
    });
  });
}
