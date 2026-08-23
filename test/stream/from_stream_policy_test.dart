import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:fxdart/src/async_iterable.dart'
    show
        FxFastIterator,
        StreamPullCancel,
        fromStreamChunked,
        fromStreamLatest,
        fromStreamNext;
import 'package:test/test.dart';

/// Emits [values] (then optionally [error]) *during* `listen()`, before it
/// returns — the Dart analogue of RxJS's synchronous Observable.
/// `StreamController` and `Stream.multi` both defer events added from
/// `onListen` until after `listen` has returned.
Stream<T> syncStream<T>(Iterable<T> values, [Object? error]) =>
    _SyncListenStream(List<T>.of(values), error);

class _SyncListenStream<T> extends Stream<T> {
  _SyncListenStream(this._values, this._error);
  final List<T> _values;
  final Object? _error;

  @override
  StreamSubscription<T> listen(
    void Function(T value)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final sub = _SyncListenSubscription<T>();
    for (final v in _values) {
      if (sub.cancelled) break;
      onData?.call(v);
    }
    if (sub.cancelled) return sub;
    if (_error != null) {
      if (onError is void Function(Object, StackTrace)) {
        onError(_error, StackTrace.current);
      } else if (onError is void Function(Object)) {
        onError(_error);
      }
    } else {
      onDone?.call();
    }
    return sub;
  }
}

class _SyncListenSubscription<T> implements StreamSubscription<T> {
  var cancelled = false;

  @override
  Future<void> cancel() {
    cancelled = true;
    return Future<void>.value();
  }

  @override
  void pause([Future<void>? resumeSignal]) {}

  @override
  void resume() {}

  @override
  bool get isPaused => false;

  @override
  Future<E> asFuture<E>([E? futureValue]) => Completer<E>().future;

  @override
  void onData(void Function(T data)? handleData) {}

  @override
  void onDone(void Function()? handleDone) {}

  @override
  void onError(Function? handleError) {}
}

