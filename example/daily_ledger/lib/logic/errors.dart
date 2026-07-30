/// The app's failure vocabulary (typed-errors series, round 10).
///
/// One sealed family, so every renderer is exhaustive: adding a failure mode
/// becomes a compile error at each `switch`, not a runtime surprise. This is
/// the whole reason the app moved off `(T?, Issue?)` tuples and
/// `FormState.validate()` — see `TYPED_ERRORS_PLAN.md`.
library;

import 'package:fxdart/fxdart.dart';

sealed class LedgerError {
  const LedgerError();

  /// One line, ready to render. Every subclass owns its own phrasing.
  String get message;
}

/// One bad field of one draft or row — the atom of accumulation.
///
/// Value equality on purpose: tests assert the *exact* accumulated list, and
/// branch order is part of the contract.
final class FieldError extends LedgerError {
  /// Which field: `'amount'`, `'date'`, `'category'`, … or `'row'`/`'header'`
  /// for problems that belong to the whole line.
  final String field;
  final String detail;

  const FieldError(this.field, this.detail);

  @override
  String get message => '$field: $detail';

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      other is FieldError && other.field == field && other.detail == detail;

  @override
  int get hashCode => Object.hash(field, detail);
}

/// One bad CSV row, carrying **every** bad field on it.
///
/// `Nel` (not `List`) is the point: a row error with no field errors is not a
/// thing, so [fields] cannot be empty and [ErrorPanel]-style renderers can
/// call `head` without an emptiness check.
final class RowError extends LedgerError {
  /// 1-based, matching the pasted text; the header is line 1.
  final int line;
  final Nel<FieldError> fields;

  const RowError(this.line, this.fields);

  /// Convenience for the common single-field case.
  factory RowError.one(int line, FieldError field) =>
      RowError(line, Nel.of(field));

  @override
  String get message =>
      'line $line — ${fields.map((f) => f.message).join(', ')}';

  @override
  String toString() => message;
}
