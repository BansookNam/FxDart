import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/tap.spec.ts. Dart's tap is data-first:
// `fxTap(f, value)`; curried usage becomes a closure.
void main() {
  group('tap', () {
    group('sync', () {
      test('should return the received argument as it is', () {
        final res = fxTap((a) => a * 100, 10);
        expect(res, equals(10));
      });

      test('should invoke the given callback once', () {
        var callCount = 0;
        fxTap((a) {
          callCount++;
        }, 10);
        expect(callCount, equals(1));
      });

      test('should support a curried style via a closure', () {
        var res1 = 10;
        curried(int a) => fxTap((int v) {
          res1 += v;
        }, a);
        final res2 = curried(50);

        expect(res1, equals(60));
        expect(res2, equals(50));
      });
    });

    group('async', () {
      test('should return the received argument as it is', () {
        final res = fxTap(
          (a) => fxDelay(const Duration(milliseconds: 50), a),
          10,
        );
        expect(res, equals(10));
      });

      test('should work as a side effect inside an async map', () async {
        final res = await fxAsync(fxToAsync(fxRange(5)))
            .map(
              (a) =>
                  fxTap((v) => fxDelay(const Duration(milliseconds: 10), v), a),
            )
            .toList();
        expect(res, equals([0, 1, 2, 3, 4]));
      });
    });
  });
}
