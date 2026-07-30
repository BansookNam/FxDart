import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final items = makeItems();
  await bench(
    slug: 'invoice-summary',
    impl: 'native',
    n: n,
    run: () {
      final totals = <String, double>{};
      for (final l in items) {
        totals[l.category] = (totals[l.category] ?? 0) + l.qty * l.unitPrice;
      }
      final rows = totals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final total = items.fold(0.0, (sum, l) => sum + l.qty * l.unitPrice);
      final lines = rows
          .map((row) => '${row.key}: \$${row.value.toStringAsFixed(2)}')
          .toList();
      return '${lines.length}|${lines.first}|${lines.last}'
          '|total=${total.toStringAsFixed(2)}';
    },
  );
}
