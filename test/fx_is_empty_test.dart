import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Fx.isEmpty was `size() == 0` through 0.8.5 — an O(n) walk, so it never
// returned on an unbounded chain. The timeouts below are the regression
// guard: a reverted fix has to fail the test rather than hang the suite.
void main() {
  group('Fx.isEmpty / isNotEmpty', () {
    test('agree with the element count on finite chains', () {
      expect(fx(<int>[]).isEmpty, isTrue);
      expect(fx(<int>[]).isNotEmpty, isFalse);
      expect(fx([1]).isEmpty, isFalse);
      expect(fx([1]).isNotEmpty, isTrue);
      expect(fx([1, 2, 3]).isEmpty, isFalse);
      expect(fx([1, 2, 3]).isNotEmpty, isTrue);
    });

    test('see through a lazy chain that filters everything out', () {
      expect(fx([1, 3, 5]).filter((a) => a.isEven).isEmpty, isTrue);
      expect(fx([1, 3, 5]).filter((a) => a.isOdd).isNotEmpty, isTrue);
    });

    test('terminate on an unbounded chain', () {
      expect(fx(cycle([1, 2])).isEmpty, isFalse);
      expect(fx(cycle([1, 2])).isNotEmpty, isTrue);
    }, timeout: const Timeout(Duration(seconds: 5)));

    test('terminate on an unbounded chain built with map/filter stages', () {
      final chain = fx(cycle([1, 2, 3])).map((a) => a * 2).filter((a) => a > 2);
      expect(chain.isEmpty, isFalse);
      expect(chain.isNotEmpty, isTrue);
    }, timeout: const Timeout(Duration(seconds: 5)));

    test('consume only the first element', () {
      var pulled = 0;
      final chain = fx([1, 2, 3, 4, 5]).peek((_) => pulled++);
      expect(chain.isEmpty, isFalse);
      expect(pulled, 1);
    });

    test('length still counts, and stays O(1) for a List source', () {
      // O(n) is inherent for a general Iterable, so length is deliberately
      // left as a full walk — only isEmpty was wrong.
      expect(fx([1, 2, 3]).length, 3);
      expect(fx(<int>[]).length, 0);
      expect(fx([1, 2, 3]).filter((a) => a.isOdd).length, 2);
    });
  });
}
