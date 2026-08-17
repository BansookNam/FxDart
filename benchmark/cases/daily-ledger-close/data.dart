// Deterministic ledger shared verbatim by both sides.
// Async case: the on-device store delay is Duration.zero and the example's
// 3-wide load window is kept. The headline is 20,000 rather than the async
// family's usual 100,000 because the example's loadEntry does a linear
// firstWhere scan over the whole ledger per id — the load phase is O(n^2) on
// both sides, so cost grows ~100x for every 10x of n. 20,000 is the largest
// round headline that still clears the runner's fixed N=10,000 pass (so the
// third set of bars says something new) while keeping one iteration inside
// the 2 s budget; measured ~1.3 s/iteration per side.
import '../../harness.dart';

final n = caseN(20000);

enum EntryType { income, expense, bill }

class Entry {
  final String id;
  final String title;
  final EntryType type;
  final double amount;
  final String categoryId;
  final DateTime date;
  Entry(
    this.id,
    this.title,
    this.type,
    this.amount,
    this.categoryId,
    this.date,
  );
}

const _categories = [
  'food',
  'housing',
  'utilities',
  'fun',
  'transport',
  'health',
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
    final category = type == EntryType.income
        ? 'income'
        : _categories[rng.nextInt(6)];
    final amount = type == EntryType.income
        ? (50000 + rng.nextInt(300000)) / 100
        : (100 + rng.nextInt(19900)) / 100;
    return Entry(
      'e$i',
      'entry $i',
      type,
      amount,
      category,
      DateTime(2026, month, day),
    );
  });
}
