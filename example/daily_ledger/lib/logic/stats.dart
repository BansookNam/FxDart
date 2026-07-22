/// Quick stats + recent activity (Round 3 features).
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';
import 'summaries.dart';

String _money(double v) => '\$${v.toStringAsFixed(2)}';

/// Four at-a-glance stats for the dashboard header.
///
/// `juxt` is the star: one list of stat functions, applied to the same
/// month slice in a single call — adding a stat is adding a lambda.
List<(String label, String value)> quickStats(
    List<Entry> entries, DateTime month) {
  final inMonth = fx(entries).filter((e) => sameMonth(e.date, month)).toList();

  final stats = juxt<List<Entry>, (String, String)>([
    (es) {
      final biggest = fx(es)
          .filter((e) => e.type == EntryType.expense || e.type == EntryType.bill)
          .sortBy((e) => -(e.amount ?? 0));
      final top = head(biggest);
      return (
        'Biggest expense',
        top == null ? '—' : '${top.title} · ${_money(top.amount ?? 0)}',
      );
    },
    (es) {
      final busiest = fx(fx(es).countBy((e) => e.date.day).entries)
          .sortBy((kv) => -kv.value);
      final top = head(busiest);
      return (
        'Busiest day',
        top == null ? '—' : 'Day ${top.key} · ${top.value} entries',
      );
    },
    (es) {
      final spend = fx(es)
          .filter((e) => e.type == EntryType.expense || e.type == EntryType.bill)
          .map((e) => e.amount ?? 0.0)
          .toList();
      final days = fx(es).uniqBy((e) => e.date.day).size();
      return (
        'Avg daily spend',
        spend.isEmpty || days == 0
            ? '—'
            : _money(fx(spend).sum().toDouble() / days),
      );
    },
    (es) {
      final open =
          fx(es).filter((e) => !e.done && e.dueDate != null).size();
      return ('Open due items', open == 0 ? 'none' : '$open');
    },
  ]);

  return stats(inMonth);
}

/// The [count] most recently dated entries, newest first.
/// Pipeline: `sortBy` (date) → `takeRight` → `reverse`.
List<Entry> recentActivity(List<Entry> entries, {int count = 8}) => fx(entries)
    .sortBy((e) => e.date)
    .takeRight(count)
    .reverse()
    .toList();
