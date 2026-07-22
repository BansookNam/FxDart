/// Tag explorer (Round 4 feature): set algebra over tag usage with
/// `intersection` / `difference`, and `pluck` + `compact` for totals.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';
import 'summaries.dart';

List<String> _tagsOfMonth(List<Entry> entries, DateTime month) => fx(entries)
    .filter((e) => sameMonth(e.date, month))
    .flatMap((e) => e.tags)
    .uniq()
    .toList();

class TagMonthComparison {
  /// Tags used in this month *and* the previous one — `intersection`.
  final List<String> shared;

  /// Tags that appear this month but not last month — `difference`.
  final List<String> fresh;

  /// Tags from last month that vanished this month — `difference` mirrored.
  final List<String> dropped;

  const TagMonthComparison(this.shared, this.fresh, this.dropped);
}

/// Pipeline: two `flatMap` → `uniq` tag sets, then `intersection` and both
/// directions of `difference`.
TagMonthComparison compareTagMonths(List<Entry> entries, DateTime month) {
  final thisMonth = _tagsOfMonth(entries, month);
  final lastMonth = _tagsOfMonth(
    entries,
    DateTime(month.year, month.month - 1),
  );
  return TagMonthComparison(
    intersection(lastMonth, thisMonth).toList(),
    difference(lastMonth, thisMonth).toList(),
    difference(thisMonth, lastMonth).toList(),
  );
}

/// Entries carrying [tag] in [month], newest first.
List<Entry> tagEntries(List<Entry> entries, String tag, DateTime month) =>
    fx(entries)
        .filter((e) => sameMonth(e.date, month) && e.tags.contains(tag))
        .sortBy((e) => -e.date.millisecondsSinceEpoch)
        .toList();

/// Money spent on [tag] in [month].
/// Pipeline: entries → field maps (non-spending entries map to a null
/// amount) → `pluck('amount')` → `compact` drops the nulls → `sum`.
double tagSpend(List<Entry> entries, String tag, DateTime month) {
  final maps = fx(tagEntries(entries, tag, month))
      .map(
        (e) => <String, double?>{
          'amount': e.type == EntryType.expense || e.type == EntryType.bill
              ? e.amount
              : null,
        },
      )
      .toList();
  return sum(compact(pluck<String, double?>('amount', maps))).toDouble();
}
