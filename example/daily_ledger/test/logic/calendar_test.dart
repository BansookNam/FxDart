import 'package:daily_ledger/logic/calendar.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('monthGrid', () {
    test('July 2026 grid starts on Sunday and covers the whole month', () {
      final grid = monthGrid(DateTime(2026, 7));
      expect(grid.length, 6);
      expect(grid.every((week) => week.length == 7), isTrue);
      // 2026-07-01 is a Wednesday → the grid starts Sun 2026-06-28.
      expect(grid.first.first, DateTime(2026, 6, 28));
      expect(grid.first.first.weekday, DateTime.sunday);
      // Every day of July is present.
      final all = grid.expand((w) => w).toList();
      for (var d = 1; d <= 31; d++) {
        expect(all, contains(DateTime(2026, 7, d)));
      }
    });

    test('month starting on Sunday has no leading days', () {
      // 2026-02-01 is a Sunday.
      final grid = monthGrid(DateTime(2026, 2));
      expect(grid.first.first, DateTime(2026, 2, 1));
    });
  });

  group('entriesByDay / dayNet / dueCount', () {
    final entries = [
      Entry(
        id: 'a',
        title: 'coffee',
        type: EntryType.expense,
        amount: 4.5,
        categoryId: 'dining',
        date: DateTime(2026, 7, 23, 9, 30), // time of day must not matter
      ),
      Entry(
        id: 'b',
        title: 'pay',
        type: EntryType.income,
        amount: 10,
        categoryId: 'salary',
        date: DateTime(2026, 7, 23, 18),
      ),
      Entry(
        id: 'c',
        title: 'todo',
        type: EntryType.task,
        categoryId: 'chores',
        date: DateTime(2026, 7, 20),
        dueDate: DateTime(2026, 7, 23),
      ),
    ];

    test('groups on the day key ignoring time', () {
      final byDay = entriesByDay(entries);
      expect(byDay[DateTime(2026, 7, 23)]?.map((e) => e.id), ['a', 'b']);
    });

    test('dayNet sums signed amounts (tasks count as 0)', () {
      final byDay = entriesByDay(entries);
      expect(dayNet(byDay[DateTime(2026, 7, 23)]!), 5.5);
      expect(dayNet(byDay[DateTime(2026, 7, 20)]!), 0);
    });

    test('dueCountByDay indexes open items by due day', () {
      final dueByDay = dueCountByDay(entries);
      expect(dueByDay[DateTime(2026, 7, 23)], 1);
      expect(dueByDay[DateTime(2026, 7, 22)], isNull);
    });
  });
}
