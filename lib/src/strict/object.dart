import 'dart:async';

/// Builds a map from `(key, value)` records.
///
/// Port of FxTS `fromEntries` (TS entry tuples become Dart records).
///
/// ```dart
/// fromEntries([('a', 1), ('b', 2)]); // {a: 1, b: 2}
/// ```
Map<K, V> fromEntries<K, V>(Iterable<(K, V)> entries) =>
    {for (final (k, v) in entries) k: v};

/// Returns a copy of [map] without the given [keysToOmit].
///
/// Port of FxTS `omit`.
Map<K, V> omit<K, V>(Iterable<K> keysToOmit, Map<K, V> map) {
  final set = keysToOmit.toSet();
  return {
    for (final e in map.entries)
      if (!set.contains(e.key)) e.key: e.value
  };
}

/// Returns a copy of [map] with only the given [keysToPick].
///
/// Port of FxTS `pick`.
Map<K, V> pick<K, V>(Iterable<K> keysToPick, Map<K, V> map) {
  final set = keysToPick.toSet();
  return {
    for (final e in map.entries)
      if (set.contains(e.key)) e.key: e.value
  };
}

/// Returns a copy of [map] without entries matching the predicate [f].
///
/// Port of FxTS `omitBy` (entry tuples become records).
Map<K, V> omitBy<K, V>(bool Function((K, V) entry) f, Map<K, V> map) => {
      for (final e in map.entries)
        if (!f((e.key, e.value))) e.key: e.value
    };

/// Returns a copy of [map] with only entries matching the predicate [f].
///
/// Port of FxTS `pickBy`.
Map<K, V> pickBy<K, V>(bool Function((K, V) entry) f, Map<K, V> map) => {
      for (final e in map.entries)
        if (f((e.key, e.value))) e.key: e.value
    };

/// Returns the value of [key] in [map], or `null`.
///
/// Port of FxTS `prop`.
V? prop<K, V>(K key, Map<K, V> map) => map[key];

/// Returns the values of [propKeys] in [map] (missing keys yield `null`).
///
/// Port of FxTS `props`.
List<V?> props<K, V>(Iterable<K> propKeys, Map<K, V> map) =>
    [for (final k in propKeys) map[k]];

/// Returns a copy of [map] with `null` values removed (shallow).
///
/// Port of FxTS `compactObject`.
Map<K, V> compactObject<K, V>(Map<K, V?> map) => {
      for (final e in map.entries)
        if (e.value != null) e.key: e.value as V
    };

/// Creates a new map by running each value whose key appears in
/// [transformations] through its transformation function.
///
/// Port of FxTS `evolve`. Untransformed keys are kept as-is.
Map<K, Object?> evolve<K>(
    Map<K, Object? Function(Object? value)> transformations,
    Map<K, Object?> map) {
  return {
    for (final e in map.entries)
      e.key: transformations.containsKey(e.key)
          ? transformations[e.key]!(e.value)
          : e.value
  };
}

/// Awaits every value of the map — the async analogue of `Future.wait` for
/// maps.
///
/// Port of FxTS `resolveProps`.
///
/// ```dart
/// await resolveProps({'a': Future.value(1), 'b': 2}); // {a: 1, b: 2}
/// ```
Future<Map<K, V>> resolveProps<K, V>(Map<K, FutureOr<V>> map) async {
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
/// Port of FxTS `isMatch`.
bool isMatch(Object? target, Object? pattern) {
  if (pattern is Map) {
    if (target is! Map) return false;
    for (final e in pattern.entries) {
      if (!target.containsKey(e.key) || !isMatch(target[e.key], e.value)) {
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
      if (!ti.moveNext() || !isMatch(ti.current, pi.current)) return false;
    }
    // FxTS matches when the pattern is a prefix of the target.
    return true;
  }
  return target == pattern;
}

/// Curried [isMatch]: returns a predicate that matches against [pattern].
///
/// Port of FxTS `matches`.
bool Function(Object? target) matches(Object? pattern) =>
    (target) => isMatch(target, pattern);
