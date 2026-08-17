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
      // Same operators, same order as content/code-comparison/
      // multi-currency-report/fxdart.dart. This case previously replaced
      // groupBy/sumBy/sortBy/uniq/maxBy with hand-written loops and toSet(),
      // which measured a program the page does not show; see
      // tool/check_benchmark_faithfulness.dart.
      final usd = fx(
        txns,
      ).map((t) => (t, t.amount * rates[t.currency]!)).toList();

      final byCategory = fx(
        usd,
      ).foldBy((p) => p.$1.category, 0.0, (s, p) => s + p.$2);
      final catLines = fx(byCategory.entries)
          .sortBy((e) => -e.value)
          .map((e) => '  ${e.key.padRight(8)} ${money(e.value)}');

      final currencies = fx(
        txns,
      ).map((t) => t.currency).uniq().sortBy((c) => c);
      final biggest = fx(usd).maxBy((p) => p.$2)!;
      final total = fx(usd).sumBy((p) => p.$2);

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
