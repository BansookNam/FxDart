import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('scan', () {
    group('sync', () {
      test('should return value that is reduced given elements successively',
          () {
        expect(toList(scan((int a, int b) => a * b, 1, [1, 2, 3, 4])),
            equals([1, 1, 2, 6, 24]));
        expect(toList(scan((String a, String b) => a + b, 'a', ['b', 'c'])),
            equals(['a', 'ab', 'abc']));
      });

      test('should reduce given elements successively without seed', () {
        expect(toList(scan1((int a, int b) => a * b, [1, 2, 3, 4])),
            equals([1, 2, 6, 24]));
        expect(toList(scan1((String a, String b) => a + b, ['a', 'b', 'c'])),
            equals(['a', 'ab', 'abc']));
      });

      test('should be able to be used in the pipeline', () {
        final res = toList(scan1((int a, int b) => a * b, [1, 2, 3, 4]));
        expect(res, equals([1, 2, 6, 24]));
      });
    });

    group('async', () {
      test('should return value that is reduced given elements successively',
          () async {
        expect(
            await toListAsync(
                scanAsync((int a, int b) => a * b, 1, toAsync([1, 2, 3, 4]))),
            equals([1, 1, 2, 6, 24]));
        expect(
            await toListAsync(scanAsync(
                (String a, String b) => a + b, 'a', toAsync(['b', 'c']))),
            equals(['a', 'ab', 'abc']));
      });

      test('should reduce given elements successively when seed is a Future',
          () async {
        expect(
            await toListAsync(scanAsync((int a, int b) => a * b,
                Future.value(1), toAsync([1, 2, 3, 4]))),
            equals([1, 1, 2, 6, 24]));
        expect(
            await toListAsync(scanAsync((String a, String b) => a + b,
                Future.value('a'), toAsync(['b', 'c']))),
            equals(['a', 'ab', 'abc']));
      });

      test('should reduce given elements successively without seed', () async {
        expect(
            await toListAsync(
                scan1Async((int a, int b) => a * b, toAsync([1, 2, 3, 4]))),
            equals([1, 2, 6, 24]));
        expect(
            await toListAsync(scan1Async(
                (String a, String b) => a + b, toAsync(['a', 'b', 'c']))),
            equals(['a', 'ab', 'abc']));
      });

      test('should be passed concurrent object when job works concurrently',
          () async {
        final mock = ConcurrentMock<int>();
        final it = scan1Async((int a, int b) => a, mock).iterator;
        await it.next(Concurrent.of(2));
        expect(mock.received?.length, equals(2));
      });

      test('should be handled concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await toListAsync(concurrentAsync(
            3,
            scanAsync(
                (int a, int b) => a * b,
                1,
                mapAsync((int a) => delay(const Duration(milliseconds: 100), a),
                    toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9])))));

        expect(res, equals([1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880]));
        // sequential is ~900ms; concurrent(3) is ~300ms
        expect(sw.elapsedMilliseconds, lessThan(700));
      });

      test('should be able to handle an error when working concurrent',
          () async {
        final future = toListAsync(concurrentAsync(
            2,
            scan1Async((int a, int b) {
              if (a * b == 24) {
                throw StateError('err');
              }
              return a * b;
            },
                mapAsync((int a) => delay(const Duration(milliseconds: 20), a),
                    toAsync(range(1, 21))))));
        await expectLater(future, throwsStateError);
      });
    });
  });
}
