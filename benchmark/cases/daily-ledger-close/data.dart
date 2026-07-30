// Deterministic ledger shared verbatim by both sides (headline 3,000).
// Async case: the on-device store delay is Duration.zero and the example's
// 3-wide load window is kept. The headline is capped at 3000 (not the usual
// 5000+) because the example's loadEntry does a linear firstWhere scan over
// the whole ledger per id — the load phase is O(n^2) on both sides, and
// 3000 keeps one headline iteration well under the 2 s budget (the runner's
// BENCH_N=10000 pass runs ~1 s/iteration; accepted).
import '../../harness.dart';

final n = caseN(3000);

enum EntryType { income, expense, bill }

class Entry {
  final String id;
  final String title;
  final EntryType type;
  final double amount;
  final String categoryId;
  final DateTime date;
  Entry(this.id, this.title, this.type, this.amount, this.categoryId,
      this.date);
}

const _categories = [
  'food', 'housing', 'utilities', 'fun', 'transport', 'health',
];

List<Entry> makeLedger() {
  final rng = Lcg(21);
  return List.generate(n, (i) {
    final month = 6 + rng.nextInt(3); // Jun / Jul / Aug 2026
    final day = 1 + rng.nextInt(28);
    final roll = rng.nextInt(10);
    final type = roll == 0
        ? EntryType.income
        : roll <= 3
            ? EntryType.bill
            : EntryType.expense;
    final category =
        type == EntryType.income ? 'income' : _categories[rng.nextInt(6)];
    final amount = type == EntryType.income
        ? (50000 + rng.nextInt(300000)) / 100
        : (100 + rng.nextInt(19900)) / 100;
    return Entry(
        'e$i', 'entry $i', type, amount, category, DateTime(2026, month, day));
  });
}
