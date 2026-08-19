// `filter` over a `zip`/`zip3` whose sides are all `List` ranges runs as a
// single iterator instead of two stages (see FxFilterFusable). The record it
// builds is unavoidable — the predicate is a closure, so the record escapes
// into the call — but the stage boundary is not, and over 1,000,000 elements
// that boundary was the whole gap to a hand-written loop.
//
// What is pinned here is behaviour the fusion could plausibly break: the
// elements and their order, the predicate's call count and order, the
// short-circuit at the shortest side, laziness, and the fallback whenever a
// side is not indexable.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  final xs = List<int>.generate(10, (i) => i);

  group('zip + filter fusion', () {
    test('matches the unfused layering', () {
      bool p((int, int) t) => t.$1.isEven;

      expect(
        filter(p, zip(xs, drop(3, xs))).toList(),
        zip(xs, drop(3, xs)).where(p).toList(),
      );
    });

    test('stops at the shorter side', () {
      final short = [100, 200];
      expect(filter((t) => true, zip(xs, short)).toList(), [
        (0, 100),
        (1, 200),
      ]);
      expect(filter((t) => true, zip(short, xs)).toList(), [
        (100, 0),
        (200, 1),
      ]);
    });

    test('runs the predicate once per pair, in order', () {
      final seen = <(int, int)>[];
      filter((t) {
        seen.add(t);
        return t.$1 > 7;
      }, zip(xs, xs)).toList();

      expect(seen.length, xs.length);
      expect(seen.first, (0, 0));
      expect(seen.last, (9, 9));
    });

    test('an empty side yields nothing and never tests', () {
      var calls = 0;
      final res = filter((t) {
        calls++;
        return true;
      }, zip(xs, <int>[])).toList();

      expect(res, <(int, int)>[]);
      expect(calls, 0);
    });

    test('stays lazy until iterated', () {
      var calls = 0;
      final chain = filter((t) {
        calls++;
        return true;
      }, zip(xs, xs));

      expect(calls, 0);
      expect(chain.first, (0, 0));
      expect(calls, 1, reason: 'first stops after the first survivor');
    });

    test('falls back when a side is not indexable', () {
      Iterable<int> gen() sync* {
        yield* xs;
      }

      bool p((int, int) t) => t.$1.isOdd;
      expect(filter(p, zip(gen(), xs)).toList(), zip(xs, xs).where(p).toList());
      expect(filter(p, zip(xs, gen())).toList(), zip(xs, xs).where(p).toList());
    });

    test('a re-iterated chain restarts', () {
      final chain = filter((t) => t.$1 < 3, zip(xs, xs));
      expect(chain.toList(), chain.toList());
      expect(chain.toList().length, 3);
    });
  });

  group('zip3 + filter fusion', () {
    test('matches the unfused layering over a sliding window', () {
      bool p((int, int, int) t) => t.$1 + t.$2 + t.$3 > 12;
      final a = filter(p, zip3(xs, drop(1, xs), drop(2, xs))).toList();
      final b = zip3(xs, drop(1, xs), drop(2, xs)).where(p).toList();

      expect(a, b);
      expect(a, isNotEmpty);
    });

    test('stops at the shortest side', () {
      expect(filter((t) => true, zip3(xs, [1, 2], xs)).toList(), [
        (0, 1, 0),
        (1, 2, 1),
      ]);
    });

    test('runs the predicate once per triple, in order', () {
      final seen = <(int, int, int)>[];
      filter((t) {
        seen.add(t);
        return false;
      }, zip3(xs, drop(1, xs), drop(2, xs))).toList();

      expect(seen.length, xs.length - 2);
      expect(seen.first, (0, 1, 2));
      expect(seen.last, (7, 8, 9));
    });

    test('falls back when any side is not indexable', () {
      Iterable<int> gen() sync* {
        yield* xs;
      }

      bool p((int, int, int) t) => t.$3.isEven;
      final want = zip3(xs, xs, xs).where(p).toList();
      expect(filter(p, zip3(gen(), xs, xs)).toList(), want);
      expect(filter(p, zip3(xs, gen(), xs)).toList(), want);
      expect(filter(p, zip3(xs, xs, gen())).toList(), want);
    });

    test('the chain form agrees with the layered form', () {
      final readings = List<int>.generate(50, (i) => (i * 37) % 100)
        // A planted over-50 run of three, so the filter has survivors.
        ..setRange(20, 23, [60, 70, 80]);
      final chain = fx(readings)
          .zip3(drop(1, readings), drop(2, readings))
          .filter((t) => t.$1 > 50 && t.$2 > 50 && t.$3 > 50)
          .map((t) => '${t.$1}-${t.$3}')
          .toList();
      final layered = zip3(readings, drop(1, readings), drop(2, readings))
          .where((t) => t.$1 > 50 && t.$2 > 50 && t.$3 > 50)
          .map((t) => '${t.$1}-${t.$3}')
          .toList();

      expect(chain, layered);
      expect(chain, isNotEmpty);
    });
  });
}
