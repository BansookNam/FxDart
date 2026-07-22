import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('sumBy', () {
    group('sync', () {
      test('should sum the key of every element', () {
        expect(sumBy((String s) => s.length, ['a', 'bb', 'ccc']), equals(6));
        expect(sumBy((int n) => n * 2, [1, 2, 3]), equals(12));
      });

      test('should return 0 for an empty iterable', () {
        expect(sumBy((int n) => n, <int>[]), equals(0));
      });

      test('should be able to be used in the pipeline', () {
        final res = fx(['a', 'bb', 'ccc'])
            .filter((s) => s.length > 1)
            .sumBy((s) => s.length);
        expect(res, equals(5));
      });
    });

    group('async', () {
      test('should sum the key of every element', () async {
        expect(
            await sumByAsync((String s) => s.length, toAsync(['a', 'bb'])),
            equals(3));
      });

      test('should return 0 for an empty iterable', () async {
        expect(await sumByAsync((int n) => n, toAsync(<int>[])), equals(0));
      });

      test('should await async keys and be usable in the pipeline', () async {
        final res = await fx([1, 2, 3])
            .toAsync()
            .sumBy((n) => delay(const Duration(milliseconds: 10), n * 10));
        expect(res, equals(60));
      });
    });
  });
}
