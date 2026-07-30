/// CSV import — the round-trip partner of `export.dart`.
///
/// Round 7 shipped this as a `(Entry?, ImportIssue?)` tuple per row, split
/// with `compact` twice. That tuple *was* an `Either` with the type system
/// switched off; round 10 (typed-errors series) makes it one for real:
///
/// ```
/// split('\n') → zipWithIndex → filter(nonEmpty)
///   → map(parseRow)                       // Either<RowError, Entry>
///   → separated() | sequence() | mapOrAccumulate()   // ← the three modes
/// ```
///
/// The three terminals in that last line are the whole point of
/// `Either × pipelines`: one row parser, three failure policies, chosen by
/// the reader — see [ImportMode].
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';
import 'errors.dart';
import 'export.dart' show csvColumns;
import 'validate.dart';

/// What should happen when a row does not parse.
///
/// Each mode is one `fx_either` terminal, and nothing else about the parse
/// changes — the same [parseRow] feeds all three.
enum ImportMode {
  /// Import the good rows, list the bad ones. Terminal: `separated()`.
  lenient,

  /// The first bad row aborts the whole import. Terminal: `sequence()`.
  strict,

  /// Import nothing; report **every** bad row, not just the first.
  /// Terminal: `mapOrAccumulate()`.
  report,
}

class ImportPreview {
  final ImportMode mode;

  /// Every data row in file order with its verdict — the render source for
  /// the dialog's row list (`fold` per row). Empty when the header itself
  /// was rejected, since no row was ever attempted.
  final List<Either<RowError, Entry>> rows;

  /// What the Import button would actually commit. In [ImportMode.strict]
  /// and [ImportMode.report] this is empty as soon as anything failed —
  /// that is the difference between the modes, made visible.
  final List<Entry> entries;

  /// Every problem found, or `null` when the file is clean.
  ///
  /// `Nel?` rather than an empty `List` on purpose: there is no such thing
  /// as an empty error panel, so absence is `null` and presence is
  /// guaranteed non-empty (`issues.head` needs no emptiness check).
  final Nel<RowError>? issues;

  /// How many rows about to be imported match an existing entry
  /// (same title + amount + day — the `possibleDuplicates` key).
  /// Duplicates import anyway; they are a warning, not a failure.
  final int duplicateCount;

  const ImportPreview({
    required this.mode,
    required this.rows,
    required this.entries,
    required this.issues,
    required this.duplicateCount,
  });

  bool get isClean => issues == null;
  int get issueCount => issues?.length ?? 0;

  /// Rows that parsed, whether or not the mode will commit them. In strict
  /// mode this is how the dialog can say "3 rows were fine, but strict mode
  /// aborts" — `sequence()` throws that information away, `rights()` keeps it.
  int get healthyCount => fx(rows).rights().length;
}

/// Splits one CSV line into cells, honoring `"quoted, cells"` and the
/// doubled-quote escape (`""` → `"`). Returns null when quotes are
/// unbalanced (e.g. a multi-line field, which this importer doesn't support).
List<String>? splitCsvLine(String line) {
  final cells = <String>[];
  final buf = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < line.length && line[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        buf.write(c);
      }
    } else if (c == '"') {
      inQuotes = true;
    } else if (c == ',') {
      cells.add(buf.toString());
      buf.clear();
    } else {
      buf.write(c);
    }
  }
  if (inQuotes) return null;
  cells.add(buf.toString());
  return cells;
}

String _dupKey(String title, double? amount, DateTime date) =>
    '$title|$amount|${date.year}-${date.month}-${date.day}';

/// Non-blank lines as `(1-based line number, raw text)`.
List<(int, String)> _numbered(String text) => fx(text.split('\n'))
    .zipWithIndex()
    .map((p) => (p.$1 + 1, p.$2))
    .filter((p) => p.$2.trim().isNotEmpty)
    .toList();

/// The header gate. Raises a [FieldError] because it is about the header's
/// *cells*; the caller stamps the line number on with `mapLeft` — the
/// scope-free counterpart to the `withError` adapter used inside [parseRow].
Either<FieldError, List<(int, String)>> _dataRows(List<(int, String)> lines) =>
    either((r) {
      r.ensure(lines.isNotEmpty, () => const FieldError('file', 'no data'));
      final cells = splitCsvLine(lines.first.$2);
      r.ensure(
        cells != null && cells.join(',') == csvColumns.join(','),
        () => FieldError('header', 'must be exactly: ${csvColumns.join(',')}'),
      );
      return lines.skip(1).toList();
    });

