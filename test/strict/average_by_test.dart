import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('averageBy', () {
    group('sync', () {
      test('should average the key of every element', () {
        expect(
          fxAverageBy((String s) => s.length, ['a', 'bb', 'ccc']),
          equals(2.0),
        );
      });

      test('should return NaN for an empty iterable', () {
        expect(fxAverageBy((int n) => n, <int>[]).isNaN, isTrue);
      });

      test('should be able to be used in the pipeline', () {
        final res = fx([
          1,
          2,
          3,
          4,
        ]).filter((n) => n.isEven).averageBy((n) => n * 10);
        expect(res, equals(30.0));
      });
    });

    group('async', () {
      test('should average the key of every element', () async {
        expect(
          await fxAverageByAsync(
            (String s) => s.length,
            fxToAsync(['a', 'bbb']),
          ),
          equals(2.0),
        );
      });

      test('should return NaN for an empty iterable', () async {
        final res = await fxAverageByAsync((int n) => n, fxToAsync(<int>[]));
        expect(res.isNaN, isTrue);
      });

      test('should await async keys and be usable in the pipeline', () async {
        final res = await fx([1, 2, 3]).toAsync().averageBy(
          (n) => fxDelay(const Duration(milliseconds: 10), n * 2),
        );
        expect(res, equals(4.0));
      });
    });
  });
}
