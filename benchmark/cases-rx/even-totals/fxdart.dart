import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final amounts = makeAmounts();
  await bench(
    slug: 'even-totals',
    impl: 'fxdart',
    n: n,
    run: () {
      final total = fx(compact(amounts)).filter((a) => a.isEven).sum();
      return total;
    },
  );
}
