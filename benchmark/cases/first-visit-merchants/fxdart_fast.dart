import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'first-visit-merchants',
    impl: 'fxdart-fast',
    n: n,
    run: () {
      // Explicit opt-in: fxFast uses eager uniq for dedup-heavy patterns
      final merchants = fxFast(txns)
          .map((t) => t.merchant)
          .uniq()
          .toList();
      return '${merchants.length}|${merchants.first}|${merchants.last}';
    },
  );
}
