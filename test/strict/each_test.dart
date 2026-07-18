import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('each', () {
    group('sync', () {
      test("should iterate and call the function to each item of 'Iterable'",
          () {
        var acc = 0;
        each((int a) {
          acc += a;
        }, [1, 2, 3, 4, 5]);
        expect(acc, equals(15));
      });

      test('should be able to be used in the pipeline', () {
        var acc = 0;
        each((int a) {
          acc += a;
        }, map((int a) => a + 10, [1, 2, 3, 4]));
        expect(acc, equals(50));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        var acc = 0;
        fx([1, 2, 3, 4]).map((a) => a + 10).each((a) {
          acc += a;
        });
        expect(acc, equals(50));
      });
    });

    group('async', () {
      test(
          "should iterate and call the function to each item of 'AsyncIterable'",
          () async {
        var acc = 0;
        await eachAsync((int a) {
          acc += a;
        }, toAsync([1, 2, 3, 4, 5]));
        expect(acc, equals(15));
      });

      test('should work when the given function is asynchronous', () async {
        var acc = 0;
        await eachAsync((int a) async {
          acc += a;
        }, toAsync([1, 2, 3, 4, 5]));
        expect(acc, equals(15));
      });

      test('should work with a lazy range source', () async {
        var acc = 0;
        await eachAsync((int a) {
          acc += a;
        }, toAsync(range(1, 6, 1)));
        expect(acc, equals(15));
      });

      test('should throw an error occurs in the callback', () async {
        var res1 = 0;
        try {
          await eachAsync((int a) {
            if (a == 3) {
              throw 'err';
            }
            res1 += a;
          }, toAsync(range(1, 6, 1)));
          fail('should have thrown');
        } catch (err) {
          expect(err, equals('err'));
        }
        expect(res1, equals(3));

        var res2 = 0;
        try {
          await eachAsync((int a) {
            if (a == 3) {
              return Future<void>.error('err');
            }
            res2 += a;
            return null;
          }, toAsync(range(1, 6, 1)));
          fail('should have thrown');
        } catch (err) {
          expect(err, equals('err'));
        }
        expect(res2, equals(3));
      });

      test('should be able to be used in the pipeline', () async {
        var res1 = 0;
        await eachAsync((int a) {
          res1 += a;
        }, mapAsync((int a) => a + 10, toAsync([1, 2, 3, 4])));
        expect(res1, equals(50));

        var res2 = 0;
        await eachAsync((int a) async {
          res2 += a;
        }, mapAsync((int a) => a + 10, toAsync([1, 2, 3, 4])));
        expect(res2, equals(50));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        var acc = 0;
        await fx([1, 2, 3, 4]).toAsync().map((a) => a + 10).each((a) {
          acc += a;
        });
        expect(acc, equals(50));
      });
    });
  });
}
