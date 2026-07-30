import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

String money(num n) => '\$${n.toStringAsFixed(2)}';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'monthly-ledger-report',
    impl: 'native',
    n: n,
    run: () {
      final spend = txns.where((t) => t.category != 'Income').toList();
      final total = spend.fold(0.0, (s, t) => s + t.amount);

      final catTotals = spend
          .groupListsBy((t) => t.category)
          .entries
          .map((e) => (e.key, e.value.fold(0.0, (s, t) => s + t.amount)))
          .sortedBy<num>((c) => -c.$2);
      final catLines = [
        for (final c in catTotals) '  ${c.$1.padRight(10)} ${money(c.$2)}',
      ];

      final merchantTotals = spend
          .groupListsBy((t) => t.merchant)
          .entries
          .map((e) => (e.key, e.value.fold(0.0, (s, t) => s + t.amount)))
          .sortedBy<num>((m) => -m.$2)
          .take(3)
          .toList();
      final merchantLines = <String>[];
      for (var i = 0; i < merchantTotals.length; i++) {
        final m = merchantTotals[i];
        merchantLines.add('  ${i + 1}. ${m.$1.padRight(13)}${money(m.$2)}');
      }

      return [
        'July 2026 ledger',
        'Total spent: ${money(total)}',
        '',
        'By category:',
        ...catLines,
        '',
        'Top merchants:',
        ...merchantLines,
      ].join('\n');
    },
  );
}
