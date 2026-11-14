import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

class _State {
  final int gold;
  _State(this.gold);
}

void main() {
  group('fxMemoizeLast', () {
    test('same instance is served from the slot', () {
      var calls = 0;
      final f = fxMemoizeLast((_State s) {
        calls++;
        return s.gold * 2;
      });
      final a = _State(3);
      expect(f(a), 6);
      expect(f(a), 6);
      expect(calls, 1);
    });

    test('an equal but new instance recomputes under identical', () {
      var calls = 0;
      final f = fxMemoizeLast((List<int> xs) {
        calls++;
        return xs.length;
      });
      f([1, 2]);
      f([1, 2]);
      expect(calls, 2);
    });

    test('keeps only the last argument', () {
      var calls = 0;
      final f = fxMemoizeLast((_State s) {
        calls++;
        return s.gold;
      });
      final a = _State(1), b = _State(2);
      f(a);
      f(b);
      f(a);
      expect(calls, 3);
      f(a);
      expect(calls, 3);
    });

    test('equals: value comparison and record keys', () {
      var calls = 0;
      final byValue = fxMemoizeLast<String, int>((s) {
        calls++;
        return s.length;
      }, equals: (a, b) => a == b);
      byValue('ab');
      byValue(String.fromCharCodes('ab'.codeUnits));
      expect(calls, 1);

      final s = _State(5);
      var recCalls = 0;
      final card = fxMemoizeLast<(_State, String), String>((k) {
        recCalls++;
        return '${k.$2}:${k.$1.gold}';
      }, equals: (a, b) => identical(a.$1, b.$1) && a.$2 == b.$2);
      expect(card((s, 'x')), 'x:5');
      expect(card((s, 'x')), 'x:5');
      expect(card((s, 'y')), 'y:5');
      expect(recCalls, 2);
    });

    test('a null result is cached too', () {
      var calls = 0;
      final f = fxMemoizeLast<int, String?>((n) {
        calls++;
        return null;
      });
      f(1);
      f(1);
      expect(calls, 1);
    });
  });
}
