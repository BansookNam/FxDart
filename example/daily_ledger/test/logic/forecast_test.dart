import 'package:daily_ledger/logic/forecast.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Entry money(
  String id,
  DateTime date,
  double amount, {
  EntryType type = EntryType.expense,
  String? ruleId,
}) => Entry(
  id: id,
  title: id,
  type: type,
  amount: amount,
  categoryId: 'housing',
  date: date,
  recurringRuleId: ruleId,
);

void main() {
  final july = DateTime(2026, 7);
  final today = DateTime(2026, 7, 15);
  final rule = RecurringRule(
    id: 'rent',
    period: RecurrencePeriod.weekly,
    anchorDate: DateTime(2026, 7, 1),
  );

  group('monthForecast', () {
    test('concat: history flows into projection through one scan', () {
      final entries = [
        money('salary', DateTime(2026, 7, 1), 1000, type: EntryType.income),
        money(
          'rent-1',
          DateTime(2026, 7, 8),
          100,
          type: EntryType.bill,
          ruleId: 'rent',
        ),
      ];
      final f = monthForecast(entries, [rule], july, today);

      // 2 real entries + ghosts on Jul 22 and Jul 29 (Jul 15 dropped: the
      // dropWhile window starts at `from`, Jul 8+7=15 is not before from).
      expect(f.ghostCount, greaterThanOrEqualTo(2));
      expect(f.points.length, 2 + f.ghostCount);
      // Balance accumulates through the ghosts: 1000 - 100 - 100*ghosts.
      expect(f.endBalance, 1000 - 100 - 100.0 * f.ghostCount);
      expect(f.hasProjection, isTrue);
      // Everything after `projectedFrom` is dated after today.
      for (final p in f.points.sublist(f.projectedFrom)) {
        expect(p.date.isAfter(DateTime(2026, 7, 15)), isTrue);
      }
    });

    test('horizon is the last day of the month, inclusive', () {
      final anchoredOnLastDay = RecurringRule(
        id: 'eom',
        period: RecurrencePeriod.monthly,
        anchorDate: DateTime(2026, 6, 30),
      );
      final entries = [
        money(
          'seed',
          DateTime(2026, 6, 30),
          50,
          type: EntryType.bill,
          ruleId: 'eom',
        ),
      ];
      final f = monthForecast(entries, [anchoredOnLastDay], july, today);
      // July 30 is inside the month and inside the horizon.
      expect(f.ghostCount, 1);
      expect(f.points.last.date, DateTime(2026, 7, 30));
    });

    test('past month degenerates to the plain running balance', () {
      final entries = [
        money(
          'rent-old',
          DateTime(2026, 6, 8),
          100,
          type: EntryType.bill,
          ruleId: 'rent',
        ),
      ];
      final f = monthForecast(entries, [rule], DateTime(2026, 6), today);
      expect(f.ghostCount, 0);
      expect(f.hasProjection, isFalse);
      expect(f.points.length, 1);
    });

    test('materialized dates are not double-counted', () {
      final entries = [
        money(
          'rent-1',
          DateTime(2026, 7, 8),
          100,
          type: EntryType.bill,
          ruleId: 'rent',
        ),
        // The Jul 22 occurrence already happened for real:
        money(
          'rent-2',
          DateTime(2026, 7, 22),
          100,
          type: EntryType.bill,
          ruleId: 'rent',
        ),
      ];
      final f = monthForecast(entries, [rule], july, today);
      expect(f.points.where((p) => p.date == DateTime(2026, 7, 22)).length, 1);
    });
  });
}
