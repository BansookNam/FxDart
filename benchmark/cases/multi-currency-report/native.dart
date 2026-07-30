import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

String money(num n) => '\$${n.toStringAsFixed(2)}';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'multi-currency-report',
    impl: 'native',
    n: n,
    run: () {
      final usd = txns.map((t) => (t, t.amount * rates[t.currency]!)).toList();

      final catLines = usd
          .groupListsBy((p) => p.$1.category)
          .entries
          .map((e) => (e.key, e.value.fold(0.0, (s, p) => s + p.$2)))
          .sortedBy<num>((c) => -c.$2)
          .map((c) => '  ${c.$1.padRight(8)} ${money(c.$2)}');

      final currencies = txns.map((t) => t.currency).toSet().toList()..sort();
      final biggest = usd.reduce((a, b) => a.$2 >= b.$2 ? a : b);
      final total = usd.fold(0.0, (s, p) => s + p.$2);

      return [
        'Trip expenses in USD (currencies: ${currencies.join(', ')})',
        ...catLines,
        'Largest single expense: ${biggest.$1.category} ${money(biggest.$2)} '
            '(${biggest.$1.amount.toStringAsFixed(2)} ${biggest.$1.currency})',
        'Total: ${money(total)}',
      ].join('\n');
    },
  );
}
