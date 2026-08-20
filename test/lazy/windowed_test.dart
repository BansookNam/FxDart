import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('windowed', () {
    group('sync', () {
      test('should slide by one by default', () {
        expect(
          toList(windowed(3, [1, 2, 3, 4, 5])),
          equals([
            [1, 2, 3],
            [2, 3, 4],
            [3, 4, 5],
          ]),
        );
      });

      test('should slide by the given step', () {
        expect(
          toList(windowed(3, [1, 2, 3, 4, 5], step: 2)),
          equals([
            [1, 2, 3],
            [3, 4, 5],
          ]),
        );
      });

      test('should keep trailing partial windows when asked', () {
        expect(
          toList(windowed(3, [1, 2, 3, 4, 5], partial: true)),
          equals([
            [1, 2, 3],
            [2, 3, 4],
            [3, 4, 5],
            [4, 5],
            [5],
          ]),
        );
        expect(
          toList(windowed(3, [1, 2, 3, 4, 5, 6], step: 2, partial: true)),
          equals([
            [1, 2, 3],
            [3, 4, 5],
            [5, 6],
          ]),
        );
      });

      test('should skip the gap when step exceeds size', () {
        expect(
          toList(windowed(2, [1, 2, 3, 4, 5, 6, 7], step: 3)),
          equals([
            [1, 2],
            [4, 5],
          ]),
        );
        expect(
          toList(windowed(2, [1, 2, 3, 4, 5, 6, 7], step: 3, partial: true)),
          equals([
            [1, 2],
            [4, 5],
            [7],
          ]),
        );
      });

      test(
        'should stop when the source ends inside the gap between windows',
        () {
          expect(
            toList(windowed(2, [1, 2, 3], step: 5)),
            equals([
              [1, 2],
            ]),
          );
          expect(
            toList(windowed(2, [1, 2, 3], step: 5, partial: true)),
            equals([
              [1, 2],
            ]),
          );
        },
      );

      test('should handle sources shorter than one window', () {
        expect(toList(windowed(3, [1, 2])), equals([]));
        expect(
          toList(windowed(3, [1, 2], partial: true)),
          equals([
            [1, 2],
            [2],
          ]),
        );
        expect(toList(windowed(3, <int>[])), equals([]));
        expect(toList(windowed(3, <int>[], partial: true)), equals([]));
      });

      test('should reject non-positive size or step', () {
        expect(() => windowed(0, [1, 2]), throwsArgumentError);
        expect(() => windowed(2, [1, 2], step: 0), throwsArgumentError);
      });

      test('should stay lazy over an endless source', () {
        expect(
          toList(take(2, windowed(3, cycle([1, 2, 3])))),
          equals([
            [1, 2, 3],
            [2, 3, 1],
          ]),
        );
      });

      test('should support repeated iteration', () {
        final windows = windowed(2, [1, 2, 3]);
        expect(toList(windows), toList(windows));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        expect(
          fx([1, 2, 3, 4]).windowed(2).toList(),
          equals([
            [1, 2],
            [2, 3],
            [3, 4],
          ]),
        );
        expect(
          fx([1, 2, 3, 4, 5]).windowed(2, step: 2, partial: true).toList(),
          equals([
            [1, 2],
            [3, 4],
            [5],
          ]),
        );
      });

      test('chunk should equal windowed with step = size and partials', () {
        for (final n in [1, 2, 3, 4, 7]) {
          expect(
            toList(chunk(n, range(1, 12))),
            equals(toList(windowed(n, range(1, 12), step: n, partial: true))),
            reason: 'size $n',
          );
        }
      });
    });

    // Replaces the old "windows are fixed-length" pin. 0.8.6 made every window
    // growable; before it, the two sync paths handed back a fixed-length list
    // while windowedAsync/chunkAsync already returned a growable one, so the
    // same operator disagreed with its own async twin. The value of the old
    // test was catching an unintended change to window mutability, and that
    // value is what this keeps — now across all four paths at once.
    //
    // The reason for the flip is on `_windowSlice`: a fixed-length window has
    // to be filled from package code at one covariant store check per element,
    // and no bulk copy that preserves the fixed length is faster than that
    // loop.
    group('window representation', () {
      test('every window is growable, on all four paths', () async {
        // sync, List source — the indexed path (_windowSlice)
        final syncList = windowed(2, [1, 2, 3]).first;
        // sync, non-List source — the ring path, contiguous and wrapped
        final syncPulledContiguous = chunk(2, range(1, 5)).first;
        final syncPulledWrapped = windowed(3, range(1, 6)).toList()[2];
        // async
        final asyncWindow = (await toListAsync(
          windowedAsync(2, toAsync(range(1, 4))),
        )).first;
        final asyncChunk = (await toListAsync(
          chunkAsync(2, toAsync(range(1, 5))),
        )).first;

        expect(syncList, [1, 2]);
        expect(syncPulledContiguous, [1, 2]);
        expect(syncPulledWrapped, [3, 4, 5]);
        expect(asyncWindow, [1, 2]);
        expect(asyncChunk, [1, 2]);

        for (final w in [
          syncList,
          syncPulledContiguous,
          syncPulledWrapped,
          asyncWindow,
          asyncChunk,
        ]) {
          expect(() => w.add(99), returnsNormally);
          expect(w.last, 99);
        }
      });

      test('a window is a copy the caller owns, not a view', () {
        final src = [1, 2, 3];
        final ws = toList(windowed(2, src));
        expect(ws, [
          [1, 2],
          [2, 3],
        ]);
        // Writing through one window touches neither its neighbour nor the
        // source — the property the fixed-length pin was really protecting.
        ws.first[0] = 99;
        ws.first.add(-1);
        expect(ws.last, [2, 3]);
        expect(src, [1, 2, 3]);
      });
    });

    group('async', () {
      test('should slide like the sync form', () async {
        expect(
          await toListAsync(windowedAsync(3, toAsync(range(1, 6)))),
          equals([
            [1, 2, 3],
            [2, 3, 4],
            [3, 4, 5],
          ]),
        );
        expect(
          await toListAsync(
            windowedAsync(3, toAsync(range(1, 6)), step: 2, partial: true),
          ),
          equals([
            [1, 2, 3],
            [3, 4, 5],
            [5],
          ]),
        );
        expect(
          await toListAsync(windowedAsync(2, toAsync(range(1, 8)), step: 3)),
          equals([
            [1, 2],
            [4, 5],
          ]),
        );
        expect(
          await toListAsync(windowedAsync(3, asyncEmpty<int>())),
          equals([]),
        );
      });

      test('should cascade trailing partial windows', () async {
        expect(
          await toListAsync(
            windowedAsync(3, toAsync(range(1, 6)), partial: true),
          ),
          equals([
            [1, 2, 3],
            [2, 3, 4],
            [3, 4, 5],
            [4, 5],
            [5],
          ]),
        );
      });

      test(
        'should stop when the source ends inside the gap between windows',
        () async {
          expect(
            await toListAsync(windowedAsync(2, toAsync([1, 2, 3]), step: 5)),
            equals([
              [1, 2],
            ]),
          );
        },
      );

      test('should reject non-positive size or step', () {
        expect(() => windowedAsync(0, toAsync([1, 2])), throwsArgumentError);
        expect(
          () => windowedAsync(2, toAsync([1, 2]), step: 0),
          throwsArgumentError,
        );
      });

      test('should be windowed after concurrent', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(toAsync(range(1, 12)))
            .map((a) => delay(const Duration(milliseconds: 100), a))
            .concurrent(2)
            .windowed(3, step: 3, partial: true)
            .toList();
        sw.stop();

        expect(
          res,
          equals([
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
            [10, 11],
          ]),
        );
        // Sequential would be ~1100ms; concurrent(2) should be ~600ms.
        expect(sw.elapsedMilliseconds, lessThan(950));
      });

      test('should propagate an upstream error', () async {
        await expectLater(
          fxAsync(toAsync(range(1, 21)))
              .map((a) {
                if (a == 5) return Future<int>.error(Exception('err'));
                return delay(const Duration(milliseconds: 10), a);
              })
              .windowed(3)
              .concurrent(2)
              .toList(),
          throwsException,
        );
      });

      test(
        'should be able to be used as a chaining method in the `fx`',
        () async {
          expect(
            await fx([1, 2, 3, 4]).toAsync().windowed(2).toList(),
            equals([
              [1, 2],
              [2, 3],
              [3, 4],
            ]),
          );
        },
      );
    });
  });
}
