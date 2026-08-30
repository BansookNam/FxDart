import 'dart:async';
import 'dart:typed_data';

import '../async_iterable.dart';
import 'filter.dart';
import 'list_range.dart';
import 'map.dart';
import 'zip.dart';

/// Returns an iterable of the first [length] values from [iterable].
///
/// Port of FxTS `take`.
Iterable<A> take<A>(int length, Iterable<A> iterable) =>
    _TakeIterable(length, iterable);

class _TakeIterable<A> extends Iterable<A> implements FxListRangeSource<A> {
  _TakeIterable(this._length, this._source);
  final int _length;
  final Iterable<A> _source;
  @override
  FxListRange<A>? get listRange {
    final r = fxListRangeOf(_source);
    if (r == null) return null;
    final end = _length < 0 ? r.start : r.start + _length;
    return FxListRange(r.list, r.start, end > r.end ? r.end : end);
  }

  @override
  Iterator<A> get iterator {
    final r = listRange;
    if (r != null) return FxListRangeIterator(r.list, r.start, r.end);
    return _TakeIterator(_length, _source.iterator);
  }
}

class _TakeIterator<A> implements Iterator<A> {
  _TakeIterator(this._remaining, this._it);
  int _remaining;
  final Iterator<A> _it;
  @override
  late A current;
  @override
  bool moveNext() {
    if (_remaining < 1 || !_it.moveNext()) return false;
    _remaining--;
    current = _it.current;
    return true;
  }
}

/// Async counterpart of [take]. Pass-through: overlapping pulls stay
/// parallel, as in FxTS.
///
/// A fused stage, so a chain that truncates stays on the subscription drive
/// instead of dropping to the pull protocol. The counter lives on the
/// iterator, so only one `take` fuses into a run and a second starts a new
/// one; a [Concurrent] marker falls back to [_takeAsyncLegacy], which is what
/// keeps overlapping pulls parallel.
@pragma('vm:prefer-inline')
FxAsyncIterable<A> takeAsync<A>(int length, FxAsyncIterable<A> iterable) {
  // A non-positive count yields nothing and must not pull at all — off the
  // fused path entirely, since [FxTakeStage] only ever sees counts >= 1.
  // [_takeAsyncLegacy] answers done before its first pull, so it is the whole
  // implementation of that case as well as the concurrent fallback.
  if (length < 1) return _takeAsyncLegacy(length, iterable);
  final stage = FxTakeStage(length);
  if (iterable is FxFusedAsyncIterable<A> && iterable.takeIndex < 0) {
    final source = iterable.source;
    final stages = iterable.stages;
    final legacy = iterable.legacy;
    return FxFusedAsyncIterable<A>(source, [
      ...stages,
      stage,
    ], () => _takeAsyncLegacy(length, legacy()));
  }
  return FxFusedAsyncIterable<A>(iterable, [
    stage,
  ], () => _takeAsyncLegacy(length, iterable));
}

FxAsyncIterable<A> _takeAsyncLegacy<A>(
  int length,
  FxAsyncIterable<A> iterable,
) {
  return DelegateAsyncIterable(() {
    final iterator = iterable.iterator;
    var remaining = length;
    var cancelled = false;
    void cancelOnce() {
      if (cancelled) return;
      cancelled = true;
      fxCancel(iterator);
    }

    return DelegateAsyncIterator(
      (concurrent) {
        if (remaining-- < 1) {
          cancelOnce();
          return Future.value(IterResult<A>.done());
        }
        return iterator.next(concurrent);
      },
      cancel: () {
        cancelOnce();
        return Future<void>.value();
      },
    );
  });
}

/// Returns an iterable of the last [length] values.
///
/// Port of FxTS `takeRight`. A [List] source is indexed directly; any other
/// source is consumed into a ring buffer of [length] elements on the first
/// pull.
Iterable<A> takeRight<A>(int length, Iterable<A> iterable) {
  if (length < 0) throw RangeError("'length' must be greater than 0");
  return _TakeRightIterable(length, iterable);
}

class _TakeRightIterable<A> extends Iterable<A>
    implements FxListRangeSource<A> {
  _TakeRightIterable(this._length, this._source);
  final int _length;
  final Iterable<A> _source;
  @override
  FxListRange<A>? get listRange {
    final r = fxListRangeOf(_source);
    if (r == null) return null;
    final start = r.end - _length;
    return FxListRange(r.list, start < r.start ? r.start : start, r.end);
  }

  @override
  Iterator<A> get iterator {
    final r = listRange;
    if (r != null) return FxListRangeIterator(r.list, r.start, r.end);
    return _TakeRightIterator(_length, _source);
  }
}

class _TakeRightIterator<A> implements Iterator<A> {
  _TakeRightIterator(this._length, this._source);
  final int _length;
  final Iterable<A> _source;
  List<A>? _ring;
  int _pos = 0;
  int _left = -1; // -1: source not consumed yet
  @override
  late A current;

  void _init() {
    _left = 0;
    if (_length == 0) return;
    // One pass over the source, keeping only the last [_length] elements —
    // O(length) memory instead of materializing everything.
    List<A>? ring;
    var write = 0;
    var count = 0;
    for (final a in _source) {
      ring ??= List<A>.filled(_length, a);
      ring[write] = a;
      write++;
      if (write == _length) write = 0;
      if (count < _length) count++;
    }
    if (ring == null) return;
    _ring = ring;
    _pos = count < _length ? 0 : write;
    _left = count;
  }

  @override
  bool moveNext() {
    if (_left < 0) _init();
    if (_left == 0) return false;
    current = _ring![_pos];
    _pos++;
    if (_pos == _length) _pos = 0;
    _left--;
    return true;
  }
}

/// Async counterpart of [takeRight].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> takeRightAsync<A>(int length, FxAsyncIterable<A> iterable) {
  if (length < 0) throw RangeError("'length' must be greater than 0");
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    Iterator<A>? tail;
    return SerialAsyncIterator((concurrent) async {
      if (tail == null) {
        final arr = <A>[];
        while (true) {
          final r = await iterator.next(concurrent);
          if (r.done) break;
          arr.add(r.value);
        }
        tail = takeRight(length, arr).iterator;
      }
      if (tail!.moveNext()) return IterResult.value(tail!.current);
      return IterResult<A>.done();
    });
  });
}

/// Returns an iterable that yields values as long as [f] returns true.
///
/// Port of FxTS `takeWhile`.
Iterable<A> takeWhile<A>(bool Function(A a) f, Iterable<A> iterable) =>
    _TakeWhileIterable(f, iterable);

class _TakeWhileIterable<A> extends Iterable<A> {
  _TakeWhileIterable(this._f, this._source);
  final bool Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _TakeWhileIterator(_f, _source.iterator);
}

