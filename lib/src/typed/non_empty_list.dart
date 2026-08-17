/// Shorthand for [NonEmptyList] (port of Arrow's `Nel` alias).
typedef Nel<T> = NonEmptyList<T>;

/// A list statically guaranteed to hold at least one element — the error
/// carrier of the accumulation API (port of Arrow's `NonEmptyList`, which is
/// a `value class`; the Dart analogue is an extension type: zero allocation,
/// erased at runtime).
///
/// The win over `Iterable` is *cannot-throw*: [head] and `first` cannot hit
/// an empty receiver. (Dart's `Iterable.first` is already non-nullable — it
/// just throws on empty.)
///
/// **The invariant is compile-time discipline, not a runtime guarantee**:
/// extension types erase to their representation, so `<int>[] is Nel<int>`
/// is `true` and `<int>[] as Nel<int>` *succeeds — even for the empty list*.
/// Constructors ([NonEmptyList.of], [orNull]) are the only sanctioned entry
/// points; casts bypass the invariant at your own risk.
///
/// `==` is identity (delegates to `List.==`); use [deepEquals] for a
/// structural comparison.
extension type NonEmptyList<T>._(List<T> _all) implements Iterable<T> {
  /// A non-empty list of [head] followed by [tail].
  factory NonEmptyList.of(T head, [Iterable<T> tail = const []]) =>
      NonEmptyList._([head, ...tail]);

  /// Copies [list] into a [NonEmptyList], or `null` when it is empty.
  static NonEmptyList<T>? orNull<T>(List<T> list) =>
      list.isEmpty ? null : NonEmptyList._(List.of(list));

  /// The first element — total, cannot throw.
  T get head => _all.first;

  /// Everything after [head]; possibly empty.
  List<T> get tail => _all.sublist(1);

  /// Transforms every element; non-emptiness is preserved in the type.
  // ignore: annotate_redeclares
  NonEmptyList<R> map<R>(R Function(T element) f) =>
      NonEmptyList._([for (final e in _all) f(e)]);

  /// Concatenation — non-empty + non-empty is trivially non-empty.
  NonEmptyList<T> operator +(NonEmptyList<T> other) =>
      NonEmptyList._([..._all, ...other._all]);

  /// Element-wise equality (extension types cannot override `==`, which
  /// stays identity via the underlying `List`).
  bool deepEquals(NonEmptyList<T> other) {
    if (_all.length != other._all.length) return false;
    for (var i = 0; i < _all.length; i++) {
      if (_all[i] != other._all[i]) return false;
    }
    return true;
  }

  /// A defensive copy as a plain [List].
  // ignore: annotate_redeclares
  List<T> toList({bool growable = true}) => List.of(_all, growable: growable);
}

/// The bridge from plain iterables into the [NonEmptyList] world.
extension IterableToNel<T> on Iterable<T> {
  /// Copies this iterable into a [NonEmptyList], or `null` when it is
  /// empty — the `Iterable`-friendly form of [NonEmptyList.orNull] (port of
  /// Arrow's `toNonEmptyListOrNull`), so accumulated error lists need no
  /// `.toList()` shuffle first.
  NonEmptyList<T>? toNelOrNull() {
    final copy = List.of(this);
    return copy.isEmpty ? null : NonEmptyList._(copy);
  }
}
