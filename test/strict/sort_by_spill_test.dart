// The typed-key fast path in _sortByImpl reads keys straight into a typed
// array and spills to the boxed path when a later key disagrees. These pin
// that the spill is invisible: same order, and [f] still runs exactly once
// per element.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('sortBy typed-key extraction', () {
    test('mixed num keys sort like the generic path', () {
      // First key is int, a later one is double -> spills.
      final xs = [3, 1.5, 2, 0.5, 4];
      expect(sortBy((n) => n, xs), equals([0.5, 1.5, 2, 3, 4]));
      expect(sortByDesc((n) => n, xs), equals([4, 3, 2, 1.5, 0.5]));
    });

    test('spill at the very first comparison', () {
      final xs = [1, 'b', 0];
      expect(() => sortBy((a) => a, xs), throwsA(isA<TypeError>()));
    });

    test('the key extractor runs exactly once per element — typed path', () {
      var calls = 0;
      final xs = [3.0, 1.0, 2.0];
      sortBy((double a) {
        calls++;
        return a;
      }, xs);
      expect(calls, equals(3));
    });

    test('the key extractor runs exactly once per element — spilled path', () {
      var calls = 0;
      final xs = <Object>[3.0, 1, 2.0, 0.5];
      sortBy((Object a) {
        calls++;
        return a as num;
      }, xs);
      expect(calls, equals(4));
    });

    test('homogeneous double / int / String keys are unchanged', () {
      expect(sortBy((a) => a, [3.5, 1.5, 2.5]), equals([1.5, 2.5, 3.5]));
      expect(sortBy((a) => a, [3, 1, 2]), equals([1, 2, 3]));
      expect(sortBy((a) => a, ['c', 'a', 'b']), equals(['a', 'b', 'c']));
      expect(sortByDesc((a) => a, ['c', 'a', 'b']), equals(['c', 'b', 'a']));
    });

    test('single element and empty are untouched', () {
      expect(sortBy((a) => a, <int>[]), equals(<int>[]));
      expect(sortBy((a) => a, [7]), equals([7]));
    });

    test('NaN and -0.0 keep their compareTo semantics', () {
      final r = sortBy((double a) => a, [double.nan, 1.0, -0.0, 0.0]);
      expect(r.first, equals(-0.0));
      expect(r.last.isNaN, isTrue);
    });

    test('ties keep source order (stable permutation)', () {
      final xs = [('a', 1), ('b', 1), ('c', 0)];
      expect(sortBy((r) => r.$2, xs).map((r) => r.$1).toList(),
          equals(['c', 'a', 'b']));
    });
  });
}
