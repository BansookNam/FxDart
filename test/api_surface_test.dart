// Calls every `Fx` / `FxAsync` member that a user can write with no arguments
// (or with all of its arguments defaulted), and asserts the result.
//
// This exists because line coverage cannot see this class of bug. `Fx.join`
// took a *required* separator from 0.8.0 to 0.8.2: redeclaring a member on an
// extension type REPLACES the interface member rather than overriding it, so
// `Iterable.join`'s default never applied and `fx(xs).join()` did not compile.
// Every join test passed a separator, so coverage stayed at 100% while the
// call shape users would actually write was broken — for two releases.
//
// The value here is largely in *compiling*: a member that stops being callable
// bare fails the build. The assertions pin the defaults on top of that.
import 'package:fxdart/fxdart.dart';
// fxdart exports predicate helpers that collide with matcher's names.
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('Fx — every bare-callable member', () {
    test('lazy operators', () {
      expect(fx([1, 2, 3]).pairwise().toList(), [(1, 2), (2, 3)]);
      expect(fx([1, 2, 2, 3]).uniq().toList(), [1, 2, 3]);
      expect(fx([1, 2, 2, 3]).distinct().toList(), [1, 2, 3]);
      expect(fx([1, 2, 2, 3]).uniqStrict(), [1, 2, 3]);
      expect(fx([1, 1, 2, 1]).uniqAdjacent().toList(), [1, 2, 1]);
      expect(fx(['a', 'b']).zipWithIndex().toList(), [(0, 'a'), (1, 'b')]);
      expect(fx([1, 2, 3]).reverse().toList(), [3, 2, 1]);
      expect(fx([1, 2]).cycle().take(5).toList(), [1, 2, 1, 2, 1]);
    });

    test('flat / flattened default to depth 1', () {
      expect(fx([
        [1, 2],
        [3]
      ]).flat().toList(), [1, 2, 3]);
      expect(fx([
        [1, 2],
        [3]
      ]).flattened().toList(), [1, 2, 3]);
    });

    test('terminals', () {
      expect(fx([1, 2, 3]).toList(), [1, 2, 3]);
      expect(fx([1, 2, 3]).head(), 1);
      expect(fx(<int>[]).head(), isNull);
      expect(fx([1, 2, 3]).size(), 3);
      // The regression this file was written for.
      expect(fx([1, 2, 3]).join(), '123');
      expect(fx(<int>[]).join(), '');
    });

    test('consume() with no count drains the whole chain', () {
      var seen = 0;
      fx([1, 2, 3]).peek((_) => seen++).consume();
      expect(seen, 3);
    });

    test('toAsync() bridges without arguments', () async {
      expect(await fx([1, 2, 3]).toAsync().toList(), [1, 2, 3]);
    });

    test('FxNum aggregates', () {
      expect(fx(<num>[1, 2, 3]).sum(), 6);
      expect(fx(<num>[1, 2, 3]).average(), 2);
      expect(fx(<num>[3, 1, 2]).min(), 1);
      expect(fx(<num>[3, 1, 2]).max(), 3);
    });
  });

  group('FxAsync — every bare-callable member', () {
    FxAsync<int> src() => fx([1, 2, 3]).toAsync();

    test('lazy operators', () async {
      expect(await fx([1, 2, 3]).toAsync().pairwise().toList(), [(1, 2), (2, 3)]);
      expect(await fx([1, 2, 2, 3]).toAsync().uniq().toList(), [1, 2, 3]);
      expect(await fx([1, 2, 2, 3]).toAsync().distinct().toList(), [1, 2, 3]);
      expect(await fx([1, 1, 2, 1]).toAsync().uniqAdjacent().toList(),
          [1, 2, 1]);
      expect(await fx(['a', 'b']).toAsync().zipWithIndex().toList(),
          [(0, 'a'), (1, 'b')]);
      expect(await fx([1, 2, 3]).toAsync().reverse().toList(), [3, 2, 1]);
      expect(await fx([1, 2]).toAsync().cycle().take(5).toList(),
          [1, 2, 1, 2, 1]);
      expect(await fx(['a', 'b']).toAsync().indexed().toList(),
          [(0, 'a'), (1, 'b')]);
    });

    test('flat / flattened default to depth 1', () async {
      expect(
          await fx([
            [1, 2],
            [3]
          ]).toAsync().flat().toList(),
          [1, 2, 3]);
      expect(
          await fx([
            [1, 2],
            [3]
          ]).toAsync().flattened().toList(),
          [1, 2, 3]);
    });

    test('terminals', () async {
      expect(await src().toList(), [1, 2, 3]);
      expect(await src().head(), 1);
      expect(await src().last(), 3);
      expect(await src().size(), 3);
      expect(await src().count(), 3);
      expect(await src().firstOrNull(), 1);
      expect(await src().lastOrNull(), 3);
      expect(await fx(<int>[]).toAsync().firstOrNull(), isNull);
      expect(await fx(<int>[]).toAsync().lastOrNull(), isNull);
    });

    test('toStream() takes no arguments', () async {
      expect(await src().toStream().toList(), [1, 2, 3]);
    });

    test('consume() with no count drains the whole chain', () async {
      var seen = 0;
      await fx([1, 2, 3]).toAsync().peek((_) => seen++).consume();
      expect(seen, 3);
    });

    test('FxAsyncNum aggregates', () async {
      expect(await fx(<num>[1, 2, 3]).toAsync().sum(), 6);
      expect(await fx(<num>[1, 2, 3]).toAsync().average(), 2);
      expect(await fx(<num>[3, 1, 2]).toAsync().min(), 1);
      expect(await fx(<num>[3, 1, 2]).toAsync().max(), 3);
    });

    test('join() defaults to a COMMA on the async side, unlike sync', () async {
      // Deliberate pin of an asymmetry, not an endorsement of it:
      //   fx(xs).join()        -> '123'   (matches Iterable.join)
      //   fxAsync(xs).join()   -> '1,2,3'
      // Switching a chain from sync to async silently changes the output.
      // Left as-is because changing a published default is a breaking change;
      // pass the separator explicitly in real code.
      expect(await src().join(), '1,2,3');
      expect(fx([1, 2, 3]).join(), '123');
    });
  });
}
