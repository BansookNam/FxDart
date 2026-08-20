import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// FxNum.min/max are shadowed on a plain `fx(xs).min()` receiver: a member
// redeclared on an extension type wins over every extension on that type, so
// the member at Fx.min is what runs there. The extension is still reachable
// through explicit extension application, which is why it is not dead code
// and why the two implementations must not disagree.
//
// Through 0.8.5 they did: the member threw StateError on empty input, the
// extension returned +/-infinity.
void main() {
  group('Fx<num> min/max — member vs extension', () {
    test('a plain receiver resolves to the Fx member', () {
      expect(fx(<num>[3, 1, 2]).min(), 1);
      expect(fx(<num>[3, 1, 2]).max(), 3);
    });

    test('explicit extension application reaches FxNum', () {
      expect(FxNum(fx(<num>[3, 1, 2])).min(), 1);
      expect(FxNum(fx(<num>[3, 1, 2])).max(), 3);
    });

    test('both spellings agree on the same input', () {
      for (final xs in [
        <num>[1],
        <num>[3, 1, 2],
        <num>[2.5, 1.5],
        <num>[-1, 0, 1],
      ]) {
        expect(FxNum(fx(xs)).min(), fx(xs).min(), reason: 'input: $xs');
        expect(FxNum(fx(xs)).max(), fx(xs).max(), reason: 'input: $xs');
      }
    });

    test('both spellings throw StateError on an empty chain', () {
      expect(() => fx(<num>[]).min(), throwsStateError);
      expect(() => fx(<num>[]).max(), throwsStateError);
      expect(() => FxNum(fx(<num>[])).min(), throwsStateError);
      expect(() => FxNum(fx(<num>[])).max(), throwsStateError);
    });

    test('single element is both the min and the max', () {
      expect(FxNum(fx(<num>[7])).min(), 7);
      expect(FxNum(fx(<num>[7])).max(), 7);
    });

    test('NaN propagates, as in the top-level min/max', () {
      expect(FxNum(fx(<num>[1, double.nan])).min().isNaN, isTrue);
      expect(FxNum(fx(<num>[1, double.nan])).max().isNaN, isTrue);
    });

    test('FxNum.sum / average / product still resolve', () {
      expect(FxNum(fx(<num>[1, 2, 3])).sum(), 6);
      expect(FxNum(fx(<num>[1, 2, 3])).average(), 2.0);
      expect(FxNum(fx(<num>[2, 3])).product(), 6);
    });

    test('FxAsyncNum.min/max are not shadowed and stay reachable', () async {
      expect(await fxAsync(toAsync(<num>[3, 1, 2])).min(), 1);
      expect(await fxAsync(toAsync(<num>[3, 1, 2])).max(), 3);
    });
  });
}
