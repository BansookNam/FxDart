import 'package:fxdart/fxdart.dart';

void main() {
  final products = [
    {'name': 'mouse', 'price': 25},
    {'name': 'keyboard', 'price': 60},
    {'name': 'monitor', 'price': 220},
  ];

  // TODO: find the CHEAPEST price among the products.
  final cheapest = fx(products).map((p) => p['price'] as num).sum();

  print(cheapest);
}
