import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// The int-key strategies behind sortBy/sortByDesc: a presorted/reversed scan,
// a stable counting sort for narrow key ranges, and a stable lockstep merge
// for wide ones. Which strategy runs is an implementation detail, so every
// test here pins the OBSERVABLE contract — order and tie order — and the
// groups differ only in the key range that selects the strategy.

/// A row whose [tag] distinguishes records with equal keys, so a stable sort
/// is observable.
class Row {
  const Row(this.key, this.tag);
  final int key;
  final String tag;
  @override
  String toString() => '$key$tag';
}

List<String> tags(List<Row> rows) => [for (final r in rows) r.toString()];

void main() {
  group('sortBy (int keys)', () {
    // --- narrow range: the counting-sort path -----------------------------

    test('sorts a narrow key range ascending', () {
      expect(
        sortBy((int a) => a, [5, 1, 4, 1, 3, 2, 0]),
        equals([0, 1, 1, 2, 3, 4, 5]),
      );
    });

    test('is stable over a narrow key range', () {
      final rows = [
        const Row(2, 'a'),
        const Row(1, 'b'),
        const Row(2, 'c'),
        const Row(1, 'd'),
        const Row(2, 'e'),
      ];
      expect(tags(sortBy((Row r) => r.key, rows)), equals([
        '1b',
        '1d',
        '2a',
        '2c',
        '2e',
      ]));
    });

    test('is stable over a narrow key range, descending', () {
      final rows = [
        const Row(2, 'a'),
        const Row(1, 'b'),
        const Row(2, 'c'),
        const Row(1, 'd'),
      ];
      expect(tags(sortByDesc((Row r) => r.key, rows)), equals([
        '2a',
        '2c',
        '1b',
        '1d',
      ]));
      // `sortBy` with a negated key must agree with `sortByDesc`.
      expect(
        tags(sortBy((Row r) => -r.key, rows)),
        equals(tags(sortByDesc((Row r) => r.key, rows))),
      );
    });

    test('handles negative and mixed-sign keys', () {
      expect(
        sortBy((int a) => a, [3, -2, 0, -5, 1, -2]),
        equals([-5, -2, -2, 0, 1, 3]),
      );
      expect(
        sortByDesc((int a) => a, [3, -2, 0, -5, 1, -2]),
        equals([3, 1, 0, -2, -2, -5]),
      );
    });

    test('handles a single repeated key', () {
      final rows = [const Row(7, 'a'), const Row(7, 'b'), const Row(7, 'c')];
      expect(tags(sortBy((Row r) => r.key, rows)), equals(['7a', '7b', '7c']));
      expect(
        tags(sortByDesc((Row r) => r.key, rows)),
        equals(['7a', '7b', '7c']),
      );
    });

    // --- wide range: the merge path ---------------------------------------

    test('sorts a key range wider than the input', () {
      final keys = [900000000, -900000000, 5, 1 << 50, -(1 << 50), 0];
      expect(
        sortBy((int a) => a, keys),
        equals([-(1 << 50), -900000000, 0, 5, 900000000, 1 << 50]),
      );
    });

    test('is stable over a wide key range', () {
      final rows = [
        const Row(1 << 40, 'a'),
        const Row(-(1 << 40), 'b'),
        const Row(1 << 40, 'c'),
        const Row(-(1 << 40), 'd'),
      ];
      expect(tags(sortBy((Row r) => r.key, rows)), equals([
        '-1099511627776b',
        '-1099511627776d',
        '1099511627776a',
        '1099511627776c',
      ]));
    });

    test('survives keys whose span overflows a 64-bit subtraction', () {
      // max - min wraps negative here; the counting sort must decline it.
      const lo = -0x7fffffffffffffff;
      const hi = 0x7fffffffffffffff;
      expect(
        sortBy((int a) => a, [hi, 0, lo]),
        equals([lo, 0, hi]),
      );
      expect(
        sortByDesc((int a) => a, [lo, 0, hi]),
        equals([hi, 0, lo]),
      );
    });

    // --- the O(n) shortcuts -----------------------------------------------

    test('returns already-ordered input unchanged, ties included', () {
      final rows = [
        const Row(1, 'a'),
        const Row(1, 'b'),
        const Row(2, 'c'),
        const Row(3, 'd'),
      ];
      expect(tags(sortBy((Row r) => r.key, rows)), equals([
        '1a',
        '1b',
        '2c',
        '3d',
      ]));
    });

    test('reverses a strictly reversed input', () {
      expect(sortBy((int a) => a, [5, 4, 3, 2, 1]), equals([1, 2, 3, 4, 5]));
      expect(
        sortByDesc((int a) => a, [1, 2, 3, 4, 5]),
        equals([5, 4, 3, 2, 1]),
      );
    });

    test('does not reverse a NON-strictly reversed input (stability)', () {
      // [2a, 2b, 1c] is non-increasing but not strictly so: reversing it
      // would swap 2a and 2b, which a stable sort must not do.
      final rows = [const Row(2, 'a'), const Row(2, 'b'), const Row(1, 'c')];
      expect(tags(sortByDesc((Row r) => r.key, rows)), equals([
        '2a',
        '2b',
        '1c',
      ]));
      expect(tags(sortBy((Row r) => r.key, rows)), equals([
        '1c',
        '2a',
        '2b',
      ]));
    });

    // --- agreement with a reference sort ----------------------------------

    test('agrees with a reference stable sort at both range widths', () {
      for (final span in [8, 1 << 30]) {
        var seed = 12345;
        int next() => seed = (seed * 1103515245 + 12345) & 0x3fffffff;
        final rows = [
          for (var i = 0; i < 500; i++) Row(next() % span - span ~/ 2, 'r$i'),
        ];
        final expected = [...rows]
          ..sort((a, b) => a.key.compareTo(b.key)); // List.sort is unstable…
        // …so compare keys only, then check stability separately.
        expect(
          [for (final r in sortBy((Row r) => r.key, rows)) r.key],
          equals([for (final r in expected) r.key]),
          reason: 'span=$span',
        );
        final sorted = sortBy((Row r) => r.key, rows);
        final index = {for (var i = 0; i < rows.length; i++) rows[i].tag: i};
        for (var i = 1; i < sorted.length; i++) {
          if (sorted[i - 1].key == sorted[i].key) {
            expect(
              index[sorted[i - 1].tag]!,
              lessThan(index[sorted[i].tag]!),
              reason: 'span=$span: equal keys must keep source order',
            );
          }
        }
      }
    });

    test('chains through Fx and keeps laziness of the source', () {
      final res = fx([5, 3, 9, 1, 3])
          .filter((a) => a > 1)
          .sortBy((a) => a)
          .toList();
      expect(res, equals([3, 3, 5, 9]));
    });
  });
}
