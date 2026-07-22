/// Weekday spending profile (Round 8 feature): which day of the week does
/// the money go? A two-stage aggregation: daily totals first (`groupBy` day
/// → `sumBy`), then the *average of those day totals* per weekday —
/// fxdart's new `averageBy` doing exactly what its name says.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';
import 'calendar.dart';
import 'summaries.dart';

/// One row per weekday, Monday (1) … Sunday (7), always all seven.
class WeekdayStat {
  final int weekday; // DateTime.monday … DateTime.sunday
  final double avgSpend; // average of that weekday's DAY TOTALS, 0 if none
  final int dayCount; // how many such weekdays had spending
  const WeekdayStat(this.weekday, this.avgSpend, this.dayCount);
}

/// Pipeline: `filter` (month, spending) → `groupBy` (day) → `sumBy` per day
/// → `groupBy` (weekday of day) → **`averageBy`** (day total) per weekday.
List<WeekdayStat> weekdayProfile(List<Entry> entries, DateTime month) {
  final perDay = fx(entries)
      .filter(
        (e) =>
            (e.type == EntryType.expense || e.type == EntryType.bill) &&
            sameMonth(e.date, month),
      )
      .groupBy((e) => dayKey(e.date));

  final dayTotals = fx(perDay.entries)
      .map(
        (kv) => (
          day: kv.key,
          total: fx(kv.value).sumBy((e) => e.amount ?? 0).toDouble(),
        ),
      )
      .toList();

  final byWeekday = fx(dayTotals).groupBy((d) => d.day.weekday);

  return [
    for (var wd = DateTime.monday; wd <= DateTime.sunday; wd++)
      WeekdayStat(
        wd,
        byWeekday.containsKey(wd)
            ? fx(byWeekday[wd]!).averageBy((d) => d.total)
            : 0,
        byWeekday[wd]?.length ?? 0,
      ),
  ];
}
