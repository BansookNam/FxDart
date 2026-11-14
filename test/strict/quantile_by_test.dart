import 'dart:math' as math;

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('fxQuantileBy', () {
    test('returns the element at the key quantile', () {
      final ps = [(n: 'a', p: 30), (n: 'b', p: 10), (n: 'c', p: 20)];
      expect(fxQuantileBy(0.5, (({String n, int p}) x) => x.p, ps)!.n, 'c');
      expect(fxQuantileBy(0, (({String n, int p}) x) => x.p, ps)!.n, 'b');
      expect(fxQuantileBy(1, (({String n, int p}) x) => x.p, ps)!.n, 'a');
    });

    test('f runs once per element', () {
      var calls = 0;
      fxQuantileBy(0.5, (int x) {
        calls++;
        return x;
      }, fxRange(50));
      expect(calls, 50);
    });

    test('key agrees with sorting', () {
      final rnd = math.Random(3);
      for (var round = 0; round < 200; round++) {
        final xs = [
          for (var i = 0; i < 1 + rnd.nextInt(40); i++) rnd.nextInt(10),
        ];
        final sorted = [...xs]..sort();
        for (final q in [0.0, 0.5, 0.75, 1.0]) {
          expect(
            fxQuantileBy(q, (int x) => x, xs),
            sorted[((sorted.length - 1) * q).round()],
          );
        }
      }
    });

    test('empty, bad q, chain, async', () async {
      expect(fxQuantileBy(0.5, (int x) => x, <int>[]), null);
      expect(() => fxQuantileBy(3, (int x) => x, [1]), throwsArgumentError);
      expect(fx(['aaa', 'b', 'cc']).quantileBy(0.5, (s) => s.length), 'cc');
      expect(
        await fxAsync(
          fxToAsync(['aaa', 'b']),
        ).quantileBy(0, (s) async => s.length),
        'b',
      );
      expect(
        await fxQuantileByAsync(0.5, (int x) => x, fxToAsync(<int>[])),
        null,
      );
    });
  });
}
