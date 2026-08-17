import 'package:fxdart/fxdart.dart';

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

Future<void> main() async {
  final ids = [for (final e in ledger) e.id];
  await bench(
    slug: 'daily-ledger-close',
    impl: 'fxdart',
    n: n,
    run: () async {
      maxInFlight = 0;
      final entries = await fx(
        ids,
      ).toAsync().map(loadEntry).concurrent(3).toList();

      final (income, spending) = fx(entries)
          .filter((e) => e.date.year == 2026 && e.date.month == 7)
          .partition((e) => e.type == EntryType.income);
      final earned = fx(income).sumBy((e) => e.amount);
      final spent = fx(spending).sumBy((e) => e.amount);

      final byCategory = fx(spending).groupBy((e) => e.categoryId);
      final top = fx(byCategory.entries)
          .map(
            (kv) =>
                (kv.key, fx(kv.value).sumBy((e) => e.amount), kv.value.length),
          )
          .sortBy((c) => -c.$2)
          .take(3)
          .toList();

      final topStr = fx(
        top,
      ).map((c) => '${c.$1}:${c.$2.toStringAsFixed(2)}:${c.$3}').join(',');
      return '${entries.length}|earned=${earned.toStringAsFixed(2)}'
          '|spent=${spent.toStringAsFixed(2)}|top=$topStr|max=$maxInFlight';
    },
  );
}
