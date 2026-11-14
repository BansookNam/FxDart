import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('fxAtMost', () {
    test('true while matches stay within n', () {
      expect(fxAtMost(2, (int x) => x.isEven, [1, 2, 3, 4]), isTrue);
      expect(fxAtMost(1, (int x) => x.isEven, [1, 2, 3, 4]), isFalse);
      expect(fxAtMost(0, (int x) => x > 9, [1, 2]), isTrue);
      expect(fxAtMost(0, (int x) => x > 9, <int>[]), isTrue);
    });

    test('negative n is false', () {
      expect(fxAtMost(-1, (int _) => false, <int>[]), isFalse);
    });

    test('stops at the n + 1th match', () {
      var tested = 0;
      expect(
        fxAtMost(1, (int x) {
          tested++;
          return true;
        }, fxRange(1000000)),
        isFalse,
      );
      expect(tested, 2);
    });

    test('chain and async', () async {
      expect(fx([1, 2, 3]).atMost(3, (x) => x > 0), isTrue);
      expect(
        await fxAsync(fxToAsync([1, 2, 3])).atMost(1, (x) async => x > 1),
        isFalse,
      );
      expect(
        await fxAtMostAsync(-1, (int _) => true, fxToAsync(<int>[])),
        isFalse,
      );
      expect(
        await fxAtMostAsync(5, (int _) => true, fxToAsync([1, 2])),
        isTrue,
      );
    });
  });
}
