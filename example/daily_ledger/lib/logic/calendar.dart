/// Calendar pipelines: the month grid is literally
/// `range` → `map` → `chunk(7)`, and day cells look entries up in a
/// `groupBy`-built index.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';

DateTime dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

/// A 6×7 grid of days covering [month], starting on Sunday.
/// Pipeline: `range(42)` → `map` (day offset → date) → `chunk(7)` (weeks).
List<List<DateTime>> monthGrid(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final leading = first.weekday % 7; // days shown before the 1st (Sun = 0)
  return fx(range(42))
      .map((i) => DateTime(first.year, first.month, 1 - leading + i))
      .chunk(7)
      .toList();
}

/// Entries indexed per calendar day. Pipeline: `groupBy` (day key).
Map<DateTime, List<Entry>> entriesByDay(List<Entry> entries) =>
    fx(entries).groupBy((e) => dayKey(e.date));

/// Net money flow for one day cell. Pipeline: `sumBy` (signed amount).
double dayNet(List<Entry> dayEntries) =>
    fx(dayEntries).sumBy((e) => e.signedAmount).toDouble();

/// Open (not-done) due items counted per day — built **once** per frame and
/// read by all 42 cells, instead of scanning all entries per cell.
/// Pipeline: `filter` (open, has due) → `countBy` (due day).
Map<DateTime, int> dueCountByDay(List<Entry> entries) => fx(entries)
    .filter((e) => !e.done && e.dueDate != null)
    .countBy((e) => dayKey(e.dueDate!));
