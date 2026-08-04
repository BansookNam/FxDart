import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// A source that counts how many times it is iterated, so "one pass" is a
/// property the tests can assert rather than assume.
class _CountingSource {
  int runs = 0;
  Iterable<int> call(List<int> values) sync* {
    runs++;
    yield* values;
  }
}

void main() {
  group('tee', () {
    test('runs both folds over a single pass of the source', () {
      final src = _CountingSource();
      final (total, peak) = tee(
          src([12, 7, 25, 3, 18, 9]),
          (seed: 0, step: (int a, int r) => a + r),
          (seed: 0, step: (int a, int r) => r > a ? r : a));

      expect(total, 74);
      expect(peak, 25);
      expect(src.runs, 1, reason: 'the source must be iterated exactly once');
    });

    test('agrees with the same folds run separately', () {
      const values = [5, 1, 9, 4];
      final (sum, max) = tee(
          values,
          (seed: 0, step: (int a, int r) => a + r),
          (seed: 0, step: (int a, int r) => r > a ? r : a));

      expect(sum, fold(0, (int a, int r) => a + r, values));
      expect(max, values.reduce((a, b) => a > b ? a : b));
    });

    test('returns the seeds untouched for an empty source', () {
      final (a, b) = tee(
          const <int>[],
          (seed: 5, step: (int acc, int x) => acc + x),
          (seed: 'z', step: (String acc, int x) => '$acc$x'));

      expect(a, 5);
      expect(b, 'z');
    });

    test('carries independent, differently typed accumulators', () {
      final (chars, seen) = tee(
          ['a', 'bb', 'ccc'],
          (seed: 0, step: (int acc, String x) => acc + x.length),
          (seed: <String>[], step: (List<String> acc, String x) => acc..add(x)));

      expect(chars, 6);
      expect(seen, ['a', 'bb', 'ccc']);
    });

    test('steps see every element in order', () {
      final left = <int>[];
      final right = <int>[];
      tee(
          [3, 1, 2],
          (seed: 0, step: (int a, int x) => (left..add(x)).length),
          (seed: 0, step: (int a, int x) => (right..add(x)).length));

      expect(left, [3, 1, 2]);
      expect(right, [3, 1, 2]);
    });

    test('a throwing step propagates', () {
      expect(
          () => tee(
              [1, 2],
              (seed: 0, step: (int a, int x) => a + x),
              (seed: 0, step: (int a, int x) => throw StateError('step'))),
          throwsStateError);
    });
  });

  group('tee3', () {
    test('runs three folds over a single pass', () {
      final src = _CountingSource();
      final (sum, max, count) = tee3(
          src([12, 7, 25]),
          (seed: 0, step: (int a, int r) => a + r),
          (seed: 0, step: (int a, int r) => r > a ? r : a),
          (seed: 0, step: (int a, int _) => a + 1));

      expect(sum, 44);
      expect(max, 25);
      expect(count, 3);
      expect(src.runs, 1);
    });

    test('returns the seeds untouched for an empty source', () {
      final (a, b, c) = tee3(
          const <int>[],
          (seed: 1, step: (int acc, int x) => acc + x),
          (seed: 2, step: (int acc, int x) => acc + x),
          (seed: 3, step: (int acc, int x) => acc + x));

      expect((a, b, c), (1, 2, 3));
    });
  });

  group('Fx chain', () {
    test('tee folds the chain in one pass', () {
      final (sum, product) = fx([1, 2, 3, 4]).tee(
          (seed: 0, step: (int acc, int x) => acc + x),
          (seed: 1, step: (int acc, int x) => acc * x));

      expect(sum, 10);
      expect(product, 24);
    });

    test('tee sees the chain output, not the source', () {
      final (sum, count) = fx([1, 2, 3, 4, 5])
          .filter((a) => a.isOdd)
          .map((a) => a * 10)
          .tee((seed: 0, step: (int acc, int x) => acc + x),
              (seed: 0, step: (int acc, int _) => acc + 1));

      expect(sum, 90);
      expect(count, 3);
    });

    test('tee3 folds the chain in one pass', () {
      final (sum, max, count) = fx([4, 8, 2]).tee3(
          (seed: 0, step: (int a, int x) => a + x),
          (seed: 0, step: (int a, int x) => x > a ? x : a),
          (seed: 0, step: (int a, int _) => a + 1));

      expect((sum, max, count), (14, 8, 3));
    });
  });

  group('teeAsync', () {
    test('folds an async chain in one pass', () async {
      final (sum, max) = await fxAsync(toAsync([3, 9, 4])).tee(
          (seed: 0, step: (int acc, int x) => acc + x),
          (seed: 0, step: (int acc, int x) => x > acc ? x : acc));

      expect(sum, 16);
      expect(max, 9);
    });

    test('awaits asynchronous steps on both sides', () async {
      final (sum, max) = await fxAsync(toAsync([3, 9, 4])).tee(
          (seed: 0, step: (int acc, int x) async => acc + x),
          (seed: 0, step: (int acc, int x) async => x > acc ? x : acc));

      expect(sum, 16);
      expect(max, 9);
    });

    test('mixes a synchronous step with an asynchronous one', () async {
      final (sum, max) = await fxAsync(toAsync([3, 9, 4])).tee(
          (seed: 0, step: (int acc, int x) => acc + x),
          (seed: 0, step: (int acc, int x) async => x > acc ? x : acc));

      expect(sum, 16);
      expect(max, 9);

      final (sum2, max2) = await fxAsync(toAsync([3, 9, 4])).tee(
          (seed: 0, step: (int acc, int x) async => acc + x),
          (seed: 0, step: (int acc, int x) => x > acc ? x : acc));

      expect(sum2, 16);
      expect(max2, 9);
    });

    test('accepts Future seeds', () async {
      final (a, b) = await fxAsync(toAsync([1, 2])).tee(
          (seed: Future.value(10), step: (int acc, int x) => acc + x),
          (seed: 0, step: (int acc, int x) => acc + x * 2));

      expect(a, 13);
      expect(b, 6);
    });

    test('returns the seeds untouched for an empty source', () async {
      final (a, b) = await fxAsync(toAsync(<int>[])).tee(
          (seed: 7, step: (int acc, int x) => acc + x),
          (seed: 8, step: (int acc, int x) => acc + x));

      expect((a, b), (7, 8));
    });

    test('steps see every element in order', () async {
      final left = <int>[];
      final right = <int>[];
      await fxAsync(toAsync([3, 1, 2])).tee(
          (seed: 0, step: (int a, int x) async => (left..add(x)).length),
          (seed: 0, step: (int a, int x) => (right..add(x)).length));

      expect(left, [3, 1, 2]);
      expect(right, [3, 1, 2]);
    });

    test('a throwing step propagates', () {
      expect(
          fxAsync(toAsync([1, 2])).tee(
              (seed: 0, step: (int a, int x) => a + x),
              (seed: 0, step: (int a, int x) async => throw StateError('step'))),
          throwsStateError);
    });
  });
}
