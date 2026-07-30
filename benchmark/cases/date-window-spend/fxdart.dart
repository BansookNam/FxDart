import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'date-window-spend',
    impl: 'fxdart',
    n: n,
    run: () {
      final total = fx(txns)
          .dropWhile((t) => t.date.compareTo(start) < 0)
          .takeWhile((t) => t.date.compareTo(end) <= 0)
          .sumBy((t) => t.amount);
      return total.toStringAsFixed(2);
    },
  );
}
