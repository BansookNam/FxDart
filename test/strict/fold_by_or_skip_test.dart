// `foldByOrSkip` is `filter(...).foldBy(...)` collapsed into one strict call:
// the key function both selects and buckets, and a `null` key skips the
// element. It exists because a lazy `filter` keeps its predicate in an
// iterator field, which the AOT compiler cannot see through — the same reason
// `takeUniqBy` exists.
//
// What has to hold is agreement with the spelling it replaces, plus the two
// things that are easy to get wrong when a filter is folded into a key: a
// null key must skip rather than bucket under null, and the seed must stay a
// per-key starting value rather than a running one.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

class Tx {
  const Tx(this.date, this.category, this.amount);
  final String date;
  final String category;
  final double amount;
}

const txns = [
  Tx('2026-07-02', 'Food', 10.0),
  Tx('2026-06-30', 'Food', 99.0), // out of scope
  Tx('2026-07-11', 'Transport', 2.5),
  Tx('2026-07-19', 'Food', 4.0),
  Tx('2026-08-01', 'Transport', 50.0), // out of scope
];

String? julyCategory(Tx t) => t.date.startsWith('2026-07') ? t.category : null;

void main() {
  group('foldByOrSkip', () {
    test('folds only the elements whose key is not null', () {
      expect(
        foldByOrSkip(julyCategory, 0.0, (double s, Tx t) => s + t.amount, txns),
        {'Food': 14.0, 'Transport': 2.5},
      );
    });

    test('agrees with the lazy spelling it replaces', () {
      final lazy = fx(txns)
          .filter((t) => t.date.startsWith('2026-07'))
          .foldBy((t) => t.category, 0.0, (s, t) => s + t.amount);

      expect(
        foldByOrSkip(julyCategory, 0.0, (double s, Tx t) => s + t.amount, txns),
        lazy,
      );
    });

    test('a null key skips rather than bucketing under null', () {
      final res = foldByOrSkip(
        julyCategory,
        0.0,
        (double s, Tx t) => s + t.amount,
        txns,
      );

      expect(res.containsKey(null), isFalse);
      expect(
        res.values.reduce((a, b) => a + b),
        16.5,
        reason: 'the two out-of-scope rows are not folded anywhere',
      );
    });

    test('the fold never sees a skipped element', () {
      final seen = <String>[];
      foldByOrSkip(julyCategory, 0.0, (double s, Tx t) {
        seen.add(t.date);
        return s + t.amount;
      }, txns);

      expect(seen, ['2026-07-02', '2026-07-11', '2026-07-19']);
    });

    test('the seed starts every key, it does not run across them', () {
      expect(
        foldByOrSkip(
          julyCategory,
          100.0,
          (double s, Tx t) => s + t.amount,
          txns,
        ),
        {'Food': 114.0, 'Transport': 102.5},
      );
    });

    test('keys appear in first-seen order, like foldBy', () {
      expect(
        foldByOrSkip(
          julyCategory,
          0.0,
          (double s, Tx t) => s + t.amount,
          txns,
        ).keys.toList(),
        ['Food', 'Transport'],
      );
    });

    test('every key null yields an empty map', () {
      expect(
        foldByOrSkip(
          (Tx t) => null,
          0.0,
          (double s, Tx t) => s + t.amount,
          txns,
        ),
        <String, double>{},
      );
    });

    test('an empty source yields an empty map', () {
      expect(
        foldByOrSkip(
          julyCategory,
          0.0,
          (double s, Tx t) => s + t.amount,
          const <Tx>[],
        ),
        <String, double>{},
      );
    });

    test('a non-List source takes the pulled loop and agrees', () {
      Iterable<Tx> gen() sync* {
        yield* txns;
      }

      expect(
        foldByOrSkip(
          julyCategory,
          0.0,
          (double s, Tx t) => s + t.amount,
          gen(),
        ),
        foldByOrSkip(julyCategory, 0.0, (double s, Tx t) => s + t.amount, txns),
      );
    });

    test(
      'a nullable accumulator is folded, not mistaken for an absent key',
      () {
        // A stored null must not read as "no cell yet" — foldBy documents the
        // same trap.
        final res = foldByOrSkip<Tx, String, double?>(
          julyCategory,
          null,
          (acc, t) => acc == null ? t.amount : acc + t.amount,
          txns,
        );

        expect(res, {'Food': 14.0, 'Transport': 2.5});
      },
    );

    test('keys need not be strings', () {
      expect(
        foldByOrSkip(
          (Tx t) => t.date.startsWith('2026-07') ? t.category.length : null,
          0,
          (int c, Tx t) => c + 1,
          txns,
        ),
        {4: 2, 9: 1},
      );
    });
  });

  group('Fx.foldByOrSkip', () {
    test('is the same operator', () {
      expect(
        fx(txns).foldByOrSkip(julyCategory, 0.0, (s, t) => s + t.amount),
        foldByOrSkip(julyCategory, 0.0, (double s, Tx t) => s + t.amount, txns),
      );
    });

    test('composes after a lazy stage', () {
      expect(
        fx(txns)
            .filter((t) => t.amount > 3)
            .foldByOrSkip(julyCategory, 0.0, (s, t) => s + t.amount),
        {'Food': 14.0},
      );
    });
  });
}
