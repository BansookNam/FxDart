import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'monthly-category-report',
    impl: 'native',
    n: n,
    run: () {
      final totals = <String, double>{};
      for (final t in txns) {
        if (!t.date.startsWith('2026-07')) continue;
        totals[t.category] = (totals[t.category] ?? 0) + t.amount;
      }
      final rows = totals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      // The example joins the formatted rows; the checksum stays O(1) instead
      // of embedding all 250 lines.
      final lines = rows
          .map((row) => '${row.key}: \$${row.value.toStringAsFixed(2)}')
          .toList();
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
