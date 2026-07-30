import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'top-expenses',
    impl: 'fxdart',
    n: n,
    run: () {
      // sortBy is ascending — negate the key to sort largest-first.
      final top = fx(txns).sortBy((t) => -t.amount).take(3).toList();
      return top
          .map((t) => '${t.merchant.padRight(15)} \$${t.amount.toStringAsFixed(2)}')
          .join('|');
    },
  );
}
