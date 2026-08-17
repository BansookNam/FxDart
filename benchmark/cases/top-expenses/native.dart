import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'top-expenses',
    impl: 'native',
    n: n,
    run: () {
      // package:collection's sortedBy returns a new sorted list; negate the
      // key to sort largest-first.
      final top = txns.sortedBy<num>((t) => -t.amount).take(3);
      return top
          .map(
            (t) =>
                '${t.merchant.padRight(15)} \$${t.amount.toStringAsFixed(2)}',
          )
          .join('|');
    },
  );
}
