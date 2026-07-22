/// CSV import (Round 7 feature) — the round-trip partner of `export.dart`.
///
/// The showcase pipeline: `split('\n')` → `zipWithIndex` → `map(parse)` →
/// `compact` twice (once for entries, once for issues) — a row parses into
/// *either* an Entry or a line-numbered issue, and `compact` separates the
/// two streams without a single imperative loop. Per row, the header is
/// married to the cells with `zip` → `fromEntries`.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';
import 'export.dart' show csvColumns;

class ImportIssue {
  final int line; // 1-based, header = line 1
  final String message;
  const ImportIssue(this.line, this.message);

  @override
  String toString() => 'line $line: $message';
}

class ImportPreview {
  final List<Entry> entries;
  final List<ImportIssue> issues;

  /// How many parsed rows exactly match an existing entry
  /// (same title + amount + day — the `possibleDuplicates` key).
  final int duplicateCount;

  const ImportPreview(this.entries, this.issues, this.duplicateCount);
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

DateTime? _parseYmd(String s) {
  final m = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(s.trim());
  if (m == null) return null;
  return DateTime(
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
  );
}

String _dupKey(String title, double? amount, DateTime date) =>
    '$title|$amount|${date.year}-${date.month}-${date.day}';

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
}) {
  final byName = fx(categories).indexBy((c) => c.name.toLowerCase());

  // (1-based line number, raw line), blank lines dropped.
  final numbered = fx(text.split('\n'))
      .zipWithIndex()
      .map((p) => (p.$1 + 1, p.$2))
      .filter((p) => p.$2.trim().isNotEmpty)
      .toList();
  if (numbered.isEmpty) {
    return const ImportPreview([], [ImportIssue(1, 'no data')], 0);
  }

  final (headerLine, headerRaw) = numbered.first;
  if (splitCsvLine(headerRaw)?.join(',') != csvColumns.join(',')) {
    return ImportPreview(const [], [
      ImportIssue(
        headerLine,
        'header must be exactly: ${csvColumns.join(',')}',
      ),
    ], 0);
  }

  // Each data row becomes either (Entry, null) or (null, ImportIssue).
  (Entry?, ImportIssue?) parseRow(int line, String raw) {
    ImportIssue issue(String msg) => ImportIssue(line, msg);

    final cells = splitCsvLine(raw);
    if (cells == null) {
      return (null, issue('unbalanced quotes (multi-line fields unsupported)'));
    }
    if (cells.length != csvColumns.length) {
      return (
        null,
        issue('expected ${csvColumns.length} columns, got ${cells.length}'),
      );
    }

    // zip(header, cells) → fromEntries: the row as a column-keyed map.
    final row = fromEntries(fx(csvColumns).zip(cells));

    final date = _parseYmd(row['date']!);
    if (date == null) return (null, issue('bad date "${row['date']}"'));

    final type = find((EntryType t) => t.name == row['type'], EntryType.values);
    if (type == null) return (null, issue('unknown type "${row['type']}"'));

    final title = row['title']!.trim();
    if (title.isEmpty) return (null, issue('empty title'));

    double? amount;
    if (row['amount']!.trim().isNotEmpty) {
      amount = double.tryParse(row['amount']!);
      if (amount == null || amount <= 0) {
        return (null, issue('bad amount "${row['amount']}"'));
      }
    }
    if (amount == null && type != EntryType.task) {
      return (null, issue('${type.name} needs an amount'));
    }

    final category = byName[row['category']!.trim().toLowerCase()];
    if (category == null) {
      return (null, issue('unknown category "${row['category']}"'));
    }

    return (
      Entry(
        id: '$idPrefix-L$line',
        title: title,
        type: type,
        amount: amount,
        categoryId: category.id,
        tags: row['tags']!.split('|').where((t) => t.isNotEmpty).toList(),
        date: date,
        done: row['done'] == 'yes',
      ),
      null,
    );
  }

  final parsed = fx(numbered.skip(1)).map((p) => parseRow(p.$1, p.$2)).toList();

  // `compact` splits the (Entry?, ImportIssue?) stream into its two halves.
  final entries = compact(fx(parsed).map((p) => p.$1)).toList();
  final issues = compact(fx(parsed).map((p) => p.$2)).toList();

  final existingKeys = fx(
    existing,
  ).map((e) => _dupKey(e.title, e.amount, e.date)).toList().toSet();
  final duplicateCount = fx(entries)
      .filter((e) => existingKeys.contains(_dupKey(e.title, e.amount, e.date)))
      .size();

  return ImportPreview(entries, issues, duplicateCount);
}
