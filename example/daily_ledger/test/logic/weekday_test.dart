import 'package:daily_ledger/logic/weekday.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Entry spend(String id, DateTime date, double amount) => Entry(
  id: id,
  title: id,
  type: EntryType.expense,
  amount: amount,
  categoryId: 'dining',
  date: date,
);

void main() {
  final july = DateTime(2026, 7);

  group('weekdayProfile', () {
    test('averages DAY TOTALS per weekday, not raw entries', () {
      final entries = [
        // Wed Jul 1: two entries, day total 30.
        spend('a', DateTime(2026, 7, 1), 10),
        spend('b', DateTime(2026, 7, 1), 20),
        // Wed Jul 8: one entry, day total 10 → Wednesday avg = 20.
        spend('c', DateTime(2026, 7, 8), 10),
        // Fri Jul 3: 50 → Friday avg = 50.
        spend('d', DateTime(2026, 7, 3), 50),
      ];
      final profile = weekdayProfile(entries, july);
      expect(profile, hasLength(7));

      final wednesday = profile.firstWhere(
        (w) => w.weekday == DateTime.wednesday,
      );
      expect(wednesday.avgSpend, 20);
      expect(wednesday.dayCount, 2);

      final friday = profile.firstWhere((w) => w.weekday == DateTime.friday);
      expect(friday.avgSpend, 50);

      final monday = profile.firstWhere((w) => w.weekday == DateTime.monday);
      expect(monday.avgSpend, 0);
      expect(monday.dayCount, 0);
    });

    test('ignores income and other months', () {
      final entries = [
        spend('in-month', DateTime(2026, 7, 6), 10),
        spend('other-month', DateTime(2026, 6, 6), 99),
        Entry(
          id: 'salary',
          title: 'salary',
          type: EntryType.income,
          amount: 1000,
          categoryId: 'salary',
          date: DateTime(2026, 7, 6),
        ),
      ];
      final profile = weekdayProfile(entries, july);
      final monday = profile.firstWhere((w) => w.weekday == DateTime.monday);
      expect(monday.avgSpend, 10);
      expect(profile.where((w) => w.dayCount > 0), hasLength(1));
    });
  });
}
