// `scan(...).map(f)` is built as a single stage rather than two (see
// FxMapFusable): `scan` emits one value per source element (plus the seed), so
// the boundary between it and the `map` stage is paid at the full element rate.
//
// The fused node is a separately written copy of the accumulation, twice over
// — once in `_ScanMapIterator.moveNext`, once in the `_ScanMapIterable.toList`
// loop that resolves the source shape itself. The bugs that can introduce are
// the fused loop drifting from the unfused pair, and `toList` drifting from the
// lazy walk. Every behavioural test below therefore pins all three against each
// other, over each of the three source shapes `toList` distinguishes:
//
//   * a `List`, which `fxListRangeOf` resolves and the loop indexes;
//   * a `range()`, which only `fxIntRangeOf` resolves and the loop counts;
//   * a generator, which neither resolves and the loop pulls.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// The layered pair, built so it cannot fuse: `Iterable.map` is the SDK's own
/// instance method and knows nothing about [FxMapFusable].
Iterable<C> unfused<A, B, C>(
  B Function(B acc, A a) f,
  B seed,
  Iterable<A> src,
  C Function(B) g,
) => scan(f, seed, src).map(g);

/// A source neither `fxListRangeOf` nor `fxIntRangeOf` can resolve, so the
/// pulled branch is taken.
Iterable<A> pulled<A>(Iterable<A> xs) sync* {
  for (final a in xs) {
    yield a;
  }
}

/// `map(g, scan(f, seed, src))` over each of the three source shapes, against
/// [expected] and against the layered reference for that shape.
///
/// [src] must be consecutive ascending ints, so that a `range()` can stand in
/// for it. Each shape is checked twice, once collected by `toList` and once by
/// walking the iterator, because those are two separate copies of the
/// accumulation.
void expectAllShapes<B, C>(
  B Function(B acc, int a) f,
  B seed,
  List<int> src,
  C Function(B) g, {
  required List<C> expected,
}) {
  final counted = src.isEmpty ? range(0, 0) : range(src.first, src.last + 1);
  expect(counted.toList(), src, reason: 'the range must stand in for src');
  for (final source in <Iterable<int>>[src, counted, pulled(src)]) {
    final chain = map(g, scan(f, seed, source));
    expect(chain.toList(), expected, reason: '$source toList');
    expect([for (final v in chain) v], expected, reason: '$source lazy walk');
    expect(
      chain.toList(),
      unfused(f, seed, source, g).toList(),
      reason: '$source vs the layered pair',
    );
  }
}

