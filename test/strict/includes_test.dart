import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('includes', () {
    group('sync', () {
      test('should check if the specified value is equal.', () {
        expect(includes('r', 'marpple'.split('')), isTrue);
        expect(includes('b', 'marpple'.split('')), isFalse);

        expect(includes(1, [1, 2, 3, 4]), isTrue);
        expect(includes(5, [1, 2, 3, 4]), isFalse);
      });

      test('should be able to be used in the pipeline', () {
        final res1 = includes(
            14, fx([1, 2, 3, 4]).map((a) => a + 10).filter((a) => a % 2 == 0));
        expect(res1, isTrue);
      });
    });

    group('async', () {
      test('should check if the specified value is equal.', () async {
        expect(await includesAsync('r', toAsync('marpple'.split(''))), isTrue);
        expect(await includesAsync('b', toAsync('marpple'.split(''))), isFalse);

        expect(await includesAsync(1, toAsync([1, 2, 3, 4])), isTrue);
        expect(await includesAsync(5, toAsync([1, 2, 3, 4])), isFalse);
      });

      test('should be able to be used in the pipeline', () async {
        final res1 = await includesAsync(
            14,
            filterAsync((int a) => a % 2 == 0,
                mapAsync((int a) => a + 10, toAsync([1, 2, 3, 4]))));
        expect(res1, isTrue);
      });
    });
  });
}
