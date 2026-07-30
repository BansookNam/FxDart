import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

String fmt(Tx t) => '${t.merchant} \$${t.amount.abs().toStringAsFixed(2)}';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'refunds-vs-charges',
    impl: 'fxdart',
    n: n,
    run: () {
      final (refundTxns, chargeTxns) = fx(txns).partition((t) => t.amount < 0);
      final refunds = fx(refundTxns).map(fmt).toList();
      final charges = fx(chargeTxns).map(fmt).toList();
      return '${refunds.length}|${refunds.first}|${refunds.last}'
          '|${charges.length}|${charges.first}|${charges.last}';
    },
  );
}
