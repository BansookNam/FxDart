import 'dart:math' as math;

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

num nearestRank(List<num> xs, double q) {
  final s = [...xs]..sort((a, b) => a.compareTo(b));
  return s[((s.length - 1) * q).round()];
}

void main() {
  group('fxQuantile', () {
    test('min, median, max', () {
      final xs = [7, 1, 5, 3, 9];
      expect(fxQuantile(0, xs), 1);
      expect(fxQuantile(0.5, xs), 5);
      expect(fxQuantile(1, xs), 9);
    });

    test('even length takes the upper middle', () {
      expect(fxQuantile(0.5, [4, 1, 3, 2]), 3);
    });

    test('empty is null; one element is itself', () {
      expect(fxQuantile(0.3, <num>[]), null);
      expect(fxQuantile(0.3, [42]), 42);
    });

    test('q outside [0, 1] or NaN throws', () {
      expect(() => fxQuantile(-0.1, [1]), throwsArgumentError);
      expect(() => fxQuantile(1.1, [1]), throwsArgumentError);
      expect(() => fxQuantile(double.nan, [1]), throwsArgumentError);
    });

    test('does not modify the input', () {
      final xs = [3, 1, 2];
      fxQuantile(0.5, xs);
      expect(xs, [3, 1, 2]);
    });

    test('agrees with sorting, across shapes and duplicates', () {
      final rnd = math.Random(7);
      for (var round = 0; round < 300; round++) {
        final n = 1 + rnd.nextInt(60);
        final shape = round % 4;
        final xs = <num>[
          for (var i = 0; i < n; i++)
            switch (shape) {
              0 => rnd.nextInt(5),
              1 => i,
              2 => n - i,
              _ => rnd.nextDouble() * 100,
            },
        ];
        for (final q in [0.0, 0.1, 0.25, 0.5, 0.9, 0.95, 1.0]) {
          expect(fxQuantile(q, xs), nearestRank(xs, q), reason: '$xs q=$q');
        }
      }
    });

    test('NaN orders last, like compareTo', () {
      expect(fxQuantile(1, [1.0, double.nan, 2.0])!.isNaN, isTrue);
      expect(fxQuantile(0.5, [double.nan, 1.0, 2.0]), 2.0);
    });

    test('chain and async', () async {
      expect(fx([5, 1, 3]).quantile(0.5), 3);
      expect(await fxAsync(fxToAsync([5, 1, 3])).quantile(1), 5);
      expect(await fxQuantileAsync(0.5, fxToAsync(<num>[])), null);
      expect(() => fxQuantileAsync(2, fxToAsync([1])), throwsArgumentError);
    });
  });
}
