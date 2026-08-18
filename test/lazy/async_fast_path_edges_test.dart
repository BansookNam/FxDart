// Edge paths of the 0.8.5 async fast paths.
//
// `dropWhileAsync` became a fused stage and `windowed`/`chunk` moved onto the
// internal fast-pull path. Both have branches the ordinary all-consuming
// terminal never reaches: the *asynchronous* predicate inside each of the
// stage walkers, and the layered fallback `windowed` keeps for a `Concurrent`
// consumer. Those are the branches pinned here.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

Stream<int> streamOf(List<int> xs) async* {
  for (final x in xs) {
    yield x;
  }
}

void main() {
  group('dropWhile async predicate, per execution path', () {
    test('through the pull path (a short-circuiting consumer)', () async {
      // `head` pulls one element, so the chain is walked by the iterator
      // rather than handed to an all-consuming drive.
      final first = await fxAsync(toAsync([1, 2, 3, 4]))
          .dropWhile((a) async => a < 3)
          .head();
      expect(first, 3);
    });

    test('through the fused drive (toList over a sync source)', () async {
      final all = await fxAsync(toAsync([1, 2, 3, 1]))
          .dropWhile((a) async => a < 3)
          .toList();
      expect(all, [3, 1]);
    });

    test('through the stream drive (toList over a Stream source)', () async {
      final all = await fxStream(streamOf([1, 2, 3, 1]))
          .dropWhile((a) async => a < 3)
          .toList();
      expect(all, [3, 1]);
    });

    test('a stream-sourced dropWhile that never stops dropping', () async {
      expect(
        await fxStream(streamOf([1, 2])).dropWhile((a) async => true).toList(),
        <int>[],
      );
    });

    test('the async predicate runs only until it first fails', () async {
      final tested = <int>[];
      final all = await fxStream(streamOf([1, 2, 3, 1, 0]))
          .dropWhile((a) async {
            tested.add(a);
            return a < 3;
          })
          .toList();
      expect(all, [3, 1, 0]);
      expect(tested, [1, 2, 3], reason: 'the latch stops the predicate');
    });
  });

  group('windowed/chunk fast-pull edges', () {
    test('next() with no Concurrent marker stays on the fast path', () async {
      final it = chunkAsync(2, toAsync([1, 2, 3])).iterator;
      expect((await it.next()).value, [1, 2]);
      expect((await it.next()).value, [3]);
      expect((await it.next()).done, isTrue);
    });

    test('step > size skips, over an asynchronous source', () async {
      // A Stream answers each pull asynchronously, which is the branch a
      // synchronous `toAsync` source never takes.
      expect(
        await fxStream(streamOf([1, 2, 3, 4, 5, 6, 7]))
            .windowed(2, step: 3, partial: true)
            .toList(),
        [
          [1, 2],
          [4, 5],
          [7],
        ],
      );
    });

    test('overlap carry, over an asynchronous source', () async {
      expect(
        await fxStream(streamOf([1, 2, 3, 4])).windowed(3).toList(),
        [
          [1, 2, 3],
          [2, 3, 4],
        ],
      );
    });

    test('a Concurrent consumer gets the layered fallback, same output',
        () async {
      final viaConcurrent = await fxAsync(toAsync([1, 2, 3, 4, 5]))
          .chunk(2)
          .concurrent(2)
          .toList();
      final viaFastPull = await fxAsync(toAsync([1, 2, 3, 4, 5]))
          .chunk(2)
          .toList();
      expect(viaConcurrent, viaFastPull);
      expect(viaConcurrent, [
        [1, 2],
        [3, 4],
        [5],
      ]);
    });

    test('the fallback keeps step > size and the partial tail', () async {
      expect(
        await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7]))
            .windowed(2, step: 3, partial: true)
            .concurrent(2)
            .toList(),
        [
          [1, 2],
          [4, 5],
          [7],
        ],
      );
      expect(
        await fxAsync(toAsync([1, 2, 3]))
            .windowed(2, step: 2)
            .concurrent(2)
            .toList(),
        [
          [1, 2],
        ],
      );
    });

    test('the source ending mid-skip, over an asynchronous source', () async {
      // step 5 > size 2, so after the first window the stage has to skip 3 —
      // but the stream only has 1 element left, so it runs out inside the skip.
      expect(
        await fxStream(streamOf([1, 2, 3]))
            .windowed(2, step: 5, partial: true)
            .toList(),
        [
          [1, 2],
        ],
      );
    });

    test('the fallback also handles a source ending mid-skip', () async {
      expect(
        await fxAsync(toAsync([1, 2, 3]))
            .windowed(2, step: 5, partial: true)
            .concurrent(2)
            .toList(),
        [
          [1, 2],
        ],
      );
    });

    test('the fallback carries overlap into a partial tail', () async {
      // size 3 / step 1 over 4 elements ends with two short windows, so the
      // partial branch has to carry rather than finish.
      expect(
        await fxAsync(toAsync([1, 2, 3, 4]))
            .windowed(3, partial: true)
            .concurrent(2)
            .toList(),
        [
          [1, 2, 3],
          [2, 3, 4],
          [3, 4],
          [4],
        ],
      );
    });

    test('once it has fallen back, a plain pull stays on the fallback',
        () async {
      // The marker installs the layered form; a later pull with no marker must
      // keep using it rather than resume the fused path, which would consume
      // the source twice.
      final it = chunkAsync(2, toAsync([1, 2, 3, 4])).iterator;
      expect((await it.next(Concurrent.of(2))).value, [1, 2]);
      expect((await it.next()).value, [3, 4]);
      expect((await it.next()).done, isTrue);
    });

    test('the fallback ends cleanly on an empty source', () async {
      expect(
        await fxAsync(toAsync(<int>[])).chunk(2).concurrent(2).toList(),
        <List<int>>[],
      );
    });
  });
}
