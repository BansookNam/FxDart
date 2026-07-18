import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('toAsync', () {
    group('sync', () {
      test("should convert 'Iterable<A>' to 'FxAsyncIterable<A>'", () async {
        final asyncIter = toAsync([1, 2, 3, 4, 5]);

        var acc = 0;
        await eachAsync((int item) => acc += item, asyncIter);
        expect(acc, equals(15));
      });
    });

    group('async', () {
      test("should convert 'Iterable<Future<A>>' to 'FxAsyncIterable<A>'",
          () async {
        final asyncIter = toAsync([
          Future.value(1),
          Future.value(2),
          Future.value(3),
          Future.value(4),
          Future.value(5),
        ]);

        var acc = 0;
        await eachAsync((int item) => acc += item, asyncIter);
        expect(acc, equals(15));
      });

      test(
          "should be consumed 'FxAsyncIterable' as many times as called with 'next'",
          () async {
        final it = toAsync([
          Future.value(1),
          Future.value(2),
          Future.value(3),
          Future.value(4),
          Future.value(5),
        ]).iterator;

        expect((await it.next()).value, equals(1));
        expect((await it.next()).value, equals(2));
        expect((await it.next()).value, equals(3));
        expect((await it.next()).value, equals(4));
        expect((await it.next()).value, equals(5));
        expect((await it.next()).done, isTrue);
      });

      test('should be able to handle concurrently', () async {
        final it = toAsync(() sync* {
          for (var i = 1; i <= 5; i++) {
            yield delay(const Duration(milliseconds: 100), i);
          }
        }())
            .iterator;

        final sw = Stopwatch()..start();
        final results = await Future.wait(
            [it.next(), it.next(), it.next(), it.next(), it.next()]);
        expect(results.map((r) => r.value).toList(), equals([1, 2, 3, 4, 5]));
        // overlapping next() calls start overlapping futures: ~100ms, not ~500ms
        expect(sw.elapsedMilliseconds, lessThan(400));
      });
    });
  });
}
