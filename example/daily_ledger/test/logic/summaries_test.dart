import 'package:daily_ledger/logic/summaries.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Entry entry(
  String id, {
  EntryType type = EntryType.expense,
  double? amount,
  String category = 'groceries',
  List<String> tags = const [],
  required DateTime date,
  DateTime? due,
  bool done = false,
}) =>
    Entry(
      id: id,
      title: id,
      type: type,
      amount: amount,
      categoryId: category,
      tags: tags,
      date: date,
      dueDate: due,
      done: done,
    );

void main() {
  final july = DateTime(2026, 7);

  group('monthSummary', () {
    test('sums income and expenses separately, ignoring other months', () {
      final entries = [
        entry('a', type: EntryType.income, amount: 1000, date: DateTime(2026, 7, 25)),
        entry('b', amount: 100, date: DateTime(2026, 7, 3)),
        entry('c', type: EntryType.bill, amount: 50, date: DateTime(2026, 7, 10)),
        entry('d', amount: 999, date: DateTime(2026, 6, 30)), // other month
        entry('e', type: EntryType.task, date: DateTime(2026, 7, 5)), // no money
      ];
      final s = monthSummary(entries, july);
      expect(s.income, 1000);
      expect(s.expense, 150);
      expect(s.net, 850);
    });

    test('empty month yields zeros, not NaN', () {
      final s = monthSummary(const [], july);
      expect(s.income, 0);
      expect(s.expense, 0);
      expect(s.net, 0);
    });
  });

  group('categoryBreakdown', () {
    test('groups, totals, sorts desc, takes limit', () {
      final entries = [
        entry('a', amount: 10, category: 'dining', date: DateTime(2026, 7, 1)),
        entry('b', amount: 30, category: 'dining', date: DateTime(2026, 7, 2)),
        entry('c', amount: 25, category: 'transport', date: DateTime(2026, 7, 3)),
        entry('d', amount: 100, category: 'housing', date: DateTime(2026, 7, 4)),
        entry('e', type: EntryType.income, amount: 500, category: 'salary',
            date: DateTime(2026, 7, 5)), // income excluded
      ];
      final top = categoryBreakdown(entries, july, limit: 2);
      expect(top.map((c) => c.categoryId), ['housing', 'dining']);
      expect(top[1].total, 40);
      expect(top[1].count, 2);
    });
  });

  group('runningBalance', () {
    test('scan accumulates in date order regardless of input order', () {
      final entries = [
        entry('late', amount: 30, date: DateTime(2026, 7, 20)),
        entry('early', type: EntryType.income, amount: 100, date: DateTime(2026, 7, 1)),
      ];
      final points = runningBalance(entries, july);
      expect(points.map((p) => p.balance), [100, 70]);
    });

    test('empty month gives no points', () {
      expect(runningBalance(const [], july), isEmpty);
    });
  });

  group('duePartition', () {
    final today = DateTime(2026, 7, 23);
    test('splits open dued entries into overdue and upcoming, sorted', () {
      final entries = [
        entry('overdue', type: EntryType.bill, amount: 1,
            date: DateTime(2026, 7, 1), due: DateTime(2026, 7, 20)),
        entry('up1', type: EntryType.task, date: DateTime(2026, 7, 1),
            due: DateTime(2026, 7, 25)),
        entry('doneOne', type: EntryType.task, date: DateTime(2026, 7, 1),
            due: DateTime(2026, 7, 1), done: true),
        entry('noDue', type: EntryType.task, date: DateTime(2026, 7, 1)),
        entry('dueToday', type: EntryType.task, date: DateTime(2026, 7, 1),
            due: DateTime(2026, 7, 23)),
      ];
      final (overdue, upcoming) = duePartition(entries, today);
      expect(overdue.map((e) => e.id), ['overdue']);
      // Due today is upcoming, not overdue.
      expect(upcoming.map((e) => e.id), ['dueToday', 'up1']);
    });
  });

  group('monthlyTrend', () {
    test('pairs each month with its predecessor', () {
      final entries = [
        entry('june', amount: 100, date: DateTime(2026, 6, 10)),
        entry('july', amount: 250, date: DateTime(2026, 7, 10)),
      ];
      final trend = monthlyTrend(entries, DateTime(2026, 7, 23), months: 2);
      expect(trend.length, 2);
      expect(trend.last.month.month, 7);
      expect(trend.last.current.expense, 250);
      expect(trend.last.previous.expense, 100);
      expect(trend.last.expenseDelta, 150);
    });
  });

  group('tagStats', () {
    test('counts tags across entries, most frequent first', () {
      final entries = [
        entry('a', tags: ['food', 'social'], date: DateTime(2026, 7, 1)),
        entry('b', tags: ['food'], date: DateTime(2026, 7, 2)),
      ];
      final stats = tagStats(entries);
      expect(stats.first, ('food', 2));
      expect(stats, contains(('social', 1)));
    });
  });

  group('possibleDuplicates', () {
    test('finds same title+amount+day pairs', () {
      final entries = [
        entry('a', amount: 12, date: DateTime(2026, 7, 3)).copyWith(title: 'Coffee'),
        entry('b', amount: 12, date: DateTime(2026, 7, 3)).copyWith(title: 'Coffee'),
        entry('c', amount: 12, date: DateTime(2026, 7, 4)).copyWith(title: 'Coffee'),
      ];
      final dupes = possibleDuplicates(entries);
      expect(dupes.length, 1);
      expect(dupes.single.id, 'b');
    });
  });

  group('searchEntries', () {
    final entries = [
      entry('a', tags: ['food'], date: DateTime(2026, 7, 1)).copyWith(title: 'Supermarket'),
      entry('b', tags: ['commute'], date: DateTime(2026, 7, 2)).copyWith(title: 'Bus fare'),
    ];
    test('matches title case-insensitively', () {
      expect(searchEntries(entries, 'super').single.id, 'a');
    });
    test('matches tags', () {
      expect(searchEntries(entries, 'commute').single.id, 'b');
    });
    test('empty query returns everything', () {
      expect(searchEntries(entries, '  '), entries);
    });
  });

  group('entriesByDayDesc', () {
    test('groups by day, newest day first', () {
      final entries = [
        entry('a', date: DateTime(2026, 7, 1)),
        entry('b', date: DateTime(2026, 7, 15)),
        entry('c', date: DateTime(2026, 7, 15)),
      ];
      final grouped = entriesByDayDesc(entries, july);
      expect(grouped.first.$1, DateTime(2026, 7, 15));
      expect(grouped.first.$2.length, 2);
      expect(grouped.last.$1, DateTime(2026, 7, 1));
    });
  });
}
