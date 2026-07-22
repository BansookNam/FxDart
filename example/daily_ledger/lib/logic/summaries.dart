/// Dashboard & insights pipelines. Every function here is pure:
/// `List<Entry>` in, view data out — each one an fxdart pipeline that reads
/// like the tutorial snippet for the operator it demonstrates.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';

bool sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

class MonthSummary {
  final double income;
  final double expense;
  const MonthSummary({required this.income, required this.expense});
  double get net => income - expense;
}

/// Income vs expense totals for one month.
/// Pipeline: `filter` (month + money) → `partition` (income?) → `sum` each half.
MonthSummary monthSummary(List<Entry> entries, DateTime month) {
  final (income, spending) = fx(entries)
      .filter((e) => e.type.isMoney && sameMonth(e.date, month))
      .partition((e) => e.type == EntryType.income);
  return MonthSummary(
    income: fx(income).map((e) => e.amount ?? 0.0).sum().toDouble(),
    expense: fx(spending).map((e) => e.amount ?? 0.0).sum().toDouble(),
  );
}

class CategoryTotal {
  final String categoryId;
  final double total;
  final int count;
  const CategoryTotal(this.categoryId, this.total, this.count);
}

/// Top-[limit] spending categories for a month.
/// Pipeline: `filter` → `groupBy` (category) → `map` to totals →
/// `sortBy` (descending via negated key) → `take`.
List<CategoryTotal> categoryBreakdown(
  List<Entry> entries,
  DateTime month, {
  int limit = 5,
}) {
  final byCategory = fx(entries)
      .filter(
        (e) =>
            (e.type == EntryType.expense || e.type == EntryType.bill) &&
            sameMonth(e.date, month),
      )
      .groupBy((e) => e.categoryId);
  return fx(byCategory.entries)
      .map(
        (kv) => CategoryTotal(
          kv.key,
          fx(kv.value).map((e) => e.amount ?? 0.0).sum().toDouble(),
          kv.value.length,
        ),
      )
      .sortBy((c) => -c.total)
      .take(limit)
      .toList();
}

class BalancePoint {
  final DateTime date;
  final double balance;
  const BalancePoint(this.date, this.balance);
}

/// Cumulative balance over a month, for the sparkline.
/// Pipeline: `filter` → `sortBy` (date) → `scan` (running sum).
List<BalancePoint> runningBalance(List<Entry> entries, DateTime month) {
  final ordered = fx(entries)
      .filter((e) => e.type.isMoney && sameMonth(e.date, month))
      .sortBy((e) => e.date);
  return fx(ordered)
      .scan(
        (acc, e) => BalancePoint(e.date, acc.balance + e.signedAmount),
        BalancePoint(DateTime(month.year, month.month), 0),
      )
      .drop(1) // drop the seed point
      .toList();
}

/// Not-done entries with a due date, split into (overdue, upcoming) around
/// [today]. Pipeline: `filter` → `sortBy` (dueDate) → `partition`.
(List<Entry> overdue, List<Entry> upcoming) duePartition(
  List<Entry> entries,
  DateTime today,
) {
  final day0 = DateTime(today.year, today.month, today.day);
  return fx(entries)
      .filter((e) => !e.done && e.dueDate != null)
      .sortBy((e) => e.dueDate)
      .partition((e) => e.dueDate!.isBefore(day0));
}

class MonthTrendPoint {
  final DateTime month;
  final MonthSummary current;
  final MonthSummary previous;
  const MonthTrendPoint(this.month, this.current, this.previous);
  double get incomeDelta => current.income - previous.income;
  double get expenseDelta => current.expense - previous.expense;
}

/// Month-over-month comparison for the [months] months ending at [reference].
/// Pipeline: `range` → `map` (month summaries) → `zip` the list against
/// itself shifted by one, pairing each month with its predecessor.
List<MonthTrendPoint> monthlyTrend(
  List<Entry> entries,
  DateTime reference, {
  int months = 6,
}) {
  final summaries = fx(range(months, -1, -1))
      .map((back) => DateTime(reference.year, reference.month - back))
      .map((m) => (m, monthSummary(entries, m)))
      .toList();
  return fx(summaries)
      .drop(1)
      .zip(summaries) // (this month, previous month)
      .map((pair) => MonthTrendPoint(pair.$1.$1, pair.$1.$2, pair.$2.$2))
      .toList();
}

/// Tag frequency across all entries.
/// Pipeline: `flatMap` (tags) → `countBy` → sort desc.
List<(String tag, int count)> tagStats(List<Entry> entries) {
  final counts = fx(entries).flatMap((e) => e.tags).countBy((tag) => tag);
  return fx(
    counts.entries,
  ).map((kv) => (kv.key, kv.value)).sortBy((t) => -t.$2).toList();
}

/// Possible duplicate money entries: same title+amount+day submitted twice.
/// Pipeline: `filter` → `uniqBy` keeps first occurrences → `difference`
/// (everything uniqBy dropped) is exactly the duplicates.
List<Entry> possibleDuplicates(List<Entry> entries) {
  Object key(Entry e) =>
      '${e.title}|${e.amount}|${e.date.year}-${e.date.month}-${e.date.day}';
  final money = fx(entries).filter((e) => e.type.isMoney).toList();
  final firstSeen = fx(money).uniqBy(key).toList();
  return difference(firstSeen, money).toList();
}

/// Live search over entries: case-insensitive match on title and tags.
/// (The UI debounces the query with fxdart's `debounce` before calling this.)
List<Entry> searchEntries(List<Entry> entries, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return entries;
  return fx(entries)
      .filter(
        (e) =>
            e.title.toLowerCase().contains(q) ||
            e.tags.any((t) => t.toLowerCase().contains(q)),
      )
      .toList();
}

/// Entries of a month grouped per day (newest day first), for the list view.
/// Pipeline: `filter` → `groupBy` (day) → `sortBy` keys desc.
List<(DateTime day, List<Entry> entries)> entriesByDayDesc(
  List<Entry> entries,
  DateTime month,
) {
  final byDay = fx(entries)
      .filter((e) => sameMonth(e.date, month))
      .groupBy((e) => DateTime(e.date.year, e.date.month, e.date.day));
  return fx(byDay.entries)
      .map((kv) => (kv.key, fx(kv.value).sortBy((e) => e.title).toList()))
      .sortBy((day) => -day.$1.millisecondsSinceEpoch)
      .toList();
}

/// Count badges for the filter chips: how many entries of each type.
Map<EntryType, int> typeCounts(List<Entry> entries, DateTime month) =>
    fx(entries).filter((e) => sameMonth(e.date, month)).countBy((e) => e.type);
