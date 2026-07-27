import 'package:fxdart/fxdart.dart';

class Item {
  final String name;
  final int stock;
  final int minStock;
  final int reorderQty;
  final double unitCost;
  const Item(this.name, this.stock, this.minStock, this.reorderQty,
      this.unitCost);
}

const budget = 500.0;

const items = [
  Item('Espresso Beans', 2, 10, 12, 18.00),
  Item('Oat Milk', 5, 12, 24, 3.80),
  Item('Filter Papers', 1, 6, 10, 6.40),
  Item('Ceramic Mug', 18, 6, 6, 12.00),
  Item('Hand Grinder', 2, 3, 4, 49.90),
  Item('Cleaning Tabs', 3, 5, 8, 9.50),
  Item('Paper Cups', 30, 120, 200, 0.05),
];

String money(num n) => '\$${n.toStringAsFixed(2)}';

void main() {
  final needed = fx(items)
      .filter((i) => i.stock < i.minStock)
      .sortBy((i) => i.stock - i.minStock) // biggest deficit first
      .toList();

  final running = fx(needed)
      .scan((acc, i) => acc + i.reorderQty * i.unitCost, 0.0)
      .drop(1); // scan emits the seed first

  final plan =
      fx(needed).zip(running).takeWhile((p) => p.$2 <= budget).toList();
  final lines = fx(plan).map((p) => '  ${p.$1.name.padRight(15)} '
      'x${'${p.$1.reorderQty}'.padLeft(3)}  '
      '${money(p.$1.reorderQty * p.$1.unitCost).padRight(8)} '
      'running ${money(p.$2)}').toList();
  final spent = fx(plan).sumBy((p) => p.$1.reorderQty * p.$1.unitCost);

  print(join('\n', [
    'Restock plan (budget ${money(budget)})',
    ...lines,
    'Ordering ${lines.length} of ${needed.length} needed items; '
        'total ${money(spent)}, ${money(budget - spent)} left',
  ]));
}
