import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// unzip is zip's inverse, so the round trip is the contract worth pinning.
// The list source and the pulled source take different loops.
//
// The results are destructured before comparing: a record's `==` compares its
// fields with `==`, and two equal-but-distinct Lists are not `==`.
void main() {
  group('unzip', () {
    group('sync', () {
      test('splits pairs into two lists', () {
        final (left, right) = unzip([('a', 1), ('b', 2)]);
        expect(left, ['a', 'b']);
        expect(right, [1, 2]);
      });

      test('empty input gives two empty lists', () {
        final (left, right) = unzip(<(String, int)>[]);
        expect(left, <String>[]);
        expect(right, <int>[]);
      });

      test('single pair', () {
        final (left, right) = unzip([('a', 1)]);
        expect(left, ['a']);
        expect(right, [1]);
      });

      test('inverts zip, truncated to the shorter side', () {
        // zip() is not a List, so this also drives the pulled loop.
        final (left, right) = unzip(zip(['a', 'b', 'c'], [1, 2]));
        expect(left, ['a', 'b']);
        expect(right, [1, 2]);
      });

      test('round-trips equal-length inputs exactly', () {
        final expectedLeft = ['a', 'b', 'c'];
        final expectedRight = [1, 2, 3];
        final (left, right) = unzip(zip(expectedLeft, expectedRight).toList());
        expect(left, expectedLeft);
        expect(right, expectedRight);
      });

      test('the list and the pulled loop agree', () {
        final pairs = [('a', 1), ('b', 2), ('c', 3)];
        final (listLeft, listRight) = unzip(pairs);
        final (pulledLeft, pulledRight) = unzip(filter((_) => true, pairs));
        expect(pulledLeft, listLeft);
        expect(pulledRight, listRight);
      });

      test('keeps duplicate and null components', () {
        final (left, right) = unzip([(1, null), (1, 'x')]);
        expect(left, [1, 1]);
        expect(right, [null, 'x']);
      });
    });

    group('async', () {
      test('agrees with the sync spelling', () async {
        final pairs = [('a', 1), ('b', 2)];
        final (syncLeft, syncRight) = unzip(pairs);
        final (left, right) = await unzipAsync(toAsync(pairs));
        expect(left, syncLeft);
        expect(right, syncRight);
      });

      test('empty input gives two empty lists', () async {
        final (left, right) = await unzipAsync(toAsync(<(String, int)>[]));
        expect(left, <String>[]);
        expect(right, <int>[]);
      });
    });

    group('chain', () {
      test('FxPair.unzip agrees with the top-level function', () {
        final pairs = [('a', 1), ('b', 2)];
        final (expectedLeft, expectedRight) = unzip(pairs);
        final (left, right) = fx(pairs).unzip();
        expect(left, expectedLeft);
        expect(right, expectedRight);
      });

      test('FxPair.unzip closes a zip chain', () {
        final (left, right) = fx(['a', 'b', 'c']).zip([1, 2, 3]).unzip();
        expect(left, ['a', 'b', 'c']);
        expect(right, [1, 2, 3]);
      });

      test('FxAsyncPair.unzip agrees with the top-level function', () async {
        final pairs = [('a', 1), ('b', 2)];
        final (expectedLeft, expectedRight) = unzip(pairs);
        final (left, right) = await fxAsync(toAsync(pairs)).unzip();
        expect(left, expectedLeft);
        expect(right, expectedRight);
      });
    });
  });
}
