import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/sum.spec.ts.
void main() {
  group('sum', () {
    group('sync', () {
      test('should sum all elements [1, 2, 3]', () {
        expect(sum([1, 2, 3]), equals(6));
      });

      test('should sum all elements []', () {
        expect(sum(<num>[]), equals(0));
      });

      test('should be able to be used in the pipeline', () {
        final res1 = pipe([1, 2, 3], [sum]);
        expect(res1, equals(6));
        final res2 = pipe(<num>[], [sum]);
        expect(res2, equals(0));
      });
    });

    group('async', () {
      test('should sum all elements [1, 2, 3]', () async {
        expect(await sumAsync(toAsync(<num>[1, 2, 3])), equals(6));
      });

      test('should sum all elements []', () async {
        expect(await sumAsync(toAsync(<num>[])), equals(0));
      });

      test('should be able to be used in the pipeline', () async {
        final res1 = await pipe(<num>[
          1,
          2,
          3
        ], [
          (List<num> a) => toAsync(a),
          (FxAsyncIterable<num> a) => sumAsync(a),
        ]);
        expect(res1, equals(6));
        final res2 = await pipe(<num>[], [
          (List<num> a) => toAsync(a),
          (FxAsyncIterable<num> a) => sumAsync(a),
        ]);
        expect(res2, equals(0));
      });
    });
  });
}