class _TakeWhileIterator<A> implements Iterator<A> {
  _TakeWhileIterator(this._f, this._it);
  final bool Function(A) _f;
  final Iterator<A> _it;
  var _done = false;
  @override
  late A current;
  @override
  bool moveNext() {
    if (_done || !_it.moveNext()) return false;
    final v = _it.current;
    if (!_f(v)) {
      _done = true;
      return false;
    }
    current = v;
    return true;
  }
}

/// Async counterpart of [takeWhile].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> takeWhileAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
  // Fused-stage form; a Concurrent marker falls back to
  // [_takeWhileAsyncLegacy]'s dispatch layering.
  final stage = FxTakeWhileStage((v) => f(v as A));
  if (iterable is FxFusedAsyncIterable<A>) {
    final source = iterable.source;
    final stages = iterable.stages;
    final legacy = iterable.legacy;
    return FxFusedAsyncIterable<A>(source, [
      ...stages,
      stage,
    ], () => _takeWhileAsyncLegacy(f, legacy()));
  }
  return FxFusedAsyncIterable<A>(iterable, [
    stage,
  ], () => _takeWhileAsyncLegacy(f, iterable));
}

FxAsyncIterable<A> _takeWhileAsyncLegacy<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var end = false;
    return SerialAsyncIterator((concurrent) {
      if (end) return Future.value(IterResult<A>.done());
      return iterator.next(concurrent).then((result) {
        if (result.done || end) return IterResult<A>.done();
        final keep = f(result.value);
        FutureOr<IterResult<A>> decide(bool k) {
          if (k) return result;
          end = true;
          return IterResult<A>.done();
        }

        if (keep is Future<bool>) return keep.then(decide);
        return decide(keep);
      });
    });
  });
}

/// Returns the longest **suffix** whose every element satisfies [f], in
/// source order.
///
/// The predicate counterpart of [takeRight], where [takeWhile] is the
/// predicate counterpart of [take]. Not an FxTS port.
///
/// ```dart
/// takeWhileRight((a) => a > 2, [1, 4, 2, 3, 4]); // (3, 4)
/// ```
///
/// Order is the source's, so this composes with the rest of the library;
/// fpdart's `takeWhileRight` hands back the reversed run instead. Nothing
/// can be emitted before the source ends, and a non-[List] source is
/// buffered up to the longest matching run it has seen. A [List] source is
/// indexed from the end instead, so [f] is called only on the trailing run
/// and in reverse — keep the predicate pure.
Iterable<A> takeWhileRight<A>(bool Function(A a) f, Iterable<A> iterable) =>
    _TakeWhileRightIterable(f, iterable);

/// The index at which [list]'s trailing run of [f]-matching elements begins
/// (`list.length` when the last element already fails).
int _suffixStart<A>(bool Function(A) f, List<A> list) {
  var start = list.length;
  while (start > 0 && f(list[start - 1])) {
    start--;
  }
  return start;
}

class _TakeWhileRightIterable<A> extends Iterable<A> {
  _TakeWhileRightIterable(this._f, this._source);
  final bool Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator {
    final source = _source;
    if (source is List<A>) {
      return FxListRangeIterator(
        source,
        _suffixStart(_f, source),
        source.length,
      );
    }
    return _TakeWhileRightIterator(_f, _source);
  }
}

class _TakeWhileRightIterator<A> implements Iterator<A> {
  _TakeWhileRightIterator(this._f, this._source);
  final bool Function(A) _f;
  final Iterable<A> _source;
  // The run in flight, built on the first pull. Every element that fails [_f]
  // proves the run so far was not the suffix, so it is dropped — the buffer
  // costs the longest run seen, not the whole source.
  List<A>? _tail;
  int _i = 0;
  @override
  late A current;
  @override
  bool moveNext() {
    var tail = _tail;
    if (tail == null) {
      tail = _tail = <A>[];
      for (final a in _source) {
        if (_f(a)) {
          tail.add(a);
        } else if (tail.isNotEmpty) {
          tail.clear();
        }
      }
    }
    if (_i >= tail.length) return false;
    current = tail[_i++];
    return true;
  }
}

/// Async counterpart of [takeWhileRight].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> takeWhileRightAsync<A>(
  bool Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    Iterator<A>? tail;
    return SerialAsyncIterator((concurrent) async {
      if (tail == null) {
        final arr = <A>[];
        while (true) {
          final r = await iterator.next(concurrent);
          if (r.done) break;
          arr.add(r.value);
        }
        tail = takeWhileRight(f, arr).iterator;
      }
      if (tail!.moveNext()) return IterResult.value(tail!.current);
      return IterResult<A>.done();
    });
  });
}

/// Returns an iterable that yields values until [f] returns true —
/// **including** the element that matched.
///
/// Port of FxTS `takeUntilInclusive`.
Iterable<A> takeUntilInclusive<A>(bool Function(A a) f, Iterable<A> iterable) =>
    _TakeUntilInclusiveIterable(f, iterable);

class _TakeUntilInclusiveIterable<A> extends Iterable<A> {
  _TakeUntilInclusiveIterable(this._f, this._source);
  final bool Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _TakeUntilInclusiveIterator(_f, _source.iterator);
}

class _TakeUntilInclusiveIterator<A> implements Iterator<A> {
  _TakeUntilInclusiveIterator(this._f, this._it);
  final bool Function(A) _f;
  final Iterator<A> _it;
  var _done = false;
  @override
  late A current;
  @override
  bool moveNext() {
    if (_done || !_it.moveNext()) return false;
    final v = _it.current;
    if (_f(v)) _done = true;
    current = v;
    return true;
  }
}

/// Async counterpart of [takeUntilInclusive].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> takeUntilInclusiveAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var end = false;
    return SerialAsyncIterator((concurrent) async {
      if (end) return IterResult<A>.done();
      final result = await iterator.next(concurrent);
      if (result.done || end) return IterResult<A>.done();
      if (await f(result.value)) {
        end = true;
      }
      return result;
    });
  });
}

/// Alias of [takeUntilInclusive].
///
/// Deprecated in FxTS in favor of `takeUntilInclusive`; kept for parity.
@Deprecated('Use takeUntilInclusive instead')
Iterable<A> takeUntil<A>(bool Function(A a) f, Iterable<A> iterable) =>
    takeUntilInclusive(f, iterable);

/// Alias of [takeUntilInclusiveAsync].
@Deprecated('Use takeUntilInclusiveAsync instead')
@pragma('vm:prefer-inline')
FxAsyncIterable<A> takeUntilAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => takeUntilInclusiveAsync(f, iterable);

