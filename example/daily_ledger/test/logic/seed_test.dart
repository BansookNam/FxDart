import 'package:daily_ledger/data/seed.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 7, 23);

  test('seed is deterministic for a given day', () {
    final a = seedEntries(today);
    final b = seedEntries(today);
    expect(a.map((e) => e.id), b.map((e) => e.id));
    expect(a.map((e) => e.amount), b.map((e) => e.amount));
  });

  test('seed ids are unique', () {
    final entries = seedEntries(today);
    expect(entries.map((e) => e.id).toSet().length, entries.length);
  });

  test('every entry references a seeded category', () {
    final categoryIds = seedCategories().map((c) => c.id).toSet();
    for (final e in seedEntries(today)) {
      expect(categoryIds, contains(e.categoryId));
    }
  });

  test('seed contains both overdue and upcoming open items', () {
    final entries = seedEntries(today);
    final open = entries.where((e) => !e.done && e.dueDate != null);
    expect(open.any((e) => e.dueDate!.isBefore(today)), isTrue);
    expect(open.any((e) => e.dueDate!.isAfter(today)), isTrue);
  });

  test('money entries all carry amounts; every month has a salary', () {
    final entries = seedEntries(today);
    for (final e in entries.where((e) => e.type.isMoney)) {
      expect(e.amount, isNotNull, reason: e.id);
      expect(e.amount, greaterThan(0), reason: e.id);
    }
    final salaries = entries.where((e) => e.type == EntryType.income).toList();
    expect(salaries.length, 7);
  });

  test('recurring rules reference materialized rent entries', () {
    final entries = seedEntries(today);
    final rules = seedRules(today);
    expect(rules.map((r) => r.id), contains('rule-rent'));
    expect(entries.any((e) => e.recurringRuleId == 'rule-rent'), isTrue);
  });
}
