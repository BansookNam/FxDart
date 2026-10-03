import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('ifEmpty', () {
    group('sync', () {
      test('should pass a non-empty source through untouched', () {
        var called = false;
        final res = fxToList(
          fxIfEmpty(() {
            called = true;
            return [0];
          }, [1, 2]),
        );
        expect(res, equals([1, 2]));
        expect(called, isFalse);
      });

      test('should switch to the fallback when empty', () {
        expect(fxToList(fxIfEmpty(() => [0], <int>[])), equals([0]));
        expect(
          fxToList(
            fxIfEmpty(() => [7, 8], fxFilter((int a) => a > 10, [1, 2])),
          ),
          equals([7, 8]),
        );
      });

      test('defaultIfEmpty should yield the single default', () {
        expect(fxToList(defaultIfEmpty(0, <int>[])), equals([0]));
        expect(fxToList(defaultIfEmpty(0, [1, 2])), equals([1, 2]));
      });

      test('should support repeated iteration', () {
        final res = defaultIfEmpty(0, <int>[]);
        expect(fxToList(res), fxToList(res));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        expect(fx(<int>[]).ifEmpty(() => [1, 2]).toList(), equals([1, 2]));
        expect(fx([5]).defaultIfEmpty(0).toList(), equals([5]));
        expect(
          fx([1, 2, 3]).filter((a) => a > 10).defaultIfEmpty(-1).toList(),
          equals([-1]),
        );
      });
    });

    group('async', () {
      test('should pass a non-empty source through untouched', () async {
        var called = false;
        final res = await fxToListAsync(
          fxIfEmptyAsync(() {
            called = true;
            return fxToAsync([0]);
          }, fxToAsync([1, 2])),
        );
        expect(res, equals([1, 2]));
        expect(called, isFalse);
      });

      test('should switch to the fallback when empty', () async {
        expect(
          await fxToListAsync(
            fxIfEmptyAsync(() => fxToAsync([0]), fxAsyncEmpty<int>()),
          ),
          equals([0]),
        );
      });

      test('defaultIfEmpty should accept a future default', () async {
        expect(
          await fxToListAsync(
            defaultIfEmptyAsync(Future.value(0), fxAsyncEmpty<int>()),
          ),
          equals([0]),
        );
        expect(
          await fxToListAsync(defaultIfEmptyAsync(0, fxToAsync([1, 2]))),
          equals([1, 2]),
        );
      });

      test('should work after concurrent', () async {
        final res = await fxAsync(fxToAsync(fxRange(1, 7)))
            .map((a) => fxDelay(const Duration(milliseconds: 20), a))
            .filter((a) => a > 10)
            .concurrent(3)
            .defaultIfEmpty(-1)
            .toList();
        expect(res, equals([-1]));
      });

      test('should propagate an upstream error', () async {
        await expectLater(
          fxAsync(
            fxToAsync([1, 2]),
          ).map<int>((a) => throw Exception('err')).defaultIfEmpty(0).toList(),
          throwsException,
        );
      });

      test(
        'should be able to be used as a chaining method in the `fx`',
        () async {
          expect(
            await fx(<int>[]).toAsync().ifEmpty(() => fxToAsync([1])).toList(),
            equals([1]),
          );
          expect(
            await fx([5]).toAsync().defaultIfEmpty(0).toList(),
            equals([5]),
          );
        },
      );
    });
  });
}
