import 'package:collection/collection.dart';

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
  final needed = items
      .where((i) => i.stock < i.minStock)
      .sortedBy<num>((i) => i.stock - i.minStock); // biggest deficit first

  final lines = <String>[];
  var running = 0.0;
  for (final i in needed) {
    final cost = i.reorderQty * i.unitCost;
    if (running + cost > budget) break;
    running += cost;
    lines.add('  ${i.name.padRight(15)} '
        'x${'${i.reorderQty}'.padLeft(3)}  '
        '${money(cost).padRight(8)} '
        'running ${money(running)}');
  }

  print([
    'Restock plan (budget ${money(budget)})',
    ...lines,
    'Ordering ${lines.length} of ${needed.length} needed items; '
        'total ${money(running)}, ${money(budget - running)} left',
  ].join('\n'));
}
