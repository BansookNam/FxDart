import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

final ledger = makeLedger();

int inFlight = 0;
int maxInFlight = 0;

/// Loads one entry from the (simulated) on-device store.
Future<Entry> loadEntry(String id) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future<void>.delayed(Duration.zero);
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
  final ids = [for (final e in ledger) e.id];
  await bench(
    slug: 'daily-ledger-close',
    impl: 'native',
    n: n,
    run: () async {
      maxInFlight = 0;
      final entries = await loadAll(ids);

      final july = entries
          .where((e) => e.date.year == 2026 && e.date.month == 7)
          .toList();
      final income = july.where((e) => e.type == EntryType.income);
      final spending = july.where((e) => e.type != EntryType.income).toList();
      final earned = income.fold(0.0, (sum, e) => sum + e.amount);
      final spent = spending.fold(0.0, (sum, e) => sum + e.amount);

      final byCategory = spending.groupListsBy((e) => e.categoryId);
      final top = byCategory.entries
          .map(
            (kv) => (
              kv.key,
              kv.value.fold(0.0, (sum, e) => sum + e.amount),
              kv.value.length,
            ),
          )
          .sortedBy<num>((c) => -c.$2)
          .take(3);

      final topStr = top
          .map((c) => '${c.$1}:${c.$2.toStringAsFixed(2)}:${c.$3}')
          .join(',');
      return '${entries.length}|earned=${earned.toStringAsFixed(2)}'
          '|spent=${spent.toStringAsFixed(2)}|top=$topStr|max=$maxInFlight';
    },
  );
}
