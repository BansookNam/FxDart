import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  final budgets = makeBudgets();
  await bench(
    slug: 'budget-alerts',
    impl: 'fxdart',
    n: n,
    run: () {
      final byCategory = fx(txns).groupBy((t) => t.category);
      final alerts = fx(byCategory.entries)
          .map((kv) => (kv.key, kv.value.fold(0.0, (sum, t) => sum + t.amount)))
          .filter((row) => row.$2 > budgets[row.$1]!)
          .sortBy((row) => budgets[row.$1]! - row.$2) // most over first
          .map((row) => '${row.$1}: \$${row.$2.toStringAsFixed(2)} spent, '
              '\$${budgets[row.$1]!.toStringAsFixed(2)} budget '
              '(over by \$${(row.$2 - budgets[row.$1]!).toStringAsFixed(2)})')
          .toList();
      return '${alerts.length}|${alerts.first}|${alerts.last}';
    },
  );
}
