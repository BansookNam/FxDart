import 'package:fxdart/fxdart.dart' hide isEmpty, isNotNull, isNull;
import 'package:test/test.dart';

void main() {
  group('attach', () {
    group('sync', () {
      test('should pair each element with the derived value', () {
        expect(attach((String w) => w.length, ['a', 'bb', 'ccc']).toList(),
            equals([('a', 1), ('bb', 2), ('ccc', 3)]));
      });

      test('should stay lazy', () {
        var calls = 0;
        final pairs = attach((int n) {
          calls++;
          return n * 10;
        }, [1, 2, 3, 4]);
        expect(calls, equals(0));
        expect(pairs.take(2).toList(), equals([(1, 10), (2, 20)]));
        expect(calls, equals(2));
      });

      test('should handle an empty iterable', () {
        expect(attach((int n) => n, <int>[]), isEmpty);
      });

      test('should be able to be used in the pipeline', () {
        final result = fx(['apple', 'fig', 'banana'])
            .attach((w) => w.length)
            .filter((p) => p.$2 > 3)
            .map((p) => p.$1)
            .toList();
        expect(result, equals(['apple', 'banana']));
      });
    });

    group('async', () {
      test('should pair each element with the awaited result', () async {
        final result = await toListAsync(
            attachAsync((int n) async => n * 10, toAsync([1, 2, 3])));
        expect(result, equals([(1, 10), (2, 20), (3, 30)]));
      });

      test('should compose with concurrent: overlapping pulls', () async {
        var inFlight = 0;
        var maxInFlight = 0;
        final result = await fx([1, 2, 3, 4, 5, 6])
            .toAsync()
            .attach((n) async {
              inFlight++;
              if (inFlight > maxInFlight) maxInFlight = inFlight;
              await Future.delayed(const Duration(milliseconds: 5));
              inFlight--;
              return n * 10;
            })
            .concurrent(3)
            .toList();
        expect(result,
            equals([(1, 10), (2, 20), (3, 30), (4, 40), (5, 50), (6, 60)]));
        expect(maxInFlight, equals(3));
      });

      test('should keep the input beside a nullable result', () async {
        Future<int?> lookup(String sku) async => sku == 'a' ? 1 : null;
        final result = await fx(['a', 'b'])
            .toAsync()
            .attach(lookup)
            .map((r) => (r.$1, r.$2 ?? -1))
            .toList();
        expect(result, equals([('a', 1), ('b', -1)]));
      });

      test('should be able to be used in the pipeline', () async {
        final result = await fxStream(Stream.fromIterable(['a', 'bb']))
            .attach((w) async => w.length)
            .toList();
        expect(result, equals([('a', 1), ('bb', 2)]));
      });
    });
  });
}
