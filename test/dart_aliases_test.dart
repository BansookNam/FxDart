import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

/// Every FxTS operator with a Dart-idiomatic synonym exposes BOTH spellings
/// (except `toArray`, which was removed in favour of `toList`). These assert
/// the alias delegates to exactly the same behaviour as the FxTS-named original.
void main() {
  group('sync fx() chain aliases', () {
    final xs = fx([1, 2, 3, 4, 5, null, 3]);

    test('where == filter', () {
      expect(fx([1, 2, 3, 4]).where((a) => a.isEven).toList(),
          equals(fx([1, 2, 3, 4]).filter((a) => a.isEven).toList()));
    });
    test('whereNot == reject', () {
      expect(fx([1, 2, 3, 4]).whereNot((a) => a.isEven).toList(), equals([1, 3]));
    });
    test('expand == flatMap', () {
      expect(fx([1, 2]).expand((a) => [a, a]).toList(),
          equals(fx([1, 2]).flatMap((a) => [a, a]).toList()));
    });
    test('skip == drop, skipWhile == dropWhile', () {
      expect(fx([1, 2, 3, 4]).skip(2).toList(), equals([3, 4]));
      expect(fx([1, 2, 3, 4]).skipWhile((a) => a < 3).toList(), equals([3, 4]));
    });
    test('takeLast == takeRight', () {
      expect(fx([1, 2, 3, 4]).takeLast(2).toList(), equals([3, 4]));
    });
    test('distinct == uniq, distinctBy == uniqBy', () {
      expect(fx([1, 1, 2, 2, 3]).distinct().toList(), equals([1, 2, 3]));
      expect(fx(['a', 'bb', 'cc']).distinctBy((s) => s.length).toList(),
          equals(['a', 'bb']));
    });
    test('flattened == flat', () {
      expect(fx([[1], [2, 3]]).flattened().toList(), equals([1, 2, 3]));
    });
    test('firstWhereOrNull == find, indexWhere == findIndex', () {
      expect(fx([1, 2, 3]).firstWhereOrNull((a) => a > 1), equals(2));
      expect(fx([1, 2, 3]).firstWhereOrNull((a) => a > 9), isNull);
      expect(fx([1, 2, 3]).indexWhere((a) => a == 3), equals(2));
    });
    test('inherited Dart names still work on the chain', () {
      expect(xs.firstOrNull, equals(1)); // head
      expect(fx(<int>[]).firstOrNull, isNull);
      expect(fx([1, 2, 3]).any((a) => a > 2), isTrue); // some
      expect(fx([1, 2, 3]).length, equals(3)); // size
    });
  });

  group('async fx() chain aliases', () {
    test('where/whereNot/expand/skip/any/firstOrNull/count', () async {
      expect(await fx([1, 2, 3, 4]).toAsync().where((a) => a.isEven).toList(),
          equals([2, 4]));
      expect(await fx([1, 2, 3, 4]).toAsync().whereNot((a) => a.isEven).toList(),
          equals([1, 3]));
      expect(await fx([1, 2]).toAsync().expand((a) => [a, a]).toList(),
          equals([1, 1, 2, 2]));
      expect(await fx([1, 2, 3, 4]).toAsync().skip(2).toList(), equals([3, 4]));
      expect(await fx([1, 2, 3]).toAsync().any((a) => a > 2), isTrue);
      expect(await fx([1, 2, 3]).toAsync().firstOrNull(), equals(1));
      expect(await fx([1, 2, 3]).toAsync().count(), equals(3));
    });
  });

  group('top-level aliases', () {
    test('where/whereNot/nonNulls/distinct/expand/skip', () {
      expect(toList(where((int a) => a.isEven, [1, 2, 3, 4])), equals([2, 4]));
      expect(toList(whereNot((int a) => a.isEven, [1, 2, 3, 4])), equals([1, 3]));
      expect(toList(nonNulls([1, null, 2, null, 3])), equals([1, 2, 3]));
      expect(toList(distinct([1, 1, 2, 3])), equals([1, 2, 3]));
      expect(toList(skip(2, [1, 2, 3, 4])), equals([3, 4]));
    });
    test('access + aggregate aliases', () {
      expect(firstOrNull([1, 2, 3]), equals(1));
      expect(firstOrNull(<int>[]), isNull);
      expect(lastOrNull([1, 2, 3]), equals(3));
      expect(elementAtOrNull(1, [1, 2, 3]), equals(2));
      expect(firstWhereOrNull((int a) => a > 1, [1, 2, 3]), equals(2));
      expect(indexWhere((int a) => a == 3, [1, 2, 3]), equals(2));
      expect(any((int a) => a > 2, [1, 2, 3]), isTrue);
      expect(count([1, 2, 3]), equals(3));
      expect(toList(indexed(['a', 'b'])), equals([(0, 'a'), (1, 'b')]));
      expect(sorted((int a, int b) => a - b, [3, 1, 2]), equals([1, 2, 3]));
    });
    test('predicate + unicode aliases (both spellings)', () {
      expect(isBool(true), isTrue);
      expect(isBoolean(true), isTrue);
      expect(isNum(1), isTrue);
      expect(isNumber(1), isTrue);
      expect(isDateTime(DateTime(2024)), isTrue);
      expect(isDate(DateTime(2024)), isTrue);
      expect(unicodeToList('ab'), equals(['a', 'b']));
      expect(unicodeToArray('ab'), equals(['a', 'b']));
    });
  });
}
