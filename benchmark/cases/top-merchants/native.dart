import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

double total(List<Tx> ts) => ts.fold(0.0, (sum, t) => sum + t.amount);

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'top-merchants',
    impl: 'native',
    n: n,
    run: () {
      final byMerchant = txns.groupListsBy((t) => t.merchant);
      final top = byMerchant.entries
          .sortedBy<num>((kv) => -total(kv.value))
          .take(5);
      return top
          .map((kv) => '${kv.key}:${total(kv.value).toStringAsFixed(2)}')
          .join('|');
    },
  );
}