/// Returns an iterable that skips the first [length] values.
///
/// Port of FxTS `drop`.
Iterable<A> drop<A>(int length, Iterable<A> iterable) =>
    _DropIterable(length, iterable);

class _DropIterable<A> extends Iterable<A> implements FxListRangeSource<A> {
  _DropIterable(this._length, this._source);
  final int _length;
  final Iterable<A> _source;
  @override
  FxListRange<A>? get listRange {
    final r = fxListRangeOf(_source);
    if (r == null) return null;
    final start = _length < 0 ? r.start : r.start + _length;
    return FxListRange(r.list, start > r.end ? r.end : start, r.end);
  }

  @override
  Iterator<A> get iterator {
    final r = listRange;
    if (r != null) return FxListRangeIterator(r.list, r.start, r.end);
    return _DropIterator(_length, _source.iterator);
  }
}

class _DropIterator<A> implements Iterator<A> {
  _DropIterator(this._remaining, this._it);
  int _remaining;
  final Iterator<A> _it;
  @override
  late A current;
  @override
  bool moveNext() {
    while (_remaining > 0) {
      _remaining--;
      if (!_it.moveNext()) return false;
    }
    if (!_it.moveNext()) return false;
    current = _it.current;
    return true;
  }
}

/// Async counterpart of [drop].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> dropAsync<A>(int length, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var remaining = length;
    return SerialAsyncIterator((concurrent) async {
      while (remaining > 0) {
        remaining--;
        final r = await iterator.next(concurrent);
        if (r.done) return IterResult<A>.done();
      }
      return iterator.next(concurrent);
    });
  });
}

/// Returns an iterable that omits the last [length] values.
///
/// Port of FxTS `dropRight`. A [List] source is indexed directly; any other
/// source streams through a [length]-element delay line, so the pipeline
/// stays lazy in O([length]) memory instead of materializing the source.
Iterable<A> dropRight<A>(int length, Iterable<A> iterable) {
  if (length < 0) throw RangeError("'length' must be greater than 0");
  return _DropRightIterable(length, iterable);
}

class _DropRightIterable<A> extends Iterable<A>
    implements FxListRangeSource<A> {
  _DropRightIterable(this._length, this._source);
  final int _length;
  final Iterable<A> _source;
  @override
  FxListRange<A>? get listRange {
    final r = fxListRangeOf(_source);
    if (r == null) return null;
    final end = r.end - _length;
    return FxListRange(r.list, r.start, end < r.start ? r.start : end);
  }

  @override
  Iterator<A> get iterator {
    final r = listRange;
    if (r != null) return FxListRangeIterator(r.list, r.start, r.end);
    if (_length == 0) return _source.iterator;
    return _DropRightIterator(_length, _source.iterator);
  }
}

class _DropRightIterator<A> implements Iterator<A> {
  _DropRightIterator(this._length, this._it);
  final int _length;
  final Iterator<A> _it;
  // A ring of the [_length] most recent elements: each new upstream value
  // releases the value pulled [_length] steps earlier, so the last [_length]
  // are exactly the ones never emitted.
  List<A>? _ring;
  int _pos = 0;
  bool _done = false;
  @override
  late A current;
  @override
  bool moveNext() {
    if (_done) return false;
    final it = _it;
    var ring = _ring;
    if (ring == null) {
      var filled = 0;
      while (filled < _length && it.moveNext()) {
        ring ??= List<A>.filled(_length, it.current);
        ring[filled] = it.current;
        filled++;
      }
      if (filled < _length) {
        _done = true;
        return false;
      }
      _ring = ring;
    }
    if (!it.moveNext()) {
      _done = true;
      return false;
    }
    current = ring![_pos];
    ring[_pos] = it.current;
    _pos++;
    if (_pos == _length) _pos = 0;
    return true;
  }
}

/// Async counterpart of [dropRight].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> dropRightAsync<A>(int length, FxAsyncIterable<A> iterable) {
  if (length < 0) throw RangeError("'length' must be greater than 0");
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    Iterator<A>? head;
    return SerialAsyncIterator((concurrent) async {
      if (head == null) {
        final arr = <A>[];
        while (true) {
          final r = await iterator.next(concurrent);
          if (r.done) break;
          arr.add(r.value);
        }
        head = dropRight(length, arr).iterator;
      }
      if (head!.moveNext()) return IterResult.value(head!.current);
      return IterResult<A>.done();
    });
  });
}

/// Skips values while [f] returns true, then yields the rest.
///
/// Port of FxTS `dropWhile`.
Iterable<A> dropWhile<A>(bool Function(A a) f, Iterable<A> iterable) =>
    _DropWhileIterable(f, iterable);

class _DropWhileIterable<A> extends Iterable<A> {
  _DropWhileIterable(this._f, this._source);
  final bool Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _DropWhileIterator(_f, _source.iterator);
}

class _DropWhileIterator<A> implements Iterator<A> {
  _DropWhileIterator(this._f, this._it);
  final bool Function(A) _f;
  final Iterator<A> _it;
  var _dropping = true;
  @override
  late A current;
  @override
  bool moveNext() {
    while (_it.moveNext()) {
      final v = _it.current;
      if (_dropping) {
        if (_f(v)) continue;
        _dropping = false;
      }
      current = v;
      return true;
    }
    return false;
  }
}

/// Async counterpart of [dropWhile].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> dropWhileAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
  // Fused-stage form, like filterAsync/takeWhileAsync. Only one dropWhile
  // fuses into a run — its latch lives on the iterator — so a second one
  // starts a new run over this iterable, exactly as a second scan does.
  // A Concurrent marker falls back to [_dropWhileAsyncLegacy].
  final stage = FxDropWhileStage((v) => f(v as A));
  if (iterable is FxFusedAsyncIterable<A> && iterable.dropWhileIndex < 0) {
    final source = iterable.source;
    final stages = iterable.stages;
    final legacy = iterable.legacy;
    return FxFusedAsyncIterable<A>(source, [
      ...stages,
      stage,
    ], () => _dropWhileAsyncLegacy(f, legacy()));
  }
  return FxFusedAsyncIterable<A>(iterable, [
    stage,
  ], () => _dropWhileAsyncLegacy(f, iterable));
}

FxAsyncIterable<A> _dropWhileAsyncLegacy<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var dropping = true;
    return SerialAsyncIterator((concurrent) {
      Future<IterResult<A>> loop() => iterator.next(concurrent).then((result) {
        if (result.done) return IterResult<A>.done();
        if (!dropping) return result;
        final drop = f(result.value);
        FutureOr<IterResult<A>> decide(bool d) {
          if (d) return loop();
          dropping = false;
          return result;
        }

        if (drop is Future<bool>) return drop.then(decide);
        return decide(drop);
      });
      return loop();
    });
  });
}

