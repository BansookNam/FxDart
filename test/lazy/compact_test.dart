import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('compact', () {
    group('sync', () {
      test("should be excluded 'null' - number", () {
        final acc = <int>[];
        for (final a in compact([0, 1, null, 3, null, 5])) {
          acc.add(a);
        }
        expect(acc, equals([0, 1, 3, 5]));
      });

      test("should be excluded 'null' - string", () {
        final acc = <String>[];
        for (final a in compact(['', 'a', null, 'b', null])) {
          acc.add(a);
        }
        expect(acc, equals(['', 'a', 'b']));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe(<int?>[
          1,
          null,
          3,
          4,
          5,
          null,
          7,
          8
        ], [
          (v) => compact(v),
          (v) => map((int a) => a + 10, v),
          (v) => filter((int a) => a % 2 == 0, v),
          (v) => toArray(v),
        ]);

        expect(res, equals([14, 18]));
      });
    });

    group('async', () {
      test("should be excluded 'null' - number", () async {
        final acc = <int>[];
        final it =
            compactAsync(toAsync<int?>([0, 1, null, 3, null, 5])).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          acc.add(r.value);
        }
        expect(acc, equals([0, 1, 3, 5]));
      });

      test("should be excluded 'null' - string", () async {
        final res = await toArrayAsync(
            compactAsync(toAsync<String?>(['', 'a', null, 'b', null])));
        expect(res, equals(['', 'a', 'b']));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(
                compactAsync(toAsync<int?>([1, null, 3, 4, 5, null, 7, 8])))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .toArray();

        expect(res, equals([14, 18]));
      });
    });
  });
}
