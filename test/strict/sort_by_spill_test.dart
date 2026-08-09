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
  doubleKeyStrategies();
}

// The double-key path picks a strategy from the shape of the keys: already
// ordered -> no sort, exactly reversed -> reverse, otherwise a stable merge.
// These pin every branch, and that the choice is invisible.
void doubleKeyStrategies() {
  group('sortBy double-key strategies', () {
    List<(int, double)> rows(List<double> ks) =>
        [for (var i = 0; i < ks.length; i++) (i, ks[i])];

    test('already ascending is returned in order', () {
      expect(sortBy((r) => r.$2, rows([1, 2, 3, 4])).map((r) => r.$1).toList(),
          equals([0, 1, 2, 3]));
    });

    test('exactly reversed is reversed', () {
      expect(sortBy((r) => r.$2, rows([4, 3, 2, 1])).map((r) => r.$1).toList(),
          equals([3, 2, 1, 0]));
      expect(
          sortByDesc((r) => r.$2, rows([1, 2, 3, 4])).map((r) => r.$1).toList(),
          equals([3, 2, 1, 0]));
    });

    test('a non-strict reversed run must NOT take the reverse shortcut', () {
      // Keys 2,1,1,0 descending with a tie: reversing would swap the two
      // 1-keyed rows, breaking stability. Rows 1 and 2 must stay in order.
      final r = sortBy((x) => x.$2, rows([2, 1, 1, 0])).map((x) => x.$1).toList();
      expect(r, equals([3, 1, 2, 0]));
    });

    test('ties stay in source order at every strategy', () {
      final xs = [for (var i = 0; i < 400; i++) (i, (i % 4).toDouble())];
      for (final got in [sortBy((r) => r.$2, xs), sortByDesc((r) => r.$2, xs)]) {
        for (var key = 0; key < 4; key++) {
          final run =
              got.where((r) => r.$2 == key).map((r) => r.$1).toList();
          expect(run, equals(List.of(run)..sort()));
        }
      }
    });

    test('agrees with a reference sort on random data, every size', () {
      for (final n in [0, 1, 2, 3, 5, 8, 17, 64, 129, 1000]) {
        var seed = n * 7919 + 13;
        int next() => seed = (seed * 1103515245 + 12345) & 0x3fffffff;
        final xs = [for (var i = 0; i < n; i++) (next() % 50).toDouble()];
        final want = List.of(xs)..sort();
        expect(sortBy((double a) => a, xs), equals(want), reason: 'n=$n');
        expect(sortByDesc((double a) => a, xs),
            equals(want.reversed.toList()), reason: 'n=$n desc');
      }
    });

    test('-0.0 vs 0.0 is not mistaken for a sorted run', () {
      // 0.0 <= -0.0 is true but compareTo is positive: a `<=` scan would call
      // this sorted and return it unchanged.
      expect(sortBy((double a) => a, [0.0, -0.0]), equals([-0.0, 0.0]));
    });

    test('NaN falls through to the merge and sorts last', () {
      final r = sortBy((double a) => a, [1.0, double.nan, -1.0]);
      expect(r[0], equals(-1.0));
      expect(r[1], equals(1.0));
      expect(r[2].isNaN, isTrue);
    });

    test('the result is always growable', () {
      for (final xs in [[1.0, 2.0], [2.0, 1.0], [2.0, 3.0, 1.0]]) {
        expect(() => sortBy((double a) => a, xs).add(9.0), returnsNormally);
      }
    });
  });
}
