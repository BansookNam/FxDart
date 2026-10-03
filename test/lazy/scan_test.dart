import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('scan', () {
    group('sync', () {
      test(
        'should return value that is reduced given elements successively',
        () {
          expect(
            fxToList(fxScan((int a, int b) => a * b, 1, [1, 2, 3, 4])),
            equals([1, 1, 2, 6, 24]),
          );
          expect(
            fxToList(fxScan((String a, String b) => a + b, 'a', ['b', 'c'])),
            equals(['a', 'ab', 'abc']),
          );
        },
      );

      test('should reduce given elements successively without seed', () {
        expect(
          fxToList(fxScan1((int a, int b) => a * b, [1, 2, 3, 4])),
          equals([1, 2, 6, 24]),
        );
        expect(
          fxToList(fxScan1((String a, String b) => a + b, ['a', 'b', 'c'])),
          equals(['a', 'ab', 'abc']),
        );
      });

      test('should be able to be used in the pipeline', () {
        final res = fxToList(fxScan1((int a, int b) => a * b, [1, 2, 3, 4]));
        expect(res, equals([1, 2, 6, 24]));
      });
    });

    group('async', () {
      test(
        'should return value that is reduced given elements successively',
        () async {
          expect(
            await fxToListAsync(
              fxScanAsync((int a, int b) => a * b, 1, fxToAsync([1, 2, 3, 4])),
            ),
            equals([1, 1, 2, 6, 24]),
          );
          expect(
            await fxToListAsync(
              fxScanAsync(
                (String a, String b) => a + b,
                'a',
                fxToAsync(['b', 'c']),
              ),
            ),
            equals(['a', 'ab', 'abc']),
          );
        },
      );

      test(
        'should reduce given elements successively when seed is a Future',
        () async {
          expect(
            await fxToListAsync(
              fxScanAsync(
                (int a, int b) => a * b,
                Future.value(1),
                fxToAsync([1, 2, 3, 4]),
              ),
            ),
            equals([1, 1, 2, 6, 24]),
          );
          expect(
            await fxToListAsync(
              fxScanAsync(
                (String a, String b) => a + b,
                Future.value('a'),
                fxToAsync(['b', 'c']),
              ),
            ),
            equals(['a', 'ab', 'abc']),
          );
        },
      );

      test('should reduce given elements successively without seed', () async {
        expect(
          await fxToListAsync(
            fxScan1Async((int a, int b) => a * b, fxToAsync([1, 2, 3, 4])),
          ),
          equals([1, 2, 6, 24]),
        );
        expect(
          await fxToListAsync(
            fxScan1Async(
              (String a, String b) => a + b,
              fxToAsync(['a', 'b', 'c']),
            ),
          ),
          equals(['a', 'ab', 'abc']),
        );
      });

      test(
        'should be passed concurrent object when job works concurrently',
        () async {
          final mock = ConcurrentMock<int>();
          final it = fxScan1Async((int a, int b) => a, mock).iterator;
          await it.next(Concurrent.of(2));
          expect(mock.received?.length, equals(2));
        },
      );

      test('should be handled concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fxToListAsync(
          fxConcurrentAsync(
            3,
            fxScanAsync(
              (int a, int b) => a * b,
              1,
              fxMapAsync(
                (int a) => fxDelay(const Duration(milliseconds: 100), a),
                fxToAsync([1, 2, 3, 4, 5, 6, 7, 8, 9]),
              ),
            ),
          ),
        );

        expect(res, equals([1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880]));
        // sequential is ~900ms; concurrent(3) is ~300ms
        expect(sw.elapsedMilliseconds, lessThan(700));
      });

      test(
        'should be able to handle an error when working concurrent',
        () async {
          final future = fxToListAsync(
            fxConcurrentAsync(
              2,
              fxScan1Async(
                (int a, int b) {
                  if (a * b == 24) {
                    throw StateError('err');
                  }
                  return a * b;
                },
                fxMapAsync(
                  (int a) => fxDelay(const Duration(milliseconds: 20), a),
                  fxToAsync(fxRange(1, 21)),
                ),
              ),
            ),
          );
          await expectLater(future, throwsStateError);
        },
      );
    });
  });
}
