import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// The five-point accumulation contract from PLAN v0.6 §4.3, copied from
/// Arrow's RaiseAccumulate.
void main() {
  group('accumulate', () {
    test('all branches run; errors concatenate in branch order', () {
      final ran = <String>[];
      final result = either<Nel<String>, int>((r) => r.accumulate((acc) {
            final a = acc.accumulating<int>((r) {
              ran.add('a');
              return r.raise('err-a');
            });
            final b = acc.accumulating<int>((r) {
              ran.add('b');
              return 2;
            });
            final c = acc.accumulating<int>((r) {
              ran.add('c');
              return r.raise('err-c');
            });
            return a.value + b.value + c.value;
          }));
      expect(ran, ['a', 'b', 'c']);
      expect(result.leftOrNull()!.toList(), ['err-a', 'err-c']);
    });

    test('all branches succeed → combined value', () {
      final result = either<Nel<String>, int>((r) => r.accumulate((acc) {
            final a = acc.accumulating((r) => 1);
            final b = acc.accumulating((r) => 2);
            return a.value + b.value;
          }));
      expect(result, Right(3));
    });

    test('reading an errored AccValue detonates with the FULL accumulated '
        'list (lazy detonation)', () {
      final result = either<Nel<String>, int>((r) => r.accumulate((acc) {
            final a = acc.accumulating<int>((r) => r.raise('one'));
            acc.accumulating<int>((r) => r.raise('two'));
            // Detonation happens here, after both branches recorded errors.
            return a.value;
          }));
      expect(result.leftOrNull()!.toList(), ['one', 'two']);
    });

    test('END-OF-BLOCK contract: errors raise even when no .value is ever '
        'read', () {
      final result = either<Nel<String>, int>((r) => r.accumulate((acc) {
            acc.accumulating((r) => r.raise('silent'));
            return 42; // must NOT become Right(42)
          }));
      expect(result.leftOrNull()!.toList(), ['silent']);
    });

    test('hasErrors reflects branch failures', () {
      either<Nel<String>, void>((r) => r.accumulate((acc) {
            expect(acc.hasErrors, isFalse);
            acc.accumulating((r) => r.raise('x'));
            expect(acc.hasErrors, isTrue);
          }));
    });

    test('a THROWN exception beats accumulation and propagates', () {
      expect(
          () => either<Nel<String>, int>((r) => r.accumulate((acc) {
                acc.accumulating((r) => r.raise('raised'));
                acc.accumulating<int>((r) => throw StateError('thrown'));
                return 1;
              })),
          throwsStateError);
    });

    test('a branch can contribute MULTIPLE errors via bindNel', () {
      final result = either<Nel<String>, int>((r) => r.accumulate((acc) {
            acc.accumulating(
                (r) => r.bindNel(Left(NonEmptyList.of('x', ['y']))));
            acc.accumulating((r) => r.raise('z'));
            return 0;
          }));
      expect(result.leftOrNull()!.toList(), ['x', 'y', 'z']);
    });

    test('nested mapOrAccumulate inside a branch joins all errors', () {
      final result = either<Nel<String>, List<int>>(
          (r) => r.accumulate((acc) {
                final xs = acc.accumulating((r) => r.mapOrAccumulate(
                    [1, 2, 3], (r, n) => n.isEven ? n : r.raise('odd $n')));
                return xs.value;
              }));
      expect(result.leftOrNull()!.toList(), ['odd 1', 'odd 3']);
    });
  });

  group('bindNel', () {
    test('unwraps Right and raises all errors of Left', () {
      expect(
          either<Nel<String>, int>((r) => r.bindNel(Right(5))), Right(5));
      final result = either<Nel<String>, int>(
          (r) => r.bindNel(Left(NonEmptyList.of('a', ['b']))));
      expect(result.leftOrNull()!.toList(), ['a', 'b']);
    });
  });

  group('mapOrAccumulate (scope)', () {
    test('collects every failure instead of stopping at the first', () {
      final result = either<Nel<String>, List<int>>((r) => r.mapOrAccumulate(
          [1, 2, 3, 4], (r, n) => n.isEven ? n * 10 : r.raise('odd $n')));
      expect(result.leftOrNull()!.toList(), ['odd 1', 'odd 3']);
    });

    test('returns all results when nothing fails', () {
      final result = either<Nel<String>, List<int>>(
          (r) => r.mapOrAccumulate([1, 2], (r, n) => n * 10));
      expect(result.getOrNull(), [10, 20]);
    });

    test('keeps iterating after the first error (fail-slow), and results '
        'are dropped once an error exists', () {
      final seen = <int>[];
      either<Nel<String>, List<int>>((r) => r.mapOrAccumulate([1, 2, 3],
          (r, n) {
        seen.add(n);
        return n == 2 ? r.raise('two') : n;
      }));
      expect(seen, [1, 2, 3]);
    });
  });

  group('RaiseAccumulate.over', () {
    test('wraps single raises into singleton Nels', () {
      final result = either<Nel<String>, int>((r) {
        final single = RaiseAccumulate.over(r);
        return single.raise('one');
      });
      expect(result.leftOrNull()!.toList(), ['one']);
    });

    test('delegates bindNel and mapOrAccumulate', () {
      final result = either<Nel<String>, List<int>>((r) {
        final single = RaiseAccumulate.over(r);
        expect(single.bindNel(Right(1)), 1);
        return single.mapOrAccumulate(
            [1, 2], (r, n) => n.isOdd ? r.raise('odd $n') : n);
      });
      expect(result.leftOrNull()!.toList(), ['odd 1']);
    });
  });

  group('zipOrAccumulate', () {
    test('2-ary combines successes', () {
      final result = either<Nel<String>, String>((r) => r.zipOrAccumulate2(
          (r) => 'a', (r) => 'b', (a, b) => '$a$b'));
      expect(result, Right('ab'));
    });

    test('2-ary accumulates both failures', () {
      final result = either<Nel<String>, String>((r) => r.zipOrAccumulate2(
          (r) => r.raise('e1'), (r) => r.raise('e2'), (a, b) => '$a$b'));
      expect(result.leftOrNull()!.toList(), ['e1', 'e2']);
    });

    test('3-ary mixes successes and failures', () {
      final result = either<Nel<String>, String>((r) => r.zipOrAccumulate3(
          (r) => 'a',
          (r) => r.raise('e2'),
          (r) => r.raise('e3'),
          (a, b, c) => '$a$b$c'));
      expect(result.leftOrNull()!.toList(), ['e2', 'e3']);
    });

    test('4-ary and 5-ary combine successes', () {
      expect(
          either<Nel<String>, String>((r) => r.zipOrAccumulate4((r) => 'a',
              (r) => 'b', (r) => 'c', (r) => 'd', (a, b, c, d) => '$a$b$c$d')),
          Right('abcd'));
      expect(
          either<Nel<String>, String>((r) => r.zipOrAccumulate5(
              (r) => 'a',
              (r) => 'b',
              (r) => 'c',
              (r) => 'd',
              (r) => 'e',
              (a, b, c, d, e) => '$a$b$c$d$e')),
          Right('abcde'));
    });

    test('5-ary accumulates across all arities', () {
      final result = either<Nel<String>, String>((r) => r.zipOrAccumulate5(
          (r) => r.raise('1'),
          (r) => 'b',
          (r) => r.raise('3'),
          (r) => 'd',
          (r) => r.raise('5'),
          (a, b, c, d, e) => '$a$b$c$d$e'));
      expect(result.leftOrNull()!.toList(), ['1', '3', '5']);
    });

    test('branches receive an accumulating scope: bindNel contributes '
        'multiple errors from ONE branch', () {
      final result = either<Nel<String>, int>((r) => r.zipOrAccumulate2(
          (r) => r.bindNel(Left(NonEmptyList.of('x', ['y']))),
          (r) => r.raise('z'),
          (a, b) => 0));
      expect(result.leftOrNull()!.toList(), ['x', 'y', 'z']);
    });
  });
}
