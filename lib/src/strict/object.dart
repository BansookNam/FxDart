import 'dart:async';

/// Builds a map from `(key, value)` records.
///
/// Port of FxTS `fxFromEntries` (TS entry tuples become Dart records).
///
/// ```dart
/// fxFromEntries([('a', 1), ('b', 2)]); // {a: 1, b: 2}
/// ```
Map<K, V> fxFromEntries<K, V>(Iterable<(K, V)> entries) => {
  for (final (k, v) in entries) k: v,
};

/// The `(key, value)` records of [map], in the map's own iteration order —
/// the inverse of [fxFromEntries], and the chain *entrance* for anything a
/// `Map`-returning operator produced.
///
/// `groupBy`, `countBy`, `foldBy` and `indexBy` all end a chain with a
/// `Map`. Continuing (ranking, formatting) means re-entering with
/// `fx(m.entries)` and then converting `MapEntry` back into the record shape
/// the rest of fxdart speaks; `fx(fxToPairs(m))` is both steps at once.
///
/// Lazy: this is a view over `Map.entries`, so nothing is copied. Mutations
/// made before iteration begins are reflected; structural mutation during
/// active iteration may throw [ConcurrentModificationError].
///
/// No `*Async` twin, and that is this file's convention rather than an
/// omission: no function in `object.dart` has one, because a `Map` argument
/// is already fully materialized — there is nothing to await.
///
/// Port of Lodash `fxToPairs` (FxTS `fxEntries`, Kotlin `Map.toList()`). Named
/// `fxToPairs`, not `fxEntries`, because fxdart's barrel exports every top-level
/// name unprefixed and `fxEntries` is a common local variable name.
///
/// ```dart
/// fx(fxToPairs(fxGroupBy(f, xs))).sortByDesc((p) => p.$2.length);
/// ```
Iterable<(K, V)> fxToPairs<K, V>(Map<K, V> map) =>
    map.entries.map((e) => (e.key, e.value));

/// Returns a copy of [map] without the given [keysToOmit].
///
/// Port of FxTS `fxOmit`.
Map<K, V> fxOmit<K, V>(Iterable<K> keysToOmit, Map<K, V> map) {
  final set = keysToOmit.toSet();
  return {
    for (final e in map.entries)
      if (!set.contains(e.key)) e.key: e.value,
  };
}

/// Returns a copy of [map] with only the given [keysToPick].
///
/// Port of FxTS `fxPick`.
Map<K, V> fxPick<K, V>(Iterable<K> keysToPick, Map<K, V> map) {
  final set = keysToPick.toSet();
  return {
    for (final e in map.entries)
      if (set.contains(e.key)) e.key: e.value,
  };
}

/// Returns a copy of [map] with every value run through [f]; keys are
/// untouched.
///
/// Not an FxTS port — TS spreads entries through `Object.fromEntries`, which
/// in Dart is [fxFromEntries] over [fxMapEntries] and reads worse than the thing
/// it does. Insertion order is preserved.
///
/// ```dart
/// fxMapValues((n) => n * 2, {'a': 1, 'b': 2}); // {a: 2, b: 4}
/// ```
Map<K, T> fxMapValues<K, V, T>(T Function(V value) f, Map<K, V> map) => {
  for (final e in map.entries) e.key: f(e.value),
};

/// Returns a copy of [map] with every key run through [f]; values are
/// untouched.
///
/// [f] is not required to be injective: when two keys collide, the **last**
/// one in iteration order wins, as it would in a map literal. Insertion order
/// follows the first appearance of each new key.
///
/// ```dart
/// fxMapKeys((k) => k.toUpperCase(), {'a': 1, 'b': 2}); // {A: 1, B: 2}
/// ```
Map<T, V> fxMapKeys<K, V, T>(T Function(K key) f, Map<K, V> map) => {
  for (final e in map.entries) f(e.key): e.value,
};

/// Returns a new map built by running each `(key, value)` record through [f]
/// — the general form of [fxMapValues] and [fxMapKeys], and the transforming
/// counterpart of [fxPickBy].
///
/// Colliding results follow the same last-one-wins rule as [fxMapKeys].
///
/// ```dart
/// fxMapEntries((e) => (e.$1.toUpperCase(), e.$2 * 2), {'a': 1});
/// // {A: 2}
/// ```
Map<K2, V2> fxMapEntries<K, V, K2, V2>(
  (K2, V2) Function((K, V) entry) f,
  Map<K, V> map,
) {
  final out = <K2, V2>{};
  for (final e in map.entries) {
    final (k, v) = f((e.key, e.value));
    out[k] = v;
  }
  return out;
}

