import 'package:daily_ledger/logic/budgets.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Entry spend(
  String id,
  double amount,
  String category,
  DateTime date, {
  EntryType type = EntryType.expense,
}) => Entry(
  id: id,
  title: id,
  type: type,
  amount: amount,
  categoryId: category,
  date: date,
);

void main() {
  final july = DateTime(2026, 7);

  group('spentByCategory', () {
    test(
      'folds expenses and bills per category, ignores income and other months',
      () {
        final entries = [
          spend('a', 10, 'dining', DateTime(2026, 7, 1)),
          spend('b', 15, 'dining', DateTime(2026, 7, 8)),
          spend(
            'c',
            100,
            'housing',
            DateTime(2026, 7, 1),
            type: EntryType.bill,
          ),
          spend('d', 999, 'dining', DateTime(2026, 6, 1)), // other month
          spend(
            'e',
            500,
            'salary',
            DateTime(2026, 7, 25),
            type: EntryType.income,
          ),
        ];
        final spent = spentByCategory(entries, july);
        expect(spent, {'dining': 25, 'housing': 100});
      },
    );
  });

  group('budgetStatuses', () {
    test('joins budgets with spending, most-stressed first', () {
      final entries = [
        spend('a', 90, 'dining', DateTime(2026, 7, 1)),
        spend('b', 10, 'transport', DateTime(2026, 7, 2)),
      ];
      final statuses = budgetStatuses(entries, {
        'dining': 100,
        'transport': 100,
      }, july);
      expect(statuses.first.categoryId, 'dining');
      expect(statuses.first.ratio, 0.9);
      expect(statuses.first.over, isFalse);
      expect(statuses.last.remaining, 90);
    });

    test('unspent budget shows zero spent; overspend flags over', () {
      final statuses = budgetStatuses(
        [spend('a', 120, 'fun', DateTime(2026, 7, 4))],
        {'fun': 100, 'health': 50},
        july,
      );
      expect(statuses.first.over, isTrue);
      expect(statuses.last.spent, 0);
    });
  });

  group('suggestedBudgets', () {
    test('evolves 3-month averages into padded, rounded suggestions', () {
      final entries = [
        spend('a', 100, 'dining', DateTime(2026, 6, 5)),
        spend('b', 200, 'dining', DateTime(2026, 5, 5)),
        spend('c', 300, 'dining', DateTime(2026, 4, 5)),
        spend(
          'd',
          999,
          'dining',
          DateTime(2026, 7, 5),
        ), // current month ignored
      ];
      final suggested = suggestedBudgets(entries, july);
      // avg(100, 200, 300) = 200 → ×1.1 = 220 → ceil to $10 = 220.
      expect(suggested, {'dining': 220});
    });

    test('categories missing in some months average over zeros', () {
      final entries = [spend('a', 300, 'fun', DateTime(2026, 6, 5))];
      final suggested = suggestedBudgets(entries, july);
      // avg(300, 0, 0) = 100 → ×1.1 = 110 → 110.
      expect(suggested, {'fun': 110});
    });
  });
}