/// Drops the longest **suffix** whose every element satisfies [f], yielding
/// what is left in source order — trimming a trailing run.
///
/// The predicate counterpart of [dropRight], and the complement of
/// [takeWhileRight]: the two partition the source. Not an FxTS port.
///
/// ```dart
/// dropWhileRight((a) => a == 0, [1, 2, 0, 0]); // (1, 2)
/// ```
///
/// Unlike [takeWhileRight] this streams: a matching run is held back only
/// until an element fails [f], which proves the run was not the suffix and
/// releases it. Memory is the longest run, not the source. A [List] source
/// is indexed from the end instead, so [f] is called only on the trailing
/// run and in reverse — keep the predicate pure.
Iterable<A> dropWhileRight<A>(bool Function(A a) f, Iterable<A> iterable) =>
    _DropWhileRightIterable(f, iterable);

class _DropWhileRightIterable<A> extends Iterable<A> {
  _DropWhileRightIterable(this._f, this._source);
  final bool Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator {
    final source = _source;
    if (source is List<A>) {
      return FxListRangeIterator(source, 0, _suffixStart(_f, source));
    }
    return _DropWhileRightIterator(_f, _source.iterator);
  }
}

class _DropWhileRightIterator<A> implements Iterator<A> {
  _DropWhileRightIterator(this._f, this._it);
  final bool Function(A) _f;
  final Iterator<A> _it;
  // Matching elements are held back: they are the suffix only if the source
  // ends here. The first failing element releases them all.
  final _pending = <A>[];
  final _ready = <A>[];
  int _out = 0;
  bool _done = false;
  @override
  late A current;
  @override
  bool moveNext() {
    if (_out < _ready.length) {
      current = _ready[_out++];
      return true;
    }
    if (_done) return false;
    _ready.clear();
    _out = 0;
    while (_it.moveNext()) {
      final v = _it.current;
      if (_f(v)) {
        _pending.add(v);
        continue;
      }
      if (_pending.isEmpty) {
        current = v;
        return true;
      }
      _ready
        ..addAll(_pending)
        ..add(v);
      _pending.clear();
      current = _ready[_out++];
      return true;
    }
    // The source ended inside a matching run: that run was the suffix.
    _done = true;
    return false;
  }
}

/// Async counterpart of [dropWhileRight].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> dropWhileRightAsync<A>(
  bool Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    Iterator<A>? head;
    return SerialAsyncIterator((concurrent) async {
      if (head == null) {
        final arr = <A>[];
        while (true) {
          final r = await iterator.next(concurrent);
          if (r.done) break;
          arr.add(r.value);
        }
        head = dropWhileRight(f, arr).iterator;
      }
      if (head!.moveNext()) return IterResult.value(head!.current);
      return IterResult<A>.done();
    });
  });
}

/// Skips values until [f] returns true — the matching element is dropped
/// too — then yields the rest.
///
/// Port of FxTS `dropUntil`.
Iterable<A> dropUntil<A>(bool Function(A a) f, Iterable<A> iterable) =>
    _DropUntilIterable(f, iterable);

class _DropUntilIterable<A> extends Iterable<A> {
  _DropUntilIterable(this._f, this._source);
  final bool Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _DropUntilIterator(_f, _source.iterator);
}

class _DropUntilIterator<A> implements Iterator<A> {
  _DropUntilIterator(this._f, this._it);
  final bool Function(A) _f;
  final Iterator<A> _it;
  var _dropping = true;
  @override
  late A current;
  @override
  bool moveNext() {
    while (_dropping) {
      if (!_it.moveNext()) return false;
      if (_f(_it.current)) _dropping = false;
    }
    if (!_it.moveNext()) return false;
    current = _it.current;
    return true;
  }
}

/// Async counterpart of [dropUntil].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> dropUntilAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var dropping = true;
    return SerialAsyncIterator((concurrent) {
      if (!dropping) return iterator.next(concurrent);
      Future<IterResult<A>> loop() => iterator.next(concurrent).then((result) {
        if (result.done) return IterResult<A>.done();
        final match = f(result.value);
        FutureOr<IterResult<A>> decide(bool m) {
          if (!m) return loop();
          dropping = false;
          return iterator.next(concurrent);
        }

        if (match is Future<bool>) return match.then(decide);
        return decide(match);
      });
      return loop();
    });
  });
}

/// Returns an iterable of the values between [start] (inclusive) and [end]
/// (exclusive) by index.
///
/// Port of FxTS `slice`. Omit [end] to take everything from [start].
///
/// The source is consumed only up to [end], so `slice(0, xs, k)` costs O(k)
/// like [take] and terminates on an infinite source. Before 0.8.6 it kept
/// pulling to the end of the source; a side-effecting or single-shot source
/// that relied on being drained will now see only the first [end] elements.
Iterable<A> slice<A>(int start, Iterable<A> iterable, [int? end]) =>
    _SliceIterable(start, end, iterable);

class _SliceIterable<A> extends Iterable<A> {
  _SliceIterable(this._start, this._end, this._source);
  final int _start;
  final int? _end;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _SliceIterator(_start, _end, _source.iterator);
}

class _SliceIterator<A> implements Iterator<A> {
  _SliceIterator(this._start, this._end, this._it);
  final int _start;
  final int? _end;
  final Iterator<A> _it;
  var _i = 0;
  @override
  late A current;
  @override
  bool moveNext() {
    // O(k), not O(n) — see [slice].
    final end = _end;
    while (end == null || _i < end) {
      if (!_it.moveNext()) return false;
      if (_i++ >= _start) {
        current = _it.current;
        return true;
      }
    }
    return false;
  }
}

/// Async counterpart of [slice], including its stop-at-[end] consumption.
@pragma('vm:prefer-inline')
FxAsyncIterable<A> sliceAsync<A>(
  int start,
  FxAsyncIterable<A> iterable, [
  int? end,
]) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var i = 0;
    return SerialAsyncIterator((concurrent) async {
      while (end == null || i < end) {
        final result = await iterator.next(concurrent);
        if (result.done) return IterResult<A>.done();
        if (i++ >= start) return result;
      }
      return IterResult<A>.done();
    });
  });
}

/// Returns an iterable of lists, each containing [size] consecutive
/// elements (the last chunk may be shorter).
///
/// Port of FxTS `chunk`. Equivalent to
/// `windowed(size, iterable, step: size, partial: true)`, except that a
/// non-positive [size] yields nothing instead of throwing.
///
/// Each chunk is a fresh growable list — see [windowed].
Iterable<List<A>> chunk<A>(int size, Iterable<A> iterable) => size < 1
    ? Iterable<List<A>>.empty()
    : _WindowIterable(size, size, true, iterable);

