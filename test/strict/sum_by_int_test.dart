import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('sumByInt', () {
    test('sums as int', () {
      final int r = sumByInt((String s) => s.length, ['ab', 'cde']);
      expect(r, 5);
      expect(sumByInt((int x) => x, fxRange(5)), 10);
      expect(sumByInt((int x) => x, <int>[]), 0);
    });

    test('chain and async', () async {
      final int c = fx(['a', 'bb']).sumByInt((s) => s.length);
      expect(c, 3);
      final int a = await fxAsync(
        fxToAsync(['a', 'bb']),
      ).sumByInt((s) async => s.length);
      expect(a, 3);
      expect(await sumByIntAsync((int x) => x, fxToAsync([4, 5])), 9);
    });
  });
}
