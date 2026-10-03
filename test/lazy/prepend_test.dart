import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('prepend', () {
    group('sync', () {
      test('should be prepended the contents of the given element', () {
        expect(fxToList(fxPrepend('a', ['b', 'c'])), equals(['a', 'b', 'c']));
      });

      test('should be prepended to a lazy iterable', () {
        expect(
          fxToList(fxPrepend('a', ['b', 'c'].where((_) => true))),
          equals(['a', 'b', 'c']),
        );
      });

      test('should be able to be used in the pipeline', () {
        final res = fx(fxRange(4, 7)).prepend(3).prepend(2).prepend(1).toList();
        expect(res, equals([1, 2, 3, 4, 5, 6]));
      });
    });

    group('async', () {
      test('should be prepended the contents of the given element', () async {
        final res = await fxToListAsync(
          fxPrependAsync(
            fxDelay(const Duration(milliseconds: 100), 1),
            fxToAsync([2, 3, 4]),
          ),
        );
        expect(res, equals([1, 2, 3, 4]));
      });

      test('should be prepend the given element sequentially', () async {
        Future<void> chained = Future.value();
        Future<int> chain(int v) {
          final next = chained.then(
            (_) => fxDelay(const Duration(milliseconds: 50), v),
          );
          chained = next;
          return next;
        }

        var it = fxToAsync(fxRange(4, 7));
        it = fxPrependAsync(chain(3), it);
        it = fxPrependAsync(chain(2), it);
        it = fxPrependAsync(chain(1), it);
        expect(await fxToListAsync(it), equals([1, 2, 3, 4, 5, 6]));
      });

      test('should be prepend the given element concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fx([4, 5, 6])
            .toAsync()
            .map((a) => fxDelay(const Duration(milliseconds: 100), a))
            .prepend(3)
            .prepend(Future.value(2))
            .prepend(1)
            .concurrent(3)
            .toList();
        expect(res, equals([1, 2, 3, 4, 5, 6]));
        // sequential would be ~300ms; concurrent(3) is ~100ms
        expect(sw.elapsedMilliseconds, lessThan(250));
      });
    });
  });
}
