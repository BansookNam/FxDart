import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('zip3', () {
    group('sync', () {
      test('should zip three iterables', () {
        expect(
          zip3([1, 2], ['a', 'b'], [true, false]).toList(),
          equals([(1, 'a', true), (2, 'b', false)]),
        );
      });

      test('should stop at the shortest iterable', () {
        expect(
          zip3([1, 2, 3], ['a', 'b'], [true, false, true, false]).toList(),
          equals([(1, 'a', true), (2, 'b', false)]),
        );
      });

      test('should return empty when any iterable is empty', () {
        expect(zip3(<int>[], ['a'], [true]).toList(), equals([]));
        expect(zip3([1], <String>[], [true]).toList(), equals([]));
        expect(zip3([1], ['a'], <bool>[]).toList(), equals([]));
      });

      test('should be lazy', () {
        var pulled = 0;
        Iterable<int> counted() sync* {
          for (var i = 0; i < 10; i++) {
            pulled++;
            yield i;
          }
        }

        final res = zip3(counted(), ['a', 'b'], [true, false]).take(1).toList();
        expect(res, equals([(0, 'a', true)]));
        expect(pulled, equals(1));
      });
    });

    group('async', () {
      test('should zip three async iterables', () async {
        expect(
          await toArrayAsync(
              zip3Async(toAsync([1, 2]), toAsync(['a', 'b']), toAsync([true, false]))),
          equals([(1, 'a', true), (2, 'b', false)]),
        );
      });

      test('should stop at the shortest iterable', () async {
        expect(
          await toArrayAsync(zip3Async(
              toAsync([1, 2, 3]), toAsync(['a', 'b']), toAsync([true, false, true]))),
          equals([(1, 'a', true), (2, 'b', false)]),
        );
      });

      test('should return empty when any iterable is empty', () async {
        expect(
          await toArrayAsync(
              zip3Async(toAsync(<int>[]), toAsync(['a']), toAsync([true]))),
          equals([]),
        );
        expect(
          await toArrayAsync(
              zip3Async(toAsync([1]), toAsync(<String>[]), toAsync([true]))),
          equals([]),
        );
        expect(
          await toArrayAsync(
              zip3Async(toAsync([1]), toAsync(['a']), toAsync(<bool>[]))),
          equals([]),
        );
      });

      test('should be able to be used in the pipeline', () async {
        final res = await pipe(
          zip3Async(toAsync([1, 2]), toAsync(['a', 'b']), toAsync([true, false])),
          [
            (FxAsyncIterable<(int, String, bool)> a) =>
                mapAsync((r) => '${r.$1}${r.$2}${r.$3}', a),
            (FxAsyncIterable<String> a) => toArrayAsync(a),
          ],
        );
        expect(res, equals(['1atrue', '2bfalse']));
      });
    });
  });
}
