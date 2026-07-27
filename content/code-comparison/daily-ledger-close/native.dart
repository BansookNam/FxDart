import 'package:collection/collection.dart';

enum EntryType { income, expense, bill }

class Entry {
  final String id;
  final String title;
  final EntryType type;
  final double amount;
  final String categoryId;
  final DateTime date;
  Entry(this.id, this.title, this.type, this.amount, this.categoryId, this.date);
}

final ledger = [
  Entry('e0', 'Coffee', EntryType.expense, 4.50, 'food', DateTime(2026, 6, 30)),
  Entry('e1', 'Salary', EntryType.income, 3200.00, 'income', DateTime(2026, 7, 1)),
  Entry('e2', 'Rent', EntryType.bill, 1150.00, 'housing', DateTime(2026, 7, 3)),
  Entry('e3', 'Groceries', EntryType.expense, 82.40, 'food', DateTime(2026, 7, 5)),
  Entry('e4', 'Dinner out', EntryType.expense, 46.10, 'food', DateTime(2026, 7, 12)),
  Entry('e5', 'Electricity', EntryType.bill, 61.30, 'utilities', DateTime(2026, 7, 15)),
  Entry('e6', 'Freelance', EntryType.income, 400.00, 'income', DateTime(2026, 7, 18)),
  Entry('e7', 'Groceries', EntryType.expense, 77.85, 'food', DateTime(2026, 7, 19)),
  Entry('e8', 'Cinema', EntryType.expense, 15.50, 'fun', DateTime(2026, 7, 24)),
  Entry('e9', 'Internet', EntryType.bill, 45.00, 'utilities', DateTime(2026, 7, 25)),
];

int inFlight = 0;
int maxInFlight = 0;

/// Loads one entry from the (simulated) on-device store.
Future<Entry> loadEntry(String id) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future.delayed(const Duration(milliseconds: 15));
  inFlight--;
  return ledger.firstWhere((e) => e.id == id);
}

/// Worker pool: 3 workers over a shared cursor, ordered result slots.
Future<List<Entry>> loadAll(List<String> ids) async {
  final results = List<Entry?>.filled(ids.length, null);
  var next = 0;
  Future<void> worker() async {
    while (next < ids.length) {
      final i = next++;
      results[i] = await loadEntry(ids[i]);
    }
  }

  await Future.wait([worker(), worker(), worker()]);
  return results.cast<Entry>();
}

Future<void> main() async {
  final entries = await loadAll([for (final e in ledger) e.id]);

  final july = entries
      .where((e) => e.date.year == 2026 && e.date.month == 7)
      .toList();
  final income = july.where((e) => e.type == EntryType.income);
  final spending = july.where((e) => e.type != EntryType.income).toList();
  final earned = income.fold(0.0, (sum, e) => sum + e.amount);
  final spent = spending.fold(0.0, (sum, e) => sum + e.amount);

  final byCategory = spending.groupListsBy((e) => e.categoryId);
  final top = byCategory.entries
      .map((kv) => (
            kv.key,
            kv.value.fold(0.0, (sum, e) => sum + e.amount),
            kv.value.length
          ))
      .sortedBy<num>((c) => -c.$2)
      .take(3);

  print('July 2026 close — ${entries.length} entries loaded, 3 at a time '
      '(max in flight: $maxInFlight)');
  print('income  \$${earned.toStringAsFixed(2)}');
  print('expense \$${spent.toStringAsFixed(2)}');
  print('net     \$${(earned - spent).toStringAsFixed(2)}');
  print('top spending categories:');
  for (final (cat, total, count) in top) {
    print('  $cat: \$${total.toStringAsFixed(2)} '
        '($count ${count == 1 ? 'entry' : 'entries'})');
  }
}
