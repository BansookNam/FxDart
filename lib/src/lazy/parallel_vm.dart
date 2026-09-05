import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;
import 'dart:isolate';

import '../async_iterable.dart';

/// Isolate entry: [boot] is `[SendPort toMain, Function worker, bool chunked]`.
///
/// [chunked] is fixed for the isolate's life, so a batch needs no per-message
/// tag and the unbatched path keeps the message shape it always had.
///
/// A sync [worker] still answers on this turn — no `await` of a non-Future,
/// which is the hop the 5µs path cannot pay. A [Future] is subscribed with
/// `then`; [_shutdown] arriving while that Future is pending reaps any
/// nested [parallel] pool this isolate spawned, then the parent isolate
/// kills this one after [_reapAfter].
void parallelIsolateEntry(List<dynamic> boot) {
  final toMain = boot[0] as SendPort;
  final worker = boot[1] as Function;
  final chunked = boot[2] as bool;
  final inbox = RawReceivePort();
  var closed = false;
  toMain.send(inbox.sendPort);
  inbox.handler = (msg) {
    if (msg == _shutdown) {
      closed = true;
      inbox.close();
      _killNested();
      return;
    }
    final input = (msg as List<dynamic>)[0];
    if (chunked) {
      _runBatch(toMain, worker, input as List<dynamic>, () => closed);
      return;
    }
    _runOne(toMain, worker, input, () => closed);
  };
}

/// Isolates this isolate spawned as a [parallel] pool. Isolate-local: a
/// worker's list is its nested pool; the caller's list is the outer pool.
final _nested = <Isolate>[];

void _killNested() {
  final spawned = List<Isolate>.of(_nested);
  _nested.clear();
  for (final iso in spawned) {
    iso.kill(priority: Isolate.immediate);
  }
}

void _runOne(
  SendPort toMain,
  Function worker,
  dynamic input,
  bool Function() closed,
) {
  try {
    final result = worker(input);
    if (result is Future) {
      result.then(
        (v) {
          if (!closed()) _sendOk(toMain, v);
        },
        onError: (Object e, StackTrace st) {
          if (!closed()) _sendErr(toMain, e, st);
        },
      );
      return;
    }
    _sendOk(toMain, result);
  } catch (e, st) {
    _sendErr(toMain, e, st);
  }
}

void _sendOk(SendPort toMain, Object? result) {
  try {
    toMain.send([true, result]);
  } catch (_) {
    // Same hang as an unsendable *error* if this send throws inside the
    // handler and nothing answers that job. ArgumentError is sendable.
    toMain.send([
      false,
      ArgumentError('parallel result is not sendable (${result.runtimeType})'),
      StackTrace.current,
    ]);
  }
}

