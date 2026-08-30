import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import '../async_iterable.dart';

/// Isolate entry: [boot] is `[SendPort toMain, Function worker]`.
void parallelIsolateEntry(List<dynamic> boot) {
  final toMain = boot[0] as SendPort;
  final worker = boot[1] as Function;
  final inbox = ReceivePort();
  toMain.send(inbox.sendPort);
  inbox.listen((msg) {
    if (msg == _shutdown) {
      inbox.close();
      return;
    }
    final list = msg as List<dynamic>;
    final id = list[0] as int;
    final input = list[1];
    try {
      toMain.send([id, true, worker(input)]);
    } catch (e, st) {
      toMain.send([id, false, '$e', st.toString()]);
    }
  });
}

const _shutdown = 0;

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
  FxAsyncIterator<R> get iterator =>
      _ParallelIterator<A, R>(workers, worker, sync?.iterator, async?.iterator);
}

class _ParallelIterator<A, R> implements FxAsyncIterator<R> {
  _ParallelIterator(this._workers, this._worker, this._sync, this._async);

  final int _workers;
  final R Function(A input) _worker;
  final Iterator<A>? _sync;
  final FxAsyncIterator<A>? _async;

  _Pool<A, R>? _pool;
  final Queue<Future<R>> _inflight = Queue<Future<R>>();
  var _sourceDone = false;
  var _shut = false;

  static final _finalizer = Finalizer<_Pool<dynamic, dynamic>>((p) => p.kill());

  @override
  Future<IterResult<R>> next([Concurrent? concurrent]) async {
    if (_shut) return IterResult<R>.done();
    await _ensurePool();
    await _fill();
    if (_inflight.isEmpty) {
      await _shutdown();
      return IterResult<R>.done();
    }
    try {
      final value = await _inflight.removeFirst();
      return IterResult<R>.value(value);
    } catch (e, st) {
      await _shutdown();
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> _ensurePool() async {
    if (_pool != null) return;
    final pool = await _Pool.spawn<A, R>(_workers, _worker);
    _pool = pool;
    _finalizer.attach(this, pool, detach: this);
  }

  Future<void> _fill() async {
    final pool = _pool!;
    while (_inflight.length < _workers && !_sourceDone) {
      if (_sync != null) {
        if (!_sync.moveNext()) {
          _sourceDone = true;
          break;
        }
        _inflight.add(pool.run(_sync.current));
      } else {
        final r = await _async!.next();
        if (r.done) {
          _sourceDone = true;
          break;
        }
        _inflight.add(pool.run(r.value));
      }
    }
  }

  Future<void> _shutdown() async {
    if (_shut) return;
    _shut = true;
    final pool = _pool;
    _pool = null;
    if (pool != null) {
      _finalizer.detach(this);
      await pool.kill();
    }
  }
}

class _Pool<A, R> {
  _Pool(this._workers);

  final List<_Iso<A, R>> _workers;
  final Queue<_Iso<A, R>> _idle = Queue<_Iso<A, R>>();
  final Queue<(A, Completer<R>)> _waiting = Queue<(A, Completer<R>)>();
  var _dead = false;

  static Future<_Pool<A, R>> spawn<A, R>(
    int n,
    R Function(A input) worker,
  ) async {
    final workers = <_Iso<A, R>>[];
    for (var i = 0; i < n; i++) {
      workers.add(await _Iso.spawn<A, R>(worker));
    }
    final pool = _Pool<A, R>(workers);
    pool._idle.addAll(workers);
    return pool;
  }

  Future<R> run(A input) {
    if (_dead) {
      return Future.error(StateError('parallel pool is shut down'));
    }
    final c = Completer<R>();
    _waiting.add((input, c));
    _pump();
    return c.future;
  }

  void _pump() {
    while (_idle.isNotEmpty && _waiting.isNotEmpty && !_dead) {
      final iso = _idle.removeFirst();
      final (input, c) = _waiting.removeFirst();
      iso
          .run(input)
          .then(
            (v) {
              if (!c.isCompleted) c.complete(v);
            },
            onError: (Object e, StackTrace st) {
              if (!c.isCompleted) c.completeError(e, st);
            },
          )
          .whenComplete(() {
            if (!_dead) {
              _idle.add(iso);
              _pump();
            }
          });
    }
  }

  Future<void> kill() async {
    if (_dead) return;
    _dead = true;
    for (final w in _workers) {
      w.kill();
    }
  }
}

class _Iso<A, R> {
  _Iso(this._isolate, this._toWorker, this._incoming);

  final Isolate _isolate;
  final SendPort _toWorker;
  final ReceivePort _incoming;
  int _nextId = 0;
  final Map<int, Completer<R>> _pending = {};

  static Future<_Iso<A, R>> spawn<A, R>(R Function(A input) worker) async {
    final incoming = ReceivePort();
    final ready = Completer<SendPort>();
    late final _Iso<A, R> iso;
    incoming.listen((msg) {
      if (!ready.isCompleted && msg is SendPort) {
        ready.complete(msg);
        return;
      }
      iso._onMessage(msg);
    });
    late Isolate isolate;
    try {
      isolate = await Isolate.spawn(parallelIsolateEntry, [
        incoming.sendPort,
        worker,
      ]);
    } catch (e, st) {
      incoming.close();
      Error.throwWithStackTrace(e, st);
    }
    final toWorker = await ready.future;
    iso = _Iso<A, R>(isolate, toWorker, incoming);
    return iso;
  }

  void _onMessage(dynamic msg) {
    if (msg is SendPort) return;
    final list = msg as List<dynamic>;
    final id = list[0] as int;
    final ok = list[1] as bool;
    final c = _pending.remove(id);
    if (c == null || c.isCompleted) return;
    if (ok) {
      c.complete(list[2] as R);
    } else {
      c.completeError(
        StateError(list[2] as String),
        StackTrace.fromString(list[3] as String),
      );
    }
  }

  Future<R> run(A input) {
    final id = _nextId++;
    final c = Completer<R>();
    _pending[id] = c;
    _toWorker.send([id, input]);
    return c.future;
  }

  void kill() {
    for (final c in _pending.values) {
      if (!c.isCompleted) {
        c.completeError(StateError('parallel isolate shut down'));
      }
    }
    _pending.clear();
    _toWorker.send(_shutdown);
    _incoming.close();
    _isolate.kill(priority: Isolate.immediate);
  }
}