/// One row, **fail-fast**: the first bad field ends it.
///
/// Two error types meet here. The field validators in `validate.dart` raise
/// [FieldError]; this scope raises [RowError], which carries the line number.
/// `withError` is the adapter between them — no `catch`, no wrapper type,
/// just a change of error type at the boundary.
///
/// The outer `catching` is the sanctioned replacement for a bare `catch`
/// inside a raise scope: an unexpected throw from any parser is contained to
/// this one row instead of taking down a paste-anything dialog, while
/// fxdart's own raise signal is rethrown untouched (a bare `catch` would
/// swallow it and break every `ensure` above).
Either<RowError, Entry> parseRow(
  (int, String) numberedRow, {
  required Map<String, Category> byName,
  required String idPrefix,
}) {
  final (line, raw) = numberedRow;
  return either<RowError, Entry>(
    (r) => catching(
      // Explicit type arguments: inference does not flow from the
      // transform's parameter type here, and without them `fr` lands as
      // `Raise<Object?>`.
      () => r.withError<FieldError, Entry>((f) => RowError.one(line, f), (fr) {
        final cells = fr.ensureNotNull(
          splitCsvLine(raw),
          () => const FieldError(
            'row',
            'unbalanced quotes (multi-line fields unsupported)',
          ),
        );
        fr.ensure(
          cells.length == csvColumns.length,
          () => FieldError(
            'row',
            'expected ${csvColumns.length} columns, got ${cells.length}',
          ),
        );
        // zip(header, cells) → fromEntries: the row as a column-keyed map.
        final row = fromEntries(fx(csvColumns).zip(cells));

        // Written in column order, so the *first* bad column is the one
        // reported — fail-fast is an ordering promise, not just a count.
        final date = vDate(fr, row['date']!);
        final type = vType(fr, row['type']!);
        final title = vTitle(fr, row['title']!);
        final amount = vAmount(fr, row['amount']!, type);
        final category = vCategory(fr, row['category']!, byName);

        return Entry(
          id: '$idPrefix-L$line',
          title: title,
          type: type,
          amount: amount,
          categoryId: category.id,
          tags: parseTags(row['tags']!),
          date: date,
          done: row['done'] == 'yes',
        );
      }),
      (error, _) => r.raise(
        RowError.one(line, FieldError('row', 'could not be parsed: $error')),
      ),
    ),
  );
}

/// The structural checks every row needs before its *fields* mean anything.
///
/// They stay fail-fast even in the accumulating parser: with the wrong number
/// of cells there are no columns to report on. `AccumulatingRaise.over` is
/// the single-error view of an accumulating scope — one raise here becomes a
/// one-element `Nel`.
Map<String, String> _rowCells(Raise<Nel<FieldError>> r, String raw) {
  final single = AccumulatingRaise.over(r);
  final cells = single.ensureNotNull(
    splitCsvLine(raw),
    () => const FieldError(
      'row',
      'unbalanced quotes (multi-line fields unsupported)',
    ),
  );
  single.ensure(
    cells.length == csvColumns.length,
    () => FieldError(
      'row',
      'expected ${csvColumns.length} columns, got ${cells.length}',
    ),
  );
  return fromEntries(fx(csvColumns).zip(cells));
}

