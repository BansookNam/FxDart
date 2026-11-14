import 'package:fxdart/fxdart.dart';

void main() {
  final products = [
    (name: 'pen', price: 2),
    (name: 'lamp', price: 40),
    (name: 'mug', price: 9),
    (name: 'desk', price: 180),
    (name: 'book', price: 15),
  ];

  // quantileBy returns the element, not the number:
  final median = fx(products).quantileBy(0.5, (p) => p.price);
  print(median); // (name: book, price: 15)

  final cheap = fxQuantileBy(0.25, (p) => p.price, products);
  print(cheap?.name); // mug
}
