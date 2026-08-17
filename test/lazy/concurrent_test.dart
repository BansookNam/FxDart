import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('concurrent(1)', () {
    // A concurrency of one takes a dedicated forwarding path that skips the
    // ordered-batch machinery entirely; these pin that it behaves exactly
    // like the general path did.
    test('yields every element, in order', () async {
      final res = concurrentAsync(1, toAsync([1, 2, 3, 4]));
      expect(await toListAsync(res), equals([1, 2, 3, 4]));
    });

    test('runs serially — one in flight at a time', () async {
      var inFlight = 0;
      var maxInFlight = 0;
      final res = fx([1, 2, 3, 4])
          .toAsync()
          .map((a) async {
            inFlight++;
            maxInFlight = maxInFlight > inFlight ? maxInFlight : inFlight;
            await delay(const Duration(milliseconds: 20), a);
            inFlight--;
            return a;
          })
          .concurrent(1);

      expect(await res.toList(), equals([1, 2, 3, 4]));
      expect(maxInFlight, equals(1));
    });

    test('propagates an error from upstream', () async {
      final res = concurrentAsync(
        1,
        toAsync(() sync* {
          yield Future.value(1);
          yield Future<int>.error(StateError('boom'));
        }()),
      );
      expect(toListAsync(res), throwsStateError);
    });

    test('an empty source completes empty', () async {
      expect(
        await toListAsync(concurrentAsync(1, toAsync(<int>[]))),
        equals(<int>[]),
      );
    });

    test('a downstream take still cuts the source short', () async {
      var pulled = 0;
      final res = fx([
        1,
        2,
        3,
        4,
        5,
      ]).toAsync().peek((_) => pulled++).concurrent(1).take(2);
      expect(await res.toList(), equals([1, 2]));
      expect(pulled, lessThan(5));
    });
  });

  group('concurrent', () {
    test("should be consumed 'FxAsyncIterable' concurrently", () async {
      final res = concurrentAsync(
        2,
        toAsync(() sync* {
          for (var i = 1; i <= 4; i++) {
            yield delay(const Duration(milliseconds: 150), i);
          }
        }()),
      );

      final sw = Stopwatch()..start();
      final acc = await toListAsync(res);
      expect(acc, equals([1, 2, 3, 4]));
      // sequential is ~600ms; concurrent(2) is ~300ms
      expect(sw.elapsedMilliseconds, lessThan(500));
    });

    test('should be able to be used in the pipeline', () async {
      final it = concurrentAsync(
        2,
        mapAsync(
          (int a) => delay(const Duration(milliseconds: 100), a),
          toAsync(range(1, 101)),
        ),
      ).iterator;

      final sw = Stopwatch()..start();
      final arr = await Future.wait(
        List.generate(10, (_) => it.next()),
      ).then((results) => results.map((r) => r.value).toList());

      expect(arr, equals([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]));
      // sequential is ~1000ms; concurrent(2) is ~500ms
      expect(sw.elapsedMilliseconds, lessThan(900));
    });

    test(
      'should be able to be used as a chaining method in the `fx`',
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
      },
    );

    test(
      "should return a done result after consuming all of the 'FxAsyncIterable'",
      () async {
        final it = concurrentAsync(
          2,
          toAsync(() sync* {
            yield delay(const Duration(milliseconds: 100), 1);
            yield delay(const Duration(milliseconds: 100), 2);
          }()),
        ).iterator;

        final results = await Future.wait([
          it.next(),
          it.next(),
          it.next(),
          it.next(),
        ]);

        expect(results[0].done, isFalse);
        expect(results[0].value, equals(1));
        expect(results[1].done, isFalse);
        expect(results[1].value, equals(2));
        expect(results[2].done, isTrue);
        expect(results[3].done, isTrue);
      },
    );

    test('should be able to handle an error when working concurrent', () async {
      final it = concurrentAsync(
        2,
        toAsync(() sync* {
          yield delay(const Duration(milliseconds: 100), 1);
          yield delay(const Duration(milliseconds: 100), 2);
          yield delay(const Duration(milliseconds: 100), 3);
          yield Future<int>.error(StateError('err'));
          yield delay(const Duration(milliseconds: 100), 4);
          yield delay(const Duration(milliseconds: 100), 5);
        }()),
      ).iterator;

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
