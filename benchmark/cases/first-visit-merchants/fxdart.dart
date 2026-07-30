import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'first-visit-merchants',
    impl: 'fxdart',
    n: n,
    run: () {
      // uniq keeps the FIRST occurrence of each merchant, by contract.
      final merchants = fx(txns).map((t) => t.merchant).uniq().toList();
      return '${merchants.length}|${merchants.first}|${merchants.last}';
    },
  );
}