void main() {
  group('fromStream (each / lossless)', () {
    test('a sync burst is delivered in full, in order', () async {
      expect(
        await toListAsync(fromStream(syncStream([1, 2, 3]))),
        equals([1, 2, 3]),
      );
    });

    test('values that arrive between pulls stay queued', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStream(c.stream).iterator;
      final first = it.next();
      c.add(0);
      expect((await first).value, 0);
      c
        ..add(1)
        ..add(2)
        ..add(3);
      expect((await it.next()).value, 1);
      expect((await it.next()).value, 2);
      expect((await it.next()).value, 3);
      unawaited(c.close());
      expect((await it.next()).done, isTrue);
    });
  });

  group('fromStreamLatest', () {
    test('a sync burst collapses to the last value', () async {
      expect(
        await toListAsync(fromStreamLatest(syncStream([1, 2, 3]))),
        equals([3]),
      );
    });

    test('push 1,2,3 while not pulling, pull once → 3', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamLatest(c.stream).iterator;
      final first = it.next();
      c.add(0);
      expect((await first).value, 0);
      c
        ..add(1)
        ..add(2)
        ..add(3);
      expect((await it.next()).value, 3);
      unawaited(c.close());
      expect((await it.next()).done, isTrue);
    });

    test('a same-turn burst while waiting settles on the last value', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamLatest(c.stream).iterator;
      final first = it.next();
      c
        ..add(1)
        ..add(2)
        ..add(3);
      expect((await first).value, 3);
      unawaited(c.close());
      expect((await it.next()).done, isTrue);
    });

    test('does not subscribe until the first pull', () async {
      var listens = 0;
      final c = StreamController<int>(onListen: () => listens++);
      final iterable = fromStreamLatest(c.stream);
      expect(listens, 0);
      final pending = iterable.iterator.next();
      expect(listens, 1);
      c.add(1);
      expect((await pending).value, 1);
      unawaited(c.close());
    });

    test('completion flushes the accepted latest then ends', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamLatest(c.stream).iterator;
      final first = it.next();
      c.add(1);
      expect((await first).value, 1);
      c
        ..add(2)
        ..add(3);
      unawaited(c.close());
      expect((await it.next()).value, 3);
      expect((await it.next()).done, isTrue);
    });

    test('completion with nothing accepted ends immediately', () async {
      expect(
        await toListAsync(fromStreamLatest(const Stream<int>.empty())),
        equals(<int>[]),
      );
    });

    test('completion while waiting with no slot ends the pull', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamLatest(c.stream).iterator;
      final pending = it.next();
      unawaited(c.close());
      expect((await pending).done, isTrue);
    });

    test('error after an accepted latest is thrown on the next pull', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamLatest(c.stream).iterator;
      final first = it.next();
      c
        ..add(1)
        ..add(2)
        ..addError(StateError('boom'));
      expect((await first).value, 2);
      await expectLater(it.next(), throwsStateError);
      expect((await it.next()).done, isTrue);
    });

    test('error with a stored latest yields it then throws', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamLatest(c.stream).iterator;
      final first = it.next();
      c.add(0);
      expect((await first).value, 0);
      c
        ..add(1)
        ..add(2)
        ..addError(StateError('boom'));
      expect((await it.next()).value, 2);
      await expectLater(it.next(), throwsStateError);
    });

    test('error with no accepted latest fails the waiting pull', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamLatest(c.stream).iterator;
      final pending = it.next();
      c.addError(StateError('boom'));
      await expectLater(pending, throwsStateError);
      expect((await it.next()).done, isTrue);
    });

    test('error with no accepted latest fails the next pull', () async {
      await expectLater(
        toListAsync(fromStreamLatest(Stream<int>.error(StateError('boom')))),
        throwsStateError,
      );
    });

    test(
      'sync source that errors after values yields latest then throws',
      () async {
        await expectLater(
          toListAsync(fromStreamLatest(syncStream([1, 2], StateError('boom')))),
          throwsStateError,
        );
      },
    );

    test('overlapping next() is queued', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamLatest(c.stream).iterator;
      final a = it.next();
      final b = it.next();
      c
        ..add(1)
        ..add(2)
        ..add(3);
      expect((await a).value, 3);
      c.add(4);
      expect((await b).value, 4);
      unawaited(c.close());
    });

    test('broadcast source still latest-wins', () async {
      final c = StreamController<int>.broadcast(sync: true);
      final it = fromStreamLatest(c.stream).iterator;
      final first = it.next();
      c
        ..add(1)
        ..add(2)
        ..add(3);
      expect((await first).value, 3);
      unawaited(c.close());
      expect((await it.next()).done, isTrue);
    });

    test('nextOr answers a stored latest synchronously', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamLatest(c.stream).iterator as FxFastIterator<int>;
      final first = it.next();
      c.add(0);
      await first;
      c
        ..add(1)
        ..add(2);
      final r = it.nextOr();
      expect(r, isA<IterResult<int>>());
      expect((r as IterResult<int>).value, 2);
      unawaited(c.close());
    });

    test('cancel before subscribe is a no-op on the source', () async {
      final c = StreamController<int>();
      final it = fromStreamLatest(c.stream).iterator as StreamPullCancel;
      await it.cancel();
      expect(c.hasListener, isFalse);
      unawaited(c.close());
    });

    test('cancel drops the in-flight pull and the subscription', () async {
      final c = StreamController<int>();
      var cancelled = false;
      c.onCancel = () => cancelled = true;
      final it = fromStreamLatest(c.stream).iterator;
      final pending = it.next();
      expect(c.hasListener, isTrue);
      await (it as StreamPullCancel).cancel();
      expect(cancelled, isTrue);
      expect(c.hasListener, isFalse);
      expect((await pending).done, isTrue);
    });

    test('cancel while a burst is scheduled still ends the pull', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamLatest(c.stream).iterator;
      final pending = it.next();
      c
        ..add(1)
        ..add(2);
      await (it as StreamPullCancel).cancel();
      expect((await pending).done, isTrue);
      expect(c.hasListener, isFalse);
      unawaited(c.close());
    });
  });

  group('fromStreamChunked', () {
    test('a sync burst is one list', () async {
      expect(
        await toListAsync(fromStreamChunked(syncStream([1, 2, 3]))),
        equals([
          [1, 2, 3],
        ]),
      );
    });

    test('push 1,2,3 while not pulling, pull → [1, 2, 3]', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamChunked(c.stream).iterator;
      final first = it.next();
      c.add(0);
      expect((await first).value, [0]);
      c
        ..add(1)
        ..add(2)
        ..add(3);
      expect((await it.next()).value, [1, 2, 3]);
      unawaited(c.close());
      expect((await it.next()).done, isTrue);
    });

    test('a same-turn burst while waiting is one snapshot', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamChunked(c.stream).iterator;
      final first = it.next();
      c
        ..add(1)
        ..add(2)
        ..add(3);
      expect((await first).value, [1, 2, 3]);
      final second = it.next();
      c
        ..add(4)
        ..add(5);
      expect((await second).value, [4, 5]);
      unawaited(c.close());
      expect((await it.next()).done, isTrue);
    });

    test('does not subscribe until the first pull', () async {
      var listens = 0;
      final c = StreamController<int>(onListen: () => listens++);
      fromStreamChunked(c.stream);
      expect(listens, 0);
      final pending = fromStreamChunked(c.stream).iterator.next();
      expect(listens, 1);
      c.add(1);
      expect((await pending).value, [1]);
      unawaited(c.close());
    });

    test('completion flushes a remaining buffer then ends', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamChunked(c.stream).iterator;
      final first = it.next();
      c.add(1);
      expect((await first).value, [1]);
      c
        ..add(2)
        ..add(3);
      unawaited(c.close());
      expect((await it.next()).value, [2, 3]);
      expect((await it.next()).done, isTrue);
    });

    test('completion with an empty buffer does not yield []', () async {
      expect(
        await toListAsync(fromStreamChunked(const Stream<int>.empty())),
        equals(<List<int>>[]),
      );
    });

    test('completion while waiting with no buffer ends the pull', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamChunked(c.stream).iterator;
      final pending = it.next();
      unawaited(c.close());
      expect((await pending).done, isTrue);
    });

    test('error after an accepted buffer is thrown on the next pull', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamChunked(c.stream).iterator;
      final first = it.next();
      c
        ..add(1)
        ..add(2)
        ..addError(StateError('boom'));
      expect((await first).value, [1, 2]);
      await expectLater(it.next(), throwsStateError);
      expect((await it.next()).done, isTrue);
    });

    test('error with a stored buffer yields it then throws', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamChunked(c.stream).iterator;
      final first = it.next();
      c.add(0);
      expect((await first).value, [0]);
      c
        ..add(1)
        ..add(2)
        ..addError(StateError('boom'));
      expect((await it.next()).value, [1, 2]);
      await expectLater(it.next(), throwsStateError);
    });

    test('error with no accepted buffer fails the waiting pull', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamChunked(c.stream).iterator;
      final pending = it.next();
      c.addError(StateError('boom'));
      await expectLater(pending, throwsStateError);
      expect((await it.next()).done, isTrue);
    });

    test('error with no accepted buffer fails the next pull', () async {
      await expectLater(
        toListAsync(fromStreamChunked(Stream<int>.error(StateError('boom')))),
        throwsStateError,
      );
    });

    test('nextOr answers a stored buffer synchronously', () async {
      final c = StreamController<int>(sync: true);
      final it =
          fromStreamChunked(c.stream).iterator as FxFastIterator<List<int>>;
      final first = it.next();
      c.add(0);
      await first;
      c
        ..add(1)
        ..add(2);
      final r = it.nextOr();
      expect(r, isA<IterResult<List<int>>>());
      expect((r as IterResult<List<int>>).value, [1, 2]);
      unawaited(c.close());
    });

    test('cancel before subscribe is a no-op on the source', () async {
      final c = StreamController<int>();
      final it = fromStreamChunked(c.stream).iterator as StreamPullCancel;
      await it.cancel();
      expect(c.hasListener, isFalse);
      unawaited(c.close());
    });

    test('cancel drops the in-flight pull and the subscription', () async {
      final c = StreamController<int>();
      var cancelled = false;
      c.onCancel = () => cancelled = true;
      final it = fromStreamChunked(c.stream).iterator;
      final pending = it.next();
      expect(c.hasListener, isTrue);
      await (it as StreamPullCancel).cancel();
      expect(cancelled, isTrue);
      expect(c.hasListener, isFalse);
      expect((await pending).done, isTrue);
    });

    test('cancel while a burst is scheduled still ends the pull', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamChunked(c.stream).iterator;
      final pending = it.next();
      c
        ..add(1)
        ..add(2);
      await (it as StreamPullCancel).cancel();
      expect((await pending).done, isTrue);
      expect(c.hasListener, isFalse);
      unawaited(c.close());
    });
  });

  group('fromStreamNext', () {
    test('a sync-completing source yields nothing', () async {
      expect(
        await toListAsync(fromStreamNext(syncStream([1, 2, 3]))),
        equals(<int>[]),
      );
    });

    test('drops values that arrive while the consumer is busy', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamNext(c.stream).iterator;
      final first = it.next();
      c
        ..add(0)
        ..add(1)
        ..add(2);
      expect((await first).value, 0);
      c
        ..add(3)
        ..add(4);
      final second = it.next();
      c
        ..add(5)
        ..add(6);
      expect((await second).value, 5);
      unawaited(c.close());
      expect((await it.next()).done, isTrue);
    });

    test('does not subscribe until the first pull', () async {
      var listens = 0;
      final c = StreamController<int>(onListen: () => listens++);
      fromStreamNext(c.stream);
      expect(listens, 0);
      final pending = fromStreamNext(c.stream).iterator.next();
      expect(listens, 1);
      c.add(1);
      expect((await pending).value, 1);
      unawaited(c.close());
    });

    test('completion while waiting ends the pull', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamNext(c.stream).iterator;
      final pending = it.next();
      unawaited(c.close());
      expect((await pending).done, isTrue);
    });

    test('completion between pulls ends on the next pull', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamNext(c.stream).iterator;
      final first = it.next();
      c.add(1);
      expect((await first).value, 1);
      unawaited(c.close());
      expect((await it.next()).done, isTrue);
    });

    test('error while waiting fails the pull', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamNext(c.stream).iterator;
      final pending = it.next();
      c.addError(StateError('boom'));
      await expectLater(pending, throwsStateError);
      expect((await it.next()).done, isTrue);
    });

    test('error between pulls fails the next pull', () async {
      final c = StreamController<int>(sync: true);
      final it = fromStreamNext(c.stream).iterator;
      final first = it.next();
      c.add(1);
      expect((await first).value, 1);
      c.addError(StateError('boom'));
      await expectLater(it.next(), throwsStateError);
      expect((await it.next()).done, isTrue);
    });

    test('a sync-erroring source fails the first pull', () async {
      await expectLater(
        toListAsync(fromStreamNext(Stream<int>.error(StateError('boom')))),
        throwsStateError,
      );
    });

    test('cancel before subscribe is a no-op on the source', () async {
      final c = StreamController<int>();
      final it = fromStreamNext(c.stream).iterator as StreamPullCancel;
      await it.cancel();
      expect(c.hasListener, isFalse);
      unawaited(c.close());
    });

    test('cancel drops the in-flight pull and the subscription', () async {
      final c = StreamController<int>();
      var cancelled = false;
      c.onCancel = () => cancelled = true;
      final it = fromStreamNext(c.stream).iterator;
      final pending = it.next();
      expect(c.hasListener, isTrue);
      await (it as StreamPullCancel).cancel();
      expect(cancelled, isTrue);
      expect(c.hasListener, isFalse);
      expect((await pending).done, isTrue);
    });
  });

  group('FxEvents pull policies', () {
    test('pullLatest crosses into FxAsync under latest-wins', () async {
      expect(
        await fxEvents(syncStream([1, 2, 3])).pullLatest().toList(),
        equals([3]),
      );
    });

    test('pullChunked crosses into FxAsync under batched pull', () async {
      expect(
        await fxEvents(syncStream([1, 2, 3])).pullChunked().toList(),
        equals([
          [1, 2, 3],
        ]),
      );
    });

    test('pullNext crosses into FxAsync under demand-gated drop', () async {
      expect(
        await fxEvents(syncStream([1, 2, 3])).pullNext().toList(),
        equals(<int>[]),
      );
    });

    test('existing pull() stays lossless', () async {
      expect(
        await fxEvents(syncStream([1, 2, 3])).pull().toList(),
        equals([1, 2, 3]),
      );
    });
  });
}
