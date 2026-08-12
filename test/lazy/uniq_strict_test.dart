import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('uniqStrict', () {
    test('removes duplicates, keeping the first occurrence', () {
      expect(uniqStrict('marpple'.split('')),
          equals(['m', 'a', 'r', 'p', 'l', 'e']));
      expect(uniqStrict([1, 2, 3, 4]), equals([1, 2, 3, 4]));
      expect(uniqStrict(<int>[]), equals(<int>[]));
    });

    test('agrees element-for-element with lazy uniq', () {
      final input = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5];
      expect(uniqStrict(input), equals(uniq(input).toList()));
    });

    test('keeps distinct (identity-unequal) map objects', () {
      final res = uniqStrict([
        {'v': 1},
        {'v': 1},
      ]);
      expect(res, hasLength(2));
    });

    test('returns a growable list independent of a List source', () {
      final src = [1, 2, 3];
      final out = uniqStrict(src);
      expect(identical(out, src), isFalse);
      out.add(4);
      expect(src, equals([1, 2, 3]));
    });

    test('evaluates the upstream once, at the call', () {
      var calls = 0;
      final chain = uniqStrict(map((int a) {
        calls++;
        return a % 3;
      }, [1, 2, 3, 4, 5, 6]));
      expect(calls, equals(6), reason: 'upstream ran eagerly');
      chain.toList();
      chain.toList();
      expect(calls, equals(6), reason: 'and is not re-run on iteration');
    });

    test('by contrast, lazy uniq re-runs the upstream per iteration', () {
      var calls = 0;
      final lazy = uniq(map((int a) {
        calls++;
        return a % 3;
      }, [1, 2, 3, 4, 5, 6]));
      expect(calls, equals(0));
      lazy.toList();
      lazy.toList();
      expect(calls, equals(12));
    });

    test('works in an Fx chain via uniqStrict()', () {
      final res =
          fx([1, 2, 3, 4, 4, 2]).map((a) => a + 10).uniqStrict().toList();
      expect(res, equals([11, 12, 13, 14]));
    });

    test('Fx.uniqStrict matches Fx.uniq for a fully consumed chain', () {
      final input = [5, 1, 5, 2, 2, 9, 1];
      expect(
        fx(input).filter((a) => a > 1).uniqStrict().toList(),
        equals(fx(input).filter((a) => a > 1).uniq().toList()),
      );
    });

    test('lazy uniq().toList(growable: false) fuses into a fixed list', () {
      final res = uniq(map((int a) => a % 3, [1, 2, 3, 4, 5, 6]))
          .toList(growable: false);
      expect(res, equals([1, 2, 0]));
      expect(() => res.add(9), throwsUnsupportedError);
    });

    test('does NOT short-circuit a downstream take', () {
      var scanned = 0;
      Iterable<int> counted() => map((int a) {
            scanned++;
            return a;
          }, range(0, 1000));

      scanned = 0;
      fx(counted()).uniq().take(3).toList();
      final lazyScanned = scanned;

      scanned = 0;
      fx(counted()).uniqStrict().take(3).toList();
      final strictScanned = scanned;

      expect(lazyScanned, equals(3));
      expect(strictScanned, equals(1000),
          reason: 'strict dedups everything before take sees it');
    });
  });

  group('uniqByStrict', () {
    test('dedups by key, keeping the first of each key', () {
      final res = uniqByStrict((String s) => s.length, ['a', 'bb', 'c', 'ddd']);
      expect(res, equals(['a', 'bb', 'ddd']));
    });

    test('agrees element-for-element with lazy uniqBy', () {
      final input = ['a', 'bb', 'c', 'ddd', 'ee', 'f'];
      expect(
        uniqByStrict((String s) => s.length, input),
        equals(uniqBy((String s) => s.length, input).toList()),
      );
    });

    test('returns a growable list independent of a List source', () {
      final src = ['a', 'bb'];
      final out = uniqByStrict((String s) => s.length, src);
      expect(identical(out, src), isFalse);
      out.add('ccc');
      expect(src, equals(['a', 'bb']));
    });

    test('works in an Fx chain via uniqByStrict()', () {
      final res = fx(['a', 'bb', 'c', 'ddd'])
          .uniqByStrict((s) => s.length)
          .map((s) => s.toUpperCase())
          .toList();
      expect(res, equals(['A', 'BB', 'DDD']));
    });

    test('lazy uniqBy().toList(growable: false) fuses into a fixed list', () {
      final res = uniqBy((String s) => s.length, ['a', 'bb', 'c', 'ddd'])
          .toList(growable: false);
      expect(res, equals(['a', 'bb', 'ddd']));
      expect(() => res.add('x'), throwsUnsupportedError);
    });

    test('key function runs exactly once per element', () {
      var keyCalls = 0;
      uniqByStrict((int a) {
        keyCalls++;
        return a % 2;
      }, [1, 2, 3, 4, 5]);
      expect(keyCalls, equals(5));
    });
  });
}
