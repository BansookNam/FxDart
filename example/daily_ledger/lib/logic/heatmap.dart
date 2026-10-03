/// Spending heatmap (Round 2 feature).
///
/// The interesting operator here is `fxFork`: the filtered month-spending
/// pipeline is walked **once**, but consumed by two independent
/// aggregations (per-day totals and the month total) — fork shares one
/// underlying iterator and buffer between them.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';
import 'calendar.dart';
import 'summaries.dart';

class HeatmapData {
  /// Weeks of the month grid; each cell is (day, spent that day).
  final List<List<(DateTime day, double spent)>> weeks;
  final double maxDaySpend;
  final double totalSpend;
  const HeatmapData(this.weeks, this.maxDaySpend, this.totalSpend);

  /// 0..1 intensity for a cell.
  double intensity(double spent) => maxDaySpend <= 0 ? 0 : spent / maxDaySpend;
}

/// Pipeline: one lazy `filter` source → `fxFork` #1 feeds
/// `groupBy` → `sumBy` (per-day totals), `fxFork` #2 feeds `sumBy`
/// (month total) — then the `monthGrid` (`fxRange` → `chunk(7)`) is mapped
/// over the per-day index.
HeatmapData spendingHeatmap(List<Entry> entries, DateTime month) {
  final monthSpending = fxFilter(
    (Entry e) =>
        (e.type == EntryType.expense || e.type == EntryType.bill) &&
        sameMonth(e.date, month),
    entries,
  ); // lazy — not walked yet

  final perDay = {
    for (final kv in fxGroupBy(
      (Entry e) => dayKey(e.date),
      fxFork(monthSpending),
    ).entries)
      kv.key: fxSumBy((Entry e) => e.amount ?? 0, kv.value).toDouble(),
  };
  final total = fxSumBy(
    (Entry e) => e.amount ?? 0,
    fxFork(monthSpending),
  ).toDouble();

  final weeks = fx(monthGrid(month))
      .map(
        (week) => [for (final day in week) (day, perDay[dayKey(day)] ?? 0.0)],
      )
      .toList();
  final maxDay = perDay.isEmpty ? 0.0 : fx(perDay.values).max().toDouble();
  return HeatmapData(weeks, maxDay, total);
}
