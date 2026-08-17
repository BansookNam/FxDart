// The async operators have two pull paths: a fast one for upstreams that
// implement the internal FxFastIterator protocol, and a plain-Future one for
// upstreams that do not. Every source this library builds is fast, so the
// per-operator tests only ever exercise the first path. These tests drive the
// second by feeding the operators a hand-rolled iterator that implements only
// the public FxAsyncIterator protocol, and drive the Concurrent fallback that
// each operator installs when a concurrency marker arrives.
import 'package:fxdart/fxdart.dart';
import 'package:fxdart/src/async_iterable.dart'
    show DelegateAsyncIterable, DelegateAsyncIterator, FxFastIterator;
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

/// A source whose iterator is deliberately NOT an [FxFastIterator], so every
/// pull goes through the `Future`-returning branch of its consumer.
FxAsyncIterable<T> slow<T>(List<T> values) => DelegateAsyncIterable(() {
  var i = 0;
  return DelegateAsyncIterator((_) async {
    if (i >= values.length) return IterResult<T>.done();
    return IterResult<T>.value(values[i++]);
  });
});

void main() {
  test('slow() really is not a fast iterator', () {
    expect(slow([1]).iterator, isNot(isA<FxFastIterator<int>>()));
    expect(toAsync([1]).iterator, isA<FxFastIterator<int>>());
  });

  group('concatAsync over a non-fast upstream', () {
    test('drains both sides in order', () async {
      expect(
        await toListAsync(concatAsync(slow([1, 2]), slow([3, 4]))),
        equals([1, 2, 3, 4]),
      );
    });

    test('handles an empty left side', () async {
      expect(
        await toListAsync(concatAsync(slow(<int>[]), slow([3, 4]))),
        equals([3, 4]),
      );
    });

    test('handles an empty right side', () async {
      expect(
        await toListAsync(concatAsync(slow([1, 2]), slow(<int>[]))),
        equals([1, 2]),
      );
    });

    test('handles both sides empty', () async {
      expect(
        await toListAsync(concatAsync(slow(<int>[]), slow(<int>[]))),
        equals(<int>[]),
      );
    });

    test('mixes a fast left with a non-fast right', () async {
      expect(
        await toListAsync(concatAsync(toAsync([1, 2]), slow([3, 4]))),
        equals([1, 2, 3, 4]),
      );
    });

    test('mixes a non-fast left with a fast right', () async {
      expect(
        await toListAsync(concatAsync(slow([1, 2]), toAsync([3, 4]))),
        equals([1, 2, 3, 4]),
      );
    });

    test('composes with downstream operators', () async {
      final res = await toListAsync(
        mapAsync((int a) => a * 10, concatAsync(slow([1, 2]), slow([3]))),
      );
      expect(res, equals([10, 20, 30]));
    });
  });

  group('concatAsync Concurrent fallback', () {
    test('a concurrent pull switches to the legacy path and still '
        'yields every element in order', () async {
      final it = concatAsync(toAsync([1, 2]), toAsync([3, 4])).iterator;
      final got = <int>[];
      while (true) {
        final r = await it.next(Concurrent.of(2));
        if (r.done) break;
        got.add(r.value);
      }
      expect(got, equals([1, 2, 3, 4]));
    });

    test('a concurrent pull mid-stream keeps the remaining order', () async {
      final it = concatAsync(toAsync([1, 2, 3]), toAsync([4, 5])).iterator;
      final got = <int>[(await it.next()).value];
      while (true) {
        final r = await it.next(Concurrent.of(2));
        if (r.done) break;
        got.add(r.value);
      }
      expect(got, equals([1, 2, 3, 4, 5]));
    });

    test(
      'a serial nextOr after the fallback is installed reads through it',
      () async {
        // A concurrent pull installs the legacy fallback; a downstream serial
        // terminal then drives the same iterator with nextOr, which must route
        // through the fallback rather than the fused path it replaced.
        final it =
            concatAsync(toAsync([1, 2]), toAsync([3, 4])).iterator
                as FxFastIterator<int>;
        final got = <int>[(await it.next(Concurrent.of(2))).value];
        while (true) {
          final r = await it.nextOr();
          if (r.done) break;
          got.add(r.value);
        }
        expect(got, equals([1, 2, 3, 4]));
      },
    );
  });

  group('takeAsync over a non-fast upstream', () {
    test('takes fewer than available', () async {
      expect(
        await toListAsync(takeAsync(2, slow([1, 2, 3, 4]))),
        equals([1, 2]),
      );
    });

    test('takes exactly what is available', () async {
      expect(
        await toListAsync(takeAsync(3, slow([1, 2, 3]))),
        equals([1, 2, 3]),
      );
    });

    test('stops cleanly when the source runs out early', () async {
      expect(await toListAsync(takeAsync(10, slow([1, 2]))), equals([1, 2]));
    });

    test('take(0) pulls nothing', () async {
      expect(await toListAsync(takeAsync(0, slow([1, 2]))), equals(<int>[]));
    });

    test('an exhausted source stays done on repeated pulls', () async {
      final it = takeAsync(5, slow([1])).iterator;
      expect((await it.next()).value, equals(1));
      expect((await it.next()).done, isTrue);
      expect((await it.next()).done, isTrue);
    });
  });

  group('flatMapAsync over a non-fast upstream', () {
    // The fused iterator pulls its source with `nextOr()` when the source is
    // an FxFastIterator and with `next()` otherwise. Every source the library
    // builds is fast, so only a hand-rolled upstream reaches the second call.
    test('flattens each element in order', () async {
      expect(
        await toListAsync(flatMapAsync((int a) => [a, a * 10], slow([1, 2]))),
        equals([1, 10, 2, 20]),
      );
    });

    test('an empty inner iterable pulls the next source element', () async {
      expect(
        await toListAsync(
          flatMapAsync(
            (int a) => a.isEven ? <int>[] : [a],
            slow([1, 2, 3, 4, 5]),
          ),
        ),
        equals([1, 3, 5]),
      );
    });

    test('an empty source yields nothing', () async {
      expect(
        await toListAsync(flatMapAsync((int a) => [a], slow(<int>[]))),
        equals(<int>[]),
      );
    });

    test('an async callback is awaited', () async {
      expect(
        await toListAsync(flatMapAsync((int a) async => [a, -a], slow([1, 2]))),
        equals([1, -1, 2, -2]),
      );
    });

    test('an exhausted source stays done on repeated pulls', () async {
      final it = flatMapAsync((int a) => [a], slow([1])).iterator;
      expect((await it.next()).value, equals(1));
      expect((await it.next()).done, isTrue);
      expect((await it.next()).done, isTrue);
    });

    test('composes with downstream operators', () async {
      expect(
        await toListAsync(
          takeAsync(3, flatMapAsync((int a) => [a, a * 10], slow([1, 2, 3]))),
        ),
        equals([1, 10, 2]),
      );
    });

    test('matches the fast path element for element', () async {
      Iterable<int> f(int a) => [a, a + 100];
      expect(
        await toListAsync(flatMapAsync(f, slow([1, 2, 3]))),
        equals(await toListAsync(flatMapAsync(f, toAsync([1, 2, 3])))),
      );
    });
  });

  group('flatMapAsync Concurrent fallback', () {
    test('a concurrent pull switches to the legacy path and still '
        'yields every element in order', () async {
      final it = flatMapAsync((int a) => [a, a * 10], toAsync([1, 2])).iterator;
      final got = <int>[];
      while (true) {
        final r = await it.next(Concurrent.of(2));
        if (r.done) break;
        got.add(r.value);
      }
      expect(got, equals([1, 10, 2, 20]));
    });
  });

  group('takeAsync Concurrent fallback', () {
    test('a concurrent pull switches to the legacy path and still '
        'respects the limit', () async {
      final it = takeAsync(3, toAsync([1, 2, 3, 4, 5])).iterator;
      final got = <int>[];
      while (true) {
        final r = await it.next(Concurrent.of(2));
        if (r.done) break;
        got.add(r.value);
      }
      expect(got, equals([1, 2, 3]));
    });

    test('a concurrent pull after a serial one keeps the limit', () async {
      final it = takeAsync(3, toAsync([1, 2, 3, 4, 5])).iterator;
      final got = <int>[(await it.next()).value];
      while (true) {
        final r = await it.next(Concurrent.of(2));
        if (r.done) break;
        got.add(r.value);
      }
      expect(got, equals([1, 2, 3]));
    });

    test(
      'a serial nextOr after the fallback is installed reads through it',
      () async {
        final it =
            takeAsync(3, toAsync([1, 2, 3, 4, 5])).iterator
                as FxFastIterator<int>;
        final got = <int>[(await it.next(Concurrent.of(2))).value];
        while (true) {
          final r = await it.nextOr();
          if (r.done) break;
          got.add(r.value);
        }
        expect(got, equals([1, 2, 3]));
      },
    );
  });
}
