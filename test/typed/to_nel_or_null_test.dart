import 'package:fxdart/fxdart.dart' hide isEmpty, isNotNull, isNull;
import 'package:test/test.dart';

void main() {
  group('toNelOrNull', () {
    test('should return null for an empty iterable', () {
      expect(<String>[].toNelOrNull(), isNull);
      expect(fx(<int>[1, 2]).filter((n) => n > 9).toNelOrNull(), isNull);
    });

    test('should copy a non-empty iterable into a Nel', () {
      final nel = ['a', 'b'].toNelOrNull();
      expect(nel, isNotNull);
      expect(nel!.head, equals('a'));
      expect(nel.tail, equals(['b']));
    });

    test('should work on a lazy pipeline without toList', () {
      final nel = fx([1, 2, 3]).map((n) => n * 10).toNelOrNull();
      expect(nel!.toList(), equals([10, 20, 30]));
    });

    test('should take a defensive copy', () {
      final source = [1, 2];
      final nel = source.toNelOrNull()!;
      source.add(3);
      expect(nel.toList(), equals([1, 2]));
    });

    test('should agree with NonEmptyList.orNull', () {
      final viaStatic = NonEmptyList.orNull(['x', 'y']);
      final viaExtension = ['x', 'y'].toNelOrNull();
      expect(viaExtension!.deepEquals(viaStatic!), isTrue);
      expect(NonEmptyList.orNull(<String>[]), isNull);
      expect(<String>[].toNelOrNull(), isNull);
    });
  });
}
