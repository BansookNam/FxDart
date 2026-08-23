import 'dart:async';

import 'package:fxdart/fxdart.dart' hide isEmpty;
import 'package:test/test.dart';

/// Emits each (offsetMs, value) pair at its offset, closing at [closeMs].
Stream<T> timed<T>(List<(int, T)> events, int closeMs) {
  final c = StreamController<T>();
  for (final (ms, v) in events) {
    Timer(Duration(milliseconds: ms), () => c.add(v));
  }
  Timer(Duration(milliseconds: closeMs), c.close);
  return c.stream;
}

void _ignoreError(Object _, [StackTrace? __]) {}

Future<List<List<T>>> drainWindows<T>(FxEvents<FxEvents<T>> windows) async {
  final collected = <List<T>>[];
  final inners = <Future<void>>[];
  await windows.listen((w) {
    final bucket = <T>[];
    collected.add(bucket);
    inners.add(w.listen(bucket.add).asFuture<void>());
  }).asFuture<void>();
  await Future.wait(inners);
  return collected;
}

void main() {
  group('windowOn', () {
    test('opens immediately and rotates on each boundary', () async {
      final source = StreamController<int>();
      final bounds = StreamController<void>();
      final future = drainWindows(
        fxEvents(source.stream).windowOn(bounds.stream),
      );
      await Future<void>.delayed(Duration.zero);

      source.add(1);
      bounds.add(null);
      await Future<void>.delayed(Duration.zero);
      source.add(2);
      bounds.add(null);
      await Future<void>.delayed(Duration.zero);
      source.add(3);
      await source.close();

      expect(await future, [
        [1],
        [2],
        [3],
      ]);
      await bounds.close();
    });

    test('boundary completion leaves the current window open', () async {
      final source = StreamController<int>();
      final bounds = StreamController<void>();
      final future = drainWindows(
        fxEvents(source.stream).windowOn(bounds.stream),
      );
      await Future<void>.delayed(Duration.zero);
      source.add(1);
      await bounds.close();
      source.add(2);
      await source.close();
      expect(await future, [
        [1, 2],
      ]);
    });

    test(
      'source completion completes the live window then the outer',
      () async {
        expect(
          await drainWindows(
            fxEvents(Stream.fromIterable([1, 2, 3])).windowOn(Stream.empty()),
          ),
          [
            [1, 2, 3],
          ],
        );
      },
    );

    test('source error errors the live window then the outer', () async {
      final source = StreamController<int>();
      final bounds = StreamController<void>();
      final innerErrors = <Object>[];
      final outerErrors = <Object>[];
      var innerDone = false;
      var outerDone = false;
      fxEvents(source.stream)
          .windowOn(bounds.stream)
          .listen(
            (w) {
              w.listen(
                (_) {},
                onError: innerErrors.add,
                onDone: () => innerDone = true,
              );
            },
            onError: outerErrors.add,
            onDone: () => outerDone = true,
          );
      await Future<void>.delayed(Duration.zero);
      source.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(innerErrors.single, isA<StateError>());
      expect(outerErrors.single, isA<StateError>());
      expect(innerDone, isTrue);
      expect(outerDone, isTrue);
      await source.close();
      await bounds.close();
    });

    test('boundary error errors the live window then the outer', () async {
      final source = StreamController<int>();
      final bounds = StreamController<void>();
      final seen = <Object>[];
      fxEvents(source.stream)
          .windowOn(bounds.stream)
          .listen(
            (w) => w.listen((_) {}, onError: _ignoreError),
            onError: seen.add,
          );
      await Future<void>.delayed(Duration.zero);
      bounds.addError(StateError('bound'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await source.close();
      await bounds.close();
    });

    test('cancel completes the live inner and stops listening', () async {
      final source = StreamController<int>();
      var innerDone = false;
      final sub = fxEvents(source.stream)
          .windowOn(StreamController<void>().stream)
          .listen((w) {
            w.listen((_) {}, onDone: () => innerDone = true);
          });
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      source.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(innerDone, isTrue);
      await source.close();
    });
  });

  group('windowCount', () {
    test('tumbling windows of size', () async {
      expect(
        await drainWindows(
          fxEvents(Stream.fromIterable([1, 2, 3, 4, 5])).windowCount(2),
        ),
        [
          [1, 2],
          [3, 4],
          [5],
        ],
      );
    });

    test('overlapping windows when startEvery < size', () async {
      expect(
        await drainWindows(
          fxEvents(
            Stream.fromIterable(['a', 'b', 'c', 'd', 'e']),
          ).windowCount(3, startEvery: 1),
        ),
        [
          ['a', 'b', 'c'],
          ['b', 'c', 'd'],
          ['c', 'd', 'e'],
          ['d', 'e'],
          ['e'],
          [],
        ],
      );
    });

    test('gapped windows when startEvery > size', () async {
      expect(
        await drainWindows(
          fxEvents(
            Stream.fromIterable(['a', 'b', 'c', 'd', 'e', 'f', 'g']),
          ).windowCount(2, startEvery: 3),
        ),
        [
          ['a', 'b'],
          ['d', 'e'],
          ['g'],
        ],
      );
    });

    test('buffering inner still yields values after outer toList', () async {
      final windows = await fxEvents(
        Stream.fromIterable([1, 2, 3, 4]),
      ).windowCount(2).toList();
      expect(await windows[0].map((x) => x * 2).toList(), [2, 4]);
      expect(await windows[1].toList(), [3, 4]);
    });

    test('rejects a size or startEvery below 1', () {
      expect(
        () => fxEvents(Stream<int>.empty()).windowCount(0),
        throwsArgumentError,
      );
      expect(
        () => fxEvents(Stream<int>.empty()).windowCount(2, startEvery: 0),
        throwsArgumentError,
      );
    });

    test('source error errors every live window', () async {
      final source = StreamController<int>();
      final innerErrors = <Object>[];
      final outerErrors = <Object>[];
      fxEvents(source.stream)
          .windowCount(3, startEvery: 1)
          .listen(
            (w) => w.listen((_) {}, onError: innerErrors.add),
            onError: outerErrors.add,
          );
      await Future<void>.delayed(Duration.zero);
      source.add(1);
      await Future<void>.delayed(Duration.zero);
      source.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(innerErrors, isNotEmpty);
      expect(outerErrors.single, isA<StateError>());
      await source.close();
    });

    test('cancel mid-window completes live inners', () async {
      final source = StreamController<int>(sync: true);
      var innerDone = false;
      late final StreamSubscription<FxEvents<int>> sub;
      sub = fxEvents(source.stream).windowCount(2).listen((w) {
        w.listen((v) {
          if (v == 2) sub.cancel();
        }, onDone: () => innerDone = true);
      });
      await Future<void>.delayed(Duration.zero);
      source
        ..add(1)
        ..add(2);
      await Future<void>.delayed(Duration.zero);
      expect(innerDone, isTrue);
      await source.close();
    });
  });

  group('windowEvery', () {
    test('tumbling windows by span', () async {
      final out = await drainWindows(
        fxEvents(
          timed([(0, 1), (30, 2), (60, 3), (250, 4), (280, 5)], 520),
        ).windowEvery(const Duration(milliseconds: 200)),
      );
      expect(out, [
        [1, 2, 3],
        [4, 5],
        [],
      ]);
    });

    test('maxSize closes a tumbling window early', () async {
      final source = StreamController<int>();
      final future = drainWindows(
        fxEvents(
          source.stream,
        ).windowEvery(const Duration(seconds: 5), maxSize: 2),
      );
      await Future<void>.delayed(Duration.zero);
      source
        ..add(1)
        ..add(2)
        ..add(3);
      await source.close();
      expect(await future, [
        [1, 2],
        [3],
      ]);
    });

    test('overlapping windows at every, maxSize does not reopen', () async {
      final source = StreamController<int>();
      final future = drainWindows(
        fxEvents(source.stream).windowEvery(
          const Duration(seconds: 5),
          every: const Duration(seconds: 5),
          maxSize: 1,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      source
        ..add(1)
        ..add(2);
      await source.close();
      expect(await future, [
        [1],
      ]);
    });

    test('rejects non-positive span, every, or maxSize', () {
      expect(
        () => fxEvents(Stream<int>.empty()).windowEvery(Duration.zero),
        throwsArgumentError,
      );
      expect(
        () => fxEvents(
          Stream<int>.empty(),
        ).windowEvery(const Duration(seconds: 1), every: Duration.zero),
        throwsArgumentError,
      );
      expect(
        () => fxEvents(
          Stream<int>.empty(),
        ).windowEvery(const Duration(seconds: 1), maxSize: 0),
        throwsArgumentError,
      );
    });

    test('source error cancels timers and errors live windows', () async {
      final source = StreamController<int>();
      final innerErrors = <Object>[];
      final outerErrors = <Object>[];
      fxEvents(source.stream)
          .windowEvery(const Duration(seconds: 5))
          .listen(
            (w) => w.listen((_) {}, onError: innerErrors.add),
            onError: outerErrors.add,
          );
      await Future<void>.delayed(Duration.zero);
      source.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(innerErrors.single, isA<StateError>());
      expect(outerErrors.single, isA<StateError>());
      await source.close();
    });

    test('cancel mid-window does not leak timers', () async {
      final source = StreamController<int>();
      final sub = fxEvents(source.stream)
          .windowEvery(
            const Duration(milliseconds: 40),
            every: const Duration(milliseconds: 20),
          )
          .listen((w) => w.listen((_) {}));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      await source.close();
    });
  });

  group('windowToggle', () {
    test('overlapping windows close on the first closer event', () async {
      final source = StreamController<int>();
      final openings = StreamController<String>();
      final firstClose = StreamController<void>();
      final secondClose = StreamController<void>();
      final future = drainWindows(
        fxEvents(source.stream).windowToggle(
          openings.stream,
          (o) => o == 'first' ? firstClose.stream : secondClose.stream,
        ),
      );

      openings.add('first');
      await Future<void>.delayed(Duration.zero);
      source.add(1);
      openings.add('second');
      await Future<void>.delayed(Duration.zero);
      source.add(2);
      firstClose.add(null);
      source.add(3);
      await secondClose.close();
      source.add(4);
      await source.close();

      expect(await future, [
        [1, 2],
        [2, 3, 4],
      ]);
      await openings.close();
      await firstClose.close();
    });

    test('closer completion without a value leaves the window open', () async {
      final source = StreamController<int>();
      final openings = StreamController<void>();
      final closer = StreamController<void>();
      final future = drainWindows(
        fxEvents(
          source.stream,
        ).windowToggle(openings.stream, (_) => closer.stream),
      );
      openings.add(null);
      await Future<void>.delayed(Duration.zero);
      source.add(1);
      await closer.close();
      source.add(2);
      await source.close();
      expect(await future, [
        [1, 2],
      ]);
      await openings.close();
    });

    test('openings error errors live windows then the outer', () async {
      final source = StreamController<int>();
      final openings = StreamController<void>();
      final seen = <Object>[];
      fxEvents(source.stream)
          .windowToggle(openings.stream, (_) => StreamController<void>().stream)
          .listen((w) {
            w.listen((_) {}, onError: _ignoreError);
          }, onError: seen.add);
      await Future<void>.delayed(Duration.zero);
      openings.add(null);
      await Future<void>.delayed(Duration.zero);
      openings.addError(StateError('open'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await source.close();
      await openings.close();
    });

    test('closeOf throw errors live windows then the outer', () async {
      final source = StreamController<int>();
      final openings = StreamController<void>();
      final seen = <Object>[];
      fxEvents(source.stream)
          .windowToggle(openings.stream, (_) => throw StateError('close'))
          .listen(
            (w) => w.listen((_) {}, onError: _ignoreError),
            onError: seen.add,
          );
      await Future<void>.delayed(Duration.zero);
      openings.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await source.close();
      await openings.close();
    });

    test('closer error errors live windows then the outer', () async {
      final source = StreamController<int>();
      final openings = StreamController<void>();
      final closer = StreamController<void>();
      final seen = <Object>[];
      fxEvents(
        source.stream,
      ).windowToggle(openings.stream, (_) => closer.stream).listen((w) {
        w.listen((_) {}, onError: _ignoreError);
      }, onError: seen.add);
      openings.add(null);
      await Future<void>.delayed(Duration.zero);
      closer.addError(StateError('closer'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await source.close();
      await openings.close();
      await closer.close();
    });

    test('source error errors every live window', () async {
      final source = StreamController<int>();
      final openings = StreamController<void>();
      final innerErrors = <Object>[];
      final outerErrors = <Object>[];
      fxEvents(source.stream)
          .windowToggle(openings.stream, (_) => StreamController<void>().stream)
          .listen(
            (w) => w.listen((_) {}, onError: innerErrors.add),
            onError: outerErrors.add,
          );
      openings.add(null);
      openings.add(null);
      await Future<void>.delayed(Duration.zero);
      source.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(innerErrors, hasLength(2));
      expect(outerErrors.single, isA<StateError>());
      await source.close();
      await openings.close();
    });

    test('cancel completes live inners without emitting further', () async {
      final source = StreamController<int>();
      final openings = StreamController<void>();
      var innerDone = 0;
      final sub = fxEvents(source.stream)
          .windowToggle(openings.stream, (_) => StreamController<void>().stream)
          .listen((w) {
            w.listen((_) {}, onDone: () => innerDone++);
          });
      openings.add(null);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(innerDone, 1);
      await source.close();
      await openings.close();
    });

    test('adding after cancel of overlapping windows is ignored', () async {
      final source = StreamController<int>(sync: true);
      final openings = StreamController<void>(sync: true);
      late final StreamSubscription<FxEvents<int>> sub;
      final seen = <int>[];
      sub = fxEvents(source.stream)
          .windowToggle(openings.stream, (_) => StreamController<void>().stream)
          .listen((w) {
            w.listen((v) {
              seen.add(v);
              if (v == 1) sub.cancel();
            });
          });
      await Future<void>.delayed(Duration.zero);
      openings
        ..add(null)
        ..add(null);
      await Future<void>.delayed(Duration.zero);
      source.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isNotEmpty);
      await source.close();
      await openings.close();
    });
  });

  group('windowWhen', () {
    test('rotates on the first closer event', () async {
      final source = StreamController<int>();
      final closers = [
        StreamController<void>(),
        StreamController<void>(),
        StreamController<void>(),
      ];
      var i = 0;
      final future = drainWindows(
        fxEvents(source.stream).windowWhen(() => closers[i++].stream),
      );
      await Future<void>.delayed(Duration.zero);
      source.add(1);
      closers[0].add(null);
      await Future<void>.delayed(Duration.zero);
      source.add(2);
      closers[1].add(null);
      await Future<void>.delayed(Duration.zero);
      source.add(3);
      await source.close();
      expect(await future, [
        [1],
        [2],
        [3],
      ]);
      for (final c in closers) {
        await c.close();
      }
    });

    test('rotates when the closer completes without a value', () async {
      final source = StreamController<int>();
      final closers = [StreamController<void>(), StreamController<void>()];
      var i = 0;
      final future = drainWindows(
        fxEvents(source.stream).windowWhen(() => closers[i++].stream),
      );
      await Future<void>.delayed(Duration.zero);
      source.add(1);
      await closers[0].close();
      await Future<void>.delayed(Duration.zero);
      source.add(2);
      await source.close();
      expect(await future, [
        [1],
        [2],
      ]);
      await closers[1].close();
    });

    test('sync closer events drain without hanging', () async {
      var n = 0;
      final windows = await drainWindows(
        fxEvents(Stream.fromIterable([1, 2])).windowWhen(() {
          n++;
          return n <= 2
              ? Stream<void>.fromIterable([null])
              : StreamController<void>().stream;
        }),
      );
      expect(n, greaterThan(1));
      expect([for (final w in windows) ...w], [1, 2]);
    });

    test('closeOf throw errors the live window then the outer', () async {
      final source = StreamController<int>();
      final first = StreamController<void>();
      var calls = 0;
      final seen = <Object>[];
      fxEvents(source.stream)
          .windowWhen(() {
            calls++;
            if (calls == 1) return first.stream;
            throw StateError('sel');
          })
          .listen(
            (w) => w.listen((_) {}, onError: _ignoreError),
            onError: seen.add,
          );
      await Future<void>.delayed(Duration.zero);
      first.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await source.close();
      await first.close();
    });

    test('closer error errors the live window then the outer', () async {
      final source = StreamController<int>();
      final closer = StreamController<void>();
      final seen = <Object>[];
      fxEvents(source.stream)
          .windowWhen(() => closer.stream)
          .listen(
            (w) => w.listen((_) {}, onError: _ignoreError),
            onError: seen.add,
          );
      await Future<void>.delayed(Duration.zero);
      closer.addError(StateError('closer'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await source.close();
      await closer.close();
    });

    test('source error errors the live window then the outer', () async {
      final source = StreamController<int>();
      final seen = <Object>[];
      fxEvents(source.stream)
          .windowWhen(() => StreamController<void>().stream)
          .listen(
            (w) => w.listen((_) {}, onError: _ignoreError),
            onError: seen.add,
          );
      await Future<void>.delayed(Duration.zero);
      source.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await source.close();
    });

    test('cancel completes the live inner', () async {
      final source = StreamController<int>();
      var innerDone = false;
      final sub = fxEvents(source.stream)
          .windowWhen(() => StreamController<void>().stream)
          .listen((w) {
            w.listen((_) {}, onDone: () => innerDone = true);
          });
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(innerDone, isTrue);
      await source.close();
    });
  });

  group('chunkToggle', () {
    test('overlapping buffers emit lists on close', () async {
      final source = StreamController<int>();
      final openings = StreamController<String>();
      final firstClose = StreamController<void>();
      final secondClose = StreamController<void>();
      final out = fxEvents(source.stream)
          .chunkToggle(
            openings.stream,
            (o) => o == 'first' ? firstClose.stream : secondClose.stream,
          )
          .toList();

      openings.add('first');
      await Future<void>.delayed(Duration.zero);
      source.add(1);
      await Future<void>.delayed(Duration.zero);
      openings.add('second');
      await Future<void>.delayed(Duration.zero);
      source.add(2);
      await Future<void>.delayed(Duration.zero);
      firstClose.add(null);
      await Future<void>.delayed(Duration.zero);
      source.add(3);
      await Future<void>.delayed(Duration.zero);
      secondClose.add(null);
      await source.close();

      expect(await out, [
        [1, 2],
        [2, 3],
      ]);
      await openings.close();
      await firstClose.close();
      await secondClose.close();
    });

    test('skips empty buffers on close and on source complete', () async {
      final source = StreamController<int>();
      final openings = StreamController<void>();
      final closer = StreamController<void>.broadcast();
      final out = fxEvents(
        source.stream,
      ).chunkToggle(openings.stream, (_) => closer.stream).toList();

      openings.add(null);
      closer.add(null);
      await Future<void>.delayed(Duration.zero);
      openings.add(null);
      await source.close();

      expect(await out, isEmpty);
      await openings.close();
      await closer.close();
    });

    test('flushes a non-empty buffer when the source completes', () async {
      final source = StreamController<int>();
      final openings = StreamController<void>();
      final out = fxEvents(source.stream)
          .chunkToggle(openings.stream, (_) => StreamController<void>().stream)
          .toList();
      openings.add(null);
      source.add(1);
      await source.close();
      expect(await out, [
        [1],
      ]);
      await openings.close();
    });

    test('cancel drops open buffers without emitting', () async {
      final source = StreamController<int>();
      final openings = StreamController<void>();
      final seen = <List<int>>[];
      final sub = fxEvents(source.stream)
          .chunkToggle(openings.stream, (_) => StreamController<void>().stream)
          .listen(seen.add);
      openings.add(null);
      source.add(1);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(seen, isEmpty);
      await source.close();
      await openings.close();
    });

    test('openings error forwards to the outer', () async {
      final source = StreamController<int>();
      final openings = StreamController<void>();
      final seen = <Object>[];
      fxEvents(source.stream)
          .chunkToggle(openings.stream, (_) => Stream.empty())
          .listen((_) {}, onError: seen.add);
      openings.addError(StateError('open'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await source.close();
      await openings.close();
    });
  });

  group('groupsBy', () {
    test(
      'two keys emit live groups and the opening value is visible',
      () async {
        final seen = <int, List<int>>{};
        final done = Completer<void>();
        fxEvents(
          Stream.fromIterable([1, 2, 3, 4]),
        ).groupsBy((n) => n % 2).listen((g) {
          final bucket = <int>[];
          seen[g.key] = bucket;
          g.events.listen(bucket.add);
        }, onDone: done.complete);
        await done.future;
        expect(seen[1], [1, 3]);
        expect(seen[0], [2, 4]);
      },
    );

    test('lastFor completes a group and the key may reopen', () async {
      final source = StreamController<int>();
      final lasts = <int, StreamController<void>>{};
      final observations = <({int key, List<Object> values})>[];
      final done = Completer<void>();
      fxEvents(source.stream)
          .groupsBy(
            (n) => n % 2,
            lastFor: (key) => (lasts[key] = StreamController<void>()).stream,
          )
          .listen((g) {
            final values = <Object>[];
            observations.add((key: g.key, values: values));
            g.events.listen(values.add, onDone: () => values.add('done'));
          }, onDone: done.complete);

      source.add(1);
      await Future<void>.delayed(Duration.zero);
      source.add(3);
      lasts[1]!.add(null);
      await Future<void>.delayed(Duration.zero);
      source.add(5);
      await source.close();
      await done.future;

      expect(observations, hasLength(2));
      expect(observations[0].key, 1);
      expect(observations[0].values, [1, 3, 'done']);
      expect(observations[1].key, 1);
      expect(observations[1].values, [5, 'done']);
    });

    test('lastFor completion without a value also closes the group', () async {
      final groups = await _drainGroups(
        fxEvents(
          Stream.fromIterable([1, 1]),
        ).groupsBy((n) => n, lastFor: (_) => Stream<void>.empty()),
      );
      expect(groups, hasLength(2));
      expect(groups[0].key, 1);
      expect(groups[0].values, [1]);
      expect(groups[1].key, 1);
      expect(groups[1].values, [1]);
    });

    test('lastFor error errors that group only', () async {
      final source = StreamController<int>();
      final last = StreamController<void>.broadcast();
      final groupErrors = <Object>[];
      final outerErrors = <Object>[];
      final values = <int>[];
      fxEvents(
        source.stream,
      ).groupsBy((n) => n, lastFor: (_) => last.stream).listen((g) {
        g.events.listen(values.add, onError: groupErrors.add);
      }, onError: outerErrors.add);
      source.add(1);
      await Future<void>.delayed(Duration.zero);
      last.addError(StateError('last'));
      await Future<void>.delayed(Duration.zero);
      source.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(groupErrors.single, isA<StateError>());
      expect(outerErrors, isEmpty);
      expect(values, [1, 2]);
      await source.close();
      await last.close();
    });

    test('lastFor throw errors every group then the outer', () async {
      final seen = <Object>[];
      fxEvents(Stream.fromIterable([1]))
          .groupsBy((n) => n, lastFor: (_) => throw StateError('sel'))
          .listen(
            (g) => g.events.listen((_) {}, onError: _ignoreError),
            onError: seen.add,
          );
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
    });

    test('keyOf throw errors live groups then the outer', () async {
      final source = StreamController<int>();
      final seen = <Object>[];
      fxEvents(source.stream)
          .groupsBy((n) {
            if (n == 2) throw StateError('key');
            return n;
          })
          .listen(
            (g) => g.events.listen((_) {}, onError: _ignoreError),
            onError: seen.add,
          );
      source.add(1);
      await Future<void>.delayed(Duration.zero);
      source.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await source.close();
    });

    test('source error errors every live group then the outer', () async {
      final source = StreamController<int>();
      final innerErrors = <Object>[];
      final outerErrors = <Object>[];
      fxEvents(source.stream)
          .groupsBy((n) => n % 2)
          .listen(
            (g) => g.events.listen((_) {}, onError: innerErrors.add),
            onError: outerErrors.add,
          );
      source
        ..add(1)
        ..add(2);
      await Future<void>.delayed(Duration.zero);
      source.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(innerErrors, hasLength(2));
      expect(outerErrors.single, isA<StateError>());
      await source.close();
    });

    test('cancel completes live groups', () async {
      final source = StreamController<int>();
      var innerDone = 0;
      final sub = fxEvents(source.stream).groupsBy((n) => n).listen((g) {
        g.events.listen((_) {}, onDone: () => innerDone++);
      });
      source.add(1);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(innerDone, 1);
      await source.close();
    });
  });
}

Future<List<({int key, List<int> values})>> _drainGroups(
  FxEvents<GroupedEvents<int, int>> groups,
) async {
  final collected = <({int key, List<int> values})>[];
  final inners = <Future<void>>[];
  await groups.listen((g) {
    final values = <int>[];
    collected.add((key: g.key, values: values));
    inners.add(g.events.listen(values.add).asFuture<void>());
  }).asFuture<void>();
  await Future.wait(inners);
  return collected;
}
