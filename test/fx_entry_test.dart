import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('FxEntry — .fx on Iterable', () {
    test('is the same chain as fx()', () {
      final xs = [1, 2, 3, 4, 5];
      expect(
        xs.fx.map((a) => a + 10).filter((a) => a.isEven).toList(),
        fx(xs).map((a) => a + 10).filter((a) => a.isEven).toList(),
      );
    });

    test('stays lazy — nothing runs before a terminal', () {
      var seen = 0;
      final chain = [1, 2, 3].fx.peek((_) => seen++);
      expect(seen, 0);
      expect(chain.toList(), [1, 2, 3]);
      expect(seen, 3);
    });

    test('FxNum applies through covariance without a type argument', () {
      expect([1, 2, 3].fx.sum(), 6);
      expect([1, 2, 3].fx.average(), 2);
    });

    test('an explicit type argument goes through the extension override', () {
      expect(FxEntry<num>([1, 2, 3]).fx.sum(), 6);
      final Fx<num> widened = [1, 2, 3].fx;
      expect(widened.sum(), 6);
    });

    test('works on every Iterable shape', () {
      expect({3, 1, 2}.fx.toList(), [3, 1, 2]);
      expect('한글'.runes.fx.length, 2);
      expect({'a': 1, 'b': 2}.entries.fx.map((e) => e.key).toList(),
          ['a', 'b']);
      expect(range(0, 10, 3).fx.toList(), [0, 3, 6, 9]);
      expect(Iterable<int>.generate(1000000).fx.take(3).toList(), [0, 1, 2]);
    });

    test('is null-aware friendly', () {
      List<int>? maybe(bool present) => present ? [1, 2, 3] : null;
      expect(maybe(true)?.fx.sum(), 6);
      expect(maybe(false)?.fx.sum(), equals(null));
    });

    test('an Fx receiver resolves to itself', () {
      final chain = [1, 2, 3].fx.map((a) => a * 2);
      expect(chain.fx.toList(), [2, 4, 6]);
    });
  });

  group('FxAsyncEntry / FxStreamEntry / FxFutureEntry', () {
    test('.fx on an FxAsyncIterable chains', () async {
      expect(await toAsync([1, 2, 3]).fx.map((a) => a * 2).toList(),
          [2, 4, 6]);
    });

    test('.fx on a Stream chains', () async {
      expect(
        await Stream.fromIterable([1, 2, 3]).fx.filter((a) => a.isOdd)
            .toList(),
        [1, 3],
      );
    });

    test('.fxAsync resolves the futures rather than chaining over them',
        () async {
      final futures = <Future<int>>[
        Future.value(1),
        Future.value(2),
        Future.value(3),
      ];
      expect(futures.fx.length, 3); // Fx<Future<int>> — the trap it avoids
      expect(await futures.fxAsync.sum(), 6);
    });

    test('.fxAsync carries the concurrency back-channel', () async {
      var running = 0, peak = 0;
      Future<int> slow(int a) async {
        running++;
        peak = peak > running ? peak : running;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        running--;
        return a;
      }

      final out = await [1, 2, 3, 4]
          .fxAsync
          .map(slow)
          .concurrent(4)
          .toList();
      expect(out, [1, 2, 3, 4]);
      expect(peak, greaterThan(1));
    });

    test('.fxAsync also accepts a plain iterable of values', () async {
      expect(await [1, 2, 3].fxAsync.toList(), [1, 2, 3]);
    });
  });

  group('FxEventsEntry — .fxEvents on Stream', () {
    test('is the same chain as fxEvents()', () async {
      Stream<int> src() => Stream.fromIterable([1, 2, 3]);
      expect(
        await src().fxEvents.map((a) => a * 2).toList(),
        await fxEvents(src()).map((a) => a * 2).toList(),
      );
    });

    test('stays cold until something listens', () async {
      var listened = 0;
      final src = Stream<int>.multi((c) {
        listened++;
        c
          ..add(1)
          ..close();
      });
      final chain = src.fxEvents.map((a) => a + 1);
      expect(listened, 0);
      expect(await chain.toList(), [2]);
      expect(listened, 1);
    });

    test('the push and pull getters on Stream stay distinct', () async {
      final events = Stream.fromIterable([1, 2, 3]).fxEvents;
      final pull = Stream.fromIterable([1, 2, 3]).fx;
      expect(events, isA<FxEvents<int>>());
      expect(pull, isA<FxAsync<int>>());
      expect(await events.toList(), await pull.toList());
    });

    test('crosses into the pull chain with .pull', () async {
      expect(
        await Stream.fromIterable([1, 2, 3, 4])
            .fxEvents
            .debounce(const Duration(milliseconds: 1))
            .pull()
            .toList(),
        [4],
      );
    });
  });
}
