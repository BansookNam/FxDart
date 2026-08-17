import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'food-spending',
    impl: 'fxdart',
    n: n,
    run: () {
      final total = fx(
        txns,
      ).filter((t) => t.category == 'Food').sumBy((t) => t.amount);
      return total.toStringAsFixed(2);
    },
  );
}
