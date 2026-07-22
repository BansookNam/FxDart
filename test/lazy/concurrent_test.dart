import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('concurrent', () {
    test("should be consumed 'FxAsyncIterable' concurrently", () async {
      final res = concurrentAsync(2, toAsync(() sync* {
        for (var i = 1; i <= 4; i++) {
          yield delay(const Duration(milliseconds: 150), i);
        }
      }()));

      final sw = Stopwatch()..start();
      final acc = await toListAsync(res);
      expect(acc, equals([1, 2, 3, 4]));
      // sequential is ~600ms; concurrent(2) is ~300ms
      expect(sw.elapsedMilliseconds, lessThan(500));
    });

    test('should be able to be used in the pipeline', () async {
      final it = concurrentAsync(
              2,
              mapAsync((int a) => delay(const Duration(milliseconds: 100), a),
                  toAsync(range(1, 101))))
          .iterator;

      final sw = Stopwatch()..start();
      final arr = await Future.wait(List.generate(10, (_) => it.next()))
          .then((results) => results.map((r) => r.value).toList());

      expect(arr, equals([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]));
      // sequential is ~1000ms; concurrent(2) is ~500ms
      expect(sw.elapsedMilliseconds, lessThan(900));
    });

    test('should be able to be used as a chaining method in the `fx`',
        () async {
      final sw = Stopwatch()..start();
      final arr = await fx(range(1, 11))
          .toAsync()
          .map((a) => delay(const Duration(milliseconds: 100), a))
          .concurrent(2)
          .toList();
      expect(arr, equals([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]));
      // sequential is ~1000ms; concurrent(2) is ~500ms
      expect(sw.elapsedMilliseconds, lessThan(900));
    });

    test(
        "should return a done result after consuming all of the 'FxAsyncIterable'",
        () async {
      final it = concurrentAsync(2, toAsync(() sync* {
        yield delay(const Duration(milliseconds: 100), 1);
        yield delay(const Duration(milliseconds: 100), 2);
      }()))
          .iterator;

      final results =
          await Future.wait([it.next(), it.next(), it.next(), it.next()]);

      expect(results[0].done, isFalse);
      expect(results[0].value, equals(1));
      expect(results[1].done, isFalse);
      expect(results[1].value, equals(2));
      expect(results[2].done, isTrue);
      expect(results[3].done, isTrue);
    });

    test('should be able to handle an error when working concurrent', () async {
      final it = concurrentAsync(2, toAsync(() sync* {
        yield delay(const Duration(milliseconds: 100), 1);
        yield delay(const Duration(milliseconds: 100), 2);
        yield delay(const Duration(milliseconds: 100), 3);
        yield Future<int>.error(StateError('err'));
        yield delay(const Duration(milliseconds: 100), 4);
        yield delay(const Duration(milliseconds: 100), 5);
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
      expect(caught, isA<StateError>());
      expect(acc, equals([1, 2, 3]));
    });
  });
}
