// `map(...).uniq()` is built as a single stage rather than two (see
// FxUniqFusable): the pull protocol between the two cost more than the work
// itself on a large source.
//
// Each case is paired with what the unfused pair would do, so what is pinned
// is behaviour — elements, order, laziness, callback count — not the
// representation. The one exception is the first test, which is the only
// thing that would notice the fusion silently switching itself off.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('map().uniq() fusion', () {
    test('builds one stage, not a uniq wrapping a map', () {
      // White-box: nothing else here fails if the two stages stop fusing, and
      // a silent un-fusing is a ~1.9x regression on a large source.
      expect(
        uniq(map((int a) => a % 3, [1, 2, 3])).runtimeType.toString(),
        startsWith('_MapUniq'),
      );
      // A source that cannot absorb it still gets the plain uniq stage.
      expect(uniq([1, 2, 3]).runtimeType.toString(), startsWith('_Uniq'));
    });

    test('same elements and order as the unfused pair', () {
      List<String> initials(Iterable<String> names) =>
          names.map((n) => n[0]).toList();

      const names = ['ann', 'bob', 'amy', 'cid', 'bea', 'al'];
      expect(fx(names).map((n) => n[0]).uniq().toList(), ['a', 'b', 'c']);
      expect(uniqStrict(initials(names)), ['a', 'b', 'c']);
    });

    test('dedups the mapped value, not the source element', () {
      expect(fx([1, 2, 3, 4, 5, 6]).map((a) => a % 3).uniq().toList(), [
        1,
        2,
        0,
      ]);
    });

    test('runs the callback once per element consumed, in order', () {
      final seen = <int>[];
      final result = fx([1, 2, 2, 3, 1])
          .map((a) {
            seen.add(a);
            return a * 10;
          })
          .uniq()
          .toList();

      expect(result, [10, 20, 30]);
      expect(seen, [1, 2, 2, 3, 1], reason: 'once per source element');
    });

    test('stays lazy: a downstream take cuts the source short', () {
      final seen = <int>[];
      final result = fx([1, 1, 2, 2, 3, 4, 5])
          .map((a) {
            seen.add(a);
            return a;
          })
          .uniq()
          .take(2)
          .toList();

      expect(result, [1, 2]);
      expect(seen, [
        1,
        1,
        2,
      ], reason: 'stops as soon as the 2nd distinct lands');
    });

    test('the seen set is per-iteration, so it can be iterated twice', () {
      final chain = fx([1, 2, 2, 3]).map((a) => a * 2).uniq();
      expect(chain.toList(), [2, 4, 6]);
      expect(chain.toList(), [2, 4, 6]);
      expect(chain.toList(), chain.toList());
    });

    test('the lazy iterator and the fused toList agree', () {
      final chain = fx([3, 1, 3, 2, 1]).map((a) => 'v$a').uniq();
      expect([for (final v in chain) v], chain.toList());
      expect(chain.toList(), ['v3', 'v1', 'v2']);
    });

    test('a non-List source takes the pulled path with the same result', () {
      Iterable<int> generated() sync* {
        yield 1;
        yield 2;
        yield 1;
        yield 3;
      }

      expect(fx(generated()).map((a) => a * 2).uniq().toList(), [2, 4, 6]);
    });

    test('an empty source yields an empty list', () {
      expect(fx(<int>[]).map((a) => a).uniq().toList(), <int>[]);
      expect(fx(<int>[]).map((a) => a).uniq().iterator.moveNext(), isFalse);
    });

    test('toList(growable: false) returns a fixed-length list', () {
      final result = fx([1, 2, 2]).map((a) => a).uniq().toList(growable: false);
      expect(result, [1, 2]);
      expect(() => result.add(3), throwsUnsupportedError);
    });

    test('distinct() is the same stage as uniq()', () {
      expect(
        fx([1, 2, 2, 3]).map((a) => a * 2).distinct().toList(),
        fx([1, 2, 2, 3]).map((a) => a * 2).uniq().toList(),
      );
    });

    test('keeps identity-unequal values that compare unequal', () {
      final rows = [
        {'v': 1},
        {'v': 1},
      ];
      expect(fx(rows).map((r) => r).uniq().toList(), hasLength(2));
    });
  });
}
