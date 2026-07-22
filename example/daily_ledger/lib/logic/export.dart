/// CSV export (Round 2 feature).
/// Entries become maps, `pick` keeps the exported columns, and rows are
/// `map` → `join`ed into the final text — string building as a pipeline.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';

const csvColumns = [
  'date',
  'type',
  'title',
  'category',
  'amount',
  'tags',
  'done',
];

String _ymd(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _escape(Object? value) {
  final s = value?.toString() ?? '';
  return s.contains(RegExp(r'[",\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
}

/// Pipeline: `sortBy` (date) → `map` (entry → full field map) → `map`
/// (`pick` the exported columns) → `map` (escape + `join` cells) — then the
/// header is `prepend`ed and everything joins with newlines.
String entriesToCsv(
  List<Entry> entries, {
  Map<String, Category> categories = const {},
}) {
  final rows = fx(entries)
      .sortBy((e) => e.date)
      .map((e) {
        final full = <String, Object?>{
          'id': e.id, // present in the map, dropped by pick below
          'date': _ymd(e.date),
          'type': e.type.name,
          'title': e.title,
          'category': categories[e.categoryId]?.name ?? e.categoryId,
          'amount': e.amount?.toStringAsFixed(2) ?? '',
          'tags': e.tags.join('|'),
          'done': e.done ? 'yes' : 'no',
          'dueDate': e.dueDate == null ? '' : _ymd(e.dueDate!),
        };
        return pick(csvColumns, full);
      })
      .map(
        (row) => fx(csvColumns).map((c) => _escape(row[c])).toList().join(','),
      );

  return fx(rows).prepend(csvColumns.join(',')).toList().join('\n');
}
