// `filter(...).uniq()` and `filter(...).uniqBy(...)` are built as one stage
// rather than two (see FxUniqFusable / FxUniqByFusable), and `filter` walks a
// `List` or a `range()` source by counter rather than through its iterator.
//
// Every case is paired with what the unfused / unindexed form does, so what is
// pinned is behaviour — elements, order, laziness, callback count — not the
// representation. The exceptions are the first two tests, which are the only
// things that would notice a fast path silently switching itself off.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('filter().uniq() / filter().uniqBy() fusion', () {
    test('builds one stage, not a uniq wrapping a filter', () {
      expect(
        uniq(filter((int a) => a > 1, [1, 2, 3])).runtimeType.toString(),
        startsWith('_FilterUniq'),
      );
      expect(
        uniqBy(
          (int a) => a % 2,
          filter((int a) => a > 1, [1, 2, 3]),
        ).runtimeType.toString(),
        startsWith('_FilterUniqBy'),
      );
      // A source that cannot absorb it still gets the plain stage.
      expect(uniq([1, 2, 3]).runtimeType.toString(), startsWith('_Uniq'));
      expect(
        uniqBy((int a) => a, [1, 2, 3]).runtimeType.toString(),
        startsWith('_UniqBy'),
      );
    });

    test('filter picks the indexed walk for List and range sources', () {
      expect(
        filter((int a) => a > 1, [1, 2, 3]).iterator.runtimeType.toString(),
        startsWith('_FilterListIterator'),
      );
      expect(
        filter((int a) => a > 1, range(0, 3)).iterator.runtimeType.toString(),
        startsWith('_FilterRangeIterator'),
      );
      Iterable<int> generated() sync* {
        yield 1;
      }

      expect(
        filter((int a) => a > 1, generated()).iterator.runtimeType.toString(),
        startsWith('_FilterIterator'),
      );
    });

    test('same elements and order as the unfused pair', () {
      const words = ['ant', 'bee', 'ape', 'cow', 'bat', 'auk'];
      bool long(String w) => w.length == 3;

      expect(fx(words).filter(long).uniqBy((w) => w[0]).toList(), [
        'ant',
        'bee',
        'cow',
      ]);
      expect(uniqByStrict((String w) => w[0], words.where(long).toList()), [
        'ant',
        'bee',
        'cow',
      ]);

      const nums = [1, 2, 2, 3, 4, 4, 5];
      expect(fx(nums).filter((a) => a.isEven).uniq().toList(), [2, 4]);
      expect(uniqStrict(nums.where((a) => a.isEven).toList()), [2, 4]);
    });

    test('runs both callbacks once per element consumed, in order', () {
      final tested = <int>[];
      final keyed = <int>[];
      final result = fx([1, 2, 2, 3, 1, 4])
          .filter((a) {
            tested.add(a);
            return a < 4;
          })
          .uniqBy((a) {
            keyed.add(a);
            return a;
          })
          .toList();

      expect(result, [1, 2, 3]);
      expect(tested, [1, 2, 2, 3, 1, 4], reason: 'once per source element');
      expect(keyed, [1, 2, 2, 3, 1], reason: 'only for elements that passed');
    });

    test('stays lazy: a downstream take cuts the source short', () {
      final tested = <int>[];
      final result = fx([1, 1, 2, 2, 3, 4, 5])
          .filter((a) {
            tested.add(a);
            return true;
          })
          .uniq()
          .take(2)
          .toList();

      expect(result, [1, 2]);
      expect(tested, [1, 1, 2], reason: 'stops when the 2nd distinct lands');
    });

    test('a filter over a range stays lazy under take', () {
      final tested = <int>[];
      final result = fx(range(0, 1000))
          .filter((i) {
            tested.add(i);
            return i.isEven;
          })
          .take(3)
          .toList();

      expect(result, [0, 2, 4]);
      expect(tested, [0, 1, 2, 3, 4]);
    });

    test('the seen set is per-iteration, so it can be iterated twice', () {
      final chain = fx([1, 2, 2, 3]).filter((a) => a > 1).uniq();
      expect(chain.toList(), [2, 3]);
      expect(chain.toList(), [2, 3]);

      final keyed = fx([1, 2, 2, 3]).filter((a) => a > 1).uniqBy((a) => a);
      expect(keyed.toList(), keyed.toList());
    });

    test('the lazy iterator and the fused toList agree', () {
      final chain = fx([3, 1, 3, 2, 1]).filter((a) => a < 3).uniq();
      expect([for (final v in chain) v], chain.toList());
      expect(chain.toList(), [1, 2]);

      final keyed = fx([
        3,
        1,
        3,
        2,
        1,
      ]).filter((a) => a < 3).uniqBy((a) => a % 2);
      expect([for (final v in keyed) v], keyed.toList());
    });

    test('a non-List source takes the pulled path with the same result', () {
      Iterable<int> generated() sync* {
        yield 1;
        yield 2;
        yield 1;
        yield 3;
      }

      expect(fx(generated()).filter((a) => a < 3).uniq().toList(), [1, 2]);
      expect(fx(generated()).filter((a) => a < 3).uniqBy((a) => a).toList(), [
        1,
        2,
      ]);
    });

    test('a descending range is walked in the right direction', () {
      expect(fx(range(5, 0, -1)).filter((i) => i.isOdd).toList(), [5, 3, 1]);
    });

    test('an empty source yields an empty list', () {
      expect(fx(<int>[]).filter((a) => true).uniq().toList(), <int>[]);
      expect(
        fx(<int>[]).filter((a) => true).uniq().iterator.moveNext(),
        isFalse,
      );
      expect(fx(range(0, 0)).filter((a) => true).toList(), <int>[]);
    });

    test('toList(growable: false) returns a fixed-length list', () {
      final result = fx([
        1,
        2,
        2,
      ]).filter((a) => true).uniq().toList(growable: false);
      expect(result, [1, 2]);
      expect(() => result.add(3), throwsUnsupportedError);
    });

    test('a throwing callback propagates out of the terminal', () {
      expect(
        () => fx([1, 2, 3])
            .filter((a) => a == 2 ? throw StateError('boom') : true)
            .uniq()
            .toList(),
        throwsStateError,
      );
    });
  });
}
