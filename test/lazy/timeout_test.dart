import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('timeout', () {
    test('should pass values through when every pull is fast enough', () async {
      final res = await fxToListAsync(
        fxTimeoutAsync(
          const Duration(milliseconds: 200),
          fxMapAsync(
            (int a) => fxDelay(const Duration(milliseconds: 20), a),
            fxToAsync([1, 2, 3]),
          ),
        ),
      );
      expect(res, equals([1, 2, 3]));
    });

    test('should fail the pull that exceeds the limit', () async {
      await expectLater(
        fxToListAsync(
          fxTimeoutAsync(
            const Duration(milliseconds: 50),
            fxMapAsync(
              (int a) => fxDelay(Duration(milliseconds: a == 2 ? 200 : 10), a),
              fxToAsync([1, 2, 3]),
            ),
          ),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('should apply per pull, not to the whole pipeline', () async {
      // Total time (~5 × 30ms) exceeds the limit; each pull stays under it.
      final res = await fxAsync(fxToAsync(fxRange(1, 6)))
          .map((a) => fxDelay(const Duration(milliseconds: 30), a))
          .timeout(const Duration(milliseconds: 100))
          .toList();
      expect(res, equals([1, 2, 3, 4, 5]));
    });

    test(
      'should keep overlapping pulls independent under concurrent',
      () async {
        // Each item takes ~80ms; concurrent(3) overlaps them, and each pull's
        // own timer still sees only ~80ms.
        final res = await fxAsync(fxToAsync(fxRange(1, 7)))
            .map((a) => fxDelay(const Duration(milliseconds: 80), a))
            .timeout(const Duration(milliseconds: 300))
            .concurrent(3)
            .toList();
        expect(res, equals([1, 2, 3, 4, 5, 6]));
      },
    );

    test('should pass an empty source through', () async {
      expect(
        await fxToListAsync(
          fxTimeoutAsync(const Duration(milliseconds: 50), fxAsyncEmpty<int>()),
        ),
        equals([]),
      );
    });

    test(
      'should be able to be used as a chaining method in the `fx`',
      () async {
        await expectLater(
          fx([1])
              .toAsync()
              .map((a) => fxDelay(const Duration(milliseconds: 200), a))
              .timeout(const Duration(milliseconds: 50))
              .toList(),
          throwsA(isA<TimeoutException>()),
        );
      },
    );
  });
}
