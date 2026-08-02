import 'dart:async';

import '../async_iterable.dart';
import 'filter.dart';
import 'map.dart';
import 'zip.dart';

/// Returns an iterable of the first [length] values from [iterable].
///
/// Port of FxTS `take`.
Iterable<A> take<A>(int length, Iterable<A> iterable) =>
    _TakeIterable(length, iterable);

class _TakeIterable<A> extends Iterable<A> {
  _TakeIterable(this._length, this._source);
  final int _length;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _TakeIterator(_length, _source.iterator);
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
FxAsyncIterable<A> takeAsync<A>(int length, FxAsyncIterable<A> iterable) {
  return DelegateAsyncIterable(() {
    final iterator = iterable.iterator;
    var remaining = length;
    return DelegateAsyncIterator((concurrent) {
      if (remaining-- < 1) return Future.value(IterResult<A>.done());
      return iterator.next(concurrent);
    });
  });
}

/// Returns an iterable of the last [length] values.
///
/// Port of FxTS `takeRight` (materializes the source).
Iterable<A> takeRight<A>(int length, Iterable<A> iterable) sync* {
  if (length < 0) throw RangeError("'length' must be greater than 0");
  final arr = iterable.toList(growable: false);
  for (var i = arr.length - length < 0 ? 0 : arr.length - length;
      i < arr.length;
      i++) {
    yield arr[i];
  }
}

/// Async counterpart of [takeRight].
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
FxAsyncIterable<A> takeWhileAsync<A>(
    FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var end = false;
    return SerialAsyncIterator((concurrent) async {
      final result = await iterator.next(concurrent);
      if (result.done || end) return IterResult<A>.done();
      if (!await f(result.value)) {
        end = true;
        return IterResult<A>.done();
      }
      return result;
    });
  });
}

/// Returns an iterable that yields values until [f] returns true —
/// **including** the element that matched.
///
/// Port of FxTS `takeUntilInclusive`.
Iterable<A> takeUntilInclusive<A>(
        bool Function(A a) f, Iterable<A> iterable) =>
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
FxAsyncIterable<A> takeUntilInclusiveAsync<A>(
    FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) {
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
FxAsyncIterable<A> takeUntilAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    takeUntilInclusiveAsync(f, iterable);

/// Returns an iterable that skips the first [length] values.
///
/// Port of FxTS `drop`.
Iterable<A> drop<A>(int length, Iterable<A> iterable) =>
    _DropIterable(length, iterable);

class _DropIterable<A> extends Iterable<A> {
  _DropIterable(this._length, this._source);
  final int _length;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _DropIterator(_length, _source.iterator);
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
/// Port of FxTS `dropRight` (materializes the source).
Iterable<A> dropRight<A>(int length, Iterable<A> iterable) sync* {
  if (length < 0) throw RangeError("'length' must be greater than 0");
  final arr = iterable.toList(growable: false);
  for (var i = 0; i < arr.length - length; i++) {
    yield arr[i];
  }
}

/// Async counterpart of [dropRight].
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
FxAsyncIterable<A> dropWhileAsync<A>(
    FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var dropping = true;
    return SerialAsyncIterator((concurrent) async {
      while (true) {
        final result = await iterator.next(concurrent);
        if (result.done) return IterResult<A>.done();
        if (dropping) {
          if (await f(result.value)) continue;
          dropping = false;
        }
        return result;
      }
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
FxAsyncIterable<A> dropUntilAsync<A>(
    FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var dropping = true;
    return SerialAsyncIterator((concurrent) async {
      while (dropping) {
        final result = await iterator.next(concurrent);
        if (result.done) return IterResult<A>.done();
        if (await f(result.value)) dropping = false;
      }
      return iterator.next(concurrent);
    });
  });
}

/// Returns an iterable of the values between [start] (inclusive) and [end]
/// (exclusive) by index.
///
/// Port of FxTS `slice`. Omit [end] to take everything from [start].
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
    // Matches the generator form: the source is consumed to its end even
    // past [_end] — iteration stops only when the source does.
    while (_it.moveNext()) {
      final index = _i++;
      if (index >= _start && (_end == null || index < _end)) {
        current = _it.current;
        return true;
      }
    }
    return false;
  }
}

/// Async counterpart of [slice].
FxAsyncIterable<A> sliceAsync<A>(int start, FxAsyncIterable<A> iterable,
    [int? end]) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var i = 0;
    return SerialAsyncIterator((concurrent) async {
      while (true) {
        final result = await iterator.next(concurrent);
        if (result.done) return IterResult<A>.done();
        final index = i++;
        if (index >= start && (end == null || index < end)) {
          return result;
        }
      }
    });
  });
}

