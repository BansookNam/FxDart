import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'duplicate-transactions',
    impl: 'fxdart',
    n: n,
    run: () {
      final byKey = fx(
        txns,
      ).groupBy((t) => '${t.merchant}|${t.amount}|${t.date}');
      final flagged = fx(byKey.values)
          .filter((group) => group.length > 1)
          .flatMap((group) => group) // every transaction involved, for review
          .map(
            (t) => '${t.date}  ${t.merchant}  \$${t.amount.toStringAsFixed(2)}',
          )
          .join('\n');
      return '${flagged.length}'
          '|${flagged.substring(0, 60)}'
          '|${flagged.substring(flagged.length - 60)}';
    },
  );
}
