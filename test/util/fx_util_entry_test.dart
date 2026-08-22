import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('FxCallbackTiming — .fxDebounce / .fxThrottle', () {
    test('.fxDebounce is the same as debounce()', () async {
      final seen = <String>[];
      void record(String s) => seen.add(s);

      final d = record.fxDebounce(const Duration(milliseconds: 20));
      d('a');
      d('b');
      d('c');
      expect(seen, <String>[]);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(seen, ['c']);
    });

    test('.fxDebounce forwards leading:', () async {
      final seen = <int>[];
      void record(int a) => seen.add(a);

      final d = record.fxDebounce(
        const Duration(milliseconds: 20),
        leading: true,
      );
      d(1);
      expect(seen, [1]);
      await Future<void>.delayed(const Duration(milliseconds: 60));
    });

    test('.fxThrottle is the same as throttle()', () async {
      final seen = <int>[];
      void record(int a) => seen.add(a);

      final t = record.fxThrottle(const Duration(milliseconds: 30));
      t(1);
      t(2);
      t(3);
      expect(seen, [1]);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(seen.first, 1);
    });

    test('binds T from the callback', () {
      void takesString(String s) {}
      void takesInt(int a) {}
      expect(
        takesString.fxDebounce(const Duration(milliseconds: 1)),
        isA<Debounced<String>>(),
      );
      expect(
        takesInt.fxThrottle(const Duration(milliseconds: 1)),
        isA<Throttled<int>>(),
      );
    });
  });

  group('FxShuffleEntry — .fxShuffle', () {
    test('is the same as shuffle(), seeded', () {
      final xs = [1, 2, 3, 4, 5, 6, 7, 8];
      expect(xs.fxShuffle(42), shuffle(xs, 42));
    });

    test('does not mutate the receiver', () {
      final xs = [1, 2, 3, 4, 5];
      final out = xs.fxShuffle(7);
      expect(xs, [1, 2, 3, 4, 5]);
      expect(out, unorderedEquals(xs));
    });

    test('the name avoids List.shuffle, which is in-place and void', () {
      final xs = [1, 2, 3];
      final shuffled = xs.fxShuffle(1); // returns a new List
      expect(shuffled, isA<List<int>>());
      xs.shuffle(); // dart:core, in place, returns void
      expect(xs, unorderedEquals([1, 2, 3]));
    });

    test('async counterpart matches shuffleAsync()', () async {
      final xs = [1, 2, 3, 4, 5, 6];
      expect(
        await toAsync(xs).fxShuffle(9),
        await shuffleAsync(toAsync(xs), 9),
      );
    });
  });

  group('FxEventsEntry — .fxLive / .fxLiveSeeded', () {
    test('.fxLive matches LiveValue.from', () async {
      final c = StreamController<int>();
      final live = c.stream.fxLive;
      expect(live.hasValue, isFalse);
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(live.value, 1);
      await c.close();
      live.close();
    });

    test('.fxLiveSeeded holds the seed until the source speaks', () async {
      final c = StreamController<int>();
      final live = c.stream.fxLiveSeeded(0);
      expect(live.value, 0);
      c.add(5);
      await Future<void>.delayed(Duration.zero);
      expect(live.value, 5);
      await c.close();
      live.close();
    });
  });
}