/// Returns an iterable of lists, each containing [size] consecutive
/// elements (the last chunk may be shorter).
///
/// Port of FxTS `chunk`. Equivalent to
/// `windowed(size, iterable, step: size, partial: true)`, except that a
/// non-positive [size] yields nothing instead of throwing.
Iterable<List<A>> chunk<A>(int size, Iterable<A> iterable) =>
    size < 1 ? Iterable<List<A>>.empty() : _WindowIterable(size, size, true, iterable);

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
Iterable<List<A>> windowed<A>(int size, Iterable<A> iterable,
    {int step = 1, bool partial = false}) {
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

class _WindowIterable<A> extends Iterable<List<A>> {
  _WindowIterable(this._size, this._step, this._partial, this._source);
  final int _size;
  final int _step;
  final bool _partial;
  final Iterable<A> _source;
  @override
  Iterator<List<A>> get iterator =>
      _WindowIterator(_size, _step, _partial, _source.iterator);
}

class _WindowIterator<A> implements Iterator<List<A>> {
  _WindowIterator(this._size, this._step, this._partial, this._it);
  final int _size;
  final int _step;
  final bool _partial;
  final Iterator<A> _it;
  // Overlapping elements are kept in a reused ring buffer so each emitted
  // window costs exactly one exact-size allocation (no sublist + growth).
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

  List<A> _emit(int length) {
    final ring = _ring!;
    final window = List<A>.filled(length, ring[_ringStart]);
    var idx = _ringStart;
    for (var i = 0; i < length; i++) {
      window[i] = ring[idx];
      idx++;
      if (idx == _size) idx = 0;
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
FxAsyncIterable<List<A>> chunkAsync<A>(int size, FxAsyncIterable<A> iterable) {
  if (size < 1) return asyncEmpty();
  return _windowedAsync(size, size, true, iterable);
}

/// Async counterpart of [windowed].
FxAsyncIterable<List<A>> windowedAsync<A>(int size, FxAsyncIterable<A> iterable,
    {int step = 1, bool partial = false}) {
  _checkWindow(size, step);
  return _windowedAsync(size, step, partial, iterable);
}

FxAsyncIterable<List<A>> _windowedAsync<A>(
    int size, int step, bool partial, FxAsyncIterable<A> iterable) {
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
Iterable<String> split(String sep, Iterable<String> iterable) sync* {
  if (sep == '') {
    yield* iterable;
    return;
  }
  var acc = '';
  var chr = '';
  for (chr in iterable) {
    if (chr == sep) {
      yield acc;
      acc = '';
    } else {
      acc += chr;
    }
  }
  if (chr == sep) {
    yield '';
  } else if (acc.isNotEmpty) {
    yield acc;
  }
}

/// Async counterpart of [split].
FxAsyncIterable<String> splitAsync(
    String sep, FxAsyncIterable<String> iterable) {
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
FxAsyncIterable<B> compressAsync<B>(
        List<bool> selectors, FxAsyncIterable<B> iterable) =>
    mapAsync((r) => r.$2,
        filterAsync((r) => r.$1, zipAsync(toAsync(selectors), iterable)));
