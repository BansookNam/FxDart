/// Recurring-rule projection: an infinite `range` of occurrence indexes,
/// mapped to dates, windowed with `dropWhile` / `takeWhile`. Laziness is the
/// point — the pipeline never materializes occurrences beyond the horizon.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';

/// The dates a rule fires between [from] (exclusive of earlier) and
/// [horizon] (inclusive).
/// Pipeline: infinite `range` → `map` (i → date) → `dropWhile` → `takeWhile`.
List<DateTime> occurrences(
  RecurringRule rule,
  DateTime from,
  DateTime horizon,
) {
  final a = rule.anchorDate;
  DateTime occurrence(int i) => switch (rule.period) {
    RecurrencePeriod.weekly => DateTime(a.year, a.month, a.day + 7 * i),
    RecurrencePeriod.monthly => DateTime(a.year, a.month + i, a.day),
  };
  return fx(range(100000)) // effectively infinite; laziness does the bounding
      .map(occurrence)
      .dropWhile((d) => d.isBefore(from))
      .takeWhile((d) => !d.isAfter(horizon))
      .toList();
}

/// Projects future ghost entries for [rule] from its latest real entry.
/// Pipeline: [occurrences] → `zipWithIndex` → `map` (date → ghost entry).
List<Entry> projectRule(
  RecurringRule rule,
  List<Entry> existing,
  DateTime from,
  DateTime horizon,
) {
  final template = last(
    fx(
      existing,
    ).filter((e) => e.recurringRuleId == rule.id).sortBy((e) => e.date),
  );
  if (template == null) return const [];
  return fx(occurrences(rule, from, horizon))
      .zipWithIndex()
      .map(
        (pair) => template.copyWith(
          id: '${rule.id}-proj-${pair.$1}',
          date: pair.$2,
          dueDate: pair.$2,
          done: false,
        ),
      )
      .toList();
}

/// All projected entries for every rule, excluding dates where a real entry
/// already exists. Pipeline: `flatMap` (rules) → `filter` (not materialized).
List<Entry> projectAll(
  List<RecurringRule> rules,
  List<Entry> existing,
  DateTime from,
  DateTime horizon,
) {
  final materialized = fx(existing)
      .filter((e) => e.recurringRuleId != null)
      .map(
        (e) =>
            '${e.recurringRuleId}@${e.date.year}-${e.date.month}-${e.date.day}',
      )
      .toList();
  return fx(rules)
      .flatMap((rule) => projectRule(rule, existing, from, horizon))
      .filter(
        (ghost) => !materialized.contains(
          '${ghost.recurringRuleId}@${ghost.date.year}-${ghost.date.month}-${ghost.date.day}',
        ),
      )
      .toList();
}
