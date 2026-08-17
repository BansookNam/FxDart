import 'package:fxdart/fxdart.dart' hide isEmpty, isNotNull, isNull;
import 'package:test/test.dart';

// Record `==` compares `List` fields by identity, so groups are asserted
// per-field (key, items) rather than as whole records.
void main() {
  group('groupedBy', () {
    group('sync', () {
      test(
        'should group into (key, items) records in first-seen key order',
        () {
          final groups = groupedBy((String w) => w.length, [
            'ab',
            'cd',
            'e',
            'fg',
          ]);
          expect(groups.map((g) => g.key), equals([2, 1]));
          expect(groups[0].items, equals(['ab', 'cd', 'fg']));
          expect(groups[1].items, equals(['e']));
        },
      );

      test('should match groupBy exactly', () {
        final words = ['ab', 'cd', 'e', 'fg', 'hij'];
        final asMap = groupBy((String w) => w.length, words);
        final asGroups = groupedBy((String w) => w.length, words);
        expect(
          asGroups.map((g) => g.key).toList(),
          equals(asMap.keys.toList()),
        );
        for (final g in asGroups) {
          expect(g.items, equals(asMap[g.key]));
        }
      });

      test('should return an empty list for an empty iterable', () {
        expect(groupedBy((int n) => n, <int>[]), isEmpty);
      });

      test('should be able to be used in the pipeline (no re-entry)', () {
        final spending = [
          (cat: 'food', amount: 20),
          (cat: 'rent', amount: 900),
          (cat: 'food', amount: 30),
          (cat: 'fun', amount: 15),
        ];
        final top = fx(spending)
            .groupedBy((e) => e.cat)
            .map((g) => (g.key, fx(g.items).sumBy((e) => e.amount)))
            .sortByDesc((c) => c.$2)
            .take(2)
            .toList();
        expect(top, equals([('rent', 900), ('food', 50)]));
      });
    });

    group('async', () {
      test('should group into records in first-seen key order', () async {
        final groups = await groupedByAsync(
          (int n) async => n.isEven,
          toAsync([1, 2, 3, 4]),
        );
        expect(groups.map((g) => g.key), equals([false, true]));
        expect(groups[0].items, equals([1, 3]));
        expect(groups[1].items, equals([2, 4]));
      });

      test('should be able to be used in the pipeline', () async {
        final groups = await fx([
          'ab',
          'c',
          'de',
        ]).toAsync().groupedBy((w) => w.length);
        expect(groups.map((g) => g.key), equals([2, 1]));
        expect(groups[0].items, equals(['ab', 'de']));
        expect(groups[1].items, equals(['c']));
      });
    });
  });
}
