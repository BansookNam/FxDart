class Tx {
  final String date;
  final String category;
  final String merchant;
  final double amount;
  const Tx(this.date, this.category, this.merchant, this.amount);
}

const txns = [
  Tx('2026-07-02', 'Food', 'Cafe Aroma', 12.50),
  Tx('2026-07-03', 'Transport', 'Metro', 2.75),
  Tx('2026-07-05', 'Food', 'Green Grocer', 43.20),
  Tx('2026-07-08', 'Fun', 'Cinema', 15.00),
  Tx('2026-07-11', 'Food', 'Noodle Bar', 18.90),
  Tx('2026-07-15', 'Bills', 'Electric Co', 60.34),
  Tx('2026-07-19', 'Food', 'Cafe Aroma', 9.80),
  Tx('2026-07-23', 'Transport', 'Taxi', 11.40),
];

void main() {
  final total = txns
      .where((t) => t.category == 'Food')
      .fold(0.0, (sum, t) => sum + t.amount);
  print('Food spending: \$${total.toStringAsFixed(2)}');
}
