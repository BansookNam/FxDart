import 'package:fxdart/fxdart.dart';

const principal = 1000.0;
const rate = 0.05;
const years = 6;

void main() {
  final table = fx(range(1, years + 1))
      .scan((row, year) => (year, row.$2 * (1 + rate)), (0, principal))
      .map((row) => 'year ${row.$1}: \$${row.$2.toStringAsFixed(2)}')
      .toList();
  print(table.join('\n'));
}
