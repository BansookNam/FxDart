import 'package:fxdart/fxdart.dart' hide isNull;
import 'package:test/test.dart';

void main() {
  group('maxBy', () {
    group('sync', () {
      test('should return the element with the largest key', () {
        expect(maxBy((String s) => s.length, ['a', 'ccc', 'bb']), equals('ccc'));
        expect(maxBy((int n) => -n, [3, 1, 2]), equals(1));
      });

      test('should return null for an empty iterable', () {
        expect(maxBy((int n) => n, <int>[]), isNull);
      });

      test('should keep the first element on ties', () {
        expect(maxBy((String s) => s.length, ['aa', 'bb', 'c']), equals('aa'));
      });

      test('should walk the iterable exactly once', () {
        var walked = 0;
        final source = [5, 9, 2].map((n) {
          walked++;
          return n;
        });
        expect(maxBy((int n) => n, source), equals(9));
        expect(walked, equals(3));
      });

      test('should be able to be used in the pipeline', () {
        final res = fx(['apple', 'fig', 'banana'])
            .filter((s) => s != 'banana')
            .maxBy((s) => s.length);
        expect(res, equals('apple'));
      });
    });

    group('async', () {
      test('should return the element with the largest key', () async {
        expect(await maxByAsync((int n) => n, toAsync([3, 7, 5])), equals(7));
      });

      test('should return null for an empty iterable', () async {
        expect(await maxByAsync((int n) => n, toAsync(<int>[])), isNull);
      });

      test('should be able to be used in the pipeline', () async {
        final res =
            await fx([3, 7, 5]).toAsync().map((n) => n * 10).maxBy((n) => n);
        expect(res, equals(70));
      });
    });
  });
}
