/// Quick stats + recent activity (Round 3 features; Round 5 upgraded the
/// "biggest expense" stat from `sortBy → head` — an O(n log n) sort for a
/// maximum — to fxdart's new `maxBy`, added to the library for exactly this
/// shape).
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';
import 'format.dart';
import 'summaries.dart';

bool _isSpending(Entry e) =>
    e.type == EntryType.expense || e.type == EntryType.bill;

/// Four at-a-glance stats for the dashboard header.
///
/// `juxt` is the star: one list of stat functions, applied to the same
/// month slice in a single call — adding a stat is adding a lambda.
List<(String label, String value)> quickStats(
  List<Entry> entries,
  DateTime month,
) {
  final inMonth = fx(entries).filter((e) => sameMonth(e.date, month)).toList();

  final stats = juxt<List<Entry>, (String, String)>([
    (es) {
      // `maxBy`: the element with the largest key, one O(n) walk — no sort.
      final top = fx(es).filter(_isSpending).maxBy((e) => e.amount ?? 0);
      return (
        'Biggest expense',
        top == null ? '—' : '${top.title} · ${money(top.amount ?? 0)}',
      );
    },
    (es) {
      final busiest = maxBy(
        (kv) => kv.value,
        fx(es).countBy((e) => e.date.day).entries,
      );
      return (
        'Busiest day',
        busiest == null ? '—' : 'Day ${busiest.key} · ${busiest.value} entries',
      );
    },
    (es) {
      final spend = fx(
        es,
      ).filter(_isSpending).map((e) => e.amount ?? 0.0).toList();
      // Denominator: days that actually had spending — counting task-only
      // days would understate what a spending day really costs.
      final days = fx(es).filter(_isSpending).uniqBy((e) => e.date.day).size();
      return (
        'Avg daily spend',
        spend.isEmpty || days == 0
            ? '—'
            : money(fx(spend).sum().toDouble() / days),
      );
    },
    (es) {
      final open = fx(es).filter((e) => !e.done && e.dueDate != null).size();
      return ('Open due items', open == 0 ? 'none' : '$open');
    },
  ]);

  return stats(inMonth);
}

/// The [count] most recently dated entries, newest first.
/// Pipeline: `sortBy` (date) → `takeRight` → `reverse`.
List<Entry> recentActivity(List<Entry> entries, {int count = 8}) =>
    fx(entries).sortBy((e) => e.date).takeRight(count).reverse().toList();
