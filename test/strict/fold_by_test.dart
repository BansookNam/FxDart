import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

class Tx {
  const Tx(this.category, this.amount);
  final String category;
  final double amount;
}

const txns = [
  Tx('Food', 10.0),
  Tx('Transport', 2.5),
  Tx('Food', 5.0),
  Tx('Fun', 7.0),
  Tx('Food', 1.5),
];

void main() {
  group('foldBy', () {
    group('sync', () {
      test('folds the values under each key', () {
        expect(
          foldBy((Tx t) => t.category, 0.0, (sum, t) => sum + t.amount, txns),
          equals({'Food': 16.5, 'Transport': 2.5, 'Fun': 7.0}),
        );
      });

      test('agrees with groupBy + fold per group', () {
        final viaGroup = {
          for (final e in groupBy((Tx t) => t.category, txns).entries)
            e.key: e.value.fold(0.0, (double s, t) => s + t.amount),
        };
        expect(
          foldBy((Tx t) => t.category, 0.0, (sum, t) => sum + t.amount, txns),
          equals(viaGroup),
        );
      });

      test('keys are in first-seen order, like groupBy', () {
        expect(
          foldBy((Tx t) => t.category, 0, (n, _) => n + 1, txns).keys.toList(),
          equals(groupBy((Tx t) => t.category, txns).keys.toList()),
        );
      });

      test('an empty source yields an empty map', () {
        expect(
          foldBy(
            (Tx t) => t.category,
            0.0,
            (s, t) => s + t.amount,
            const <Tx>[],
          ),
          equals(<String, double>{}),
        );
      });

      test('the seed starts every key, and is not applied twice', () {
        // seed 100 with a single element per key: exactly one fold step.
        expect(
          foldBy(
            (int a) => a.isEven ? 'even' : 'odd',
            100,
            (acc, a) => acc + a,
            [1, 2],
          ),
          equals({'odd': 101, 'even': 102}),
        );
      });

      test('a stored null is not mistaken for an absent key', () {
        // The accumulator legitimately becomes null after the first element.
        // If that were read back as "key absent", the seed would be applied a
        // second time and the result would be null instead of 4.
        final r = foldBy<int, bool, int?>(
          (a) => a.isEven,
          -1,
          (acc, a) => acc == null ? a : null,
          [2, 4],
        );
        // seed -1 -> f(-1, 2) == null -> f(null, 4) == 4.
        expect(r, equals({true: 4}));
      });

      test('the callbacks run once per element, in source order', () {
        final seenKeys = <String>[];
        final folded = <double>[];
        foldBy((Tx t) => t.category, 0.0, (sum, t) {
          folded.add(t.amount);
          return sum + t.amount;
        }, txns);
        for (final t in txns) {
          seenKeys.add(t.category);
        }
        expect(folded, equals([10.0, 2.5, 5.0, 7.0, 1.5]));
        expect(seenKeys.length, equals(txns.length));
      });

      test('a non-List source works the same', () {
        Iterable<Tx> gen() sync* {
          yield* txns;
        }

        expect(
          foldBy((Tx t) => t.category, 0.0, (sum, t) => sum + t.amount, gen()),
          equals(
            foldBy((Tx t) => t.category, 0.0, (sum, t) => sum + t.amount, txns),
          ),
        );
      });

      test('is reachable from the fx chain', () {
        expect(
          fx(txns).foldBy((t) => t.category, 0.0, (sum, t) => sum + t.amount),
          equals({'Food': 16.5, 'Transport': 2.5, 'Fun': 7.0}),
        );
      });

      test('composes after a lazy stage', () {
        expect(
          fx(txns)
              .filter((t) => t.amount > 2)
              .foldBy((t) => t.category, 0, (n, _) => n + 1),
          equals({'Food': 2, 'Transport': 1, 'Fun': 1}),
        );
      });
    });

    group('async', () {
      test('folds the values under each key', () async {
        expect(
          await foldByAsync(
            (Tx t) => t.category,
            0.0,
            (double sum, Tx t) => sum + t.amount,
            toAsync(txns),
          ),
          equals({'Food': 16.5, 'Transport': 2.5, 'Fun': 7.0}),
        );
      });

      test('awaits an async key and an async accumulator', () async {
        expect(
          await foldByAsync(
            (Tx t) async => t.category,
            0.0,
            (double sum, Tx t) async => sum + t.amount,
            toAsync(txns),
          ),
          equals({'Food': 16.5, 'Transport': 2.5, 'Fun': 7.0}),
        );
      });

      test('accepts a Future seed', () async {
        expect(
          await foldByAsync(
            (Tx t) => t.category,
            Future.value(0.0),
            (double sum, Tx t) => sum + t.amount,
            toAsync(txns),
          ),
          equals({'Food': 16.5, 'Transport': 2.5, 'Fun': 7.0}),
        );
      });

      test('an empty source yields an empty map', () async {
        expect(
          await foldByAsync(
            (Tx t) => t.category,
            0.0,
            (double s, Tx t) => s + t.amount,
            toAsync(const <Tx>[]),
          ),
          equals(<String, double>{}),
        );
      });

      test('is reachable from the fxAsync chain', () async {
        expect(
          await fxAsync(
            toAsync(txns),
          ).foldBy((t) => t.category, 0.0, (double sum, t) => sum + t.amount),
          equals({'Food': 16.5, 'Transport': 2.5, 'Fun': 7.0}),
        );
      });
    });
  });
}
