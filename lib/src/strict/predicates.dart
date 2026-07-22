/// Type/value predicates ported from FxTS. Several of them exist only for
/// API parity — in Dart, prefer `is` checks and pattern matching. They stay
/// useful as tear-offs for `filter`, `takeWhile`, etc.
library;

/// True when [a] is `null`.
///
/// Port of FxTS `isNull`.
bool isNull(Object? a) => a == null;

/// True when [a] is not `null`.
bool isNotNull(Object? a) => a != null;

/// Port of FxTS `isNil` (`null` or `undefined`). Dart has no `undefined`,
/// so this is exactly [isNull].
bool isNil(Object? a) => a == null;

/// TODO(port): TypeScript distinguishes `undefined` from `null`; Dart has
/// only `null`, so this cannot be ported meaningfully.
@Deprecated('Dart has no undefined; use isNull instead')
bool isUndefined(Object? a) => a == null;

/// True when [a] is a [bool]. Port of FxTS `isBoolean` (Dart type: `bool`).
bool isBool(Object? a) => a is bool;

/// FxTS-named alias of [isBool].
bool isBoolean(Object? a) => isBool(a);

/// True when [a] is a [num]. Port of FxTS `isNumber` (Dart type: `num`).
bool isNum(Object? a) => a is num;

/// FxTS-named alias of [isNum].
bool isNumber(Object? a) => isNum(a);

/// True when [a] is a [String]. Port of FxTS `isString`.
bool isString(Object? a) => a is String;

/// True when [a] is a [DateTime]. Port of FxTS `isDate` (Dart type: `DateTime`).
bool isDateTime(Object? a) => a is DateTime;

/// FxTS-named alias of [isDateTime].
bool isDate(Object? a) => isDateTime(a);

/// True when [a] is a [List]. Port of FxTS `isArray`.
bool isList(Object? a) => a is List;

/// TODO(port): JS `Array` maps to Dart [List]; kept as a deprecated alias.
@Deprecated('Use isList instead')
bool isArray(Object? a) => a is List;

/// True when [a] is a [Map]. The closest analogue of FxTS `isObject`
/// (`typeof a === "object"`), whose plain-JS-object semantics do not exist
/// in Dart.
bool isMap(Object? a) => a is Map;

/// TODO(port): JS plain objects map to Dart [Map]s; kept as a deprecated
/// alias of [isMap].
@Deprecated('Use isMap instead')
bool isObject(Object? a) => a is Map;
