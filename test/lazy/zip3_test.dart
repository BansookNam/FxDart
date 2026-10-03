import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('zip3', () {
    group('sync', () {
      test('should zip three iterables', () {
        expect(
          fxZip3([1, 2], ['a', 'b'], [true, false]).toList(),
          equals([(1, 'a', true), (2, 'b', false)]),
        );
      });

      test('should stop at the shortest iterable', () {
        expect(
          fxZip3([1, 2, 3], ['a', 'b'], [true, false, true, false]).toList(),
          equals([(1, 'a', true), (2, 'b', false)]),
        );
      });

      test('should return empty when any iterable is empty', () {
        expect(fxZip3(<int>[], ['a'], [true]).toList(), equals([]));
        expect(fxZip3([1], <String>[], [true]).toList(), equals([]));
        expect(fxZip3([1], ['a'], <bool>[]).toList(), equals([]));
      });

      test('should be lazy', () {
        var pulled = 0;
        Iterable<int> counted() sync* {
          for (var i = 0; i < 10; i++) {
            pulled++;
            yield i;
          }
        }

        final res = fxZip3(
          counted(),
          ['a', 'b'],
          [true, false],
        ).take(1).toList();
        expect(res, equals([(0, 'a', true)]));
        expect(pulled, equals(1));
      });

      test('should be reachable from the fx chain', () {
        expect(
          fx([1, 2, 3]).zip3(['a', 'b'], [true, false]).toList(),
          equals([(1, 'a', true), (2, 'b', false)]),
        );
      });
    });

    group('async', () {
      test('should zip three async iterables', () async {
        expect(
          await fxToListAsync(
            fxZip3Async(
              fxToAsync([1, 2]),
              fxToAsync(['a', 'b']),
              fxToAsync([true, false]),
            ),
          ),
          equals([(1, 'a', true), (2, 'b', false)]),
        );
      });

      test('should stop at the shortest iterable', () async {
        expect(
          await fxToListAsync(
            fxZip3Async(
              fxToAsync([1, 2, 3]),
              fxToAsync(['a', 'b']),
              fxToAsync([true, false, true]),
            ),
          ),
          equals([(1, 'a', true), (2, 'b', false)]),
        );
      });

      test('should return empty when any iterable is empty', () async {
        expect(
          await fxToListAsync(
            fxZip3Async(
              fxToAsync(<int>[]),
              fxToAsync(['a']),
              fxToAsync([true]),
            ),
          ),
          equals([]),
        );
        expect(
          await fxToListAsync(
            fxZip3Async(
              fxToAsync([1]),
              fxToAsync(<String>[]),
              fxToAsync([true]),
            ),
          ),
          equals([]),
        );
        expect(
          await fxToListAsync(
            fxZip3Async(fxToAsync([1]), fxToAsync(['a']), fxToAsync(<bool>[])),
          ),
          equals([]),
        );
      });

      test('should be able to be used in the pipeline', () async {
        final res = await pipe(
          fxZip3Async(
            fxToAsync([1, 2]),
            fxToAsync(['a', 'b']),
            fxToAsync([true, false]),
          ),
          [
            (FxAsyncIterable<(int, String, bool)> a) =>
                fxMapAsync((r) => '${r.$1}${r.$2}${r.$3}', a),
            (FxAsyncIterable<String> a) => fxToListAsync(a),
          ],
        );
        expect(res, equals(['1atrue', '2bfalse']));
      });

      test('should be reachable from the fxAsync chain', () async {
        expect(
          await fxAsync(
            fxToAsync([1, 2, 3]),
          ).zip3(fxToAsync(['a', 'b']), fxToAsync([true, false])).toList(),
          equals([(1, 'a', true), (2, 'b', false)]),
        );
      });
    });
  });
}
