import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

double total(List<Tx> ts) => ts.fold(0.0, (sum, t) => sum + t.amount);

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'top-merchants',
    impl: 'fxdart',
    n: n,
    run: () {
      final top = fx(
        txns,
      ).groupedBy((t) => t.merchant).sortByDesc((g) => total(g.items)).take(5);
      return top
          .map((g) => '${g.key}:${total(g.items).toStringAsFixed(2)}')
          .join('|');
    },
  );
}
