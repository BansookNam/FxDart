import 'package:fxdart/fxdart.dart';

void main() {
  // (price, usedFallback) pairs from a price lookup:
  final priced = [
    (sku: 'a', price: 9.99, usedFallback: false),
    (sku: 'b', price: 4.50, usedFallback: true),
    (sku: 'c', price: 12.00, usedFallback: false),
    (sku: 'd', price: 3.25, usedFallback: true),
  ];

  // TODO: count the fallbacks with countWhere — no filter, no size.
  final fallbacks = 0;

  print('fallbacks used: $fallbacks'); // should print: fallbacks used: 2
}
