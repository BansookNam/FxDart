import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;
import 'dart:isolate';

import '../async_iterable.dart';

/// Isolate entry: [boot] is `[SendPort toMain, Function worker]`.
void parallelIsolateEntry(List<dynamic> boot) {
  final toMain = boot[0] as SendPort;
  final worker = boot[1] as Function;
  final inbox = RawReceivePort();
  toMain.send(inbox.sendPort);
  inbox.handler = (msg) {
    if (msg == _shutdown) {
      inbox.close();
      return;
    }
    final input = (msg as List<dynamic>)[0];
    try {
      final result = worker(input);
      try {
        toMain.send([true, result]);
      } catch (_) {
        // Same hang as an unsendable *error* if this send throws inside the
        // handler and nothing answers that job. ArgumentError is sendable.
        toMain.send([
          false,
          ArgumentError(
            'parallel result is not sendable (${result.runtimeType})',
          ),
          StackTrace.current,
        ]);
      }
    } catch (e, st) {
      // Same isolate group: sendable errors travel as themselves so
      // `attempt` / `retryOn` can still match on type. Fall back to the
      // message *text* when the object itself cannot cross — sending `e`
      // again would throw inside this handler and strand the pull, since
      // nothing else ever answers that job.
      try {
        toMain.send([false, e, st]);
      } catch (_) {
        toMain.send([false, '$e', st.toString()]);
      }
    }
  };
}

const _shutdown = 0;

/// [Platform.numberOfProcessors]. See [parallelWorkers].
int get parallelWorkersImpl => io.Platform.numberOfProcessors;

/// VM implementation. See [parallel] for the contract.
FxAsyncIterable<R> parallelImpl<A, R>(
  int workers,
  R Function(A input) worker,
  Iterable<A> iterable,
) => _ParallelIterable<A, R>(workers, worker, iterable, null);

/// VM implementation. See [parallelAsync] for the contract.
FxAsyncIterable<R> parallelAsyncImpl<A, R>(
  int workers,
  R Function(A input) worker,
  FxAsyncIterable<A> iterable,
) => _ParallelIterable<A, R>(workers, worker, null, iterable);

class _ParallelIterable<A, R> implements FxAsyncIterable<R> {
  _ParallelIterable(this.workers, this.worker, this.sync, this.async);
  final int workers;
  final R Function(A input) worker;
  final Iterable<A>? sync;
  final FxAsyncIterable<A>? async;

  @override
  FxAsyncIterator<R> get iterator {
    final source = sync;
    return _ParallelIterator<A, R>(
      workers,
      worker,
      source?.iterator,
      async?.iterator,
      source is List<A> ? source.length : null,
    );
  }
}

