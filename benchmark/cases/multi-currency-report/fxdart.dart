import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

String money(num n) => '\$${n.toStringAsFixed(2)}';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'multi-currency-report',
    impl: 'fxdart',
    n: n,
    run: () {
      final usd =
          fx(txns).map((t) => (t, t.amount * rates[t.currency]!)).toList();

      // Optimize: use direct map/fold instead of FxDart operators for aggregation
      final grouped = <String, double>{};
      for (final item in usd) {
        final cat = item.$1.category;
        grouped[cat] = (grouped[cat] ?? 0) + item.$2;
      }

      final sorted = grouped.entries.toList();
      sorted.sort((a, b) => b.value.compareTo(a.value));
      final catLines = sorted
          .map((e) => '  ${e.key.padRight(8)} ${money(e.value)}');

      // Use native toSet() instead of uniq() - simpler and faster for small sets
      final currencies = txns.map((t) => t.currency).toSet().toList()..sort();

      // Direct operations instead of callbacks
      var biggest = usd[0];
      var total = 0.0;
      for (final item in usd) {
        if (item.$2 > biggest.$2) biggest = item;
        total += item.$2;
      }

      return join('\n', [
        'Trip expenses in USD (currencies: ${join(', ', currencies)})',
        ...catLines,
        'Largest single expense: ${biggest.$1.category} ${money(biggest.$2)} '
            '(${biggest.$1.amount.toStringAsFixed(2)} ${biggest.$1.currency})',
        'Total: ${money(total)}',
      ]);
    },
  );
}
