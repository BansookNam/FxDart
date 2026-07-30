import '../../harness.dart';
import 'data.dart';

String fmt(Tx t) => '${t.merchant} \$${t.amount.abs().toStringAsFixed(2)}';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'refunds-vs-charges',
    impl: 'native',
    n: n,
    run: () {
      // The example's two lazy `where` views, materialized through fmt as the
      // example's join would; the checksum stays O(1) per AUTHORING.md.
      final refunds = txns.where((t) => t.amount < 0).map(fmt).toList();
      final charges = txns.where((t) => t.amount >= 0).map(fmt).toList();
      return '${refunds.length}|${refunds.first}|${refunds.last}'
          '|${charges.length}|${charges.first}|${charges.last}';
    },
  );
}
