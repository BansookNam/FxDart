import 'package:fxdart/fxdart.dart';

class Tx {
  final String date;
  final String category;
  final String merchant;
  final double amount;
  const Tx(this.date, this.category, this.merchant, this.amount);
}

const txns = [
  Tx('2026-07-01', 'Food', 'Green Grocer', 34.20),
  Tx('2026-07-02', 'Transport', 'Metro', 2.75),
  Tx('2026-07-03', 'Food', 'Cafe Aroma', 11.80),
  Tx('2026-07-07', 'Bills', 'Electric Co', 58.40),
  Tx('2026-07-08', 'Food', 'Noodle Bar', 16.90),
  Tx('2026-07-15', 'Fun', 'Cinema', 15.00),
  Tx('2026-07-16', 'Food', 'Green Grocer', 41.35),
  Tx('2026-07-22', 'Transport', 'Taxi', 12.60),
  Tx('2026-07-28', 'Food', 'Cafe Aroma', 9.40),
  Tx('2026-07-29', 'Bills', 'Water Co', 27.15),
];

void main() {
  final spendDays = txns.map((t) => int.parse(t.date.substring(8))).toSet();
  final strip = fx(range(1, 32))
      .map((day) => spendDays.contains(day) ? '·' : '#')
      .join('');
  // scan carries the running streak: reset on a spend day, else +1.
  final longest = fx(range(1, 32))
      .map((day) => spendDays.contains(day))
      .scan((streak, spent) => spent ? 0 : streak + 1, 0)
      .max();
  print('July (# = no-spend day): $strip');
  print('Longest no-spend streak: $longest days');
}
