import 'package:fxdart/fxdart.dart';

class Product {
  final String name;
  final double price;
  final bool inStock;
  const Product(this.name, this.price, this.inStock);
}

const products = [
  Product('Espresso Kit', 49.00, true),
  Product('Travel Mug', 19.50, true),
  Product('Pour-over Set', 34.25, false),
  Product('Grinder', 89.99, true),
  Product('Filter Pack', 6.40, true),
  Product('Milk Frother', 24.90, true),
  Product('Scale', 42.00, true),
  Product('Kettle', 58.75, false),
  Product('Tamper', 15.30, true),
  Product('Cold Brew Jar', 27.80, true),
];

void main() {
  const page = 2;
  const pageSize = 3;
  final lines = fx(products)
      .filter((p) => p.inStock)
      .sortBy((p) => p.price)
      .drop((page - 1) * pageSize)
      .take(pageSize)
      .map((p) => '${p.name} — \$${p.price.toStringAsFixed(2)}')
      .toList();
  print('Page $page of in-stock products:');
  print(lines.join('\n'));
}
