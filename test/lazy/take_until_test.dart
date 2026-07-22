// Tests for the deprecated `takeUntil` alias of `takeUntilInclusive`.
// FxTS has no dedicated takeUntil spec; these mirror the basic
// takeUntilInclusive cases through the alias.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('takeUntil (deprecated alias)', () {
    group('sync', () {
      test(
          'should be able to take the element until the callback result is truthy',
          () {
        // ignore: deprecated_member_use
        final res = toList(takeUntil((a) => a % 2 == 0, [1, 2, 3, 4]));
        expect(res, equals([1, 2]));

        // ignore: deprecated_member_use
        final res1 = toList(takeUntil((a) => a > 5, [1, 2, 3, 4]));
        expect(res1, equals([1, 2, 3, 4]));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx([1, 2, 3, 4])
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            // ignore: deprecated_member_use
            .takeUntil((a) => a > 12)
            .toList();

        expect(res, equals([12, 14]));
      });
    });

    group('async', () {
      test(
          'should be able to take the element until the callback result is truthy',
          () async {
        final res = await toListAsync(
            // ignore: deprecated_member_use
            takeUntilAsync((a) => a % 2 == 0, toAsync([1, 2, 3, 4])));
        expect(res, equals([1, 2]));

        final res1 = await toListAsync(
            // ignore: deprecated_member_use
            takeUntilAsync((a) async => a > 5, toAsync([1, 2, 3, 4])));
        expect(res1, equals([1, 2, 3, 4]));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res = await fxAsync(toAsync([1, 2, 3, 4]))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            // ignore: deprecated_member_use
            .takeUntil((a) => a > 12)
            .toList();

        expect(res, equals([12, 14]));
      });
    });
  });
}
