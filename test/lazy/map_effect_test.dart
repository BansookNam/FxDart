import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('mapEffect', () {
    group('sync', () {
      test('should apply the function to each element', () {
        expect(mapEffect((a) => a * 2, [1, 2, 3]).toList(), equals([2, 4, 6]));
      });

      test('should run the side effect for each element', () {
        final seen = <int>[];
        final res = mapEffect((int a) {
          seen.add(a);
          return a;
        }, [1, 2, 3]).toList();
        expect(res, equals([1, 2, 3]));
        expect(seen, equals([1, 2, 3]));
      });

      test('should be lazy', () {
        final seen = <int>[];
        final it = mapEffect((int a) {
          seen.add(a);
          return a;
        }, [1, 2, 3]);
        expect(seen, equals([]));
        expect(it.take(1).toList(), equals([1]));
        expect(seen, equals([1]));
      });
    });

    group('async', () {
      test('should apply the function to each element', () async {
        expect(
          await toListAsync(mapEffectAsync((a) => a * 2, toAsync([1, 2, 3]))),
          equals([2, 4, 6]),
        );
      });

      test('should support an asynchronous function', () async {
        final seen = <int>[];
        final res = await toListAsync(mapEffectAsync((int a) async {
          seen.add(a);
          return a;
        }, toAsync([1, 2, 3])));
        expect(res, equals([1, 2, 3]));
        expect(seen, equals([1, 2, 3]));
      });
    });
  });
}
