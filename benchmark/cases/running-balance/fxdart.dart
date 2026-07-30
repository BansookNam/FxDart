import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'running-balance',
    impl: 'fxdart',
    n: n,
    run: () {
      // scan emits its seed first — that becomes the opening-balance line.
      final lines = fx(txns)
          .scan((acc, t) => (t.label, acc.$2 + t.amount),
              ('Opening balance', 250.0))
          .map((e) => '${e.$1.padRight(15)} \$${e.$2.toStringAsFixed(2)}')
          .toList();
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
