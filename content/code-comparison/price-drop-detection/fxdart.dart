import 'package:fxdart/fxdart.dart';

class Item {
  final String sku;
  final String name;
  final double price;
  const Item(this.sku, this.name, this.price);
}

const june = [
  Item('SKU-01', 'Espresso Beans', 18.00),
  Item('SKU-02', 'Oat Milk', 3.80),
  Item('SKU-03', 'Filter Papers', 6.40),
  Item('SKU-04', 'Ceramic Mug', 12.00),
  Item('SKU-05', 'Hand Grinder', 49.90),
  Item('SKU-06', 'Digital Scale', 24.50),
];

const july = [
  Item('SKU-01', 'Espresso Beans', 14.50),
  Item('SKU-02', 'Oat Milk', 4.10),
  Item('SKU-03', 'Filter Papers', 5.90),
  Item('SKU-04', 'Ceramic Mug', 12.00),
  Item('SKU-05', 'Hand Grinder', 44.00),
  Item('SKU-07', 'Travel Tumbler', 21.00),
];

String money(num n) => '\$${n.toStringAsFixed(2)}';

void main() {
  final old = fx(june).indexBy((i) => i.sku);
  final drops = fx(july)
      .filter((i) => old.containsKey(i.sku) && i.price < old[i.sku]!.price)
      .map((i) => (i, old[i.sku]!.price - i.price))
      .sortBy((d) => -d.$2)
      .toList();

  final lines = fx(drops).map((d) => '  ${d.$1.name.padRight(15)} '
      '${money(old[d.$1.sku]!.price)} -> ${money(d.$1.price)}  '
      '(-${money(d.$2)})');
  final biggest = fx(drops).head()!;
  final savings = fx(drops).sumBy((d) => d.$2);

  print(join('\n', [
    'Price drops, June -> July',
    ...lines,
    'Biggest drop: ${biggest.$1.name} (-${money(biggest.$2)})',
    'Total savings if bought now: ${money(savings)}',
  ]));
}
