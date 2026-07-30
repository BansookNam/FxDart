import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'duplicate-transactions',
    impl: 'native',
    n: n,
    run: () {
      final byKey = <String, List<Tx>>{};
      for (final t in txns) {
        byKey
            .putIfAbsent('${t.merchant}|${t.amount}|${t.date}', () => [])
            .add(t);
      }
      final lines = <String>[];
      for (final group in byKey.values) {
        if (group.length > 1) {
          for (final t in group) {
            lines.add(
                '${t.date}  ${t.merchant}  \$${t.amount.toStringAsFixed(2)}');
          }
        }
      }
      final flagged = lines.join('\n');
      return '${flagged.length}'
          '|${flagged.substring(0, 60)}'
          '|${flagged.substring(flagged.length - 60)}';
    },
  );
}