/// One row, **fail-slow**: every bad column is reported, not just the first.
///
/// Used by [ImportMode.report], whose promise is "every problem in the file"
/// — which has to mean every problem in every row.
///
/// Four of the five columns are independent, so they are plain accumulating
/// branches. The amount is not: whether it may be empty depends on the *type*
/// column. A dependent check cannot sit alongside the thing it depends on —
/// reading a sibling's [Accumulated.value] detonates with the whole error
/// list — so it runs afterwards, guarded by `acc.hasErrors`.
Either<RowError, Entry> parseRowAll(
  (int, String) numberedRow, {
  required Map<String, Category> byName,
  required String idPrefix,
}) {
  final (line, raw) = numberedRow;
  return either<RowError, Entry>(
    (r) => catching(
      () => r.withError<Nel<FieldError>, Entry>(
        (fields) => RowError(line, fields),
        (fr) {
          final row = _rowCells(fr, raw);
          return fr.accumulate((acc) {
            final date = acc.accumulating((br) => vDate(br, row['date']!));
            final type = acc.accumulating((br) => vType(br, row['type']!));
            final title = acc.accumulating((br) => vTitle(br, row['title']!));
            final category = acc.accumulating(
              (br) => vCategory(br, row['category']!, byName),
            );
            final amount = acc.accumulating(
              (br) => vAmountValue(br, row['amount']!),
            );

            // The dependent rule. Only safe to read `.value` once every
            // branch above succeeded.
            if (!acc.hasErrors) {
              acc.accumulating(
                (br) => vAmountRequired(br, amount.value, type.value),
              );
            }

            // Every `.value` read below detonates with the FULL accumulated
            // list if anything failed — and `accumulate` raises at
            // end-of-block regardless, so nothing can slip through.
            return Entry(
              id: '$idPrefix-L$line',
              title: title.value,
              type: type.value,
              amount: amount.value,
              categoryId: category.value.id,
              tags: parseTags(row['tags']!),
              date: date.value,
              done: row['done'] == 'yes',
            );
          });
        },
      ),
      (error, _) => r.raise(
        RowError.one(line, FieldError('row', 'could not be parsed: $error')),
      ),
    ),
  );
}

/// Parses [text] (the format `entriesToCsv` writes) into an [ImportPreview].
///
/// Pure and deterministic: imported ids are `'$idPrefix-L<line>'`, so tests
/// can pin them. [categories] is the live category list; rows name
/// categories the way export does (display name, case-insensitive).
ImportPreview parseCsvEntries(
  String text, {
  required List<Category> categories,
  required List<Entry> existing,
  required String idPrefix,
  ImportMode mode = ImportMode.lenient,
}) {
  final lines = _numbered(text);
  final headerLine = lines.isEmpty ? 1 : lines.first.$1;

  // `mapLeft` re-types the failure without opening a scope: the header check
  // knows the *cell* that is wrong, the caller knows the *line* it was on.
  final dataRows = _dataRows(lines).mapLeft((f) => RowError.one(headerLine, f));

  ImportPreview headerRejected(RowError error) => ImportPreview(
    mode: mode,
    rows: const [],
    entries: const [],
    issues: Nel.of(error),
    duplicateCount: 0,
  );

  // Sealed + exhaustive: no `default` arm, and a new Either case would be a
  // compile error here rather than a silent fall-through.
  final List<(int, String)> rowsToParse;
  switch (dataRows) {
    case Left(:final value):
      return headerRejected(value);
    case Right(:final value):
      rowsToParse = value;
  }

  final byName = categoryIndex(categories);
  // Report mode is fail-slow all the way down: fail-slow across rows AND
  // inside each row. The other two modes stop at the first bad column.
  final parse = mode == ImportMode.report ? parseRowAll : parseRow;
  final verdicts = fx(
    rowsToParse,
  ).map((row) => parse(row, byName: byName, idPrefix: idPrefix)).toList();

  // One parser, three terminals — the entire difference between the modes.
  final List<Entry> committed;
  final List<RowError> problems;
  switch (mode) {
    case ImportMode.lenient:
      // `separated()` is `partition` for Either: (lefts, rights) in one walk.
      final (bad, good) = fx(verdicts).separated();
      committed = good;
      problems = bad;

    case ImportMode.strict:
      // `sequence()` stops at the first Left and yields nothing else.
      final result = fx(verdicts).sequence();
      committed = result.getOrElse((_) => const []);
      problems = [?result.leftOrNull()];

    case ImportMode.report:
      // `mapOrAccumulate` keeps walking after a failure, so the report is
      // every bad row rather than the first. (Round 11 makes each row
      // fail-slow internally too, via zipOrAccumulate5.)
      final result = fx(
        verdicts,
      ).mapOrAccumulate<RowError, Entry>((r, verdict) => r.bind(verdict));
      committed = result.getOrElse((_) => const []);
      problems = result.leftOrNull()?.toList() ?? const [];
  }

  final existingKeys = fx(
    existing,
  ).map((e) => _dupKey(e.title, e.amount, e.date)).toList().toSet();
  final duplicateCount = fx(committed)
      .filter((e) => existingKeys.contains(_dupKey(e.title, e.amount, e.date)))
      .size();

  return ImportPreview(
    mode: mode,
    rows: verdicts,
    entries: committed,
    // `Nel.orNull` is the bridge from "a list the pipeline accumulated" to
    // "an error panel, or none at all".
    issues: Nel.orNull(problems),
    duplicateCount: duplicateCount,
  );
}
