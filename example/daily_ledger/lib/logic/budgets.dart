/// Budget pipelines (Round 1 feature).
/// Spending per category is a `groupBy` → `fold`; budget suggestions run the
/// averages map through `evolve`.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';
import 'summaries.dart';

class BudgetStatus {
  final String categoryId;
  final double budget;
  final double spent;
  const BudgetStatus(this.categoryId, this.budget, this.spent);

  double get remaining => budget - spent;
  double get ratio => budget <= 0 ? 0 : spent / budget;
  bool get over => spent > budget;
}

bool _isSpending(Entry e) =>
    e.type == EntryType.expense || e.type == EntryType.bill;

/// Total spent per category in [month].
/// Pipeline: `filter` → `groupBy` (category) → `fold` each group →
/// `fromEntries` reassembles the map.
Map<String, double> spentByCategory(List<Entry> entries, DateTime month) {
  final groups = fx(entries)
      .filter((e) => _isSpending(e) && sameMonth(e.date, month))
      .groupBy((e) => e.categoryId);
  return fromEntries(
    fx(groups.entries).map(
      (kv) => (
        kv.key,
        fold(0.0, (double acc, Entry e) => acc + (e.amount ?? 0), kv.value),
      ),
    ),
  );
}

/// One status row per budgeted category, most-stressed budget first.
/// Pipeline: [spentByCategory] → `map` (join with budgets) → `sortBy` (-ratio).
List<BudgetStatus> budgetStatuses(
  List<Entry> entries,
  Map<String, double> budgets,
  DateTime month,
) {
  final spent = spentByCategory(entries, month);
  return fx(budgets.entries)
      .map((kv) => BudgetStatus(kv.key, kv.value, spent[kv.key] ?? 0))
      .sortBy((b) => -b.ratio)
      .toList();
}

/// Suggests budgets from the average spend of the [months] months before
/// [month]: the per-category average map is run through `evolve`, which
/// transforms every value to "average + 10% headroom, rounded up to \$10".
Map<String, double> suggestedBudgets(
  List<Entry> entries,
  DateTime month, {
  int months = 3,
}) {
  final perMonthSpend = fx(range(1, months + 1))
      .map(
        (back) =>
            spentByCategory(entries, DateTime(month.year, month.month - back)),
      )
      .toList();
  final averages = fromEntries<String, Object?>(
    fx(perMonthSpend)
        .flatMap((m) => m.keys)
        .uniq()
        .map(
          (categoryId) => (
            categoryId,
            fx(perMonthSpend).map((m) => m[categoryId] ?? 0.0).average(),
          ),
        ),
  );
  // Round to cents before ceiling so float noise (200 * 1.1 =
  // 220.00000000000003) cannot bump the suggestion a whole $10 step up.
  double headroom(Object? avg) =>
      ((((avg as double) * 1.1 * 100).round()) / 1000).ceil() * 10.0;
  return evolve({
    for (final k in averages.keys) k: headroom,
  }, averages).cast<String, double>();
}
