// `windowed(...).map(f)` and `chunk(...).map(f)` are built as a single stage
// rather than two (see FxMapFusable): at the default `step: 1`, `windowed`
// emits one window per source element, so the boundary between it and the
// `map` stage is paid at the full element rate.
//
// The fused iterator is a second, separately written copy of
// _WindowRangeIterator's bound arithmetic, so the bug this can introduce is
// the two drifting apart. Every behavioural test below therefore runs the same
// source through three spellings and pins them against each other:
//
//   * `windowed(...).map(f)` via the SDK's `Iterable.map` — never fuses, so it
//     is the reference for what the layered pair used to do;
//   * fxdart's `map(f, windowed(...))` over a `List` — the fused indexed path;
//   * the same over a generator — the fused pulled path, which still uses the
//     ring buffer and so exercises the *other* window-building loop.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// The layered pair, built so it cannot fuse: `Iterable.map` is the SDK's own
/// instance method and knows nothing about [FxMapFusable].
Iterable<B> unfused<A, B>(Iterable<List<A>> windows, B Function(List<A>) f) =>
    windows.map(f);

/// A non-`List` source, so `fxListRangeOf` returns null and the ring-buffer
/// path is taken.
Iterable<A> pulled<A>(List<A> xs) sync* {
  for (final x in xs) {
    yield x;
  }
}

/// Every window the three spellings produce, as a plain nested list.
List<List<A>> windowsOf<A>(
  List<A> src,
  int size, {
  int step = 1,
  bool partial = false,
}) => map(
  (List<A> w) => w.toList(),
  windowed(size, src, step: step, partial: partial),
).toList();

/// Asserts the layered pair, the fused indexed path and the fused pulled path
/// all produce [expected].
void expectAllSpellings(
  List<int> src,
  int size, {
  required List<String> expected,
  int step = 1,
  bool partial = false,
}) {
  String render(List<int> w) => w.join('-');

  expect(
    unfused(windowed(size, src, step: step, partial: partial), render).toList(),
    expected,
    reason: 'layered pair (the reference)',
  );
  expect(
    map(render, windowed(size, src, step: step, partial: partial)).toList(),
    expected,
    reason: 'fused, List source',
  );
  expect(
    map(
      render,
      windowed(size, pulled(src), step: step, partial: partial),
    ).toList(),
    expected,
    reason: 'fused, pulled source',
  );
  expect(
    fx(src).windowed(size, step: step, partial: partial).map(render).toList(),
    expected,
    reason: 'fused through the fx chain',
  );
}

