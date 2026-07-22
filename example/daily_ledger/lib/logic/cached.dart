/// Memoized variants of the hottest pipelines (Round 3).
///
/// The pattern is **nested `memoize`**: the outer function is keyed by the
/// entries list *instance* (LedgerState swaps in a new list on every data
/// change, so identity is a correct cache key), and it returns an inner
/// memoized function keyed by month. Rebuilds hit the cache; a data change
/// naturally misses it.
///
/// Trade-off (fine for an app-lifetime of edits, documented on purpose):
/// `memoize` caches are unbounded, so superseded entry lists keep their
/// inner caches alive until the outer map is GC'd with the state.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';
import 'heatmap.dart';
import 'stats.dart';
import 'summaries.dart';

final MonthSummary Function(DateTime) Function(List<Entry>) cachedMonthSummary =
    memoize((entries) => memoize((month) => monthSummary(entries, month)));

final List<CategoryTotal> Function(DateTime) Function(List<Entry>)
    cachedBreakdown =
    memoize((entries) => memoize((month) => categoryBreakdown(entries, month)));

final List<BalancePoint> Function(DateTime) Function(List<Entry>)
    cachedBalance =
    memoize((entries) => memoize((month) => runningBalance(entries, month)));

final HeatmapData Function(DateTime) Function(List<Entry>) cachedHeatmap =
    memoize((entries) => memoize((month) => spendingHeatmap(entries, month)));

final List<(String, String)> Function(DateTime) Function(List<Entry>)
    cachedQuickStats =
    memoize((entries) => memoize((month) => quickStats(entries, month)));
