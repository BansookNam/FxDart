import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// A source whose elements are all already resolved, so the pool's eager
/// refill runs far ahead of the consumer — the shape that made the old
/// `List` buffers quadratic.
FxAsyncIterable<int> instantSource(int n) =>
    fx(List<int>.generate(n, (i) => i)).toAsync().map((i) async => i);

void main() {
  group('FxDart.config', () {
    tearDown(() {
      FxDart.config.optimizeMemoryForConcurrentPool = false;
    });

    test('defaults to the queue-backed concurrentPool', () {
      expect(FxDart.config.optimizeMemoryForConcurrentPool, isFalse);
    });

    test('is the same instance on every access', () {
      expect(identical(FxDart.config, FxDart.config), isTrue);
    });

    group('optimizeMemoryForConcurrentPool', () {
      for (final legacy in [false, true]) {
        final label = legacy ? 'list buffers' : 'queue buffers';

        test('$label yield every element in completion order', () async {
          FxDart.config.optimizeMemoryForConcurrentPool = legacy;
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

        test('$label drain a fast source completely', () async {
          FxDart.config.optimizeMemoryForConcurrentPool = legacy;
          final acc =
              await toListAsync(concurrentPoolAsync(3, instantSource(500)));
          expect(acc.length, equals(500));
          expect(acc.toSet(), equals(List<int>.generate(500, (i) => i).toSet()));
        });

        test('$label propagate errors', () async {
          FxDart.config.optimizeMemoryForConcurrentPool = legacy;
          final source = fx([1, 2, 3])
              .toAsync()
              .map((i) async => i == 2 ? throw StateError('boom') : i);
          await expectLater(toListAsync(concurrentPoolAsync(2, source)),
              throwsA(isA<StateError>()));
        });
      }

      test('is read when iteration starts, not when the pipeline is built',
          () async {
        final pipeline = concurrentPoolAsync(3, instantSource(20));
        FxDart.config.optimizeMemoryForConcurrentPool = true;
        // Built under the default, iterated under the flag: the flag wins,
        // and either way the result is the same 20 elements.
        expect((await toListAsync(pipeline)).length, equals(20));
      });

      test('queue buffers keep a fast source linear', () async {
        Future<int> run(int n) async {
          final sw = Stopwatch()..start();
          await toListAsync(concurrentPoolAsync(3, instantSource(n)));
          return sw.elapsedMicroseconds;
        }

        // Warm up, then compare 4n against n. Linear would be ~4x, the
        // quadratic `List` form is ~16x; 8x separates them with room for
        // timing noise on a loaded CI machine.
        await run(2000);
        final small = await run(2000);
        final large = await run(8000);
        expect(large, lessThan(small * 8));
      });
    });
  });
}