void main() {
  group('windowed().map() fusion', () {
    test('builds one stage, not a map wrapping a windowed', () {
      // White-box: nothing else here fails if the two stages stop fusing, and
      // the boundary is paid once per source element.
      expect(
        map(
          (List<int> w) => w.length,
          windowed(3, [1, 2, 3, 4]),
        ).runtimeType.toString(),
        startsWith('_WindowMapIterable'),
      );
      // A List source resolves to the indexed iterator...
      expect(
        map(
          (List<int> w) => w.length,
          windowed(3, [1, 2, 3, 4]),
        ).iterator.runtimeType.toString(),
        startsWith('_WindowRangeMapIterator'),
      );
      // ...and anything else keeps the ring buffer.
      expect(
        map(
          (List<int> w) => w.length,
          windowed(3, pulled([1, 2, 3, 4])),
        ).iterator.runtimeType.toString(),
        startsWith('_WindowMapIterator'),
      );
      // A stage that cannot absorb a map still gets the plain map stage.
      expect(
        map((int a) => a, [1, 2, 3]).runtimeType.toString(),
        startsWith('_MapIterable'),
      );
    });

    test('same windows, contents and order as the layered pair', () {
      expectAllSpellings(
        [1, 2, 3, 4, 5],
        3,
        expected: ['1-2-3', '2-3-4', '3-4-5'],
      );
    });

    test('slides by the given step', () {
      expectAllSpellings(
        [1, 2, 3, 4, 5],
        3,
        step: 2,
        expected: ['1-2-3', '3-4-5'],
      );
    });

    test('skips the gap when step exceeds size', () {
      expectAllSpellings(
        [1, 2, 3, 4, 5, 6, 7, 8],
        2,
        step: 3,
        expected: ['1-2', '4-5', '7-8'],
      );
    });

    test('keeps trailing partial windows when asked', () {
      expectAllSpellings(
        [1, 2, 3, 4, 5],
        3,
        partial: true,
        expected: ['1-2-3', '2-3-4', '3-4-5', '4-5', '5'],
      );
      expectAllSpellings(
        [1, 2, 3, 4, 5],
        3,
        step: 2,
        partial: true,
        expected: ['1-2-3', '3-4-5', '5'],
      );
    });

    test('a size wider than the source yields nothing without partial', () {
      expectAllSpellings([1, 2, 3], 5, expected: <String>[]);
      expectAllSpellings(
        [1, 2, 3],
        5,
        partial: true,
        expected: ['1-2-3', '2-3', '3'],
      );
      // Exactly as wide as the source is still one full window.
      expectAllSpellings([1, 2, 3], 3, expected: ['1-2-3']);
    });

    test('an empty source yields nothing, partial or not', () {
      expectAllSpellings(<int>[], 3, expected: <String>[]);
      expectAllSpellings(<int>[], 3, partial: true, expected: <String>[]);
      expectAllSpellings(<int>[], 1, partial: true, expected: <String>[]);
      expect(
        map(
          (List<int> w) => w.length,
          windowed(2, <int>[]),
        ).iterator.moveNext(),
        isFalse,
      );
    });

    test('a size of one is one window per element', () {
      expectAllSpellings([7, 8, 9], 1, expected: ['7', '8', '9']);
    });

    test('chunk().map() fuses the same way', () {
      String render(List<int> w) => w.join('-');
      const src = [1, 2, 3, 4, 5, 6, 7];

      expect(
        map(render, chunk(3, src)).toList(),
        unfused(chunk(3, src), render).toList(),
      );
      expect(map(render, chunk(3, src)).toList(), ['1-2-3', '4-5-6', '7']);
      expect(map(render, chunk(3, pulled(src))).toList(), [
        '1-2-3',
        '4-5-6',
        '7',
      ]);
      expect(fx(src).chunk(3).map(render).toList(), ['1-2-3', '4-5-6', '7']);
      // chunk's non-positive-size escape hatch has no windows to fuse.
      expect(map(render, chunk(0, src)).toList(), <String>[]);
    });

    test('windows over a take/drop range are offset, not restarted', () {
      const src = [1, 2, 3, 4, 5, 6, 7, 8];
      final range = drop(2, take(7, src));
      expect(
        map((List<int> w) => w.join('-'), windowed(2, range)).toList(),
        unfused(windowed(2, range), (List<int> w) => w.join('-')).toList(),
      );
      expect(map((List<int> w) => w.join('-'), windowed(2, range)).toList(), [
        '3-4',
        '4-5',
        '5-6',
        '6-7',
      ]);
    });

    test('runs the callback once per window consumed, in order', () {
      for (final src in <Iterable<int>>[
        [1, 2, 3, 4],
        pulled([1, 2, 3, 4]),
      ]) {
        final seen = <String>[];
        final result = map((List<int> w) {
          seen.add(w.join('-'));
          return w.first;
        }, windowed(2, src)).toList();

        expect(result, [1, 2, 3]);
        expect(seen, [
          '1-2',
          '2-3',
          '3-4',
        ], reason: 'once per window, in order');
      }
    });

    test('stays lazy: a downstream take stops the source', () {
      final pulls = <int>[];
      Iterable<int> counting() sync* {
        for (var i = 1; i <= 100; i++) {
          pulls.add(i);
          yield i;
        }
      }

      final calls = <String>[];
      final result = fx(counting())
          .windowed(3)
          .map((w) {
            calls.add(w.join('-'));
            return w.last;
          })
          .take(2)
          .toList();

      expect(result, [3, 4]);
      expect(calls, ['1-2-3', '2-3-4']);
      expect(pulls, [
        1,
        2,
        3,
        4,
      ], reason: 'no element pulled past the 2nd window');
    });

    test('stays lazy over an endless List-backed range', () {
      final calls = <int>[];
      final result = fx(range(1, 1000000))
          .windowed(4)
          .map((w) {
            calls.add(w.first);
            return w.reduce((a, b) => a + b);
          })
          .take(3)
          .toList();

      expect(result, [10, 14, 18]);
      expect(calls, [1, 2, 3], reason: 'the callback ran three times, not 1e6');
    });

    test('supports repeated iteration with the same result', () {
      final chain = fx([1, 2, 3, 4]).windowed(2).map((w) => w.join('-'));
      expect(chain.toList(), ['1-2', '2-3', '3-4']);
      expect(chain.toList(), ['1-2', '2-3', '3-4']);
      expect(chain.toList(), chain.toList());
      // and the lazy walk agrees with toList
      expect([for (final v in chain) v], chain.toList());
    });

    test('sees a List source that grew between iterations', () {
      final src = [1, 2, 3];
      final chain = map((List<int> w) => w.join('-'), windowed(2, src));
      expect(chain.toList(), ['1-2', '2-3']);
      src.add(4);
      expect(
        chain.toList(),
        ['1-2', '2-3', '3-4'],
        reason:
            'the range is resolved per iteration, not when the chain is '
            'built',
      );
    });

    test('the window handed to the callback is the window, not a view', () {
      final windows = <List<int>>[];
      map((List<int> w) {
        windows.add(w);
        return w.length;
      }, windowed(2, [1, 2, 3])).toList();

      expect(windows, [
        [1, 2],
        [2, 3],
      ]);
      // Each window is its own list: mutating one cannot disturb the next.
      windows.first[0] = 99;
      expect(windows.last, [2, 3]);
    });

    test('every path hands back a growable window, fused or not', () {
      // The bulk-copy canary. `_windowSlice` and `_WindowIterator._emit` both
      // hand the copy to `List.sublist` to avoid a covariant store check per
      // element, and a growable result is how that is observable from outside
      // — on `smoothed-zone-changes` it measured as two thirds of this PR's
      // win. Reverting either to a pre-sized fill would fail here.
      //
      // All four paths must agree, which is the point: before 0.8.7 the two
      // sync paths were fixed-length while `windowedAsync` was already
      // growable.
      final unfusedWindow = windowed(2, [1, 2, 3]).first;
      expect(unfusedWindow, [1, 2]);
      expect(() => unfusedWindow.add(9), returnsNormally);

      final fusedWindow = map((List<int> w) => w, windowed(2, [1, 2, 3])).first;
      expect(fusedWindow, [1, 2]);
      expect(() => fusedWindow.add(9), returnsNormally);

      // The pulled path builds its window out of the ring buffer. Both of its
      // branches have to agree: `chunk` never wraps past the ring's end,
      // an overlapping `windowed` does.
      final contiguous = map(
        (List<int> w) => w,
        chunk(2, pulled([1, 2, 3, 4])),
      ).first;
      expect(contiguous, [1, 2]);
      expect(() => contiguous.add(9), returnsNormally);

      final wrapped = map(
        (List<int> w) => w,
        windowed(3, pulled([1, 2, 3, 4, 5])),
      ).toList()[2];
      expect(wrapped, [3, 4, 5], reason: 'this window wraps the ring');
      expect(() => wrapped.add(9), returnsNormally);
    });

    test('rejects a non-positive size or step before fusing', () {
      expect(
        () => map((List<int> w) => w, windowed(0, [1, 2])),
        throwsArgumentError,
      );
      expect(
        () => map((List<int> w) => w, windowed(2, [1, 2], step: 0)),
        throwsArgumentError,
      );
    });

    test('windowsOf helper agrees with the layered pair on every shape', () {
      // A sweep, so a bound that is off by one in only one of the two loops
      // cannot hide behind the hand-picked cases above.
      for (var length = 0; length <= 7; length++) {
        final src = [for (var i = 1; i <= length; i++) i];
        for (var size = 1; size <= 4; size++) {
          for (var step = 1; step <= 4; step++) {
            for (final partial in [false, true]) {
              final reference = unfused(
                windowed(size, pulled(src), step: step, partial: partial),
                (List<int> w) => w.toList(),
              ).toList();
              expect(
                windowsOf(src, size, step: step, partial: partial),
                reference,
                reason: 'length=$length size=$size step=$step partial=$partial',
              );
            }
          }
        }
      }
    });
  });
}