class _ParallelIterator<A, R>
    with FxFastNextGate<R>
    implements FxFastIterator<R>, StreamPullCancel {
  _ParallelIterator(
    this._workers,
    this._worker,
    this._sync,
    this._async,
    this._length,
  );

  final int _workers;
  final R Function(A input) _worker;
  final Iterator<A>? _sync;
  final FxAsyncIterator<A>? _async;

  /// Known source length when [sync] is a [List]; null otherwise.
  final int? _length;

  _Pool<A, R>? _pool;
  final Queue<Future<R>> _inflight = Queue<Future<R>>();
  var _sourceDone = false;
  var _ended = false;
  var _cancelled = false;

  static final _finalizer = Finalizer<_Pool<dynamic, dynamic>>((p) => p.kill());

  @override
  FutureOr<IterResult<R>> nextOr() {
    if (_ended) return IterResult<R>.done();
    return _step();
  }

  Future<IterResult<R>> _step() async {
    if (_ended) return IterResult<R>.done();
    if (_pool == null) {
      // Pull one item before paying isolate spawn so an empty source is free.
      // Bare (not `await`) on a sync source — `await` of a non-Future still
      // schedules a microtask, and that gap is where cancel used to win
      // the race against spawn.
      final firstOr = _takeOne();
      final first = firstOr is Future<A?> ? await firstOr : firstOr;
      if (_ended) return IterResult<R>.done();
      if (first == null) {
        _shutdown();
        return IterResult<R>.done();
      }
      await _ensurePool();
      if (_ended) return IterResult<R>.done();
      _enqueue(_pool!.run(first));
    }
    await _fill();
    if (_ended) return IterResult<R>.done();
    if (_inflight.isEmpty) {
      _shutdown();
      return IterResult<R>.done();
    }
    try {
      final value = await _inflight.removeFirst();
      if (_ended) return IterResult<R>.done();
      return IterResult<R>.value(value);
    } catch (e, st) {
      final cancelled = _cancelled;
      _shutdown();
      if (cancelled) return IterResult<R>.done();
      Error.throwWithStackTrace(e, st);
    }
  }

  FutureOr<A?> _takeOne() {
    if (_sourceDone) return null;
    final sync = _sync;
    if (sync != null) {
      if (!sync.moveNext()) {
        _sourceDone = true;
        return null;
      }
      return sync.current;
    }
    return _takeOneAsync();
  }

  Future<A?> _takeOneAsync() async {
    final r = await _async!.next();
    if (_ended) return null;
    if (r.done) {
      _sourceDone = true;
      return null;
    }
    return r.value;
  }

  Future<void> _ensurePool() async {
    if (_pool != null || _ended) return;
    var n = _workers;
    final known = _length;
    if (known != null && known < n) n = known;
    final pool = await _Pool.spawn<A, R>(n, _worker);
    _pool = pool;
    _finalizer.attach(this, pool, detach: this);
    // Cancel may have landed while we were spawning. One line so coverage
    // does not depend on winning that race: `_shutdown` is a no-op when
    // we are not ended, and tears this pool down when we are.
    if (_ended) _shutdown();
  }

  Future<void> _fill() async {
    final pool = _pool;
    if (pool == null || _ended) return;
    while (_inflight.length < _workers && !_sourceDone && !_ended) {
      final nextOr = _takeOne();
      final next = nextOr is Future<A?> ? await nextOr : nextOr;
      if (_ended) return;
      if (next == null) break;
      _enqueue(pool.run(next));
    }
  }

  void _enqueue(Future<R> f) {
    // Kill completes still-pending worker futures; those sitting in
    // [_inflight] have no listener until a later [nextOr]. [ignore] keeps
    // that completeError from becoming an unhandled async error.
    f.ignore();
    _inflight.add(f);
  }

  void _shutdown() {
    if (_ended && _pool == null) return;
    _ended = true;
    final pool = _pool;
    _pool = null;
    if (pool != null) {
      _finalizer.detach(this);
      pool.kill();
    }
  }

  @override
  Future<void> cancel() {
    _cancelled = true;
    _shutdown();
    fxCancel(_async);
    return Future<void>.value();
  }
}

class _Pool<A, R> {
  _Pool(this._workers);

  final List<_Iso<A, R>> _workers;
  final Queue<_Iso<A, R>> _idle = Queue<_Iso<A, R>>();
  var _dead = false;

  static Future<_Pool<A, R>> spawn<A, R>(
    int n,
    R Function(A input) worker,
  ) async {
    // Workers are interchangeable, so each spawn appends as it lands and the
    // list holds exactly the isolates that started. That is what lets the
    // failure path reuse [kill] instead of a nullable slot per worker and a
    // teardown branch of its own: a sendability failure fails every spawn of
    // the same worker, but a resource failure need not, and the leftovers
    // would keep a ReceivePort open.
    final spawned = <_Iso<A, R>>[];
    Object? error;
    StackTrace? errorSt;
    await Future.wait([
      for (var i = 0; i < n; i++)
        () async {
          try {
            spawned.add(await _Iso.spawn<A, R>(worker, i));
          } catch (e, st) {
            error ??= e;
            errorSt ??= st;
          }
        }(),
    ]);
    final pool = _Pool<A, R>(spawned);
    pool._idle.addAll(spawned);
    final spawnError = error;
    if (spawnError != null) {
      pool.kill();
      Error.throwWithStackTrace(spawnError, errorSt!);
    }
    return pool;
  }

