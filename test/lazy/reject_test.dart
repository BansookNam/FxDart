import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

bool mod(int a) => a % 2 == 0;
Future<bool> modAsync(int a) async => a % 2 == 0;

void main() {
  group('reject', () {
    group('sync', () {
      test('should be rejected by the callback', () {
        final res = [...reject(mod, range(1, 10))];
        expect(res, equals([1, 3, 5, 7, 9]));
      });

      test('should be able to handle an error', () {
        expect(
          () =>
              toArray(reject<int>((a) => throw Exception('err'), range(1, 10))),
          throwsException,
        );
      });

      test('should be able to be used in the pipeline', () {
        final res1 = pipe([
          1,
          2,
          3,
          4
        ], [
          (v) => reject((int a) => a % 2 == 0, v),
          (v) => toArray(v),
        ]);

        expect(res1, equals([1, 3]));

        final res2 =
            toArray(reject<int?>((a) => a != null, [1, 2, null, 3, null, 4]));

        expect(res2, equals([null, null]));
      });
    });

    group('async', () {
      test('should be rejected by the callback', () async {
        final res = <int>[];
        final it = rejectAsync(modAsync, toAsync(range(1, 10))).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          res.add(r.value);
        }
        expect(res, equals([1, 3, 5, 7, 9]));
      });

      test('should be able to handle an error', () async {
        await expectLater(
          toArrayAsync(rejectAsync<int>(
              (a) => throw Exception('err'), toAsync(range(1, 10)))),
          throwsException,
        );
      });

      test(
          'should be able to handle an error when the callback is asynchronous',
          () async {
        await expectLater(
          toArrayAsync(rejectAsync<int>(
              (a) => Future<bool>.error(Exception('err')),
              toAsync(range(1, 10)))),
          throwsException,
        );
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(toAsync([1, 2, 3, 4]))
            .reject((a) => a % 2 == 0)
            .toArray();

        expect(res, equals([1, 3]));
      });
    });
  });
}
