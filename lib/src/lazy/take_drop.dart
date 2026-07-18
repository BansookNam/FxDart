import 'dart:async';

import '../async_iterable.dart';
import 'filter.dart';
import 'map.dart';
import 'zip.dart';

/// Returns an iterable of the first [length] values from [iterable].
///
/// Port of FxTS `take`.
Iterable<A> take<A>(int length, Iterable<A> iterable) sync* {
  if (length < 1) return;
  var remaining = length;
  for (final a in iterable) {
    yield a;
    if (--remaining < 1) return;
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
Iterable<A> takeWhile<A>(bool Function(A a) f, Iterable<A> iterable) sync* {
  for (final a in iterable) {
    if (!f(a)) return;
    yield a;
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
    bool Function(A a) f, Iterable<A> iterable) sync* {
  for (final a in iterable) {
    yield a;
    if (f(a)) return;
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
Iterable<A> drop<A>(int length, Iterable<A> iterable) sync* {
  var remaining = length;
  for (final a in iterable) {
    if (remaining > 0) {
      remaining--;
      continue;
    }
    yield a;
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
Iterable<A> dropWhile<A>(bool Function(A a) f, Iterable<A> iterable) sync* {
  final iterator = iterable.iterator;
  while (iterator.moveNext()) {
    if (f(iterator.current)) continue;
    yield iterator.current;
    while (iterator.moveNext()) {
      yield iterator.current;
    }
    return;
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
Iterable<A> dropUntil<A>(bool Function(A a) f, Iterable<A> iterable) sync* {
  final iterator = iterable.iterator;
  while (iterator.moveNext()) {
    if (f(iterator.current)) break;
  }
  while (iterator.moveNext()) {
    yield iterator.current;
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
Iterable<A> slice<A>(int start, Iterable<A> iterable, [int? end]) sync* {
  var i = 0;
  for (final item in iterable) {
    if (i >= start && (end == null || i < end)) {
      yield item;
    }
    i += 1;
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
/// Port of FxTS `chunk`.
Iterable<List<A>> chunk<A>(int size, Iterable<A> iterable) sync* {
  if (size < 1) return;
  var items = <A>[];
  for (final a in iterable) {
    items.add(a);
    if (items.length == size) {
      yield items;
      items = <A>[];
    }
  }
  if (items.isNotEmpty) yield items;
}

/// Async counterpart of [chunk].
FxAsyncIterable<List<A>> chunkAsync<A>(int size, FxAsyncIterable<A> iterable) {
  if (size < 1) return asyncEmpty();
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var sourceDone = false;
    return SerialAsyncIterator((concurrent) async {
      if (sourceDone) return IterResult<List<A>>.done();
      final items = <A>[];
      while (items.length < size) {
        final result = await iterator.next(concurrent);
        if (result.done) {
          sourceDone = true;
          break;
        }
        items.add(result.value);
      }
      if (items.isEmpty) return IterResult<List<A>>.done();
      return IterResult.value(items);
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
    var tailEmitted = false;
    return SerialAsyncIterator((concurrent) async {
      if (sourceDone) {
        if (tailEmitted) return const IterResult<String>.done();
        tailEmitted = true;
        if (sep != '' && chr == sep) return const IterResult.value('');
        if (sep != '' && acc.isNotEmpty) return IterResult.value(acc);
        return const IterResult<String>.done();
      }
      while (true) {
        final result = await iterator.next(concurrent);
        if (result.done) {
          sourceDone = true;
          if (tailEmitted) return const IterResult<String>.done();
          tailEmitted = true;
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
