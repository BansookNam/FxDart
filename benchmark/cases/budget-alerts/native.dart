import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  final budgets = makeBudgets();
  await bench(
    slug: 'budget-alerts',
    impl: 'native',
    n: n,
    run: () {
      final totals = <String, double>{};
      for (final t in txns) {
        totals[t.category] = (totals[t.category] ?? 0) + t.amount;
      }
      final over =
          totals.entries.where((e) => e.value > budgets[e.key]!).toList()..sort(
            (a, b) => (budgets[a.key]! - a.value).compareTo(
              budgets[b.key]! - b.value,
            ),
          ); // most over first
      final alerts = over
          .map(
            (e) =>
                '${e.key}: \$${e.value.toStringAsFixed(2)} spent, '
                '\$${budgets[e.key]!.toStringAsFixed(2)} budget '
                '(over by \$${(e.value - budgets[e.key]!).toStringAsFixed(2)})',
          )
          .toList();
      return '${alerts.length}|${alerts.first}|${alerts.last}';
    },
  );
}
