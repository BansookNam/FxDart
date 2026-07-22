import 'package:daily_ledger/logic/heatmap.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Entry spend(String id, double amount, DateTime date,
        {EntryType type = EntryType.expense}) =>
    Entry(
      id: id,
      title: id,
      type: type,
      amount: amount,
      categoryId: 'dining',
      date: date,
    );

void main() {
  final july = DateTime(2026, 7);

  test('per-day totals, max and total agree; income excluded', () {
    final entries = [
      spend('a', 10, DateTime(2026, 7, 3)),
      spend('b', 20, DateTime(2026, 7, 3)),
      spend('c', 5, DateTime(2026, 7, 10), type: EntryType.bill),
      spend('d', 999, DateTime(2026, 7, 10), type: EntryType.income),
      spend('e', 50, DateTime(2026, 6, 30)), // other month
    ];
    final data = spendingHeatmap(entries, july);
    expect(data.totalSpend, 35);
    expect(data.maxDaySpend, 30);

    final flat = {
      for (final week in data.weeks)
        for (final (day, spent) in week) day: spent,
    };
    expect(flat[DateTime(2026, 7, 3)], 30);
    expect(flat[DateTime(2026, 7, 10)], 5);
    expect(flat[DateTime(2026, 7, 4)], 0);
  });

  test('grid matches the calendar shape (6 weeks × 7 days)', () {
    final data = spendingHeatmap(const [], july);
    expect(data.weeks.length, 6);
    expect(data.weeks.every((w) => w.length == 7), isTrue);
    expect(data.totalSpend, 0);
    expect(data.intensity(0), 0); // no division by zero
  });

  test('intensity normalizes against the heaviest day', () {
    final entries = [
      spend('a', 25, DateTime(2026, 7, 1)),
      spend('b', 100, DateTime(2026, 7, 2)),
    ];
    final data = spendingHeatmap(entries, july);
    expect(data.intensity(25), 0.25);
    expect(data.intensity(100), 1.0);
  });
}
