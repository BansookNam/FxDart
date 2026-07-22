import 'package:daily_ledger/logic/recurrence.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('occurrences', () {
    test('weekly rule fires every 7 days inside the window', () {
      final rule = RecurringRule(
        id: 'gym',
        period: RecurrencePeriod.weekly,
        anchorDate: DateTime(2026, 7, 6), // a Monday
      );
      final dates = occurrences(rule, DateTime(2026, 7, 23), DateTime(2026, 8, 10));
      expect(dates, [
        DateTime(2026, 7, 27),
        DateTime(2026, 8, 3),
        DateTime(2026, 8, 10), // horizon is inclusive
      ]);
    });

    test('monthly rule keeps the anchor day-of-month', () {
      final rule = RecurringRule(
        id: 'rent',
        period: RecurrencePeriod.monthly,
        anchorDate: DateTime(2026, 7, 1),
      );
      final dates = occurrences(rule, DateTime(2026, 7, 23), DateTime(2026, 10, 1));
      expect(dates, [
        DateTime(2026, 8, 1),
        DateTime(2026, 9, 1),
        DateTime(2026, 10, 1),
      ]);
    });
  });

  group('projectRule / projectAll', () {
    final rule = RecurringRule(
      id: 'rule-rent',
      period: RecurrencePeriod.monthly,
      anchorDate: DateTime(2026, 7, 1),
    );
    final rent = Entry(
      id: 'rent-0',
      title: 'Rent',
      type: EntryType.bill,
      amount: 1150,
      categoryId: 'housing',
      date: DateTime(2026, 7, 1),
      dueDate: DateTime(2026, 7, 1),
      done: true,
      recurringRuleId: 'rule-rent',
    );

    test('projects ghost entries from the latest real entry', () {
      final ghosts = projectRule(
          rule, [rent], DateTime(2026, 7, 23), DateTime(2026, 9, 30));
      expect(ghosts.length, 2);
      expect(ghosts.first.date, DateTime(2026, 8, 1));
      expect(ghosts.first.amount, 1150);
      expect(ghosts.first.done, isFalse);
      expect(ghosts.first.id, isNot(rent.id));
    });

    test('rule without a template projects nothing', () {
      expect(projectRule(rule, const [], DateTime(2026, 7, 23),
          DateTime(2026, 12, 31)), isEmpty);
    });

    test('projectAll skips dates that already have a materialized entry', () {
      final augustRent = rent.copyWith(
          id: 'rent-aug', date: DateTime(2026, 8, 1), dueDate: DateTime(2026, 8, 1));
      final ghosts = projectAll([rule], [rent, augustRent],
          DateTime(2026, 7, 23), DateTime(2026, 9, 30));
      expect(ghosts.map((e) => e.date), [DateTime(2026, 9, 1)]);
    });
  });
}
