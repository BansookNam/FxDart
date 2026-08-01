import 'package:fxdart/fxdart.dart' hide isEmpty, isNotNull, isNull;
import 'package:test/test.dart';

// Async twins of rights / lefts / separated — sync forms are covered in
// fx_either_test.dart.
void main() {
  const eithers = <Either<String, int>>[
    Right(1),
    Left('a'),
    Right(2),
    Left('b'),
  ];

  group('rightsAsync', () {
    test('should extract every Right, in order', () async {
      expect(await rightsAsync(toAsync(eithers)), equals([1, 2]));
    });

    test('should return empty for no Rights', () async {
      expect(await rightsAsync(toAsync(<Either<String, int>>[const Left('x')])),
          isEmpty);
    });

    test('should be able to be used as a chain terminal', () async {
      final result =
          await fx(eithers).toAsync().map((e) => e.map((n) => n * 10)).rights();
      expect(result, equals([10, 20]));
    });
  });

  group('leftsAsync', () {
    test('should extract every Left, in order', () async {
      expect(await leftsAsync(toAsync(eithers)), equals(['a', 'b']));
    });

    test('should be able to be used as a chain terminal', () async {
      expect(await fx(eithers).toAsync().lefts(), equals(['a', 'b']));
    });
  });

  group('separateEitherAsync', () {
    test('should split into (lefts, rights)', () async {
      final (ls, rs) = await separateEitherAsync(toAsync(eithers));
      expect(ls, equals(['a', 'b']));
      expect(rs, equals([1, 2]));
    });

    test('should return empty pairs for an empty upstream', () async {
      final (ls, rs) =
          await separateEitherAsync(toAsync(<Either<String, int>>[]));
      expect(ls, isEmpty);
      expect(rs, isEmpty);
    });

    test('should be able to be used as a chain terminal', () async {
      final (bad, good) = await fx(eithers).toAsync().separated();
      expect(bad, equals(['a', 'b']));
      expect(good, equals([1, 2]));
    });
  });
}
