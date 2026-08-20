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

final class _SinglePassIterable<T> extends Iterable<T> {
  _SinglePassIterable(Iterable<T> values) : _iterator = values.iterator;

  final Iterator<T> _iterator;

  @override
  Iterator<T> get iterator => _iterator;
}

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

    test('both spellings throw StateError("No element") on an empty chain', () {
      final noElement = isA<StateError>().having(
        (error) => error.message,
        'message',
        'No element',
      );
      expect(() => fx(<num>[]).min(), throwsA(noElement));
      expect(() => fx(<num>[]).max(), throwsA(noElement));
      expect(() => FxNum(fx(<num>[])).min(), throwsA(noElement));
      expect(() => FxNum(fx(<num>[])).max(), throwsA(noElement));
    });

    test('single element is both the min and the max', () {
      expect(FxNum(fx(<num>[7])).min(), 7);
      expect(FxNum(fx(<num>[7])).max(), 7);
    });

    test('NaN behavior agrees with the Fx members', () {
      for (final xs in [
        <num>[1, double.nan],
        <num>[double.nan, 1],
        <num>[double.nan],
      ]) {
        final memberMin = fx(xs).min();
        final extensionMin = FxNum(fx(xs)).min();
        expect(extensionMin.isNaN, memberMin.isNaN, reason: 'min input: $xs');
        if (!memberMin.isNaN) expect(extensionMin, memberMin);

        final memberMax = fx(xs).max();
        final extensionMax = FxNum(fx(xs)).max();
        expect(extensionMax.isNaN, memberMax.isNaN, reason: 'max input: $xs');
        if (!memberMax.isNaN) expect(extensionMax, memberMax);
      }
    });

    test('a lazy source observes each element once', () {
      var minObserved = 0;
      final minSource = <num>[3, 1, 2].map((value) {
        minObserved++;
        return value;
      });
      expect(FxNum(fx(minSource)).min(), 1);
      expect(minObserved, 3);

      var maxObserved = 0;
      final maxSource = <num>[3, 1, 2].map((value) {
        maxObserved++;
        return value;
      });
      expect(FxNum(fx(maxSource)).max(), 3);
      expect(maxObserved, 3);
    });

    test('a single-pass iterable does not lose its first element', () {
      expect(FxNum(fx(_SinglePassIterable<num>([3, 1, 2]))).min(), 1);
      expect(FxNum(fx(_SinglePassIterable<num>([3, 1, 2]))).max(), 3);
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
