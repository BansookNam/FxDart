/// Spending heatmap (Round 2 feature).
///
/// The interesting operator here is `fork`: the filtered month-spending
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

/// Pipeline: one lazy `filter` source → `fork` #1 feeds
/// `groupBy` → `sumBy` (per-day totals), `fork` #2 feeds `sumBy`
/// (month total) — then the `monthGrid` (`range` → `chunk(7)`) is mapped
/// over the per-day index.
HeatmapData spendingHeatmap(List<Entry> entries, DateTime month) {
  final monthSpending = filter(
    (Entry e) =>
        (e.type == EntryType.expense || e.type == EntryType.bill) &&
        sameMonth(e.date, month),
    entries,
  ); // lazy — not walked yet

  final perDay = {
    for (final kv in groupBy(
      (Entry e) => dayKey(e.date),
      fork(monthSpending),
    ).entries)
      kv.key: sumBy((Entry e) => e.amount ?? 0, kv.value).toDouble(),
  };
  final total = sumBy(
    (Entry e) => e.amount ?? 0,
    fork(monthSpending),
  ).toDouble();

  final weeks = fx(monthGrid(month))
      .map(
        (week) => [for (final day in week) (day, perDay[dayKey(day)] ?? 0.0)],
      )
      .toList();
  final maxDay = perDay.isEmpty ? 0.0 : fx(perDay.values).max().toDouble();
  return HeatmapData(weeks, maxDay, total);
}