/// Returns an iterable of sliding windows over [iterable]: lists of [size]
/// consecutive elements, each window starting [step] elements after the
/// previous one. With [partial] the trailing windows shorter than [size]
/// are kept instead of dropped.
///
/// fxdart extension (not part of FxTS) — the sliding generalization of
/// [chunk], following Kotlin's `windowed` naming; RxDart's counterpart is
/// `bufferCount(size, startEvery)`.
///
/// ```dart
/// windowed(3, [1, 2, 3, 4, 5]);                // ([1, 2, 3], [2, 3, 4], [3, 4, 5])
/// windowed(3, [1, 2, 3, 4, 5], step: 2);       // ([1, 2, 3], [3, 4, 5])
/// windowed(3, [1, 2, 3, 4, 5], partial: true); // (..., [3, 4, 5], [4, 5], [5])
/// ```
///
/// Each window is a fresh growable list, owned by the caller: it is a copy,
/// never a view onto the source, and mutating one window cannot disturb
/// another or the source.
///
/// Windows became growable in 0.8.7. Before that the two sync paths handed
/// back a fixed-length list while the async path (`windowedAsync`) already
/// returned a growable one; all four paths now agree. The reason is
/// performance: a fixed-length window has to be filled from package code, one
/// covariant store check per element, and no bulk copy that preserves the
/// fixed length is faster than that loop — the full measurement is on
/// `_windowSlice`. Nothing that only reads a window is affected.
Iterable<List<A>> windowed<A>(
  int size,
  Iterable<A> iterable, {
  int step = 1,
  bool partial = false,
}) {
  _checkWindow(size, step);
  return _WindowIterable(size, step, partial, iterable);
}

void _checkWindow(int size, int step) {
  if (size < 1) {
    throw ArgumentError.value(size, 'size', 'must be at least 1');
  }
  if (step < 1) {
    throw ArgumentError.value(step, 'step', 'must be at least 1');
  }
}

/// One window of [list] — `list[i .. i + length)` — copied by the SDK rather
/// than element by element.
///
/// Shared by [_WindowRangeIterator] and [_WindowRangeMapIterator] so the two
/// cannot disagree about how a window is built.
///
/// Filling a pre-sized `List<A>` from package code costs a **covariant store
/// check per element**: `List<A>.operator[]=` takes a covariant parameter and
/// `A` is a runtime type argument here, so the check cannot be elided — the
/// cost `_MapIterable.toList` documents at length. `List.sublist` reaches the
/// VM's own `_slice`, which copies into an array carrying no type argument and
/// so pays no check at all.
///
/// Measured AOT over 1,000,000 windows of `double`, built and summed: the
/// pre-sized fill 16.4 ms against `sublist` 14.1 ms at `size: 3`, 35.4 vs 26.7
/// at 7, 51.8 vs 36.0 at 10 — about 2.3 ns a source element at the default
/// `step: 1`, which on `smoothed-zone-changes` measured as two thirds of the
/// whole win (see the CHANGELOG). It also removes most of that case's
/// run-to-run spread: the same A/B swung 4.8 percentage points across clean
/// runs with the fill in place and 1.5 with it gone.
///
/// **No fixed-length bulk copy exists for package code.** `List.filled` +
/// `setRange` (21.1 / 44.0 / 62.4 ms) and
/// `getRange().toList(growable: false)` (29.1 / 55.0 / 76.9) are both *slower*
/// than the fill they would replace, because both copy through `Lists.copy` —
/// an element loop behind an interface `[]=` call. Buying the check back
/// therefore means giving up the fixed-length window, which 0.8.7 does
/// deliberately and uniformly: see [windowed] for the contract, and
/// [_WindowIterator._emit] for the same change on the pulled path.
@pragma('vm:prefer-inline')
List<A> _windowSlice<A>(List<A> list, int i, int length) =>
    list.sublist(i, i + length);

/// The pre-sized fill [_windowSlice] replaces, kept for the one backing list
/// it cannot serve: `TypedData`.
///
/// `List.sublist` returns a list of the *receiver's* runtime type. A
/// `Uint8List` is a `List<int>` and a `Float64List` a `List<double>`, so both
/// reach [_WindowRangeIterator] through `fxListRangeOf` unchanged — and
/// slicing one yields another typed-data list, which is fixed length and
/// truncates on store. That is not the window [windowed] promises: it would
/// make the growable contract false, and `window[0] = 300` would silently
/// leave 44 behind in a `Uint8List` window instead of throwing or storing.
///
/// Only a fresh `List<A>` keeps both halves of the contract, so the typed-data
/// source buys the covariant store check back. It is the rare source here —
/// the measured `sublist` win stands for every ordinary `List`, which is what
/// [_WindowRangeIterator._typed] is for: the receiver's type is fixed for the
/// whole iteration, so it is tested once when the iterator is built, never per
/// window.
@pragma('vm:prefer-inline')
List<A> _windowFill<A>(List<A> list, int i, int length) {
  // length >= 1 at every call site, so element i is a safe fill value.
  final out = List<A>.filled(length, list[i], growable: true);
  for (var k = 1; k < length; k++) {
    out[k] = list[i + k];
  }
  return out;
}

class _WindowIterable<A> extends Iterable<List<A>>
    implements FxMapFusable<List<A>> {
  _WindowIterable(this._size, this._step, this._partial, this._source);
  final int _size;
  final int _step;
  final bool _partial;
  final Iterable<A> _source;
  @override
  Iterator<List<A>> get iterator {
    // Over a [List] the ring buffer earns nothing: each window is already a
    // contiguous slice, so it can be filled straight from the backing list
    // and the whole upstream iterator layer disappears.
    final r = fxListRangeOf(_source);
    if (r != null) {
      return _WindowRangeIterator(_size, _step, _partial, r);
    }
    return _WindowIterator(_size, _step, _partial, _source.iterator);
  }

  /// `windowed(...).map(f)` as one stage — see [FxMapFusable].
  ///
  /// Unfused, every window crosses a megamorphic `moveNext` plus a `current`
  /// read between this iterator and the `map` iterator, and `windowed` emits
  /// one window per *source* element at the default `step: 1`, so that
  /// boundary is paid at the full element rate. [f] is still one indirect
  /// call per window either way.
  @override
  Iterable<B> fxFuseMap<B>(B Function(List<A> a) f) =>
      _WindowMapIterable(_size, _step, _partial, _source, f);
}

class _WindowRangeIterator<A> implements Iterator<List<A>> {
  _WindowRangeIterator(this._size, this._step, this._partial, FxListRange<A> r)
    : _list = r.list,
      _typed = r.list is TypedData,
      _i = r.start,
      _end = r.end,
      _lastFull = r.end - _size;
  final int _size;
  final int _step;
  final bool _partial;
  final List<A> _list;

