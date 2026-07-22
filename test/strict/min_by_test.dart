import 'package:fxdart/fxdart.dart' hide isNull;
import 'package:test/test.dart';

void main() {
  group('minBy', () {
    group('sync', () {
      test('should return the element with the smallest key', () {
        expect(minBy((String s) => s.length, ['ccc', 'a', 'bb']), equals('a'));
        expect(minBy((int n) => -n, [3, 1, 2]), equals(3));
      });

      test('should return null for an empty iterable', () {
        expect(minBy((int n) => n, <int>[]), isNull);
      });

      test('should keep the first element on ties', () {
        expect(minBy((String s) => s.length, ['aa', 'bb', 'ccc']), equals('aa'));
      });

      test('should be able to be used in the pipeline', () {
        final res = fx(['apple', 'fig', 'banana'])
            .filter((s) => s != 'fig')
            .minBy((s) => s.length);
        expect(res, equals('apple'));
      });
    });

    group('async', () {
      test('should return the element with the smallest key', () async {
        expect(await minByAsync((int n) => n, toAsync([3, 7, 5])), equals(3));
      });

      test('should return null for an empty iterable', () async {
        expect(await minByAsync((int n) => n, toAsync(<int>[])), isNull);
      });

      test('should be able to be used in the pipeline', () async {
        final res =
            await fx([3, 7, 5]).toAsync().map((n) => n * 10).minBy((n) => n);
        expect(res, equals(30));
      });
    });
  });
}
