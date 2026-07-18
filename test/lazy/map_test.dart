import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

int add10(int a) => a + 10;
Future<int> add10Async(int a) async => a + 10;

void main() {
  group('map', () {
    group('sync', () {
      test('should be mapped by the callback', () {
        final acc = <int>[];
        for (final a in map(add10, [1, 2, 3, 4, 5])) {
          acc.add(a);
        }
        expect(acc, equals([11, 12, 13, 14, 15]));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe([
          1,
          2,
          3,
          4
        ], [
          (v) => map((a) => a, v),
          (v) => map((a) => '$a', v),
          (v) => map((a) => a, v),
          (v) => toArray(v),
        ]);

        expect(res, equals(['1', '2', '3', '4']));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx([1, 2, 3, 4])
            .map((a) => a)
            .map((a) => '$a')
            .map((a) => a)
            .toArray();

        expect(res, equals(['1', '2', '3', '4']));
      });
    });

    group('async', () {
      test('should be mapped by the callback', () async {
        final acc = <int>[];
        final it = mapAsync(add10, toAsync(range(1, 6))).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          acc.add(r.value);
        }
        expect(acc, equals([11, 12, 13, 14, 15]));
      });

      test('should be mapped by the async callback', () async {
        final res =
            await toArrayAsync(mapAsync(add10Async, toAsync(range(1, 6))));
        expect(res, equals([11, 12, 13, 14, 15]));
      });

      test('should be able to handle an error when asynchronous', () async {
        await expectLater(
          toArrayAsync(mapAsync<int, int>(
              (a) => throw Exception('err'), toAsync(range(1, 10)))),
          throwsException,
        );
      });

      test('should be able to handle an error when asynchronous Future.error',
          () async {
        await expectLater(
          toArrayAsync(mapAsync<int, int>(
              (a) => Future<int>.error(Exception('err')),
              toAsync(range(1, 10)))),
          throwsException,
        );
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(toAsync([1, 2, 3, 4]))
            .map((a) => Future.value(a))
            .map((a) => '$a')
            .map((a) => a)
            .toArray();

        expect(res, equals(['1', '2', '3', '4']));
      });

      test('should be able to be used as a future-producing function',
          () async {
        final res1 = map((a) async => a, [1, 2, 3, 4]);
        expect(await Future.wait(res1), equals([1, 2, 3, 4]));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res = await fxAsync(toAsync([1, 2, 3, 4]))
            .map((a) => Future.value(a))
            .map((a) => '$a')
            .toArray();

        expect(res, equals(['1', '2', '3', '4']));
      });
    });
  });
}