  /// Whether [_list] is typed data, and so whether a window has to be filled
  /// rather than sliced — see [_windowFill]. Fixed for the whole iteration, so
  /// it is decided here and not per window.
  final bool _typed;
  final int _end;

  /// Largest start index that still has a full window behind it — the one
  /// bound the common path has to test.
  final int _lastFull;
  int _i;
  @override
  late List<A> current;
  @override
  bool moveNext() {
    final i = _i;
    if (i <= _lastFull) {
      current = _slice(i, _size);
      _i = i + _step;
      return true;
    }
    // Past the last full window: only `partial: true` keeps going, and every
    // window from here on is shorter than the one before.
    if (!_partial) return false;
    final remaining = _end - i;
    if (remaining <= 0) return false;
    current = _slice(i, remaining);
    _i = i + _step;
    return true;
  }

  List<A> _slice(int i, int length) =>
      _typed ? _windowFill(_list, i, length) : _windowSlice(_list, i, length);
}

/// `windowed`/`chunk` followed by `map`, as one stage — see [FxMapFusable].
///
/// The window is built and [_f] applied inside a single `moveNext`, instead of
/// the window crossing a stage boundary to reach a `map` iterator. Which
/// iterator that is has to be decided per iteration, not here: `fxListRangeOf`
/// snapshots the source's bounds, and doing that when the chain is built would
/// break repeated iteration over a source that changed in between.
///
/// **Fusing here ends the chain's fusion**, deliberately. This node is
/// neither [FxUniqFusable] nor [FxMapFusable], where the `_MapIterable` it
/// displaces was the former — so `{windowed,chunk} -> map -> uniq` loses the
/// map+uniq fusion it would have had without the window stage, and
/// `... -> map -> map` fuses only the first `map`. Both are a question of how
/// many stage boundaries survive; the elements and their order are identical
/// either way, which is why no regression sweep reports either one.
///
/// Closing those gaps means another fused node per source shape, and every
/// added `Iterator` implementation makes the `moveNext` call site at each
/// consumer more polymorphic — the cost that already decided several fusion
/// choices in this file. Neither combination appears in the published example
/// corpus. Left unfused on purpose, not overlooked. [_ScanMapIterable] says
/// the same of the `scan` side.
class _WindowMapIterable<A, B> extends Iterable<B> {
  _WindowMapIterable(
    this._size,
    this._step,
    this._partial,
    this._source,
    this._f,
  );
  final int _size;
  final int _step;
  final bool _partial;
  final Iterable<A> _source;
  final B Function(List<A>) _f;
  @override
  Iterator<B> get iterator {
    final r = fxListRangeOf(_source);
    if (r != null) {
      return _WindowRangeMapIterator(_size, _step, _partial, r, _f);
    }
    // Not a [List] range, so the ring buffer is still needed and the window
    // still has to come out of it. The boundary stays, but over a concrete
    // [_WindowIterator] rather than the `Iterator<A>` field a `map` stage
    // would hold, so the call is monomorphic instead of megamorphic.
    return _WindowMapIterator(
      _WindowIterator(_size, _step, _partial, _source.iterator),
      _f,
    );
  }
}

/// [_WindowRangeIterator] with the `map` callback folded in.
///
/// Deliberately a second copy of that iterator's bound arithmetic rather than
/// a wrapper around it — a wrapper is the boundary this exists to remove. The
/// two are pinned against each other in `test/lazy/fused_window_map_test.dart`.
class _WindowRangeMapIterator<A, B> implements Iterator<B> {
  _WindowRangeMapIterator(
    this._size,
    this._step,
    this._partial,
    FxListRange<A> r,
    this._f,
  ) : _list = r.list,
      _typed = r.list is TypedData,
      _i = r.start,
      _end = r.end,
      _lastFull = r.end - _size;
  final int _size;
  final int _step;
  final bool _partial;
  final B Function(List<A>) _f;
  final List<A> _list;

  /// See [_WindowRangeIterator._typed] — the fused path builds the same
  /// window, so it makes the same decision once.
  final bool _typed;
  final int _end;
  final int _lastFull;
  int _i;
  @override
  late B current;
  @override
  bool moveNext() {
    final i = _i;
    if (i <= _lastFull) {
      current = _f(_slice(i, _size));
      _i = i + _step;
      return true;
    }
    if (!_partial) return false;
    final remaining = _end - i;
    if (remaining <= 0) return false;
    current = _f(_slice(i, remaining));
    _i = i + _step;
    return true;
  }

  List<A> _slice(int i, int length) =>
      _typed ? _windowFill(_list, i, length) : _windowSlice(_list, i, length);
}

/// The pulled half of [_WindowMapIterable]: [_WindowIterator] plus [_f].
class _WindowMapIterator<A, B> implements Iterator<B> {
  _WindowMapIterator(this._it, this._f);
  final _WindowIterator<A> _it;
  final B Function(List<A>) _f;
  @override
  late B current;
  @override
  bool moveNext() {
    if (!_it.moveNext()) return false;
    current = _f(_it.current);
    return true;
  }
}

class _WindowIterator<A> implements Iterator<List<A>> {
  _WindowIterator(this._size, this._step, this._partial, this._it);
  final int _size;
  final int _step;
  final bool _partial;
  final Iterator<A> _it;
  // Overlapping elements are kept in a reused ring buffer, so a window never
  // re-pulls what the previous one already read.
  List<A>? _ring;
  int _ringStart = 0;
  int _ringCount = 0;
  int _pendingSkip = 0;
  bool _sourceDone = false;
  bool _finished = false;
  @override
  late List<A> current;

  bool _pull() {
    if (_sourceDone) return false;
    if (_it.moveNext()) return true;
    _sourceDone = true;
    return false;
  }

  /// One window out of the ring, growable to match [_windowSlice].
  ///
  /// The ring is itself a `List<A>`, so whenever the window does not wrap past
  /// its end — always, for `chunk` and for any `step >= size`, where
  /// [_ringStart] stays at 0 — the whole copy is one `sublist` and pays no
  /// covariant store check. Only an overlapping window over a non-`List`
  /// source wraps, and that tail is added by hand.
  ///
  /// Measured AOT over 1,000,000 windows of `double`, built and summed, at
  /// `size` 3/7/10: contiguous 14.8/27.8/37.6 ms against 18.8/38.7/55.8 for
  /// the pre-sized fill this replaces, wrapped 21.6/42.3/60.9 against
  /// 19.6/41.4/59.0. So the common shape gets ~21% cheaper and only the
  /// overlapping-over-a-generator shape pays, 2–10%, for a window whose
  /// growability now matches every other path in the family.
  List<A> _emit(int length) {
    final ring = _ring!;
    final start = _ringStart;
    final head = _size - start;
    if (length <= head) return ring.sublist(start, start + length);
    final window = ring.sublist(start, _size);
    final wrapped = length - head;
    for (var k = 0; k < wrapped; k++) {
      window.add(ring[k]);
    }
    return window;
  }

