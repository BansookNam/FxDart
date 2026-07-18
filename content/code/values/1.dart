import 'package:fxdart/fxdart.dart';

void main() {
  // values() gives a plain lazy Iterable<V>, so it composes with the same
  // chain operators as any other sequence — here, total revenue in stock.
  final stock = {'apples': 4, 'bananas': 0, 'cherries': 12};
  final prices = {'apples': 1.5, 'bananas': 0.5, 'cherries': 2.0};

  final unitsInStock = fx(values(stock)).filter((n) => n > 0).toArray();
  print(unitsInStock); // [4, 12]

  final total = fx(entries(prices))
      .map((e) => e.$2 * (stock[e.$1] ?? 0))
      .sum();
  print(total); // 30.0
}
