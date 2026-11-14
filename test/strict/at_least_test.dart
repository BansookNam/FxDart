import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('fxAtLeast', () {
    test('counts matches up to n', () {
      expect(fxAtLeast(2, (int x) => x.isEven, [1, 2, 3, 4]), isTrue);
      expect(fxAtLeast(3, (int x) => x.isEven, [1, 2, 3, 4]), isFalse);
      expect(fxAtLeast(1, (int x) => x > 9, <int>[]), isFalse);
    });

    test('n <= 0 is true without reading', () {
      var reads = 0;
      final xs = Iterable.generate(3, (i) => i).map((i) {
        reads++;
        return i;
      });
      expect(fxAtLeast(0, (int _) => false, xs), isTrue);
      expect(fxAtLeast(-1, (int _) => false, xs), isTrue);
      expect(reads, 0);
    });

    test('stops at the nth match (list and lazy)', () {
      var tested = 0;
      bool even(int x) {
        tested++;
        return x.isEven;
      }

      expect(fxAtLeast(2, even, [2, 4, 6, 8]), isTrue);
      expect(tested, 2);
      tested = 0;
      expect(fxAtLeast(2, even, fxRange(1000000)), isTrue);
      expect(tested, 3); // 0, 1, 2
    });

    test('chain', () {
      expect(fx([1, 2, 3]).atLeast(3, (x) => x > 0), isTrue);
      expect(fx([1, 2, 3]).map((x) => x).atLeast(4, (x) => x > 0), isFalse);
    });

    test('async: cancels upstream at the nth match', () async {
      var pulled = 0;
      final src = fxAsync(fxToAsync(fxRange(100))).map((x) {
        pulled++;
        return x;
      });
      expect(await src.atLeast(2, (x) => x >= 5), isTrue);
      expect(pulled, 7);
      expect(
        await fxAtLeastAsync(4, (int x) async => x.isOdd, fxToAsync([1, 3, 5])),
        isFalse,
      );
      expect(
        await fxAtLeastAsync(0, (int _) => true, fxToAsync(<int>[])),
        isTrue,
      );
    });

    test('async: an error from f propagates', () async {
      await expectLater(
        fxAtLeastAsync(1, (int _) => throw StateError('x'), fxToAsync([1])),
        throwsStateError,
      );
    });
  });
}