  @override
  bool moveNext() {
    if (_finished) return false;
    while (_pendingSkip > 0 && _pull()) {
      _pendingSkip--;
    }
    if (_pendingSkip > 0) {
      _finished = true;
      return false;
    }
    while (_ringCount < _size && _pull()) {
      final v = _it.current;
      final ring = _ring ??= List<A>.filled(_size, v);
      var idx = _ringStart + _ringCount;
      if (idx >= _size) idx -= _size;
      ring[idx] = v;
      _ringCount++;
    }
    if (_ringCount == 0) {
      _finished = true;
      return false;
    }
    if (_ringCount < _size) {
      // Trailing window(s): keep sliding through the remnant only when
      // partial windows were asked for.
      if (!_partial) {
        _finished = true;
        return false;
      }
      current = _emit(_ringCount);
      if (_step >= _ringCount) {
        _finished = true;
      } else {
        _ringStart = _ringStart + _step;
        if (_ringStart >= _size) _ringStart -= _size;
        _ringCount -= _step;
      }
      return true;
    }
    current = _emit(_size);
    if (_step < _size) {
      _ringStart = _ringStart + _step;
      if (_ringStart >= _size) _ringStart -= _size;
      _ringCount -= _step;
    } else {
      _ringCount = 0;
      _pendingSkip = _step - _size;
    }
    return true;
  }
}

/// Async counterpart of [chunk].
///
/// Each chunk is a fresh growable list the caller owns — see [windowed].
@pragma('vm:prefer-inline')
FxAsyncIterable<List<A>> chunkAsync<A>(int size, FxAsyncIterable<A> iterable) {
  if (size < 1) return asyncEmpty();
  return _windowedAsync(size, size, true, iterable);
}

/// Async counterpart of [windowed].
///
/// Each window is a fresh growable list the caller owns, exactly as in the
/// sync form — see [windowed] for the contract all four of these operators
/// share.
@pragma('vm:prefer-inline')
FxAsyncIterable<List<A>> windowedAsync<A>(
  int size,
  FxAsyncIterable<A> iterable, {
  int step = 1,
  bool partial = false,
}) {
  _checkWindow(size, step);
  return _windowedAsync(size, step, partial, iterable);
}

FxAsyncIterable<List<A>> _windowedAsync<A>(
  int size,
  int step,
  bool partial,
  FxAsyncIterable<A> iterable,
) => DelegateAsyncIterable(
  () => _WindowedAsyncIterator<A>(size, step, partial, iterable),
);

/// Pull-based `windowed`/`chunk`, on the internal fast-pull path.
///
/// The previous form wrapped an `async` closure in a [SerialAsyncIterator],
/// so every *element* crossed a real `Future` and every *window* an async
/// function frame — even when the source could answer synchronously. Over a
/// `toAsync` source at 100,000 elements, `chunk(4)` cost 27 ms more than the
/// same chain without it (2.1 ms to 29.1 ms), which is 270 ns an element for
/// bookkeeping that does no work.
///
/// Filling a window is a loop of [FxFastIterator.nextOr] pulls that only
/// chains a continuation when a pull actually answers asynchronously
/// (then/bare, per the 0.7.4 shape lesson). Semantics are unchanged: window
/// contents and count, the `partial` tail, overlap carry for `step < size`,
/// the skip for `step > size`, and — via [_windowedAsyncLegacy] — the
/// concurrent path.
class _WindowedAsyncIterator<A>
    with FxFastNextGate<List<A>>
    implements FxFastIterator<List<A>> {
  _WindowedAsyncIterator(
    this._size,
    this._step,
    this._partial,
    this._sourceIterable,
  );

  final int _size;
  final int _step;
  final bool _partial;
  final FxAsyncIterable<A> _sourceIterable;
  FxAsyncIterator<A>? _source;
  FxAsyncIterator<List<A>>? _fallback;
  List<A> _carry = <A>[];
  int _pendingSkip = 0;
  bool _sourceDone = false;
  bool _finished = false;

  @override
  Future<IterResult<List<A>>> next([Concurrent? concurrent]) {
    if (_fallback == null &&
        concurrent is Concurrent &&
        _source == null &&
        !_finished) {
      // Nothing pulled yet and the consumer wants concurrency: hand the whole
      // iteration to the serial form, which threads the marker upstream.
      _fallback = _windowedAsyncLegacy(
        _size,
        _step,
        _partial,
        _sourceIterable,
      ).iterator;
    }
    final fb = _fallback;
    if (fb != null) return fb.next(concurrent);
    return super.next(concurrent);
  }

  @override
  FutureOr<IterResult<List<A>>> nextOr() {
    final fb = _fallback;
    if (fb != null) return fb.next();
    if (_finished) return IterResult<List<A>>.done();
    _source ??= _sourceIterable.iterator;
    return _skip();
  }

  FutureOr<IterResult<A>> _pull() {
    final src = _source!;
    return src is FxFastIterator<A> ? src.nextOr() : src.next();
  }

  /// Consumes the gap left by a `step` wider than `size`.
  FutureOr<IterResult<List<A>>> _skip() {
    while (_pendingSkip > 0 && !_sourceDone) {
      final r = _pull();
      if (r is Future<IterResult<A>>) {
        return r.then((rr) {
          if (rr.done) {
            _sourceDone = true;
          } else {
            _pendingSkip--;
          }
          return _skip();
        });
      }
      if (r.done) {
        _sourceDone = true;
      } else {
        _pendingSkip--;
      }
    }
    if (_pendingSkip > 0) {
      _finished = true;
      return IterResult<List<A>>.done();
    }
    final window = _carry;
    _carry = <A>[];
    return _fill(window);
  }

  FutureOr<IterResult<List<A>>> _fill(List<A> window) {
    while (window.length < _size && !_sourceDone) {
      final r = _pull();
      if (r is Future<IterResult<A>>) {
        return r.then((rr) {
          if (rr.done) {
            _sourceDone = true;
          } else {
            window.add(rr.value);
          }
          return _fill(window);
        });
      }
      if (r.done) {
        _sourceDone = true;
      } else {
        window.add(r.value);
      }
    }
    return _emit(window);
  }

  IterResult<List<A>> _emit(List<A> window) {
    if (window.isEmpty) {
      _finished = true;
      return IterResult<List<A>>.done();
    }
    if (window.length < _size) {
      if (!_partial) {
        _finished = true;
        return IterResult<List<A>>.done();
      }
      if (_step >= window.length) {
        _finished = true;
      } else {
        _carry = window.sublist(_step);
      }
      return IterResult.value(window);
    }
    if (_step < _size) {
      _carry = window.sublist(_step);
    } else {
      _pendingSkip = _step - _size;
    }
    return IterResult.value(window);
  }
}

