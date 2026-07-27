const principal = 1000.0;
const rate = 0.05;
const years = 6;

void main() {
  final table = <String>['year 0: \$${principal.toStringAsFixed(2)}'];
  var balance = principal;
  for (var year = 1; year <= years; year++) {
    balance = balance * (1 + rate);
    table.add('year $year: \$${balance.toStringAsFixed(2)}');
  }
  print(table.join('\n'));
}
