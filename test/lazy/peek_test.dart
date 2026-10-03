import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('peek', () {
    group('sync', () {
      test('should be called the provided callback', () {
        var sum = 0;
        final res = fxPeek((int a) => sum = sum + a, [1, 2, 3, 4]);
        for (final _ in res) {}
        expect(sum, equals(10));
      });

      test('should be able to be used in the pipeline', () {
        var sum = 0;
        final res = fxToList(
          fxMap(
            (int a) => a + 10,
            fxPeek(
              (int a) => sum = sum + a,
              fxMap((int a) => a + 10, [1, 2, 3, 4]),
            ),
          ),
        );
        expect(sum, equals(50));
        expect(res, equals([21, 22, 23, 24]));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        var sum = 0;
        final res = fx([1, 2, 3, 4])
            .map((a) => a + 10)
            .peek((a) => sum = sum + a)
            .map((a) => a + 10)
            .toList();

        expect(sum, equals(50));
        expect(res, equals([21, 22, 23, 24]));
      });

      test('should be able to handle an error', () {
        final res = <int>[];
        expect(
          () => fx([1, 2, 3, 4])
              .map((a) => a + 10)
              .peek((a) {
                if (a == 13) {
                  throw StateError('err');
                }
                res.add(a);
              })
              .map((a) => a + 10)
              .toList(),
          throwsStateError,
        );
        expect(res, equals([11, 12]));
      });
    });

    group('async', () {
      test('should be called the provided callback', () async {
        var sum = 0;
        await fxEachAsync(
          (int _) {},
          fxPeekAsync((int a) => sum = sum + a, fxToAsync([1, 2, 3, 4])),
        );
        expect(sum, equals(10));
      });

      test('should be able to be used in the pipeline', () async {
        var sum = 0;
        final res = await fx([1, 2, 3, 4])
            .toAsync()
            .map((a) => a + 10)
            .peek((a) => sum = sum + a)
            .map((a) => a + 10)
            .toList();
        expect(sum, equals(50));
        expect(res, equals([21, 22, 23, 24]));
      });

      test('should be able to handle an error', () async {
        final res = <int>[];
        final future = fx([1, 2, 3, 4])
            .toAsync()
            .map((a) => a + 10)
            .peek((a) {
              if (a == 13) {
                throw StateError('err');
              }
              res.add(a);
            })
            .map((a) => a + 10)
            .toList();

        await expectLater(future, throwsStateError);
        expect(res, equals([11, 12]));
      });

      test(
        'should be passed concurrent object when job works concurrently',
        () async {
          final mock = ConcurrentMock<int>();
          final it = fxPeekAsync((int a) => a, mock).iterator;
          await it.next(Concurrent.of(2));
          expect(mock.received?.length, equals(2));
        },
      );
    });
  });
}