FxAsyncIterable<List<A>> _windowedAsyncLegacy<A>(
  int size,
  int step,
  bool partial,
  FxAsyncIterable<A> iterable,
) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var carry = <A>[];
    var pendingSkip = 0;
    var sourceDone = false;
    var finished = false;
    return SerialAsyncIterator((concurrent) async {
      if (finished) return IterResult<List<A>>.done();
      while (pendingSkip > 0 && !sourceDone) {
        final result = await iterator.next(concurrent);
        if (result.done) {
          sourceDone = true;
        } else {
          pendingSkip--;
        }
      }
      if (pendingSkip > 0) {
        finished = true;
        return IterResult<List<A>>.done();
      }
      final window = carry;
      carry = <A>[];
      while (window.length < size && !sourceDone) {
        final result = await iterator.next(concurrent);
        if (result.done) {
          sourceDone = true;
        } else {
          window.add(result.value);
        }
      }
      if (window.isEmpty) {
        finished = true;
        return IterResult<List<A>>.done();
      }
      if (window.length < size) {
        if (!partial) {
          finished = true;
          return IterResult<List<A>>.done();
        }
        if (step >= window.length) {
          finished = true;
        } else {
          carry = window.sublist(step);
        }
        return IterResult.value(window);
      }
      if (step < size) {
        carry = window.sublist(step);
      } else {
        pendingSkip = step - size;
      }
      return IterResult.value(window);
    });
  });
}

/// Pairs each element with its successor: `[a, b, c]` becomes
/// `((a, b), (b, c))`. Fewer than two elements yield nothing.
///
/// fxdart extension (not part of FxTS), after RxDart's `pairwise`.
///
/// ```dart
/// pairwise([1, 2, 3, 4]); // ((1, 2), (2, 3), (3, 4))
/// ```
Iterable<(A, A)> pairwise<A>(Iterable<A> iterable) =>
    _PairwiseIterable(iterable);

class _PairwiseIterable<A> extends Iterable<(A, A)> {
  _PairwiseIterable(this._source);
  final Iterable<A> _source;
  @override
  Iterator<(A, A)> get iterator => _PairwiseIterator(_source.iterator);
}

class _PairwiseIterator<A> implements Iterator<(A, A)> {
  _PairwiseIterator(this._it);
  final Iterator<A> _it;
  bool _hasPrev = false;
  late A _prev;
  @override
  late (A, A) current;
  @override
  bool moveNext() {
    if (!_hasPrev) {
      if (!_it.moveNext()) return false;
      _prev = _it.current;
      _hasPrev = true;
    }
    if (!_it.moveNext()) return false;
    final a = _it.current;
    current = (_prev, a);
    _prev = a;
    return true;
  }
}

/// Async counterpart of [pairwise].
@pragma('vm:prefer-inline')
FxAsyncIterable<(A, A)> pairwiseAsync<A>(FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var hasPrev = false;
    late A prev;
    return SerialAsyncIterator((concurrent) async {
      while (true) {
        final result = await iterator.next(concurrent);
        if (result.done) return IterResult<(A, A)>.done();
        final value = result.value;
        if (hasPrev) {
          final pair = (prev, value);
          prev = value;
          return IterResult.value(pair);
        }
        prev = value;
        hasPrev = true;
      }
    });
  });
}

/// Splits an iterable of single-character strings on the separator [sep].
///
/// Port of FxTS `split`, which iterates strings character-wise; in Dart pass
/// e.g. `'a,b,c'.split('')`.
Iterable<String> split(String sep, Iterable<String> iterable) =>
    _SplitIterable(sep, iterable);

class _SplitIterable extends Iterable<String> {
  _SplitIterable(this._sep, this._source);
  final String _sep;
  final Iterable<String> _source;
  @override
  Iterator<String> get iterator =>
      _sep == '' ? _source.iterator : _SplitIterator(_sep, _source.iterator);
}

class _SplitIterator implements Iterator<String> {
  _SplitIterator(this._sep, this._it);
  final String _sep;
  final Iterator<String> _it;
  final StringBuffer _acc = StringBuffer();
  String _last = '';
  bool _finished = false;
  @override
  late String current;
  @override
  bool moveNext() {
    if (_finished) return false;
    while (_it.moveNext()) {
      final chr = _it.current;
      _last = chr;
      if (chr == _sep) {
        current = _acc.toString();
        _acc.clear();
        return true;
      }
      _acc.write(chr);
    }
    // Source exhausted: a trailing separator yields one empty token, a
    // non-empty accumulator yields the final token.
    _finished = true;
    if (_last == _sep) {
      current = '';
      return true;
    }
    if (_acc.isNotEmpty) {
      current = _acc.toString();
      return true;
    }
    return false;
  }
}

/// Async counterpart of [split].
@pragma('vm:prefer-inline')
FxAsyncIterable<String> splitAsync(
  String sep,
  FxAsyncIterable<String> iterable,
) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var acc = '';
    var chr = '';
    var sourceDone = false;
    return SerialAsyncIterator((concurrent) async {
      // Reaching the source's end always emits the tail (if any) in the same
      // call, so every later call is simply done.
      if (sourceDone) return const IterResult<String>.done();
      while (true) {
        final result = await iterator.next(concurrent);
        if (result.done) {
          sourceDone = true;
          if (sep != '' && chr == sep) return const IterResult.value('');
          if (sep != '' && acc.isNotEmpty) return IterResult.value(acc);
          return const IterResult<String>.done();
        }
        if (sep == '') return IterResult.value(result.value);
        chr = result.value;
        if (chr == sep) {
          final out = acc;
          acc = '';
          return IterResult.value(out);
        }
        acc += chr;
      }
    });
  });
}

/// Yields the elements of [iterable] whose matching element in [selectors]
/// is true.
///
/// Port of FxTS `compress`.
Iterable<B> compress<B>(List<bool> selectors, Iterable<B> iterable) =>
    map((r) => r.$2, filter((r) => r.$1, zip(selectors, iterable)));

/// Async counterpart of [compress].
@pragma('vm:prefer-inline')
FxAsyncIterable<B> compressAsync<B>(
  List<bool> selectors,
  FxAsyncIterable<B> iterable,
) => mapAsync(
  (r) => r.$2,
  filterAsync((r) => r.$1, zipAsync(toAsync(selectors), iterable)),
);
