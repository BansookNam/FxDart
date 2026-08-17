import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// A function that fails [failures] times before succeeding, counting calls.
class Flaky {
  Flaky(this.failures);
  final int failures;
  int calls = 0;

  Future<String> call() async {
    calls++;
    if (calls <= failures) throw StateError('boom $calls');
    return 'ok';
  }
}

void main() {
  group('retry', () {
    test('should return the first success without retrying', () async {
      final flaky = Flaky(0);
      expect(await retry(3, flaky.call), equals('ok'));
      expect(flaky.calls, equals(1));
    });

    test('should retry until success within the budget', () async {
      final flaky = Flaky(2);
      expect(await retry(3, flaky.call), equals('ok'));
      expect(flaky.calls, equals(3));
    });

    test('should rethrow the last error when attempts run out', () async {
      final flaky = Flaky(5);
      await expectLater(
        retry(3, flaky.call),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'boom 3'),
        ),
      );
      expect(flaky.calls, equals(3));
    });

    test('should call delay with the failure count between runs', () async {
      final delays = <int>[];
      final flaky = Flaky(2);
      await retry(
        3,
        flaky.call,
        delay: (failed) {
          delays.add(failed);
          return Duration.zero;
        },
      );
      expect(delays, equals([1, 2]));
    });

    test('should actually wait for the requested backoff', () async {
      final sw = Stopwatch()..start();
      final flaky = Flaky(2);
      await retry(
        3,
        flaky.call,
        delay: (failed) => const Duration(milliseconds: 50),
      );
      sw.stop();
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(90));
    });

    test('should support synchronous callbacks and errors', () async {
      var calls = 0;
      expect(
        await retry(2, () {
          calls++;
          if (calls == 1) throw Exception('sync boom');
          return 42;
        }),
        equals(42),
      );
      expect(calls, equals(2));
    });

    test('should reject a non-positive attempt count', () {
      expect(() => retry(0, () => 1), throwsArgumentError);
    });
  });

  group('mapRetry', () {
    test('should retry only the failing elements, in order', () async {
      final callCounts = <int, int>{};
      final res = await toListAsync(
        mapRetryAsync(3, (int a) async {
          final calls = (callCounts[a] ?? 0) + 1;
          callCounts[a] = calls;
          // 3 fails twice before succeeding; everything else succeeds at once.
          if (a == 3 && calls <= 2) throw StateError('flaky');
          return a * 10;
        }, toAsync([1, 2, 3, 4])),
      );

      expect(res, equals([10, 20, 30, 40]));
      expect(callCounts, equals({1: 1, 2: 1, 3: 3, 4: 1}));
    });

    test('should propagate the error once attempts run out', () async {
      var calls = 0;
      await expectLater(
        toListAsync(
          mapRetryAsync(2, (int a) async {
            if (a == 2) {
              calls++;
              throw StateError('always fails');
            }
            return a;
          }, toAsync([1, 2, 3])),
        ),
        throwsStateError,
      );
      expect(calls, equals(2));
    });

    test('should reject a non-positive attempt count', () {
      expect(
        () => mapRetryAsync(0, (int a) => a, toAsync([1])),
        throwsArgumentError,
      );
    });

    test('should retry independently under concurrent', () async {
      final callCounts = <int, int>{};
      final res = await fxAsync(toAsync(range(1, 7)))
          .mapRetry(3, (a) async {
            final calls = (callCounts[a] ?? 0) + 1;
            callCounts[a] = calls;
            await delay(const Duration(milliseconds: 20), null);
            if (a.isEven && calls == 1) throw StateError('flaky');
            return a;
          })
          .concurrent(3)
          .toList();

      expect(res, equals([1, 2, 3, 4, 5, 6]));
      expect(callCounts[2], equals(2));
      expect(callCounts[4], equals(2));
      expect(callCounts[1], equals(1));
    });

    test(
      'should be able to be used as a chaining method in the `fx`',
      () async {
        var failedOnce = false;
        final res = await fx([1, 2, 3]).mapRetry(2, (a) async {
          if (a == 2 && !failedOnce) {
            failedOnce = true;
            throw Exception('flaky');
          }
          return a * 2;
        }).toList();
        expect(res, equals([2, 4, 6]));
      },
    );
  });
}