  /// Runs [input] on a free worker.
  ///
  /// A worker is always free here: [_ParallelIterator._fill] keeps at most
  /// [_workers] items in flight and the pool holds exactly that many
  /// isolates. This used to carry a wait queue and a dead-pool guard for the
  /// over-subscribed case; neither branch was reachable through any chain,
  /// and unreachable defensive code is how a coverage number stops meaning
  /// anything. The invariant is asserted instead, so a future caller that
  /// breaks it fails loudly rather than queueing into silence.
  Future<R> run(A input) {
    assert(_idle.isNotEmpty, 'parallel pool over-subscribed');
    final iso = _idle.removeFirst();
    return iso.run(input).whenComplete(() {
      if (!_dead) _idle.add(iso);
    });
  }

  void kill() {
    if (_dead) return;
    _dead = true;
    // Work already handed to an isolate settles through [_Iso.kill], which
    // errors every completer it is still holding.
    for (final w in _workers) {
      w.kill();
    }
  }
}

class _Iso<A, R> {
  _Iso(this._isolate, this._toWorker, this._incoming);

  final Isolate _isolate;
  final SendPort _toWorker;
  final RawReceivePort _incoming;
  Completer<R>? _completer;

  static Future<_Iso<A, R>> spawn<A, R>(
    R Function(A input) worker,
    int index,
  ) async {
    final incoming = RawReceivePort();
    final ready = Completer<SendPort>();
    late final _Iso<A, R> iso;
    incoming.handler = (msg) {
      if (!ready.isCompleted) {
        ready.complete(msg as SendPort);
        return;
      }
      iso._onMessage(msg);
    };
    late Isolate isolate;
    try {
      isolate = await Isolate.spawn(parallelIsolateEntry, [
        incoming.sendPort,
        worker,
      ], debugName: 'fxdart-parallel-$index');
    } catch (e, st) {
      incoming.close();
      Error.throwWithStackTrace(
        ArgumentError(
          'parallel failed to spawn a worker isolate. The worker must be a '
          'top-level or static function (or a closure whose captures are all '
          'sendable). ($e)',
        ),
        st,
      );
    }
    final toWorker = await ready.future;
    iso = _Iso<A, R>(isolate, toWorker, incoming);
    return iso;
  }

  void _onMessage(dynamic msg) {
    final c = _completer;
    _completer = null;
    if (c == null || c.isCompleted) return;
    final list = msg as List<dynamic>;
    final ok = list[0] as bool;
    if (ok) {
      c.complete(list[1] as R);
      return;
    }
    final err = list[1];
    final stack = list[2];
    final st = stack is StackTrace ? stack : StackTrace.fromString('$stack');
    if (err is Object && err is! String) {
      c.completeError(err, st);
    } else {
      c.completeError(StateError('$err'), st);
    }
  }

  Future<R> run(A input) {
    assert(_completer == null, 'parallel worker over-subscribed');
    final c = Completer<R>();
    _completer = c;
    try {
      _toWorker.send([input]);
    } catch (e, st) {
      _completer = null;
      c.completeError(
        ArgumentError(
          'parallel cannot send this input to an isolate (not sendable). ($e)',
        ),
        st,
      );
    }
    return c.future;
  }

  void kill() {
    final c = _completer;
    _completer = null;
    if (c != null && !c.isCompleted) {
      c.completeError(StateError('parallel isolate shut down'));
    }
    _toWorker.send(_shutdown);
    _incoming.close();
    _isolate.kill(priority: Isolate.immediate);
  }
}
