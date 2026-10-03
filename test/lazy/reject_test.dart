import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

bool mod(int a) => a % 2 == 0;
Future<bool> modAsync(int a) async => a % 2 == 0;

void main() {
  group('reject', () {
    group('sync', () {
      test('should be rejected by the callback', () {
        final res = [...fxReject(mod, fxRange(1, 10))];
        expect(res, equals([1, 3, 5, 7, 9]));
      });

      test('should be able to handle an error', () {
        expect(
          () => fxToList(
            fxReject<int>((a) => throw Exception('err'), fxRange(1, 10)),
          ),
          throwsException,
        );
      });

      test('should be able to be used in the pipeline', () {
        final res1 = pipe(
          [1, 2, 3, 4],
          [(v) => fxReject((int a) => a % 2 == 0, v), (v) => fxToList(v)],
        );

        expect(res1, equals([1, 3]));

        final res2 = fxToList(
          fxReject<int?>((a) => a != null, [1, 2, null, 3, null, 4]),
        );

        expect(res2, equals([null, null]));
      });
    });

    group('async', () {
      test('should be rejected by the callback', () async {
        final res = <int>[];
        final it = fxRejectAsync(modAsync, fxToAsync(fxRange(1, 10))).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          res.add(r.value);
        }
        expect(res, equals([1, 3, 5, 7, 9]));
      });

      test('should be able to handle an error', () async {
        await expectLater(
          fxToListAsync(
            fxRejectAsync<int>(
              (a) => throw Exception('err'),
              fxToAsync(fxRange(1, 10)),
            ),
          ),
          throwsException,
        );
      });

      test(
        'should be able to handle an error when the callback is asynchronous',
        () async {
          await expectLater(
            fxToListAsync(
              fxRejectAsync<int>(
                (a) => Future<bool>.error(Exception('err')),
                fxToAsync(fxRange(1, 10)),
              ),
            ),
            throwsException,
          );
        },
      );

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(
          fxToAsync([1, 2, 3, 4]),
        ).reject((a) => a % 2 == 0).toList();

        expect(res, equals([1, 3]));
      });
    });
  });
}
