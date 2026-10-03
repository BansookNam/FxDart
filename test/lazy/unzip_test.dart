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
        final (left, right) = fxUnzip([('a', 1), ('b', 2)]);
        expect(left, ['a', 'b']);
        expect(right, [1, 2]);
      });

      test('empty input gives two empty lists', () {
        final (left, right) = fxUnzip(<(String, int)>[]);
        expect(left, <String>[]);
        expect(right, <int>[]);
      });

      test('single pair', () {
        final (left, right) = fxUnzip([('a', 1)]);
        expect(left, ['a']);
        expect(right, [1]);
      });

      test('inverts zip, truncated to the shorter side', () {
        // zip() is not a List, so this also drives the pulled loop.
        final (left, right) = fxUnzip(fxZip(['a', 'b', 'c'], [1, 2]));
        expect(left, ['a', 'b']);
        expect(right, [1, 2]);
      });

      test('round-trips equal-length inputs exactly', () {
        final expectedLeft = ['a', 'b', 'c'];
        final expectedRight = [1, 2, 3];
        final (left, right) = fxUnzip(
          fxZip(expectedLeft, expectedRight).toList(),
        );
        expect(left, expectedLeft);
        expect(right, expectedRight);
      });

      test('the list and the pulled loop agree', () {
        final pairs = [('a', 1), ('b', 2), ('c', 3)];
        final (listLeft, listRight) = fxUnzip(pairs);
        final (pulledLeft, pulledRight) = fxUnzip(fxFilter((_) => true, pairs));
        expect(pulledLeft, listLeft);
        expect(pulledRight, listRight);
      });

      test('keeps duplicate and null components', () {
        final (left, right) = fxUnzip([(1, null), (1, 'x')]);
        expect(left, [1, 1]);
        expect(right, [null, 'x']);
      });
    });

    group('async', () {
      test('agrees with the sync spelling', () async {
        final pairs = [('a', 1), ('b', 2)];
        final (syncLeft, syncRight) = fxUnzip(pairs);
        final (left, right) = await fxUnzipAsync(fxToAsync(pairs));
        expect(left, syncLeft);
        expect(right, syncRight);
      });

      test('empty input gives two empty lists', () async {
        final (left, right) = await fxUnzipAsync(fxToAsync(<(String, int)>[]));
        expect(left, <String>[]);
        expect(right, <int>[]);
      });
    });

    group('chain', () {
      test('FxPair.unzip agrees with the top-level function', () {
        final pairs = [('a', 1), ('b', 2)];
        final (expectedLeft, expectedRight) = fxUnzip(pairs);
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
        final (expectedLeft, expectedRight) = fxUnzip(pairs);
        final (left, right) = await fxAsync(fxToAsync(pairs)).unzip();
        expect(left, expectedLeft);
        expect(right, expectedRight);
      });
    });
  });
}