void _sendErr(SendPort toMain, Object e, StackTrace st) {
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

/// Applies [worker] across [batch] and answers with one message.
///
/// The point of a batch is that the port round trip — ~5µs, which dwarfs any
/// ordinary callback — is paid once for the whole run instead of per element.
/// What it must not change is what the caller observes, so a throwing element
/// still sends back the results of the elements *before* it: the iterator
/// then emits those and raises at exactly the element that failed, which is
/// where the unbatched operator raises.
///
/// Sync elements stay on this turn (the loop does not `await`). A [Future]
/// parks the rest of the batch on `then`, same as [_runOne].
void _runBatch(
  SendPort toMain,
  Function worker,
  List<dynamic> batch,
  bool Function() closed,
) {
  final out = <dynamic>[];
  var i = 0;
  void step() {
    if (closed()) return;
    while (i < batch.length) {
      try {
        final result = worker(batch[i]);
        i++;
        if (result is Future) {
          result.then(
            (v) {
              out.add(v);
              step();
            },
            onError: (Object e, StackTrace st) {
              if (!closed()) _sendBatchError(toMain, e, st, out);
            },
          );
          return;
        }
        out.add(result);
      } catch (e, st) {
        _sendBatchError(toMain, e, st, out);
        return;
      }
    }
    try {
      toMain.send([true, out]);
    } catch (_) {
      // A result that cannot cross fails the whole batch, where the unbatched
      // path fails only that pull — the one place batching is observably
      // coarser, and [parallel]'s dartdoc says so. Finding the offending index
      // would mean sending each result separately, which is the cost the batch
      // exists to avoid.
      _sendBatchError(
        toMain,
        ArgumentError('parallel result is not sendable (in a chunked batch)'),
        StackTrace.current,
        const <dynamic>[],
      );
    }
  }

  step();
}

void _sendBatchError(
  SendPort toMain,
  Object e,
  StackTrace st,
  List<dynamic> partial,
) {
  try {
    toMain.send([false, e, st, partial]);
  } catch (_) {
    // Either the error or one of the partial results cannot cross. Both are
    // dropped rather than strand the pull — nothing else answers this job,
    // and the caller is about to see the error either way.
    toMain.send([false, '$e', st.toString(), const <dynamic>[]]);
  }
}

const _shutdown = 0;

/// After sending [_shutdown], wait this long before [Isolate.kill] so a
/// worker that is waiting on nested [parallel] can reap its child pool.
const _reapAfter = Duration(milliseconds: 50);

/// [Platform.numberOfProcessors]. See [parallelWorkers].
int get parallelWorkersImpl => io.Platform.numberOfProcessors;

/// VM implementation. See [parallel] for the contract.
FxAsyncIterable<R> parallelImpl<A, R>(
  int workers,
  FutureOr<R> Function(A input) worker,
  Iterable<A> iterable,
  int chunk,
) => _ParallelIterable<A, R>(workers, chunk, worker, iterable, null);

/// VM implementation. See [parallelAsync] for the contract.
FxAsyncIterable<R> parallelAsyncImpl<A, R>(
  int workers,
  FutureOr<R> Function(A input) worker,
  FxAsyncIterable<A> iterable,
  int chunk,
) => _ParallelIterable<A, R>(workers, chunk, worker, null, iterable);

class _ParallelIterable<A, R> implements FxAsyncIterable<R> {
  _ParallelIterable(
    this.workers,
    this.chunk,
    this.worker,
    this.sync,
    this.async,
  );
  final int workers;
  final int chunk;
  final FutureOr<R> Function(A input) worker;
  final Iterable<A>? sync;
  final FxAsyncIterable<A>? async;

  @override
  FxAsyncIterator<R> get iterator {
    final source = sync;
    return _ParallelIterator<A, R>(
      workers,
      chunk,
      worker,
      source?.iterator,
      async?.iterator,
      source is List<A> ? source.length : null,
    );
  }
}

/// "The source had nothing left", as a value [A] can never be.
///
/// `null` used to mean it, which silently dropped a genuine `null` element
/// on a nullable [A] — the source was read as exhausted for that pull.
class _EndOfSource {
  const _EndOfSource();
}

const _end = _EndOfSource();

/// A batch whose element at `partial.length` threw [cause].
///
/// Carries the results of the elements before it so the iterator can emit
/// them and then raise, exactly where the unbatched operator raises.
class _BatchFailure implements Exception {
  _BatchFailure(this.partial, this.cause, this.stack);
  final List<dynamic> partial;
  final Object cause;
  final StackTrace stack;
}

class _ParallelIterator<A, R>
    with FxFastNextGate<R>
    implements FxFastIterator<R>, StreamPullCancel {
  _ParallelIterator(
    this._workers,
    this._chunk,
    this._worker,
    this._sync,
    this._async,
    this._length,
  );

  final int _workers;

  /// Elements per message. 1 is the streaming shape; see [parallel].
  final int _chunk;
  final FutureOr<R> Function(A input) _worker;
  final Iterator<A>? _sync;
  final FxAsyncIterator<A>? _async;

  /// Known source length when [sync] is a [List]; null otherwise.
  final int? _length;

  /// Exactly one of these is ever live — [_chunk] decides which at
  /// construction. They differ in what a message carries, so they differ in
  /// the pool's element type, and keeping them apart is what lets the
  /// unbatched path stay allocation-for-allocation what it was.
  _Pool<A, R>? _pool;
  _Pool<List<A>, List<dynamic>>? _batchPool;

  /// The batch being served, and how far into it we are. A batch arrives
  /// whole, so its elements are handed out straight from the list — a
  /// [Completer] per element would put two allocations and a microtask on
  /// every element of a path whose entire purpose is to stop paying
  /// per-element costs.
  List<dynamic>? _current;
  int _cursor = 0;

  /// Raised once [_current] is drained: the element after the last one in
  /// it is the one that threw.
  Object? _failure;
  StackTrace? _failureStack;

  /// Batch futures in flight, oldest first (chunked mode only).
  final Queue<Future<List<dynamic>>> _batches = Queue<Future<List<dynamic>>>();
  final Queue<Future<R>> _inflight = Queue<Future<R>>();
  var _sourceDone = false;
  var _ended = false;
  var _cancelled = false;

  static final _finalizer = Finalizer<_Pool<dynamic, dynamic>>((p) => p.kill());

  @override
  FutureOr<IterResult<R>> nextOr() {
    if (_ended) return IterResult<R>.done();
    final current = _current;
    if (current != null && _cursor < current.length) {
      return IterResult<R>.value(current[_cursor++] as R);
    }
    return _step();
  }

  bool get _started => _pool != null || _batchPool != null;

  Future<IterResult<R>> _step() async {
    if (_ended) return IterResult<R>.done();
    if (!_started) {
      // Pull one item (or one batch) before paying isolate spawn so an empty
      // source is free. Bare (not `await`) on a sync source — `await` of a
      // non-Future still schedules a microtask, and that gap is where cancel
      // used to win the race against spawn.
      final firstOr = _take();
      final first = firstOr is Future<Object?> ? await firstOr : firstOr;
      if (_ended) return IterResult<R>.done();
      if (identical(first, _end)) {
        _shutdown();
        return IterResult<R>.done();
      }
      await _ensurePool();
      if (_ended) return IterResult<R>.done();
      _dispatch(first);
    }
    // The batch in hand is spent. If its worker threw after the elements
    // it did deliver, this is where that lands — one element later than
    // the last value, which is where the unbatched operator raises.
    final failure = _failure;
    if (failure != null) {
      // No `_cancelled` guard, unlike the paths that resume from an await:
      // nothing yields between this and [nextOr]'s `_ended` check, so a
      // cancel cannot land in between.
      final st = _failureStack!;
      _shutdown();
      Error.throwWithStackTrace(failure, st);
    }
    _current = null;
    await _fill();
    if (_ended) return IterResult<R>.done();
    if (_batchPool != null) return _nextBatch();
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

  Future<IterResult<R>> _nextBatch() async {
    if (_batches.isEmpty) {
      _shutdown();
      return IterResult<R>.done();
    }
    try {
      final values = await _batches.removeFirst();
      if (_ended) return IterResult<R>.done();
      _current = values;
      _cursor = 1;
      return IterResult<R>.value(values[0] as R);
    } on _BatchFailure catch (bf) {
      if (_ended) return IterResult<R>.done();
      if (bf.partial.isEmpty) {
        // The batch's very first element threw, so there is no prefix to
        // deliver before it. No `_cancelled` guard for the reason [_step]
        // gives: the `_ended` check above it is not separated by an await.
        _shutdown();
        Error.throwWithStackTrace(bf.cause, bf.stack);
      }
      _current = bf.partial;
      _cursor = 1;
      _failure = bf.cause;
      _failureStack = bf.stack;
      return IterResult<R>.value(bf.partial[0] as R);
    } catch (e, st) {
      final cancelled = _cancelled;
      _shutdown();
      if (cancelled) return IterResult<R>.done();
      Error.throwWithStackTrace(e, st);
    }
  }

  /// The next element, or the next batch of up to [_chunk] of them, or
  /// [_end]. Synchronous whenever the source is.
  FutureOr<Object?> _take() => _chunk == 1 ? _takeOne() : _takeChunk();

  FutureOr<Object?> _takeOne() {
    if (_sourceDone) return _end;
    final sync = _sync;
    if (sync != null) {
      if (!sync.moveNext()) {
        _sourceDone = true;
        return _end;
      }
      return sync.current;
    }
    return _takeOneAsync();
  }

  Future<Object?> _takeOneAsync() async {
    final r = await _async!.next();
    if (_ended) return _end;
    if (r.done) {
      _sourceDone = true;
      return _end;
    }
    return r.value;
  }

  FutureOr<Object?> _takeChunk() {
    if (_sourceDone) return _end;
    final sync = _sync;
    if (sync == null) return _takeChunkAsync();
    final batch = <A>[];
    while (batch.length < _chunk && sync.moveNext()) {
      batch.add(sync.current);
    }
    // Short of a full batch means `moveNext` said no, not that the caller
    // asked for less — the source is out.
    if (batch.length < _chunk) _sourceDone = true;
    return batch.isEmpty ? _end : batch;
  }

  Future<Object?> _takeChunkAsync() async {
    final batch = <A>[];
    while (batch.length < _chunk) {
      final r = await _async!.next();
      if (_ended) return _end;
      if (r.done) {
        _sourceDone = true;
        break;
      }
      batch.add(r.value);
    }
    return batch.isEmpty ? _end : batch;
  }

  void _dispatch(Object? pulled) {
    final pool = _pool;
    if (pool != null) {
      _enqueue(pool.run(pulled as A));
      return;
    }
    _dispatchBatch(pulled! as List<A>);
  }

  /// Queues one message. The elements are served out of the list it comes
  /// back as ([_current]), so a batch costs one future no matter how many
  /// elements ride it.
  void _dispatchBatch(List<A> batch) {
    final f = _batchPool!.run(batch);
    // Kill errors every completer it still holds, and a queued batch has no
    // listener until a later pull reaches it (see [_enqueue]).
    f.ignore();
    _batches.add(f);
  }

  Future<void> _ensurePool() async {
    if (_started || _ended) return;
    var n = _workers;
    final known = _length;
    if (known != null) {
      // One message per batch, so it is the batch count — not the element
      // count — that bounds how many isolates can ever be busy at once.
      final jobs = _chunk == 1 ? known : (known + _chunk - 1) ~/ _chunk;
      if (jobs < n) n = jobs;
    }
    final _Pool<dynamic, dynamic> pool;
    if (_chunk == 1) {
      pool = _pool = await _Pool.spawn<A, R>(n, _worker, chunked: false);
    } else {
      pool = _batchPool = await _Pool.spawn<List<A>, List<dynamic>>(
        n,
        _worker,
        chunked: true,
      );
    }
    _finalizer.attach(this, pool, detach: this);
    // Cancel may have landed while we were spawning. One line so coverage
    // does not depend on winning that race: `_shutdown` is a no-op when
    // we are not ended, and tears this pool down when we are.
    if (_ended) _shutdown();
  }

  Future<void> _fill() async {
    if (!_started || _ended) return;
    // Messages in flight, whether each carries one element or [_chunk] of
    // them: one message occupies one isolate either way.
    while (_queued < _workers && !_sourceDone && !_ended) {
      final nextOr = _take();
      final next = nextOr is Future<Object?> ? await nextOr : nextOr;
      if (_ended) return;
      if (identical(next, _end)) break;
      _dispatch(next);
    }
  }

  int get _queued => _batchPool != null ? _batches.length : _inflight.length;

  void _enqueue(Future<R> f) {
    // Kill completes still-pending worker futures; those sitting in
    // [_inflight] have no listener until a later [nextOr]. [ignore] keeps
    // that completeError from becoming an unhandled async error.
    f.ignore();
    _inflight.add(f);
  }

  void _shutdown() {
    if (_ended && !_started) return;
    _ended = true;
    _current = null;
    final _Pool<dynamic, dynamic>? pool = _pool ?? _batchPool;
    _pool = null;
    _batchPool = null;
    if (pool != null) {
      _finalizer.detach(this);
      pool.kill();
    }
  }

  @override
  Future<void> cancel() {
    _cancelled = true;
    _shutdown();
    return fxCancelAll(_async);
  }
}

class _Pool<A, R> {
  _Pool(this._workers);

  final List<_Iso<A, R>> _workers;
  final Queue<_Iso<A, R>> _idle = Queue<_Iso<A, R>>();
  var _dead = false;

  /// [A] and [R] are the *message* types — one element and one result, or a
  /// batch of each — so [worker] arrives untyped: it is always the caller's
  /// `R Function(A)`, and [chunked] is what tells the isolate which shape to
  /// expect.
  static Future<_Pool<A, R>> spawn<A, R>(
    int n,
    Function worker, {
    required bool chunked,
  }) async {
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
            spawned.add(await _Iso.spawn<A, R>(worker, i, chunked: chunked));
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
    Function worker,
    int index, {
    required bool chunked,
  }) async {
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
        chunked,
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
    _nested.add(isolate);
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
    final cause = err is Object && err is! String ? err : StateError('$err');
    // A fourth slot means a batch: it holds the results of the elements that
    // ran before the one that threw, and they are still owed to the caller.
    if (list.length > 3) {
      c.completeError(_BatchFailure(list[3] as List<dynamic>, cause, st), st);
      return;
    }
    c.completeError(cause, st);
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

  var _dead = false;

  void kill() {
    if (_dead) return;
    _dead = true;
    final c = _completer;
    final inFlight = c != null;
    _completer = null;
    if (c != null && !c.isCompleted) {
      c.completeError(StateError('parallel isolate shut down'));
    }
    _nested.remove(_isolate);
    try {
      _toWorker.send(_shutdown);
    } catch (_) {}
    void reap() {
      _incoming.close();
      _isolate.kill(priority: Isolate.immediate);
    }

    // A job in flight may be an async worker waiting on nested parallel.
    // Give that isolate a turn to [_killNested] before we SIGKILL it.
    // Idle workers have no children; reap now so a finished chain does
    // not sit on [_reapAfter] per isolate.
    if (inFlight) {
      Future<void>.delayed(_reapAfter, reap);
    } else {
      reap();
    }
  }
}
