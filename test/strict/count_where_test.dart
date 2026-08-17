import 'package:fxdart/fxdart.dart' hide isEmpty, isNotNull, isNull;
import 'package:test/test.dart';

void main() {
  group('countWhere', () {
    group('sync', () {
      test('should count the matching values in one walk', () {
        expect(countWhere((int n) => n.isEven, [1, 2, 3, 4, 5, 6]), equals(3));
      });

      test('should return 0 for an empty iterable', () {
        expect(countWhere((int n) => n > 0, <int>[]), equals(0));
      });

      test('should return 0 when nothing matches', () {
        expect(countWhere((int n) => n > 10, [1, 2, 3]), equals(0));
      });

      test('should walk the iterable exactly once', () {
        var walked = 0;
        final source = [1, 2, 3].map((n) {
          walked++;
          return n;
        });
        expect(countWhere((int n) => n.isOdd, source), equals(2));
        expect(walked, equals(3));
      });

      test('should be able to be used in the pipeline', () {
        final n = fx([
          'apple',
          'fig',
          'banana',
        ]).map((s) => s.length).countWhere((len) => len > 3);
        expect(n, equals(2));
      });
    });

    group('async', () {
      test('should count the matching values', () async {
        expect(
          await countWhereAsync((int n) async => n.isEven, toAsync([1, 2, 4])),
          equals(2),
        );
      });

      test('should return 0 for an empty iterable', () async {
        expect(
          await countWhereAsync((int n) => n > 0, toAsync(<int>[])),
          equals(0),
        );
      });

      test('should be able to be used in the pipeline', () async {
        final n = await fx([
          1,
          2,
          3,
          4,
        ]).toAsync().map((n) => n * 2).countWhere((n) => n > 4);
        expect(n, equals(2));
      });
    });
  });
}
