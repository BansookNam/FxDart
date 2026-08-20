// The List-range fast paths (lib/src/lazy/list_range.dart): when an operator
// can prove its source is a contiguous range of a backing List, it indexes
// that list instead of pulling an iterator chain. These tests pin the
// behaviour that must be IDENTICAL either way — the same file's operators are
// exercised twice, once over a List (fast path) and once over a source that
// cannot be a range (slow path).
// fxdart exports predicates named isNull/isNotNull/isEmpty; this file wants
// matcher's versions of those names, and none of fxdart's.
import 'package:fxdart/fxdart.dart' hide isEmpty, isNotNull, isNull;
import 'package:test/test.dart';

/// A source that is emphatically not a List, so no range can be derived.
Iterable<int> gen(int n) sync* {
  for (var i = 0; i < n; i++) {
    yield i;
  }
}

void main() {
  group('List-range fast paths', () {
    group('take/drop/takeRight/dropRight agree with the pulled form', () {
      final list = [0, 1, 2, 3, 4, 5, 6, 7];

      for (final n in [-1, 0, 1, 3, 8, 9, 100]) {
        test('take($n)', () {
          expect(toList(take(n, list)), toList(take(n, gen(8))));
        });
        test('drop($n)', () {
          expect(toList(drop(n, list)), toList(drop(n, gen(8))));
        });
        if (n >= 0) {
          test('takeRight($n)', () {
            expect(toList(takeRight(n, list)), toList(takeRight(n, gen(8))));
          });
          test('dropRight($n)', () {
            expect(toList(dropRight(n, list)), toList(dropRight(n, gen(8))));
          });
        }
      }

      test('compose: ranges nest without materialising', () {
        expect(toList(drop(2, take(6, list))), [2, 3, 4, 5]);
        expect(toList(take(3, drop(2, list))), [2, 3, 4]);
        expect(toList(dropRight(2, drop(2, list))), [2, 3, 4, 5]);
        expect(toList(takeRight(2, drop(2, take(6, list)))), [4, 5]);
        // Over-dropping from both ends collapses to empty, never negative.
        expect(toList(dropRight(9, drop(4, list))), <int>[]);
        expect(toList(take(4, drop(100, list))), <int>[]);
      });

      test('every composition matches the pulled form', () {
        for (var a = 0; a <= 9; a++) {
          for (var b = 0; b <= 9; b++) {
            expect(
              toList(drop(b, take(a, list))),
              toList(drop(b, take(a, gen(8)))),
              reason: 'drop($b, take($a))',
            );
            expect(
              toList(takeRight(b, dropRight(a, list))),
              toList(takeRight(b, dropRight(a, gen(8)))),
              reason: 'takeRight($b, dropRight($a))',
            );
          }
        }
      });
    });

    group('the source is still read lazily and freshly', () {
      test('drop over a List reflects later writes to that List', () {
        final list = [1, 2, 3];
        final dropped = drop(1, list);
        list[2] = 30;
        expect(toList(dropped), [2, 30]);
      });

      test('each iteration of a range starts over', () {
        final dropped = drop(1, [1, 2, 3]);
        expect(toList(dropped), [2, 3]);
        expect(toList(dropped), [2, 3]);
      });

      test('take stays lazy over an infinite source', () {
        expect(toList(take(3, cycle([1, 2]))), [1, 2, 1]);
      });
    });

    group('zip resolves each side independently', () {
      test('List with List', () {
        expect(toList(zip([1, 2, 3], [4, 5])), [(1, 4), (2, 5)]);
        expect(toList(zip([1, 2], [4, 5, 6])), [(1, 4), (2, 5)]);
      });

      test('List with a shifted List — the sliding-window shape', () {
        final xs = [1, 2, 3, 4];
        expect(toList(zip(xs, drop(1, xs))), [(1, 2), (2, 3), (3, 4)]);
        expect(toList(zip(drop(1, xs), drop(2, xs))), [(2, 3), (3, 4)]);
        expect(toList(zip(zip(xs, drop(1, xs)), drop(2, xs))), [
          ((1, 2), 3),
          ((2, 3), 4),
        ]);
      });

      test('range on the left, pulled on the right', () {
        expect(toList(zip([1, 2, 3], gen(2))), [(1, 0), (2, 1)]);
        expect(toList(zip(drop(1, [1, 2, 3]), gen(5))), [(2, 0), (3, 1)]);
      });

      test('pulled on the left, range on the right', () {
        expect(toList(zip(gen(2), [1, 2, 3])), [(0, 1), (1, 2)]);
        expect(toList(zip(gen(5), drop(1, [1, 2, 3]))), [(0, 2), (1, 3)]);
      });

      test('neither side a range', () {
        expect(toList(zip(gen(2), gen(5))), [(0, 0), (1, 1)]);
      });

      test('pull counts match the iterator form when one side is a range', () {
        // zip pulls the left side first and only then the right, so a left
        // source that runs out is still asked once more than it yields, and
        // the right side is never pulled for that final attempt.
        var leftPulls = 0;
        final left = peek((_) => leftPulls++, gen(2));
        expect(toList(zip(left, [10, 20, 30])), [(0, 10), (1, 20)]);
        expect(leftPulls, 2);

        var rightPulls = 0;
        final right = peek((_) => rightPulls++, gen(5));
        expect(toList(zip([10, 20], right)), [(10, 0), (20, 1)]);
        // Left exhausts first, so the right side is never pulled a third time.
        expect(rightPulls, 2);
      });
    });

    group('zip3', () {
      test('all three ranges', () {
        final xs = [1, 2, 3, 4, 5];
        expect(toList(zip3(xs, drop(1, xs), drop(2, xs))), [
          (1, 2, 3),
          (2, 3, 4),
          (3, 4, 5),
        ]);
      });

      test('stops at the shortest side whichever it is', () {
        expect(toList(zip3([1], [2, 3], [4, 5])), [(1, 2, 4)]);
        expect(toList(zip3([1, 2], [3], [4, 5])), [(1, 3, 4)]);
        expect(toList(zip3([1, 2], [3, 4], [5])), [(1, 3, 5)]);
      });

      test('a single pulled side disables the indexed path', () {
        expect(toList(zip3([1, 2, 3], [4, 5, 6], gen(2))), [
          (1, 4, 0),
          (2, 5, 1),
        ]);
        expect(toList(zip3(gen(2), [4, 5, 6], [7, 8, 9])), [
          (0, 4, 7),
          (1, 5, 8),
        ]);
      });

      test('reachable from the chain', () {
        final xs = [1, 2, 3, 4];
        expect(fx(xs).zip3(drop(1, xs), drop(2, xs)).toList(), [
          (1, 2, 3),
          (2, 3, 4),
        ]);
      });
    });

    group('an Fx chain does not hide a range', () {
      // Fx is an extension type, so it erases to its representation: an
      // fx(...) chain IS the underlying iterable at runtime, and the range
      // protocol sees straight through it with nothing to unwrap.
      final xs = [1, 2, 3, 4];

      test('passing the chain equals passing the operator result', () {
        expect(toList(zip(xs, fx(xs).drop(1))), toList(zip(xs, drop(1, xs))));
        expect(
          toList(zip3(xs, fx(xs).drop(1), fx(xs).drop(2))),
          toList(zip3(xs, drop(1, xs), drop(2, xs))),
        );
        expect(
          toList(windowed(2, fx(xs).drop(1))),
          toList(windowed(2, drop(1, xs))),
        );
      });

      test('a chain of ranges composes like the top-level form', () {
        expect(
          toList(zip(xs, fx(xs).drop(1).take(2))),
          toList(zip(xs, take(2, drop(1, xs)))),
        );
      });

      test('a non-range chain still zips correctly', () {
        expect(toList(zip(xs, fx(xs).map((a) => a * 10))), [
          (1, 10),
          (2, 20),
          (3, 30),
          (4, 40),
        ]);
      });
    });

    group('windowed over a range', () {
      final list = [1, 2, 3, 4, 5, 6, 7];

      for (final size in [1, 2, 3, 7, 8]) {
        for (final step in [1, 2, 3, 7, 9]) {
          for (final partial in [false, true]) {
            test('size=$size step=$step partial=$partial', () {
              expect(
                toList(windowed(size, list, step: step, partial: partial)),
                toList(
                  windowed(
                    size,
                    gen(7).map((i) => i + 1),
                    step: step,
                    partial: partial,
                  ),
                ),
              );
            });
          }
        }
      }

      test('chunk over a List matches the pulled form', () {
        for (var size = 1; size <= 8; size++) {
          expect(
            toList(chunk(size, list)),
            toList(chunk(size, gen(7).map((i) => i + 1))),
            reason: 'chunk($size)',
          );
        }
      });

      test('windows are growable and independent', () {
        final ws = toList(windowed(2, list));
        expect(ws.first, [1, 2]);
        expect(ws[1], [2, 3]);
        // Each window is a copy the caller owns, not a view onto `list`, and
        // since 0.8.6 it is growable on every path — the fixed-length fill it
        // replaced cost a covariant store check per element (see
        // `_windowSlice`). Independence is the part that matters and is
        // unchanged: writing through one window touches nothing else.
        expect(() => ws.first.add(9), returnsNormally);
        expect(ws.first, [1, 2, 9]);
        expect(ws[1], [2, 3]);
        expect(list, [1, 2, 3, 4, 5, 6, 7]);
      });

      test('an empty or too-short source yields nothing without partial', () {
        expect(toList(windowed(3, <int>[])), <int>[]);
        expect(toList(windowed(3, [1, 2])), <int>[]);
        expect(toList(windowed(3, [1, 2], partial: true)), [
          [1, 2],
          [2],
        ]);
      });

      test('windowed over a dropped List', () {
        expect(toList(windowed(2, drop(2, list))), [
          [3, 4],
          [4, 5],
          [5, 6],
          [6, 7],
        ]);
      });
    });
  });
}
