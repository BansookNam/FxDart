/// Internal plumbing that lets operators recognise when an upstream lazy
/// iterable is nothing more than a contiguous range of a backing [List], and
/// index that list directly instead of pulling values through a chain of
/// iterators.
///
/// Nothing here is exported from `package:fxdart` — it is an implementation
/// detail shared by `take_drop.dart` and `zip.dart`. The names carry an `Fx`
/// prefix (rather than `_`) only because Dart privacy is per-file and the web
/// playground bundle concatenates every source file into one library, so
/// cross-file internals must still have unique top-level names.
library;

/// A contiguous `[start, end)` range of [list].
///
/// Resolved once, when an iterator is created — never per element.
class FxListRange<A> {
  const FxListRange(this.list, this.start, this.end);

  final List<A> list;
  final int start;
  final int end;

  int get length => end - start;
}

/// Implemented by lazy iterables that are *sometimes* a plain range over a
/// [List] — `take`, `drop`, `takeRight`, `dropRight` are, as long as whatever
/// they wrap is one too.
abstract class FxListRangeSource<A> {
  /// The range this iterable covers, or null when the ultimate source is not
  /// a [List] (a generator, a `map`, a `Set`, …) and must be pulled instead.
  FxListRange<A>? get listRange;
}

/// [iterable] viewed as a range over a backing [List], or null if it is not
/// one.
///
/// Indexing that list is faster than iterating it — one bounds check per
/// element instead of a virtual `moveNext` per pipeline layer plus the growth
/// guard `List`'s own iterator performs. The trade-off, already made by
/// `takeRight`/`dropRight`, is that a source mutated *during* iteration is not
/// reported as a `ConcurrentModificationError`; the range's bounds are those
/// the list had when iteration started.
FxListRange<A>? fxListRangeOf<A>(Iterable<A> iterable) {
  if (iterable is List<A>) return FxListRange(iterable, 0, iterable.length);
  if (iterable is FxListRangeSource<A>) {
    return (iterable as FxListRangeSource<A>).listRange;
  }
  return null;
}

/// Walks `list[start..end)` by index.
class FxListRangeIterator<A> implements Iterator<A> {
  FxListRangeIterator(this._list, this._i, this._end);
  final List<A> _list;
  int _i;
  final int _end;
  @override
  late A current;
  @override
  bool moveNext() {
    if (_i >= _end) return false;
    current = _list[_i++];
    return true;
  }
}
