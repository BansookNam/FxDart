import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('fxOnChange', () {
    test('runs only when the argument changes; first call always runs', () {
      final seen = <int>[];
      final f = fxOnChange<int>(seen.add);
      for (final x in [1, 1, 2, 2, 2, 1, 3, 3]) {
        f(x);
      }
      expect(seen, [1, 2, 1, 3]);
    });

    test('a null first argument still runs', () {
      final seen = <int?>[];
      final f = fxOnChange<int?>(seen.add);
      f(null);
      f(null);
      f(1);
      expect(seen, [null, 1]);
    });

    test('custom equals', () {
      final seen = <String>[];
      final f = fxOnChange<String>(
        seen.add,
        equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
      );
      f('a');
      f('A');
      f('b');
      expect(seen, ['a', 'b']);
    });

    test('reset forgets the last value', () {
      final seen = <int>[];
      final f = fxOnChange<int>(seen.add);
      f(1);
      f.reset();
      f(1);
      expect(seen, [1, 1]);
    });

    test('extension spelling', () {
      final seen = <int>[];
      final f = seen.add.fxOnChange();
      f(1);
      f(1);
      expect(seen, [1]);
    });

    test('a call that throws is not recorded as the last argument', () {
      var calls = 0;
      final f = fxOnChange<int>((_) {
        if (++calls == 1) throw StateError('first');
      });
      expect(() => f(5), throwsStateError);
      f(5);
      f(5);
      expect(calls, 2);
    });
  });
}
