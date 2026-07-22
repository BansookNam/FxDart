/// Cashflow forecast (Round 8 feature): the running-balance `scan` extended
/// through the projected recurring entries — real and ghost entries meet in
/// one `concat` and flow through the same pipeline.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';
import 'recurrence.dart';
import 'summaries.dart';

class Forecast {
  /// Balance curve over the whole month, date-sorted: history flows
  /// straight into the projected future.
  final List<BalancePoint> points;

  /// Index of the first point dated after today — the history/future
  /// boundary the sparkline draws differently. Equals `points.length`
  /// when nothing lies in the future (e.g. a past month).
  final int projectedFrom;

  /// Signed sum of the projected (ghost) entries only.
  final double projectedNet;

  /// How many ghost entries the projection contributed.
  final int ghostCount;

  const Forecast(
    this.points,
    this.projectedFrom,
    this.projectedNet,
    this.ghostCount,
  );

  bool get hasProjection => projectedFrom < points.length;
  double get endBalance => points.isEmpty ? 0 : points.last.balance;
}

/// Pipeline: actual = `filter` (month, money); ghosts = [projectAll]
/// (from today, through month end) → `filter` (money, in month);
/// curve = **`concat`(actual, ghosts)** → `sortBy` (date) → `scan` (running
/// signed sum). For a past month the ghost list is empty and the forecast
/// degenerates to the plain running balance — same pipeline, no branches.
Forecast monthForecast(
  List<Entry> entries,
  List<RecurringRule> rules,
  DateTime month,
  DateTime today,
) {
  final actual = fx(
    entries,
  ).filter((e) => e.type.isMoney && sameMonth(e.date, month)).toList();

  // Horizon: the last day of the viewed month, inclusive.
  final horizon = DateTime(month.year, month.month + 1, 0);
  final ghosts = fx(
    projectAll(rules, entries, today, horizon),
  ).filter((e) => e.type.isMoney && sameMonth(e.date, month)).toList();

  final points = fx(concat(actual, ghosts))
      .sortBy((e) => e.date)
      .scan(
        (acc, e) => BalancePoint(e.date, acc.balance + e.signedAmount),
        BalancePoint(DateTime(month.year, month.month), 0),
      )
      .drop(1) // the seed point
      .toList();

  final day0 = DateTime(today.year, today.month, today.day);
  final projectedFrom = fx(points).findIndex((p) => p.date.isAfter(day0));

  return Forecast(
    points,
    projectedFrom < 0 ? points.length : projectedFrom,
    fx(ghosts).sumBy((e) => e.signedAmount).toDouble(),
    ghosts.length,
  );
}
