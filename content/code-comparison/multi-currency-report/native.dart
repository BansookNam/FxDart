class Tx {
  final String date;
  final String category;
  final double amount;
  final String currency;
  const Tx(this.date, this.category, this.amount, this.currency);
}

const rates = {'USD': 1.0, 'EUR': 1.09, 'GBP': 1.27, 'JPY': 0.0063};

const txns = [
  Tx('2026-07-02', 'Travel', 120.00, 'EUR'),
  Tx('2026-07-03', 'Food', 8.40, 'USD'),
  Tx('2026-07-05', 'Travel', 5400, 'JPY'),
  Tx('2026-07-08', 'Lodging', 95.00, 'GBP'),
  Tx('2026-07-09', 'Food', 2200, 'JPY'),
  Tx('2026-07-11', 'Food', 14.30, 'EUR'),
  Tx('2026-07-12', 'Transit', 22.50, 'USD'),
  Tx('2026-07-14', 'Lodging', 110.00, 'EUR'),
];

String money(num n) => '\$${n.toStringAsFixed(2)}';

void main() {
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

  print([
    'Trip expenses in USD (currencies: ${currencies.join(', ')})',
    ...catLines,
    'Largest single expense: ${biggest.$1.category} ${money(biggest.$2)} '
        '(${biggest.$1.amount.toStringAsFixed(2)} ${biggest.$1.currency})',
    'Total: ${money(total)}',
  ].join('\n'));
}
