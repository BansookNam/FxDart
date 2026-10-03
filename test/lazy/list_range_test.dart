// The List-range fast paths (lib/src/lazy/list_range.dart): when an operator
// can prove its source is a contiguous range of a backing List, it indexes
// that list instead of pulling an iterator chain. These tests pin the
// behaviour that must be IDENTICAL either way — the same file's operators are
// exercised twice, once over a List (fast path) and once over a source that
// cannot be a range (slow path).
// fxdart exports predicates named isNull/isNotNull/isEmpty; this file wants
// matcher's versions of those names, and none of fxdart's.
import 'package:fxdart/fxdart.dart' hide fxIsEmpty, isNotNull, fxIsNull;
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
          expect(fxToList(fxTake(n, list)), fxToList(fxTake(n, gen(8))));
        });
        test('drop($n)', () {
          expect(fxToList(fxDrop(n, list)), fxToList(fxDrop(n, gen(8))));
        });
        if (n >= 0) {
          test('takeRight($n)', () {
            expect(
              fxToList(fxTakeRight(n, list)),
              fxToList(fxTakeRight(n, gen(8))),
            );
          });
          test('dropRight($n)', () {
            expect(
              fxToList(fxDropRight(n, list)),
              fxToList(fxDropRight(n, gen(8))),
            );
          });
        }
      }

      test('compose: ranges nest without materialising', () {
        expect(fxToList(fxDrop(2, fxTake(6, list))), [2, 3, 4, 5]);
        expect(fxToList(fxTake(3, fxDrop(2, list))), [2, 3, 4]);
        expect(fxToList(fxDropRight(2, fxDrop(2, list))), [2, 3, 4, 5]);
        expect(fxToList(fxTakeRight(2, fxDrop(2, fxTake(6, list)))), [4, 5]);
        // Over-dropping from both ends collapses to empty, never negative.
        expect(fxToList(fxDropRight(9, fxDrop(4, list))), <int>[]);
        expect(fxToList(fxTake(4, fxDrop(100, list))), <int>[]);
      });

      test('every composition matches the pulled form', () {
        for (var a = 0; a <= 9; a++) {
          for (var b = 0; b <= 9; b++) {
            expect(
              fxToList(fxDrop(b, fxTake(a, list))),
              fxToList(fxDrop(b, fxTake(a, gen(8)))),
              reason: 'drop($b, take($a))',
            );
            expect(
              fxToList(fxTakeRight(b, fxDropRight(a, list))),
              fxToList(fxTakeRight(b, fxDropRight(a, gen(8)))),
              reason: 'takeRight($b, dropRight($a))',
            );
          }
        }
      });
    });

    group('the source is still read lazily and freshly', () {
      test('drop over a List reflects later writes to that List', () {
        final list = [1, 2, 3];
        final dropped = fxDrop(1, list);
        list[2] = 30;
        expect(fxToList(dropped), [2, 30]);
      });

      test('each iteration of a range starts over', () {
        final dropped = fxDrop(1, [1, 2, 3]);
        expect(fxToList(dropped), [2, 3]);
        expect(fxToList(dropped), [2, 3]);
      });

      test('take stays lazy over an infinite source', () {
        expect(fxToList(fxTake(3, fxCycle([1, 2]))), [1, 2, 1]);
      });
    });

    group('zip resolves each side independently', () {
      test('List with List', () {
        expect(fxToList(fxZip([1, 2, 3], [4, 5])), [(1, 4), (2, 5)]);
        expect(fxToList(fxZip([1, 2], [4, 5, 6])), [(1, 4), (2, 5)]);
      });

      test('List with a shifted List — the sliding-window shape', () {
        final xs = [1, 2, 3, 4];
        expect(fxToList(fxZip(xs, fxDrop(1, xs))), [(1, 2), (2, 3), (3, 4)]);
        expect(fxToList(fxZip(fxDrop(1, xs), fxDrop(2, xs))), [(2, 3), (3, 4)]);
        expect(fxToList(fxZip(fxZip(xs, fxDrop(1, xs)), fxDrop(2, xs))), [
          ((1, 2), 3),
          ((2, 3), 4),
        ]);
      });

      test('range on the left, pulled on the right', () {
        expect(fxToList(fxZip([1, 2, 3], gen(2))), [(1, 0), (2, 1)]);
        expect(fxToList(fxZip(fxDrop(1, [1, 2, 3]), gen(5))), [(2, 0), (3, 1)]);
      });

      test('pulled on the left, range on the right', () {
        expect(fxToList(fxZip(gen(2), [1, 2, 3])), [(0, 1), (1, 2)]);
        expect(fxToList(fxZip(gen(5), fxDrop(1, [1, 2, 3]))), [(0, 2), (1, 3)]);
      });

      test('neither side a range', () {
        expect(fxToList(fxZip(gen(2), gen(5))), [(0, 0), (1, 1)]);
      });

      test('pull counts match the iterator form when one side is a range', () {
        // zip pulls the left side first and only then the right, so a left
        // source that runs out is still asked once more than it yields, and
        // the right side is never pulled for that final attempt.
        var leftPulls = 0;
        final left = fxPeek((_) => leftPulls++, gen(2));
        expect(fxToList(fxZip(left, [10, 20, 30])), [(0, 10), (1, 20)]);
        expect(leftPulls, 2);

        var rightPulls = 0;
        final right = fxPeek((_) => rightPulls++, gen(5));
        expect(fxToList(fxZip([10, 20], right)), [(10, 0), (20, 1)]);
        // Left exhausts first, so the right side is never pulled a third time.
        expect(rightPulls, 2);
      });
    });

    group('zip3', () {
      test('all three ranges', () {
        final xs = [1, 2, 3, 4, 5];
        expect(fxToList(fxZip3(xs, fxDrop(1, xs), fxDrop(2, xs))), [
          (1, 2, 3),
          (2, 3, 4),
          (3, 4, 5),
        ]);
      });

      test('stops at the shortest side whichever it is', () {
        expect(fxToList(fxZip3([1], [2, 3], [4, 5])), [(1, 2, 4)]);
        expect(fxToList(fxZip3([1, 2], [3], [4, 5])), [(1, 3, 4)]);
        expect(fxToList(fxZip3([1, 2], [3, 4], [5])), [(1, 3, 5)]);
      });

      test('a single pulled side disables the indexed path', () {
        expect(fxToList(fxZip3([1, 2, 3], [4, 5, 6], gen(2))), [
          (1, 4, 0),
          (2, 5, 1),
        ]);
        expect(fxToList(fxZip3(gen(2), [4, 5, 6], [7, 8, 9])), [
          (0, 4, 7),
          (1, 5, 8),
        ]);
      });

      test('reachable from the chain', () {
        final xs = [1, 2, 3, 4];
        expect(fx(xs).zip3(fxDrop(1, xs), fxDrop(2, xs)).toList(), [
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
        expect(
          fxToList(fxZip(xs, fx(xs).drop(1))),
          fxToList(fxZip(xs, fxDrop(1, xs))),
        );
        expect(
          fxToList(fxZip3(xs, fx(xs).drop(1), fx(xs).drop(2))),
          fxToList(fxZip3(xs, fxDrop(1, xs), fxDrop(2, xs))),
        );
        expect(
          fxToList(fxWindowed(2, fx(xs).drop(1))),
          fxToList(fxWindowed(2, fxDrop(1, xs))),
        );
      });

      test('a chain of ranges composes like the top-level form', () {
        expect(
          fxToList(fxZip(xs, fx(xs).drop(1).take(2))),
          fxToList(fxZip(xs, fxTake(2, fxDrop(1, xs)))),
        );
      });

      test('a non-range chain still zips correctly', () {
        expect(fxToList(fxZip(xs, fx(xs).map((a) => a * 10))), [
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
                fxToList(fxWindowed(size, list, step: step, partial: partial)),
                fxToList(
                  fxWindowed(
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
            fxToList(fxChunk(size, list)),
            fxToList(fxChunk(size, gen(7).map((i) => i + 1))),
            reason: 'chunk($size)',
          );
        }
      });

      test('windows are growable and independent', () {
        final ws = fxToList(fxWindowed(2, list));
        expect(ws.first, [1, 2]);
        expect(ws[1], [2, 3]);
        // Each window is a copy the caller owns, not a view onto `list`, and
        // since 0.8.7 it is growable on every path — the fixed-length fill it
        // replaced cost a covariant store check per element (see
        // `_windowSlice`). Independence is the part that matters and is
        // unchanged: writing through one window touches nothing else.
        expect(() => ws.first.add(9), returnsNormally);
        expect(ws.first, [1, 2, 9]);
        expect(ws[1], [2, 3]);
        expect(list, [1, 2, 3, 4, 5, 6, 7]);
      });

      test('an empty or too-short source yields nothing without partial', () {
        expect(fxToList(fxWindowed(3, <int>[])), <int>[]);
        expect(fxToList(fxWindowed(3, [1, 2])), <int>[]);
        expect(fxToList(fxWindowed(3, [1, 2], partial: true)), [
          [1, 2],
          [2],
        ]);
      });

      test('windowed over a dropped List', () {
        expect(fxToList(fxWindowed(2, fxDrop(2, list))), [
          [3, 4],
          [4, 5],
          [5, 6],
          [6, 7],
        ]);
      });
    });
  });
}
