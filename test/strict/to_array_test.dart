import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/toArray.spec.ts.
void main() {
  group('toArray', () {
    group('sync', () {
      test("should return 'List<A>' when 'Iterable<A>' is given", () {
        final res = toArray(range(5));
        expect(res, equals([0, 1, 2, 3, 4]));
      });

      test(
          "should return 'List<Future<A>>' when 'Iterable<Future<A>>' is given",
          () async {
        final numberFutures =
            toArray(map((int a) => Future.value(a), range(5)));
        final res = await Future.wait(numberFutures);
        expect(res, equals([0, 1, 2, 3, 4]));
      });
    });

    group('async', () {
      test("should return 'Future<List<A>>' when 'FxAsyncIterable<A>' is given",
          () async {
        final res = await toArrayAsync(toAsync(range(5)));
        expect(res, equals([0, 1, 2, 3, 4]));
      });
    });
  });
}
