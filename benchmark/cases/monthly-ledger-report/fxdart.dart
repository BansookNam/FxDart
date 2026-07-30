import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

String money(num n) => '\$${n.toStringAsFixed(2)}';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'monthly-ledger-report',
    impl: 'fxdart',
    n: n,
    run: () {
      final spend = fx(txns).filter((t) => t.category != 'Income').toList();
      final total = fx(spend).sumBy((t) => t.amount);

      final catLines = fx(fx(spend).groupBy((t) => t.category).entries)
          .map((e) => (e.key, fx(e.value).sumBy((t) => t.amount)))
          .sortBy((c) => -c.$2)
          .map((c) => '  ${c.$1.padRight(10)} ${money(c.$2)}');

      final merchantLines = fx(fx(spend).groupBy((t) => t.merchant).entries)
          .map((e) => (e.key, fx(e.value).sumBy((t) => t.amount)))
          .sortBy((m) => -m.$2)
          .take(3)
          .zipWithIndex()
          .map((p) => '  ${p.$1 + 1}. ${p.$2.$1.padRight(13)}${money(p.$2.$2)}');

      return join('\n', [
        'July 2026 ledger',
        'Total spent: ${money(total)}',
        '',
        'By category:',
        ...catLines,
        '',
        'Top merchants:',
        ...merchantLines,
      ]);
    },
  );
}
