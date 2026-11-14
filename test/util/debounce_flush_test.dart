import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// 0.9.1 additions to fxDebounce: maxWait, flush(), isPending. Real timers
// with wide margins, like debounce_test.dart.
Future<void> wait(int ms) => Future.delayed(Duration(milliseconds: ms));
const ms = Duration(milliseconds: 1);

void main() {
  group('fxDebounce flush / isPending', () {
    test('flush runs the pending call now with the newest argument', () async {
      final seen = <int>[];
      final d = fxDebounce<int>(seen.add, ms * 200);
      expect(d.isPending, isFalse);
      d(1);
      d(2);
      expect(d.isPending, isTrue);
      d.flush();
      expect(seen, [2]);
      expect(d.isPending, isFalse);
      await wait(300);
      expect(seen, [2]); // the timer went with the flush
    });

    test('flush with nothing pending does nothing', () {
      final seen = <int>[];
      final d = fxDebounce<int>(seen.add, ms * 50);
      d.flush();
      expect(seen, isA<List<int>>().having((l) => l.length, 'length', 0));
    });

    test('cancel clears isPending', () async {
      final seen = <int>[];
      final d = fxDebounce<int>(seen.add, ms * 50);
      d(1);
      d.cancel();
      expect(d.isPending, isFalse);
      d.flush();
      await wait(120);
      expect(seen, hasLength(0));
    });

    test('leading mode never reports pending', () {
      final seen = <int>[];
      final d = fxDebounce<int>(seen.add, ms * 50, leading: true);
      d(1);
      d(2);
      expect(seen, [1]);
      expect(d.isPending, isFalse);
      d.cancel();
    });

    test('the extension spelling takes maxWait', () {
      void f(int _) {}
      final d = f.fxDebounce(ms * 10, maxWait: ms * 20);
      d(1);
      expect(d.isPending, isTrue);
      d.cancel();
    });
  });

  group('fxDebounce maxWait', () {
    test('a source that never pauses still fires once per maxWait', () async {
      final seen = <int>[];
      final d = fxDebounce<int>(seen.add, ms * 80, maxWait: ms * 200);
      // A call every 20ms for ~500ms: without maxWait nothing would fire.
      for (var i = 0; i < 25; i++) {
        d(i);
        await wait(20);
      }
      final during = seen.length;
      expect(during, inInclusiveRange(1, 3));
      // Each forced run carries the newest argument of its window.
      for (var j = 1; j < seen.length; j++) {
        expect(seen[j], greaterThan(seen[j - 1]));
      }
      await wait(200);
      expect(seen.last, 24);
    });

    test('without maxWait the same source fires only at the end', () async {
      final seen = <int>[];
      final d = fxDebounce<int>(seen.add, ms * 80);
      for (var i = 0; i < 15; i++) {
        d(i);
        await wait(20);
      }
      expect(seen, hasLength(0));
      await wait(200);
      expect(seen, [14]);
    });

    test('leading + maxWait reopens a leading edge per maxWait', () async {
      final seen = <int>[];
      final d = fxDebounce<int>(
        seen.add,
        ms * 80,
        leading: true,
        maxWait: ms * 150,
      );
      for (var i = 0; i < 20; i++) {
        d(i);
        await wait(20);
      }
      expect(seen.first, 0);
      expect(seen.length, greaterThan(1));
      d.cancel();
    });

    test('maxWait shorter than wait throws', () {
      expect(
        () => fxDebounce<int>((_) {}, ms * 100, maxWait: ms * 50),
        throwsArgumentError,
      );
    });
  });
}
