import 'package:fxdart/fxdart.dart' hide isNull, isEmpty;
import 'package:test/test.dart';

void main() {
  group('NonEmptyList', () {
    test('of builds head + tail', () {
      final nel = NonEmptyList.of(1, [2, 3]);
      expect(nel.head, 1);
      expect(nel.tail, [2, 3]);
      expect(nel.length, 3);
    });

    test('of with no tail is a singleton', () {
      final nel = NonEmptyList.of('only');
      expect(nel.head, 'only');
      expect(nel.tail, isEmpty);
    });

    test('orNull returns null for the empty list', () {
      expect(NonEmptyList.orNull(<int>[]), isNull);
      expect(NonEmptyList.orNull([1])?.head, 1);
    });

    test('orNull copies — mutating the source does not leak in', () {
      final source = [1, 2];
      final nel = NonEmptyList.orNull(source)!;
      source.add(3);
      expect(nel.toList(), [1, 2]);
    });

    test('head/first cannot throw — the Nel win is cannot-throw', () {
      final nel = NonEmptyList.of(9);
      expect(nel.head, 9);
      expect(nel.first, 9);
    });

    test('map preserves non-emptiness in the type', () {
      final NonEmptyList<String> mapped = NonEmptyList.of(1, [
        2,
      ]).map((n) => 'n$n');
      expect(mapped.toList(), ['n1', 'n2']);
      expect(mapped.head, 'n1');
    });

    test('+ concatenates', () {
      final nel = NonEmptyList.of(1) + NonEmptyList.of(2, [3]);
      expect(nel.toList(), [1, 2, 3]);
    });

    test('is a real Iterable (where/fold/join all work)', () {
      final nel = NonEmptyList.of(1, [2, 3, 4]);
      expect(nel.where((n) => n.isEven).toList(), [2, 4]);
      expect(nel.join('-'), '1-2-3-4');
    });

    test('Nel is a working shorthand', () {
      final Nel<int> nel = Nel.of(5);
      expect(nel.head, 5);
    });

    test('== is identity; deepEquals is structural', () {
      final a = NonEmptyList.of(1, [2]);
      final b = NonEmptyList.of(1, [2]);
      expect(a == b, isFalse);
      expect(a.deepEquals(b), isTrue);
      expect(a.deepEquals(NonEmptyList.of(1, [3])), isFalse);
      expect(a.deepEquals(NonEmptyList.of(1)), isFalse);
    });

    test('toList returns a defensive copy', () {
      final nel = NonEmptyList.of(1, [2]);
      nel.toList().add(3);
      expect(nel.length, 2);
    });

    test('PINNED erasure semantics: is/as bypass the invariant — even for '
        'the empty list', () {
      // Extension types erase to their representation. These pin today's
      // language semantics so any future change is noticed.
      final Object empty = <int>[];
      expect(empty is NonEmptyList<int>, isTrue);
      final bogus = empty as NonEmptyList<int>;
      expect(() => bogus.head, throwsStateError);
    });
  });
}
