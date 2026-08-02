import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'first-over-budget-rx',
    impl: 'rxdart',
    n: n,
    run: () async {
      var examined = 0;
      // firstWhere resolves on the first match and cancels the subscription —
      // the doOnData tap counts how many events actually flowed before that.
      final hit = await Stream.fromIterable(txns)
          .doOnData((_) => examined++)
          .firstWhere((t) => t.amount > budget);
      return '${hit.id}|${hit.amount}|$examined';
    },
  );
}
