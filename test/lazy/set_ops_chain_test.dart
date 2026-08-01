import 'package:fxdart/fxdart.dart' hide isEmpty, isNotNull, isNull;
import 'package:test/test.dart';

// Chain-method twins of the differenceBy / intersectionBy family: the free
// functions have their own test files; these pin the receiver mapping —
// `fx(source).differenceBy(f, other)` is `differenceBy(f, other, source)`.
void main() {
  group('set-op chain methods', () {
    group('sync', () {
      test('differenceBy: values of the chain not keyed in other', () {
        final before = [(id: 1, v: 'a'), (id: 2, v: 'b')];
        final after = [(id: 2, v: 'b'), (id: 3, v: 'c')];
        final added = fx(after).differenceBy((t) => t.id, before).toList();
        expect(added, equals([(id: 3, v: 'c')]));
        expect(added,
            equals(differenceBy((t) => t.id, before, after).toList()));
      });

      test('difference: values of the chain not in other', () {
        expect(fx([1, 2, 3, 4]).difference([2, 4]).toList(), equals([1, 3]));
      });

      test('intersectionBy: values of the chain also keyed in other', () {
        final before = [(id: 1, v: 'a'), (id: 2, v: 'b')];
        final after = [(id: 2, v: 'b'), (id: 3, v: 'c')];
        expect(fx(after).intersectionBy((t) => t.id, before).toList(),
            equals([(id: 2, v: 'b')]));
      });

      test('intersection: values of the chain also in other', () {
        expect(fx([1, 2, 3]).intersection([2, 3, 9]).toList(), equals([2, 3]));
      });

      test('should stay chainable', () {
        final result = fx([5, 1, 3, 2, 4])
            .difference([1, 2])
            .sortByDesc((n) => n)
            .toList();
        expect(result, equals([5, 4, 3]));
      });
    });

    group('async', () {
      test('differenceBy: values of the chain not keyed in other', () async {
        final result = await fx([1, 2, 3, 4])
            .toAsync()
            .differenceBy((n) => n % 3, toAsync([3]))
            .toList();
        // keys of other = {0}; drops 3 (key 0), keeps 1, 2, 4 (keys 1, 2, 1)
        // deduped by value — all distinct here.
        expect(result, equals([1, 2, 4]));
      });

      test('difference: values of the chain not in other', () async {
        final result = await fx([1, 2, 3])
            .toAsync()
            .difference(toAsync([2]))
            .toList();
        expect(result, equals([1, 3]));
      });

      test('intersectionBy: values of the chain also keyed in other',
          () async {
        final result = await fx(['aa', 'b', 'ccc'])
            .toAsync()
            .intersectionBy((s) => s.length, toAsync(['xx', 'yyy']))
            .toList();
        expect(result, equals(['aa', 'ccc']));
      });

      test('intersection: values of the chain also in other', () async {
        final result = await fx([1, 2, 3])
            .toAsync()
            .intersection(toAsync([3, 1]))
            .toList();
        expect(result, equals([1, 3]));
      });
    });
  });
}