void main() {
  group('scan().map() fusion', () {
    test('builds one stage, not a map wrapping a scan', () {
      // White-box: nothing else here fails if the two stages stop fusing, and
      // the boundary is paid once per source element.
      expect(
        map(
          (int acc) => acc * 2,
          scan((int acc, int a) => acc + a, 0, [1, 2, 3]),
        ).runtimeType.toString(),
        startsWith('_ScanMap'),
      );
      expect(
        map(
          (int acc) => acc * 2,
          scan((int acc, int a) => acc + a, 0, [1, 2]),
        ).iterator.runtimeType.toString(),
        startsWith('_ScanMapIterator'),
      );
      // A source that cannot absorb a map still gets the plain map stage.
      expect(
        map((int a) => a, [1, 2, 3]).runtimeType.toString(),
        startsWith('_MapIterable'),
      );
      // The same fusion through the fluent wrapper.
      expect(
        fx([
          1,
          2,
          3,
        ]).scan((int acc, int a) => acc + a, 0).map((a) => '$a').toList(),
        ['0', '1', '3', '6'],
      );
    });

    test('same elements and order as the unfused pair', () {
      expectAllShapes(
        (int acc, int a) => acc + a,
        0,
        [1, 2, 3, 4],
        (int acc) => 'v$acc',
        expected: ['v0', 'v1', 'v3', 'v6', 'v10'],
      );
    });

    test('emits the mapped seed first', () {
      final chain = map(
        (int acc) => 'v$acc',
        scan((int acc, int a) => acc + a, 100, [1, 2]),
      );
      expect(chain.first, 'v100');
      expect(chain.toList().first, 'v100');
      // The seed lands before anything is pulled from the source.
      final it = chain.iterator;
      expect(it.moveNext(), isTrue);
      expect(it.current, 'v100');
    });

    test('is exactly source.length + 1 elements long', () {
      for (var length = 0; length <= 6; length++) {
        final src = [for (var i = 1; i <= length; i++) i];
        expectAllShapes(
          (int acc, int a) => acc + a,
          0,
          src,
          (int acc) => acc,
          expected: [0, for (var i = 1, acc = 0; i <= length; i++) acc += i],
        );
        expect(
          map(
            (int acc) => acc,
            scan((int acc, int a) => acc + a, 0, src),
          ).length,
          length + 1,
          reason: 'length=$length',
        );
      }
    });

    test('an empty source still yields the mapped seed, and only that', () {
      expectAllShapes(
        (int acc, int a) => acc + a,
        7,
        <int>[],
        (int acc) => 'v$acc',
        expected: ['v7'],
      );
      final it = map(
        (int acc) => acc,
        scan((int acc, int a) => acc + a, 7, <int>[]),
      ).iterator;
      expect(it.moveNext(), isTrue);
      expect(it.current, 7);
      expect(it.moveNext(), isFalse);
    });

    test('a range() source is counted, not pulled', () {
      // The `fxIntRangeOf` branch of the fused `toList` — what the
      // compound-interest shape needs.
      final chain = map(
        (double acc) => acc.toStringAsFixed(2),
        scan((double acc, int a) => acc + a, 0.0, range(1, 5)),
      );
      expect(chain.toList(), ['0.00', '1.00', '3.00', '6.00', '10.00']);
      expect([for (final v in chain) v], chain.toList());
      expect(
        chain.toList(),
        unfused(
          (double acc, int a) => acc + a,
          0.0,
          range(1, 5),
          (double acc) => acc.toStringAsFixed(2),
        ).toList(),
      );
      // A descending range walks the same counter the other way.
      final down = map(
        (int acc) => 'v$acc',
        scan((int acc, int a) => acc + a, 0, range(10, 0, -3)),
      );
      expect(down.toList(), ['v0', 'v10', 'v17', 'v21', 'v22']);
      expect([for (final v in down) v], down.toList());
      // An empty range is still one element.
      expect(
        map(
          (int acc) => acc,
          scan((int acc, int a) => acc + a, 5, range(0, 0)),
        ).toList(),
        [5],
      );
    });

    test('a range() seen through a wider element type still counts', () {
      // The counted branch casts the callback once rather than each value, so
      // it has to hold when `A` is only a supertype of `int`.
      final Iterable<num> src = range(1, 4);
      final chain = map(
        (num acc) => 'v$acc',
        scan((num acc, num a) => acc + a, 0, src),
      );
      expect(chain.toList(), ['v0', 'v1', 'v3', 'v6']);
      expect([for (final v in chain) v], chain.toList());
    });

    test('the fused toList agrees with the lazy walk on every shape', () {
      for (final source in <Iterable<int>>[
        [2, 4, 6, 8],
        range(2, 9, 2),
        pulled([2, 4, 6, 8]),
      ]) {
        final chain = map(
          (String acc) => acc.length,
          scan((String acc, int a) => '$acc:$a', 'seed', source),
        );
        expect([for (final v in chain) v], chain.toList(), reason: '$source');
        expect(chain.toList(), [4, 6, 8, 10, 12], reason: '$source');
      }
    });

    test('toList(growable: false) is fixed-length on every shape', () {
      for (final source in <Iterable<int>>[
        [1, 2, 3],
        range(1, 4),
        pulled([1, 2, 3]),
      ]) {
        final out = map(
          (int acc) => 'v$acc',
          scan((int acc, int a) => acc + a, 0, source),
        ).toList(growable: false);
        expect(out, ['v0', 'v1', 'v3', 'v6'], reason: '$source');
        expect(
          () => out.add('v9'),
          throwsUnsupportedError,
          reason: '$source is fixed-length',
        );
        // ...and the default stays growable.
        final growable = map(
          (int acc) => 'v$acc',
          scan((int acc, int a) => acc + a, 0, source),
        ).toList();
        expect(() => growable.add('v9'), returnsNormally, reason: '$source');
      }
    });

    test('runs both callbacks once per element consumed, in order', () {
      for (final source in <Iterable<int>>[
        [1, 2, 3],
        range(1, 4),
        pulled([1, 2, 3]),
      ]) {
        final folds = <String>[];
        final maps = <int>[];
        final result = map(
          (int acc) {
            maps.add(acc);
            return 'v$acc';
          },
          scan(
            (int acc, int a) {
              folds.add('$acc+$a');
              return acc + a;
            },
            0,
            source,
          ),
        ).toList();

        expect(result, ['v0', 'v1', 'v3', 'v6'], reason: '$source');
        expect(folds, [
          '0+1',
          '1+2',
          '3+3',
        ], reason: '$source: f once per source element, in order');
        expect(maps, [
          0,
          1,
          3,
          6,
        ], reason: '$source: g once per emitted value, seed first');
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

      final folds = <int>[];
      final result = fx(counting())
          .scan((int acc, int a) {
            folds.add(a);
            return acc + a;
          }, 0)
          .map((acc) => 'v$acc')
          .take(3)
          .toList();

      expect(result, ['v0', 'v1', 'v3']);
      expect(folds, [1, 2], reason: 'the seed costs no fold');
      expect(pulls, [
        1,
        2,
      ], reason: 'no element pulled past the 3rd emitted value');
    });

    test('supports repeated iteration with a fresh accumulator', () {
      for (final source in <Iterable<int>>[
        [1, 2, 3],
        range(1, 4),
        pulled([1, 2, 3]),
      ]) {
        final chain = map(
          (int acc) => 'v$acc',
          scan((int acc, int a) => acc + a, 0, source),
        );
        expect(chain.toList(), ['v0', 'v1', 'v3', 'v6'], reason: '$source');
        expect(chain.toList(), ['v0', 'v1', 'v3', 'v6'], reason: '$source');
        expect(
          [for (final v in chain) v],
          ['v0', 'v1', 'v3', 'v6'],
          reason: '$source',
        );
        expect([for (final v in chain) v], chain.toList(), reason: '$source');
      }
    });

    test('sees a List source that grew between iterations', () {
      final src = [1, 2];
      final chain = map(
        (int acc) => 'v$acc',
        scan((int acc, int a) => acc + a, 0, src),
      );
      expect(chain.toList(), ['v0', 'v1', 'v3']);
      src.add(3);
      expect(
        chain.toList(),
        ['v0', 'v1', 'v3', 'v6'],
        reason:
            'the range is resolved per iteration, not when the chain is '
            'built',
      );
    });

    test('a record element type, the shape the target cases use', () {
      // `(String, double)` — accumulating these with a pre-sized fill instead
      // of `add` is what the fused toList exists to avoid.
      const rates = [0.5, 0.25];
      (String, double) g(double acc) => ('total', acc);
      double f(double acc, double r) => acc * (1 + r);

      for (final source in <Iterable<double>>[rates, pulled(rates)]) {
        final chain = map(g, scan(f, 100.0, source));
        expect(chain.toList(), [
          ('total', 100.0),
          ('total', 150.0),
          ('total', 187.5),
        ], reason: '$source');
        expect([for (final v in chain) v], chain.toList(), reason: '$source');
        expect(
          chain.toList(),
          unfused(f, 100.0, source, g).toList(),
          reason: '$source',
        );
        final fixed = chain.toList(growable: false);
        expect(fixed.last, ('total', 187.5), reason: '$source');
        expect(
          () => fixed.add(('x', 0.0)),
          throwsUnsupportedError,
          reason: '$source',
        );
      }
    });

    test('scans a take/drop range from its offset, not from zero', () {
      // `fxListRangeOf` hands back `[start, end)` over the whole backing list
      // here, so a fused loop that ignored `start` would fold the wrong
      // elements.
      const src = [1, 2, 3, 4, 5, 6, 7, 8];
      final window = drop(2, take(6, src));
      final chain = map(
        (int acc) => 'v$acc',
        scan((int acc, int a) => acc + a, 0, window),
      );
      expect(chain.toList(), ['v0', 'v3', 'v7', 'v12', 'v18']);
      expect(
        chain.toList(),
        unfused(
          (int acc, int a) => acc + a,
          0,
          window,
          (int acc) => 'v$acc',
        ).toList(),
      );
      expect([for (final v in chain) v], chain.toList());
      // A range that is empty after the offset is still the seed alone.
      expect(
        map(
          (int acc) => acc,
          scan((int acc, int a) => acc + a, 9, drop(8, src)),
        ).toList(),
        [9],
      );
    });

    test('the unfused scan is untouched by the fusion', () {
      // The fusion must not have changed what `scan` alone does, on either of
      // its own paths.
      expect(scan((int acc, int a) => acc + a, 0, [1, 2, 3]).toList(), [
        0,
        1,
        3,
        6,
      ]);
      expect(scan((int acc, int a) => acc + a, 0, pulled([1, 2, 3])).toList(), [
        0,
        1,
        3,
        6,
      ]);
      expect(
        scan((int acc, int a) => acc + a, 0, [1, 2]).runtimeType.toString(),
        startsWith('_ScanIterable'),
      );
    });
  });
}
