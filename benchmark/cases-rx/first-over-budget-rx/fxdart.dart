import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'first-over-budget-rx',
    impl: 'fxdart',
    n: n,
    run: () {
      var examined = 0;
      // find stops pulling at the first match — the predicate runs once per
      // pulled element, so counting inside it shows how far the pull went.
      final hit = fx(txns).find((t) {
        examined++;
        return t.amount > budget;
      });
      return '${hit!.id}|${hit.amount}|$examined';
    },
  );
}
