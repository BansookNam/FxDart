import 'package:daily_ledger/logic/tags.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Entry entry(String id, DateTime date, List<String> tags,
        {EntryType type = EntryType.expense, double? amount = 10}) =>
    Entry(
      id: id,
      title: id,
      type: type,
      amount: amount,
      categoryId: 'dining',
      date: date,
      tags: tags,
    );

void main() {
  final july = DateTime(2026, 7);
  final entries = [
    entry('a', DateTime(2026, 7, 3), ['food', 'social']),
    entry('b', DateTime(2026, 7, 8), ['food']),
    entry('c', DateTime(2026, 7, 10), ['travel']),
    entry('d', DateTime(2026, 6, 5), ['food', 'commute']),
    entry('t', DateTime(2026, 7, 12), ['food'],
        type: EntryType.task, amount: null),
  ];

  test('compareTagMonths: intersection, fresh, dropped', () {
    final cmp = compareTagMonths(entries, july);
    expect(cmp.shared, ['food']); // in June and July
    expect(cmp.fresh, containsAll(['social', 'travel'])); // July only
    expect(cmp.dropped, ['commute']); // June only
  });

  test('tagEntries: month-scoped, newest first', () {
    final list = tagEntries(entries, 'food', july);
    expect(list.map((e) => e.id), ['t', 'b', 'a']);
  });

  test('tagSpend: compact(pluck) skips the amount-less task', () {
    expect(tagSpend(entries, 'food', july), 20); // a + b, task t has no amount
  });

  test('unknown tag spends zero', () {
    expect(tagSpend(entries, 'nope', july), 0);
  });
}
