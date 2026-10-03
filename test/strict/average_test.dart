import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('average', () {
    group('sync', () {
      test('should return the average of the given elements', () {
        expect(fxAverage([1, 2, 3, 4, 5]), equals(3));
        expect(fxAverage(<num>[]).isNaN, isTrue);
      });

      test('should switch to double accumulation at the first double', () {
        expect(fxAverage([1, 2, 1.5]), equals(1.5));
      });

      test('should be able to be used in the pipeline', () {
        final res = fx([1, 2, 3, 4, 5]).average();
        expect(res, equals(3));
      });
    });

    group('async', () {
      test('should return the average of the given elements', () async {
        expect(await fxAverageAsync(fxToAsync([1, 2, 3, 4, 5])), equals(3));
        final empty = await fxAverageAsync(fxToAsync(<num>[]));
        expect(empty.isNaN, isTrue);
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fx([1, 2, 3, 4, 5]).toAsync().average();
        expect(res, equals(3));
      });
    });
  });
}
