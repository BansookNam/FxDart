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

      final catLines = fx(fx(usd).groupBy((p) => p.$1.category).entries)
          .map((e) => (e.key, fx(e.value).sumBy((p) => p.$2)))
          .sortBy((c) => -c.$2)
          .map((c) => '  ${c.$1.padRight(8)} ${money(c.$2)}');

      final currencies = fx(txns).map((t) => t.currency).uniq().sortBy((c) => c);
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
