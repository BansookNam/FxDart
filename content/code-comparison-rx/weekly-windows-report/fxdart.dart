import 'package:fxdart/fxdart.dart';

// Daily spend in cents, 2026-08-01 through 2026-08-21.
const dailyCents = [
  1240, 830, 1555, 905, 2210, 480, 1130, // week 1
  1875, 760, 1420, 2005, 640, 1310, 985, // week 2
  1050, 1660, 815, 2140, 505, 1275, 1730, // week 3
];

void main() {
  fx(dailyCents)
      .chunk(7)
      .zipWithIndex()
      .map((w) => 'week ${w.$1 + 1}: '
          '\$${fx(w.$2).sumBy((c) => c / 100).toStringAsFixed(2)}')
      .toList()
      .forEach(print);
}
