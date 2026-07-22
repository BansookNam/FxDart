import 'package:daily_ledger/logic/cached.dart';
import 'package:daily_ledger/logic/stats.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Entry entry(
  String id,
  DateTime date, {
  EntryType type = EntryType.expense,
  double? amount,
  DateTime? due,
  bool done = false,
}) => Entry(
  id: id,
  title: id,
  type: type,
  amount: amount,
  categoryId: 'dining',
  date: date,
  dueDate: due,
  done: done,
);

void main() {
  final july = DateTime(2026, 7);

  group('quickStats', () {
    test('computes all four stats via one juxt application', () {
      final entries = [
        entry('coffee', DateTime(2026, 7, 3), amount: 5),
        entry('laptop', DateTime(2026, 7, 3), amount: 900),
        entry(
          'salary',
          DateTime(2026, 7, 25),
          type: EntryType.income,
          amount: 3200,
        ),
        entry(
          'todo',
          DateTime(2026, 7, 10),
          type: EntryType.task,
          due: DateTime(2026, 7, 30),
        ),
      ];
      final stats = Map.fromEntries(
        quickStats(entries, july).map((s) => MapEntry(s.$1, s.$2)),
      );
      expect(stats['Biggest expense'], 'laptop · \$900.00');
      expect(stats['Busiest day'], 'Day 3 · 2 entries');
      // Spend 905 over 1 distinct SPENDING day — the salary and task days
      // must not inflate the denominator (Round 5 correctness fix).
      expect(stats['Avg daily spend'], '\$905.00');
      expect(stats['Open due items'], '1');
    });

    test('empty month degrades to placeholders', () {
      final stats = quickStats(const [], july);
      expect(stats.map((s) => s.$2), containsAll(['—', 'none']));
    });
  });

  group('recentActivity', () {
    test('returns newest N entries, newest first', () {
      final entries = [
        for (var d = 1; d <= 12; d++)
          entry('e$d', DateTime(2026, 7, d), amount: 1),
      ];
      final recent = recentActivity(entries, count: 3);
      expect(recent.map((e) => e.id), ['e12', 'e11', 'e10']);
    });
  });

  group('cached pipelines', () {
    test('same list instance + month returns the identical cached object', () {
      final entries = [entry('a', DateTime(2026, 7, 1), amount: 10)];
      final first = cachedMonthSummary(entries)(july);
      final second = cachedMonthSummary(entries)(july);
      expect(identical(first, second), isTrue);
    });

    test('a new list instance misses the cache and recomputes', () {
      final a = [entry('a', DateTime(2026, 7, 1), amount: 10)];
      final b = [...a, entry('b', DateTime(2026, 7, 2), amount: 5)];
      expect(cachedMonthSummary(a)(july).expense, 10);
      expect(cachedMonthSummary(b)(july).expense, 15);
    });
  });
}
