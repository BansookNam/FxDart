import 'dart:async';

import 'package:fxdart/fxdart.dart' hide isEmpty;
import 'package:test/test.dart';

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  group('switchLatest', () {
    test('a newer inner stream cancels the previous one', () async {
      final outer = StreamController<Stream<int>>();
      final inner1 = StreamController<int>();
      final inner2 = StreamController<int>();
      final seen = <int>[];
      fxEvents(outer.stream).switchLatest().listen(seen.add);

      outer.add(inner1.stream);
      inner1.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1]));

      outer.add(inner2.stream);
      await Future<void>.delayed(Duration.zero);
      expect(inner1.hasListener, isFalse);

      inner1.add(99);
      inner2.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1, 2]));

      await inner2.close();
      await inner1.close();
      await outer.close();
    });

    test('closes after outer done and last inner completes', () async {
      final inner = StreamController<int>();
      final outer = StreamController<Stream<int>>();
      final seen = <int>[];
      final done = Completer<void>();
      fxEvents(
        outer.stream,
      ).switchLatest().listen(seen.add, onDone: done.complete);

      outer.add(inner.stream);
      await outer.close();
      await Future<void>.delayed(Duration.zero);
      expect(done.isCompleted, isFalse);

      inner.add(1);
      await inner.close();
      await done.future;
      expect(seen, equals([1]));
    });

    test('an empty outer closes with no event', () async {
      expect(
        await fxEvents(
          const Stream<Stream<int>>.empty(),
        ).switchLatest().toList(),
        isEmpty,
      );
    });

    test('forwards inner errors and supports cancel', () async {
      final outer = StreamController<Stream<int>>();
      final inner = StreamController<int>();
      final seen = <Object>[];
      final sub = fxEvents(
        outer.stream,
      ).switchLatest().listen(seen.add, onError: seen.add);

      outer.add(inner.stream);
      inner.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await sub.cancel();
      expect(outer.hasListener, isFalse);
      await inner.close();
      await outer.close();
    });
  });

  group('flattenMerge', () {
    test('interleaves every inner stream at once', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final outer = StreamController<Stream<int>>();
      final seen = <int>[];
      fxEvents(outer.stream).flattenMerge().listen(seen.add);
      await flush();

      outer.add(a.stream);
      outer.add(b.stream);
      await flush();
      b.add(2);
      a.add(1);
      await flush();
      expect(seen, equals([2, 1]));

      await a.close();
      await b.close();
      await outer.close();
    });

    test('concurrent caps how many inners run together', () async {
      final c1 = StreamController<int>();
      final c2 = StreamController<int>();
      final c3 = StreamController<int>();
      final seen = <int>[];
      final done = Completer<void>();
      fxEvents(
        Stream.fromIterable([c1.stream, c2.stream, c3.stream]),
      ).flattenMerge(concurrent: 2).listen(seen.add, onDone: done.complete);
      await flush();

      expect(c1.hasListener, isTrue);
      expect(c2.hasListener, isTrue);
      expect(c3.hasListener, isFalse);

      c1.add(1);
      c1.close();
      await flush();
      expect(c3.hasListener, isTrue);

      c2.close();
      c3.close();
      await done.future;
      expect(seen, equals([1]));
    });

    test('rejects a concurrent below 1', () {
      expect(
        () => fxEvents(
          const Stream<Stream<int>>.empty(),
        ).flattenMerge(concurrent: 0),
        throwsArgumentError,
      );
    });
  });

  group('flattenConcat', () {
    test('plays inner streams strictly in order', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final outer = StreamController<Stream<int>>();
      final seen = <int>[];
      fxEvents(outer.stream).flattenConcat().listen(seen.add);

      outer.add(a.stream);
      outer.add(b.stream);
      await Future<void>.delayed(Duration.zero);
      expect(b.hasListener, isFalse);

      a.add(1);
      await a.close();
      await Future<void>.delayed(Duration.zero);
      expect(b.hasListener, isTrue);
      expect(seen, equals([1]));

      b.add(2);
      await b.close();
      await outer.close();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1, 2]));
    });
  });

  group('exhaustLatest', () {
    test('ignores inner streams that arrive while one is running', () async {
      final outer = StreamController<Stream<int>>();
      final inner1 = StreamController<int>();
      final inner2 = StreamController<int>();
      final inner3 = StreamController<int>();
      final seen = <int>[];
      fxEvents(outer.stream).exhaustLatest().listen(seen.add);
      await flush();

      outer.add(inner1.stream);
      outer.add(inner2.stream);
      await flush();
      expect(inner1.hasListener, isTrue);
      expect(inner2.hasListener, isFalse);

      inner1.add(1);
      inner1.close();
      await flush();

      outer.add(inner3.stream);
      await flush();
      inner3.add(3);
      await flush();
      expect(seen, equals([1, 3]));

      inner2.close();
      await inner3.close();
      await outer.close();
    });
  });

  group('zipAll', () {
    test('waits for the outer to complete before zipping', () async {
      final outer = StreamController<Stream<int>>();
      final a = StreamController<int>();
      final b = StreamController<int>();
      final seen = <List<int>>[];
      fxEvents(outer.stream).zipAll<List<int>>().listen(seen.add);

      outer.add(a.stream);
      outer.add(b.stream);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
      expect(a.hasListener, isFalse);
      expect(b.hasListener, isFalse);

      await outer.close();
      await Future<void>.delayed(Duration.zero);
      expect(a.hasListener, isTrue);
      expect(b.hasListener, isTrue);

      a.add(1);
      b.add(10);
      await Future<void>.delayed(Duration.zero);
      expect(
        seen,
        equals([
          [1, 10],
        ]),
      );

      await a.close();
      await b.close();
    });

    test('project maps each aligned tuple', () async {
      final out = await fxEvents(
        Stream.fromIterable([
          Stream.fromIterable([1, 2]),
          Stream.fromIterable([10, 20]),
        ]),
      ).zipAll((xs) => xs[0] + xs[1]).toList();
      expect(out, equals([11, 22]));
    });

    test('an empty outer closes with no event', () async {
      expect(
        await fxEvents(
          const Stream<Stream<int>>.empty(),
        ).zipAll<List<int>>().toList(),
        isEmpty,
      );
    });

    test('forwards outer errors', () async {
      final outer = StreamController<Stream<int>>();
      final seen = <Object>[];
      fxEvents(
        outer.stream,
      ).zipAll<List<int>>().listen(seen.add, onError: seen.add);
      outer.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await outer.close();
    });

    test('forwards inner errors after the zip starts', () async {
      final outer = StreamController<Stream<int>>();
      final a = StreamController<int>();
      final seen = <Object>[];
      fxEvents(
        outer.stream,
      ).zipAll<List<int>>().listen(seen.add, onError: seen.add);
      outer.add(a.stream);
      await outer.close();
      await Future<void>.delayed(Duration.zero);
      a.addError(StateError('inner'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await a.close();
    });

    test('cancel before the outer completes cancels the outer', () async {
      final outer = StreamController<Stream<int>>();
      final sub = fxEvents(outer.stream).zipAll<List<int>>().listen((_) {});
      expect(outer.hasListener, isTrue);
      await sub.cancel();
      expect(outer.hasListener, isFalse);
      await outer.close();
    });

    test('cancel after the zip starts cancels the inners', () async {
      final outer = StreamController<Stream<int>>();
      final a = StreamController<int>();
      final sub = fxEvents(outer.stream).zipAll<List<int>>().listen((_) {});
      outer.add(a.stream);
      await outer.close();
      await Future<void>.delayed(Duration.zero);
      expect(a.hasListener, isTrue);
      await sub.cancel();
      expect(a.hasListener, isFalse);
    });
  });

  group('concatEager', () {
    test(
      'subscribes all immediately and still emits in source order',
      () async {
        final a = StreamController<int>();
        final b = StreamController<int>();
        final seen = <int>[];
        final done = Completer<void>();
        concatEager([
          a.stream,
          b.stream,
        ]).listen(seen.add, onDone: done.complete);

        expect(a.hasListener, isTrue);
        expect(b.hasListener, isTrue);

        b.add(10);
        await Future<void>.delayed(Duration.zero);
        expect(seen, isEmpty, reason: 'later source is buffered');

        a.add(1);
        await Future<void>.delayed(Duration.zero);
        expect(seen, equals([1]));

        await a.close();
        await Future<void>.delayed(Duration.zero);
        expect(seen, equals([1, 10]));

        b.add(11);
        await Future<void>.delayed(Duration.zero);
        expect(seen, equals([1, 10, 11]));

        await b.close();
        await done.future;
      },
    );

    test('drains several already-closed later sources in one step', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final c = StreamController<int>();
      final seen = <int>[];
      final done = Completer<void>();
      concatEager([
        a.stream,
        b.stream,
        c.stream,
      ]).listen(seen.add, onDone: done.complete);

      b.add(10);
      await b.close();
      await c.close();
      a.add(1);
      await a.close();
      await done.future;
      expect(seen, equals([1, 10]));
    });

    test('an empty source list closes immediately', () async {
      expect(await concatEager<int>(const []).toList(), isEmpty);
    });

    test('sync sources still emit in order', () async {
      expect(
        await concatEager([
          Stream.fromIterable([1, 2]),
          Stream<int>.empty(),
          Stream.fromIterable([3]),
        ]).toList(),
        equals([1, 2, 3]),
      );
    });

    test('forwards errors and supports cancel', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final seen = <Object>[];
      final sub = concatEager([
        a.stream,
        b.stream,
      ]).listen(seen.add, onError: seen.add);
      b.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await sub.cancel();
      expect(a.hasListener, isFalse);
      expect(b.hasListener, isFalse);
      await a.close();
      await b.close();
    });
  });

  group('combine', () {
    test('all-true specs behave like combineLatestAll', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final seen = <List<int>>[];
      combine([CombineSpec(a.stream), CombineSpec(b.stream)]).listen(seen.add);

      a.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);

      b.add(10);
      await Future<void>.delayed(Duration.zero);
      a.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(
        seen,
        equals([
          [1, 10],
          [2, 10],
        ]),
      );

      await a.close();
      await b.close();
    });

    test('mixed causesEmit is withLatestFrom-style', () async {
      final src = StreamController<int>();
      final other = StreamController<int>();
      final seen = <List<int>>[];
      combine([
        CombineSpec(src.stream),
        CombineSpec(other.stream, causesEmit: false),
      ]).listen(seen.add);

      src.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);

      other.add(10);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty, reason: 'other does not cause emit');

      src.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(
        seen,
        equals([
          [2, 10],
        ]),
      );

      await src.close();
      await other.close();
    });

    test(
      'requireFirst false fills the slot with null until it speaks',
      () async {
        final a = StreamController<int?>();
        final b = StreamController<int?>();
        final seen = <List<int?>>[];
        combine<int?>([
          CombineSpec(a.stream),
          CombineSpec(b.stream, requireFirst: false),
        ]).listen(seen.add);

        a.add(1);
        await Future<void>.delayed(Duration.zero);
        expect(
          seen,
          equals([
            [1, null],
          ]),
        );

        b.add(2);
        await Future<void>.delayed(Duration.zero);
        expect(
          seen,
          equals([
            [1, null],
            [1, 2],
          ]),
        );

        await a.close();
        await b.close();
      },
    );

    test('all requireFirst false emits on the first causesEmit', () async {
      final a = StreamController<int?>();
      final b = StreamController<int?>();
      final seen = <List<int?>>[];
      combine<int?>([
        CombineSpec(a.stream, requireFirst: false),
        CombineSpec(b.stream, requireFirst: false, causesEmit: false),
      ]).listen(seen.add);

      a.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(
        seen,
        equals([
          [1, null],
        ]),
      );

      await a.close();
      await b.close();
    });

    test('no causesEmit spec never emits, then closes', () async {
      final a = StreamController<int>();
      final seen = <List<int>>[];
      final done = Completer<void>();
      combine([
        CombineSpec(a.stream, causesEmit: false),
      ]).listen(seen.add, onDone: done.complete);
      a.add(1);
      await a.close();
      await done.future;
      expect(seen, isEmpty);
    });

    test('an empty spec list closes immediately', () async {
      expect(await combine<int>(const []).toList(), isEmpty);
    });

    test('forwards errors and supports cancel', () async {
      final a = StreamController<int>();
      final seen = <Object>[];
      final sub = combine([
        CombineSpec(a.stream),
      ]).listen(seen.add, onError: seen.add);
      a.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await sub.cancel();
      expect(a.hasListener, isFalse);
      await a.close();
    });
  });

  group('withLatestFromAll', () {
    test('drops source events until every other has spoken', () async {
      final src = StreamController<int>();
      final a = StreamController<Object?>();
      final b = StreamController<Object?>();
      final seen = <String>[];
      fxEvents(src.stream)
          .withLatestFromAll([
            a.stream,
            b.stream,
          ], (v, latest) => '$v:${latest.join(",")}')
          .listen(seen.add);

      src.add(1);
      a.add('x');
      src.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);

      b.add('y');
      src.add(3);
      a.add('z');
      src.add(4);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals(['3:x,y', '4:z,y']));

      await src.close();
      await a.close();
      await b.close();
    });

    test('empty others stamps every source event with []', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2])).withLatestFromAll(
          const <Stream<Object?>>[],
          (v, latest) {
            expect(latest, isEmpty);
            return v;
          },
        ).toList(),
        equals([1, 2]),
      );
    });

    test('closes with the source and cancels the others', () async {
      final src = StreamController<int>();
      final other = StreamController<Object?>();
      other.add(1);
      final done = Completer<void>();
      fxEvents(src.stream)
          .withLatestFromAll([other.stream], (v, latest) => v)
          .listen((_) {}, onDone: done.complete);
      await Future<void>.delayed(Duration.zero);
      expect(other.hasListener, isTrue);
      await src.close();
      await done.future;
      expect(other.hasListener, isFalse);
    });

    test('forwards source and other errors, and supports cancel', () async {
      final src = StreamController<int>();
      final other = StreamController<Object?>();
      final seen = <Object>[];
      final sub = fxEvents(src.stream)
          .withLatestFromAll([other.stream], (v, latest) => v)
          .listen(seen.add, onError: seen.add);

      other.addError(StateError('other'));
      src.addError(StateError('src'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.whereType<StateError>().length, equals(2));
      await sub.cancel();
      expect(src.hasListener, isFalse);
      expect(other.hasListener, isFalse);
      await src.close();
      await other.close();
    });
  });

  group('connect', () {
    test('listens to the source once and multicasts to the selector', () async {
      final src = StreamController<int>();
      final seen = <int>[];
      fxEvents(src.stream)
          .connect((shared) {
            return FxEvents.merge([
              shared.stream,
              shared.map((x) => x * 10).stream,
            ]);
          })
          .listen(seen.add);

      src.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen, unorderedEquals([1, 10]));
      await src.close();
    });

    test('source complete closes the shared run', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2])).connect((s) => s).toList(),
        equals([1, 2]),
      );
    });

    test('selector result complete cancels the source', () async {
      final src = StreamController<int>();
      final seen = <int>[];
      final done = Completer<void>();
      fxEvents(
        src.stream,
      ).connect((s) => s.take(1)).listen(seen.add, onDone: done.complete);
      src.add(1);
      await done.future;
      expect(seen, equals([1]));
      expect(src.hasListener, isFalse);
      await src.close();
    });

    test('an already-done selector never starts the source', () async {
      final src = StreamController<int>();
      final seen = <int>[];
      final done = Completer<void>();
      fxEvents(src.stream)
          .connect((_) => fxEvents(const Stream<int>.empty()))
          .listen(seen.add, onDone: done.complete);
      await done.future;
      expect(seen, isEmpty);
      expect(src.hasListener, isFalse);
      await src.close();
    });

    test('a throwing selector becomes an error event', () async {
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(Stream.fromIterable([1]))
          .connect<int>((_) => throw StateError('boom'))
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future;
      expect(seen.single, isA<StateError>());
    });

    test('forwards source errors through the shared run', () async {
      final src = StreamController<int>();
      final seen = <Object>[];
      fxEvents(
        src.stream,
      ).connect((s) => s).listen(seen.add, onError: seen.add);
      src.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await src.close();
    });

    test('forwards selector-result errors', () async {
      final src = StreamController<int>();
      final seen = <Object>[];
      fxEvents(src.stream)
          .connect((s) => s.map((_) => throw StateError('mapped')))
          .listen(seen.add, onError: seen.add);
      src.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await src.close();
    });

    test('cancel of the result cancels the source', () async {
      final src = StreamController<int>();
      final sub = fxEvents(src.stream).connect((s) => s).listen((_) {});
      expect(src.hasListener, isTrue);
      await sub.cancel();
      expect(src.hasListener, isFalse);
      await src.close();
    });
  });
}
