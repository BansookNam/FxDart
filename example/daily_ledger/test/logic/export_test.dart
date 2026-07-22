import 'package:daily_ledger/logic/export.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dining = Category(
    id: 'dining',
    name: 'Dining',
    iconCodePoint: 0,
    colorSeed: 0,
    kind: CategoryKind.money,
  );

  test('exports header + rows sorted by date, with picked columns only', () {
    final entries = [
      Entry(
        id: 'b',
        title: 'Lunch',
        type: EntryType.expense,
        amount: 12.5,
        categoryId: 'dining',
        tags: const ['food', 'social'],
        date: DateTime(2026, 7, 10),
      ),
      Entry(
        id: 'a',
        title: 'Groceries',
        type: EntryType.expense,
        amount: 40,
        categoryId: 'unknown-cat',
        date: DateTime(2026, 7, 2),
      ),
    ];
    final csv = entriesToCsv(entries, categories: {'dining': dining});
    final lines = csv.split('\n');
    expect(lines.first, 'date,type,title,category,amount,tags,done');
    expect(lines.length, 3);
    // Sorted by date: Groceries (Jul 2) before Lunch (Jul 10).
    expect(lines[1], '2026-07-02,expense,Groceries,unknown-cat,40.00,,no');
    expect(lines[2], '2026-07-10,expense,Lunch,Dining,12.50,food|social,no');
    // 'id' and 'dueDate' were in the field map but pick() dropped them.
    expect(csv.contains('dueDate'), isFalse);
  });

  test('escapes commas and quotes', () {
    final entries = [
      Entry(
        id: 'x',
        title: 'Dinner, with "friends"',
        type: EntryType.expense,
        amount: 30,
        categoryId: 'dining',
        date: DateTime(2026, 7, 4),
      ),
    ];
    final csv = entriesToCsv(entries);
    expect(csv.split('\n')[1], contains('"Dinner, with ""friends"""'));
  });

  test('task without amount exports an empty amount cell', () {
    final entries = [
      Entry(
        id: 't',
        title: 'Water plants',
        type: EntryType.task,
        categoryId: 'chores',
        date: DateTime(2026, 7, 4),
        done: true,
      ),
    ];
    final line = entriesToCsv(entries).split('\n')[1];
    expect(line, '2026-07-04,task,Water plants,chores,,,yes');
  });
}
