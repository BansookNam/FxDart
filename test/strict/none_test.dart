import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// none is the third quantifier beside every/some: true when no element
// matches, vacuously true on empty input, short-circuiting on the first
// match. Both the indexed list loop and the pulled loop are driven.
void main() {
  group('none', () {
    test('true when no element matches', () {
      expect(none((int a) => a > 10, [1, 2, 3]), isTrue);
    });

    test('false when some element matches', () {
      expect(none((int a) => a > 2, [1, 2, 3]), isFalse);
    });

    test('vacuously true on empty input', () {
      expect(none((int a) => true, <int>[]), isTrue);
    });

    test('single element, matching and not', () {
      expect(none((int a) => a.isEven, [2]), isFalse);
      expect(none((int a) => a.isEven, [1]), isTrue);
    });

    test('short-circuits on the first match', () {
      var seen = 0;
      expect(
        none((int a) {
          seen++;
          return a == 2;
        }, [1, 2, 3, 4]),
        isFalse,
      );
      expect(seen, 2);
    });

    test('a pulled source agrees with a list', () {
      bool f(int a) => a > 3;
      expect(none(f, Iterable<int>.generate(5)), none(f, [0, 1, 2, 3, 4]));
      expect(none(f, Iterable<int>.generate(3)), isTrue);
    });

    test('is the negation of some', () {
      bool f(int a) => a.isEven;
      for (final xs in [
        <int>[],
        [1],
        [2],
        [1, 2, 3],
        [1, 3, 5],
      ]) {
        expect(none(f, xs), !some(f, xs), reason: 'input: $xs');
      }
    });

    test('async agrees with the sync spelling', () async {
      bool f(int a) => a > 2;
      expect(await noneAsync(f, toAsync([1, 2, 3])), none(f, [1, 2, 3]));
      expect(await noneAsync(f, toAsync([1, 2])), none(f, [1, 2]));
      expect(await noneAsync(f, toAsync(<int>[])), isTrue);
    });

    test('async awaits the predicate', () async {
      expect(
        await noneAsync((int a) async => a > 2, toAsync([1, 2, 3])),
        false,
      );
    });

    test('Fx.none agrees with the top-level function', () {
      bool f(int a) => a > 2;
      expect(fx([1, 2, 3]).none(f), none(f, [1, 2, 3]));
      expect(fx([1, 2]).none(f), none(f, [1, 2]));
    });

    test('FxAsync.none agrees with the top-level function', () async {
      bool f(int a) => a > 2;
      expect(await fxAsync(toAsync([1, 2, 3])).none(f), none(f, [1, 2, 3]));
      expect(await fxAsync(toAsync([1, 2])).none(f), none(f, [1, 2]));
    });

    test('does not shadow SingletonRaise.none', () {
      // Both names are reachable from one import: the raise-scope `none` is a
      // member, the quantifier is a top-level function.
      expect(nullable<int>((r) => r.none()), null);
      expect(none((int a) => a > 1, [1]), isTrue);
    });
  });
}
