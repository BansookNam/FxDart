import 'package:fxdart/fxdart.dart' hide isEmpty, isNotNull, isNull;
import 'package:test/test.dart';

void main() {
  group('sortByDesc', () {
    group('sync', () {
      test('should sort int keys descending (unboxed path)', () {
        expect(sortByDesc((int n) => n, [3, 1, 4, 1, 5]),
            equals([5, 4, 3, 1, 1]));
      });

      test('should sort double keys descending (unboxed path)', () {
        expect(sortByDesc((double d) => d, [0.5, 2.5, 1.5]),
            equals([2.5, 1.5, 0.5]));
      });

      test('should sort String keys descending (unboxed path)', () {
        expect(sortByDesc((String s) => s, ['b', 'c', 'a']),
            equals(['c', 'b', 'a']));
      });

      test('should sort Comparable keys descending (generic path)', () {
        final dates = [
          DateTime(2026, 1, 2),
          DateTime(2026, 3, 1),
          DateTime(2026, 2, 1),
        ];
        expect(sortByDesc((DateTime d) => d, dates),
            equals([DateTime(2026, 3, 1), DateTime(2026, 2, 1), DateTime(2026, 1, 2)]));
      });

      test('should sort by an extracted key', () {
        expect(sortByDesc((String s) => s.length, ['bb', 'a', 'cccc']),
            equals(['cccc', 'bb', 'a']));
      });

      test('should return empty and single-element inputs as-is', () {
        expect(sortByDesc((int n) => n, <int>[]), isEmpty);
        expect(sortByDesc((int n) => n, [7]), equals([7]));
      });

      test('should not mutate the input', () {
        final input = [1, 3, 2];
        sortByDesc((int n) => n, input);
        expect(input, equals([1, 3, 2]));
      });

      test('should be the exact reverse of sortBy for distinct keys', () {
        final input = [3, 1, 4, 5, 9, 2, 6];
        expect(sortByDesc((int n) => n, input),
            equals(sortBy((int n) => n, input).reversed.toList()));
      });

      test('should extract each key exactly once', () {
        var calls = 0;
        sortByDesc((int n) {
          calls++;
          return n;
        }, [5, 3, 8, 1, 9, 2]);
        expect(calls, equals(6));
      });

      test('should be able to be used in the pipeline', () {
        final top = fx([('a', 3), ('b', 9), ('c', 5)])
            .sortByDesc((p) => p.$2)
            .take(2)
            .map((p) => p.$1)
            .toList();
        expect(top, equals(['b', 'c']));
      });
    });

    group('async', () {
      test('should sort descending', () async {
        expect(await sortByDescAsync((int n) => n, toAsync([2, 9, 5])),
            equals([9, 5, 2]));
      });

      test('should be able to be used in the pipeline', () async {
        final result =
            await fx(['bb', 'a', 'ccc']).toAsync().sortByDesc((s) => s.length);
        expect(result, equals(['ccc', 'bb', 'a']));
      });
    });
  });
}
