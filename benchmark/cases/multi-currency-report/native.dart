
import '../../harness.dart';
import 'data.dart';

String money(num n) => '\$${n.toStringAsFixed(2)}';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'multi-currency-report',
    impl: 'native',
    n: n,
    run: () {
      final usd = txns.map((t) => (t, t.amount * rates[t.currency]!)).toList();

      final byCategory = <String, double>{};
      for (final p in usd) {
        byCategory[p.$1.category] = (byCategory[p.$1.category] ?? 0) + p.$2;
      }
      final catLines = (byCategory.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .map((e) => '  ${e.key.padRight(8)} ${money(e.value)}');

      final currencies = txns.map((t) => t.currency).toSet().toList()..sort();
      final biggest = usd.reduce((a, b) => a.$2 >= b.$2 ? a : b);
      final total = usd.fold(0.0, (s, p) => s + p.$2);

      return [
        'Trip expenses in USD (currencies: ${currencies.join(', ')})',
        ...catLines,
        'Largest single expense: ${biggest.$1.category} ${money(biggest.$2)} '
            '(${biggest.$1.amount.toStringAsFixed(2)} ${biggest.$1.currency})',
        'Total: ${money(total)}',
      ].join('\n');
    },
  );
}
