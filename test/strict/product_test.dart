import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// product completes the numeric aggregate family beside sum/average.
//
// Empty input is 1, the multiplicative identity: it is the only value that
// keeps `fxProduct(fxConcat(xs, ys)) == fxProduct(xs) * fxProduct(ys)` true when one
// side is empty, exactly as sum's empty 0 does for addition.
//
// The int-then-double accumulation is the same as sum's, so the int-only and
// the switched-to-double paths are both driven, on a list and on a pulled
// source.
void main() {
  group('product', () {
    test('multiplies every number', () {
      expect(fxProduct([2, 3, 4]), 24);
    });

    test('empty input is the multiplicative identity 1', () {
      expect(fxProduct(<num>[]), 1);
      expect(fxProduct(<num>[]), isA<int>());
    });

    test('the identity law holds across a concat with an empty side', () {
      final xs = [2, 3];
      expect(
        fxProduct(fxConcat(xs, <num>[])),
        fxProduct(xs) * fxProduct(<num>[]),
      );
    });

    test('single element is that element', () {
      expect(fxProduct([7]), 7);
    });

    test('stays an int while every element is an int', () {
      expect(fxProduct([2, 3]), isA<int>());
    });

    test('switches to double at the first double', () {
      expect(fxProduct([2, 1.5]), 3.0);
      expect(fxProduct([2, 1.5]), isA<double>());
      expect(fxProduct([1.5, 2]), 3.0);
    });

    test('a zero anywhere makes the product zero', () {
      expect(fxProduct([2, 0, 3]), 0);
    });

    test('a pulled source gives the same value as a list', () {
      final list = [1, 2, 3, 4];
      expect(
        fxProduct(Iterable<int>.generate(4, (i) => i + 1)),
        fxProduct(list),
      );
    });

    test('async agrees with the sync spelling', () async {
      expect(await fxProductAsync(fxToAsync([2, 3, 4])), fxProduct([2, 3, 4]));
      expect(await fxProductAsync(fxToAsync(<num>[])), fxProduct(<num>[]));
    });

    test('FxNum.product agrees with the top-level function', () {
      expect(FxNum(fx([2, 3, 4])).product(), fxProduct([2, 3, 4]));
      expect(FxNum(fx(<num>[])).product(), 1);
    });

    test('FxAsyncNum.product agrees with the top-level function', () async {
      expect(
        await fxAsync(fxToAsync([2, 3, 4])).product(),
        fxProduct([2, 3, 4]),
      );
    });
  });

  group('productBy', () {
    test('multiplies the key of every element', () {
      expect(fxProductBy((String s) => s.length, ['ab', 'cde']), 6);
    });

    test('empty input is 1', () {
      expect(fxProductBy((String s) => s.length, <String>[]), 1);
    });

    test('single element is that element key', () {
      expect(fxProductBy((String s) => s.length, ['abc']), 3);
    });

    test('list source: int-only and switched-to-double', () {
      expect(fxProductBy((int a) => a, [2, 3]), 6);
      expect(fxProductBy((int a) => a / 2, [3, 4]), 3.0);
      expect(fxProductBy((int a) => a.isEven ? a / 2 : a, [3, 4]), 6.0);
    });

    test('pulled source: int-only and switched-to-double', () {
      final pulled = Iterable<int>.generate(3, (i) => i + 2); // 2, 3, 4
      expect(fxProductBy((int a) => a, pulled), 24);
      expect(fxProductBy((int a) => a / 2, pulled), 3.0);
      expect(fxProductBy((int a) => a == 4 ? a / 2 : a, pulled), 12.0);
    });

    test('agrees with product(map(f, xs))', () {
      num f(String s) => s.length;
      final xs = ['a', 'bc', 'def'];
      expect(fxProductBy(f, xs), fxProduct(fxMap(f, xs)));
    });

    test('async agrees with the sync spelling', () async {
      num f(String s) => s.length;
      final xs = ['ab', 'cde'];
      expect(await fxProductByAsync(f, fxToAsync(xs)), fxProductBy(f, xs));
      expect(await fxProductByAsync(f, fxToAsync(<String>[])), 1);
    });

    test('Fx.productBy agrees with the top-level function', () {
      num f(String s) => s.length;
      final xs = ['ab', 'cde'];
      expect(fx(xs).productBy(f), fxProductBy(f, xs));
    });

    test('FxAsync.productBy agrees with the top-level function', () async {
      num f(String s) => s.length;
      final xs = ['ab', 'cde'];
      expect(await fxAsync(fxToAsync(xs)).productBy(f), fxProductBy(f, xs));
    });
  });
}