/// Returns a copy of [map] without entries matching the predicate [f].
///
/// Port of FxTS `fxOmitBy` (entry tuples become records).
Map<K, V> fxOmitBy<K, V>(bool Function((K, V) entry) f, Map<K, V> map) => {
  for (final e in map.entries)
    if (!f((e.key, e.value))) e.key: e.value,
};

/// Returns a copy of [map] with only entries matching the predicate [f].
///
/// Port of FxTS `fxPickBy`. Together with [fxOmitBy] this is the key-aware map
/// filter; the predicate takes the whole `(key, value)` record, so ignoring
/// one half is how you filter by the other.
///
/// ```dart
/// fxPickBy((e) => e.$2 > 1, {'a': 1, 'b': 2});      // by value  -> {b: 2}
/// fxPickBy((e) => e.$1.startsWith('a'), {'a': 1});  // by key    -> {a: 1}
/// ```
Map<K, V> fxPickBy<K, V>(bool Function((K, V) entry) f, Map<K, V> map) => {
  for (final e in map.entries)
    if (f((e.key, e.value))) e.key: e.value,
};

/// Returns the value of [key] in [map], or `null`.
///
/// Port of FxTS `fxProp`.
V? fxProp<K, V>(K key, Map<K, V> map) => map[key];

/// Returns the values of [propKeys] in [map] (missing keys yield `null`).
///
/// Port of FxTS `fxProps`.
List<V?> fxProps<K, V>(Iterable<K> propKeys, Map<K, V> map) => [
  for (final k in propKeys) map[k],
];

/// Returns a copy of [map] with `null` values removed (shallow).
///
/// Port of FxTS `fxCompactObject`.
Map<K, V> fxCompactObject<K, V>(Map<K, V?> map) => {
  for (final e in map.entries) e.key: ?e.value,
};

/// Creates a new map by running each value whose key appears in
/// [transformations] through its transformation function.
///
/// Port of FxTS `fxEvolve`. Untransformed keys are kept as-is.
Map<K, Object?> fxEvolve<K>(
  Map<K, Object? Function(Object? value)> transformations,
  Map<K, Object?> map,
) {
  return {
    for (final e in map.entries)
      e.key: transformations.containsKey(e.key)
          ? transformations[e.key]!(e.value)
          : e.value,
  };
}

/// Awaits every value of the map — the async analogue of `Future.wait` for
/// maps.
///
/// Port of FxTS `fxResolveProps`.
///
/// ```dart
/// await fxResolveProps({'a': Future.value(1), 'b': 2}); // {a: 1, b: 2}
/// ```
Future<Map<K, V>> fxResolveProps<K, V>(Map<K, FutureOr<V>> map) async {
  final result = <K, V>{};
  for (final e in map.entries) {
    result[e.key] = await e.value;
  }
  return result;
}

/// Deep partial match: checks whether [target] contains everything in
/// [pattern]. Maps match when every pattern entry matches recursively;
/// iterables match pairwise; anything else compares with `==`.
///
/// Port of FxTS `fxIsMatch`.
bool fxIsMatch(Object? target, Object? pattern) {
  if (pattern is Map) {
    if (target is! Map) return false;
    for (final e in pattern.entries) {
      if (!target.containsKey(e.key) || !fxIsMatch(target[e.key], e.value)) {
        return false;
      }
    }
    return true;
  }
  if (pattern is Iterable) {
    if (target is! Iterable) return false;
    final ti = target.iterator;
    final pi = pattern.iterator;
    while (pi.moveNext()) {
      if (!ti.moveNext() || !fxIsMatch(ti.current, pi.current)) return false;
    }
    // FxTS matches when the pattern is a prefix of the target.
    return true;
  }
  return target == pattern;
}

/// Curried [fxIsMatch]: returns a predicate that matches against [pattern].
///
/// Port of FxTS `fxMatches`.
bool Function(Object? target) fxMatches(Object? pattern) =>
    (target) => fxIsMatch(target, pattern);
