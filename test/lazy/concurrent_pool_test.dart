import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('concurrentPool', () {
    test("should be consumed 'FxAsyncIterable' (concurrency 1)", () async {
      final res = concurrentPoolAsync(1, toAsync(() sync* {
        for (var i = 1; i <= 3; i++) {
          yield delay(const Duration(milliseconds: 100), i);
        }
      }()));

      final acc = await toListAsync(res);
      expect(acc, equals([1, 2, 3]));
    });

    test('should yield results in completion order', () async {
      final delays = [200, 50, 100];
      final it = concurrentPoolAsync(3, toAsync(() sync* {
        for (var i = 0; i < 3; i++) {
          yield delay(Duration(milliseconds: delays[i]), i + 1);
        }
      }()))
          .iterator;

      final results = await Future.wait([it.next(), it.next(), it.next()]);
      expect(results.map((r) => r.value).toList(), equals([2, 3, 1]));
    });

    test("should be consumed 'FxAsyncIterable' concurrently (concurrency 2)",
        () async {
      final delays = [50, 200, 100, 200, 100, 50];
      final it = concurrentPoolAsync(2, toAsync(() sync* {
        for (var i = 0; i < 6; i++) {
          yield delay(Duration(milliseconds: delays[i]), i + 1);
        }
      }()))
          .iterator;

      final sw = Stopwatch()..start();
      final results = await Future.wait(List.generate(6, (_) => it.next()));
      final acc = results.map((r) => r.value).toList()..sort();
      expect(acc, equals([1, 2, 3, 4, 5, 6]));
      // sequential is ~700ms; pool of 2 is ~400ms
      expect(sw.elapsedMilliseconds, lessThan(650));
    });

    test('should be able to be used as a chaining method in the `fx`',
        () async {
      final delays = [50, 150, 50, 150];
      final it = fxAsync(toAsync(() sync* {
        for (var i = 0; i < 4; i++) {
          yield delay(Duration(milliseconds: delays[i]), i + 1);
        }
      }()))
          .concurrentPool(2)
          .iterator;

      final results =
          await Future.wait([it.next(), it.next(), it.next(), it.next()]);
      // completion order: 1 (@50), 3 (@100), 2 (@150), 4 (@250)
      expect(results.map((r) => r.value).toList(), equals([1, 3, 2, 4]));
    });

    test('should be able to handle an error when working concurrentPool',
        () async {
      final it = concurrentPoolAsync(2, toAsync(() sync* {
        yield delay(const Duration(milliseconds: 50), 1);
        yield delay(const Duration(milliseconds: 200), 2);
        yield delay(const Duration(milliseconds: 50), 3);
        yield Future<int>.error(StateError('err'));
        yield delay(const Duration(milliseconds: 50), 4);
        yield delay(const Duration(milliseconds: 200), 5);
      }()))
          .iterator;

      final acc = <int>[];
      Object? caught;
      try {
        while (true) {
          final r = await it.next();
          if (r.done) break;
          acc.add(r.value);
        }
      } catch (e) {
        caught = e;
      }
      // Eager pool of 2: 1 (@50) and 3 (@100) complete before the error
      // future (started @100, fails immediately); 2 (@200) is still in
      // flight when the error surfaces — completion order.
      expect(caught, isA<StateError>());
      expect(acc, equals([1, 3]));
    });

    test('eagerly overlaps work even with a one-pull-at-a-time consumer',
        () async {
      // toList awaits each pull before the next; the pool must still keep
      // itself full so total time is ~ceil(6/3)*100ms, not 6*100ms.
      final sw = Stopwatch()..start();
      final acc = await toListAsync(concurrentPoolAsync(3, toAsync(() sync* {
        for (var i = 1; i <= 6; i++) {
          yield delay(const Duration(milliseconds: 100), i);
        }
      }())));
      expect(acc..sort(), equals([1, 2, 3, 4, 5, 6]));
      expect(sw.elapsedMilliseconds, lessThan(450));
    });
  });
}
