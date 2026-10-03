/// Memoized variants of the hottest pipelines (Round 3).
///
/// The pattern is **nested `fxMemoize`**: the outer function is keyed by the
/// entries list *instance* (LedgerState swaps in a new list on every data
/// change, so identity is a correct cache key), and it returns an inner
/// memoized function keyed by month. Rebuilds hit the cache; a data change
/// naturally misses it.
///
/// Trade-off (fine for an app-lifetime of edits, documented on purpose):
/// `fxMemoize` caches are unbounded, so superseded entry lists keep their
/// inner caches alive until the outer map is GC'd with the state.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';
import 'calendar.dart';
import 'forecast.dart';
import 'heatmap.dart';
import 'recurrence.dart';
import 'stats.dart';
import 'summaries.dart';
import 'weekday.dart';

final MonthSummary Function(DateTime) Function(List<Entry>) cachedMonthSummary =
    fxMemoize((entries) => fxMemoize((month) => monthSummary(entries, month)));

final List<CategoryTotal> Function(DateTime) Function(List<Entry>)
cachedBreakdown = fxMemoize(
  (entries) => fxMemoize((month) => categoryBreakdown(entries, month)),
);

final List<BalancePoint> Function(DateTime) Function(List<Entry>)
cachedBalance = fxMemoize(
  (entries) => fxMemoize((month) => runningBalance(entries, month)),
);

final HeatmapData Function(DateTime) Function(List<Entry>) cachedHeatmap =
    fxMemoize((entries) => fxMemoize((month) => spendingHeatmap(entries, month)));

final List<(String, String)> Function(DateTime) Function(List<Entry>)
cachedQuickStats = fxMemoize(
  (entries) => fxMemoize((month) => quickStats(entries, month)),
);

// The calendar indexes take no month argument, so a single memoize keyed by
// the entries list instance is the whole cache (Round 7).
final Map<DateTime, List<Entry>> Function(List<Entry>) cachedEntriesByDay =
    fxMemoize(entriesByDay);

final Map<DateTime, int> Function(List<Entry>) cachedDueCountByDay = fxMemoize(
  dueCountByDay,
);

final List<WeekdayStat> Function(DateTime) Function(List<Entry>)
cachedWeekdayProfile = fxMemoize(
  (entries) => fxMemoize((month) => weekdayProfile(entries, month)),
);

// Round 9: the remaining per-rebuild Insights pipelines join the family.
final List<MonthTrendPoint> Function(DateTime) Function(List<Entry>)
cachedTrend = fxMemoize(
  (entries) => fxMemoize((month) => monthlyTrend(entries, month)),
);

final List<(String, int)> Function(List<Entry>) cachedTagStats = fxMemoize(
  tagStats,
);

final List<Entry> Function(List<Entry>) cachedDuplicates = fxMemoize(
  possibleDuplicates,
);

final List<Entry> Function((DateTime, DateTime)) Function(List<RecurringRule>)
Function(List<Entry>)
cachedProjected = fxMemoize(
  (entries) => fxMemoize(
    (rules) => fxMemoize(
      ((DateTime, DateTime) key) => projectAll(rules, entries, key.$1, key.$2),
    ),
  ),
);

// Triple-nested memoize (Round 8): entries → rules → (month, today) record.
// Records key the inner cache by value, so a new day naturally misses.
final Forecast Function((DateTime, DateTime)) Function(List<RecurringRule>)
Function(List<Entry>)
cachedForecast = fxMemoize(
  (entries) => fxMemoize(
    (rules) => fxMemoize(
      ((DateTime, DateTime) key) =>
          monthForecast(entries, rules, key.$1, key.$2),
    ),
  ),
);
