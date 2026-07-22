import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form. Same order rule as intersection: the result comes
  // FROM iterable2, keeping elements whose f-key is ALSO present in
  // iterable1's f-keys.
  final featured = [
    {'sku': 'A1'},
    {'sku': 'B2'},
  ];
  final catalog = [
    {'sku': 'A1', 'title': 'Keyboard'},
    {'sku': 'B2', 'title': 'Mouse'},
    {'sku': 'C3', 'title': 'Monitor'},
  ];

  final featuredProducts = intersectionBy((p) => p['sku'], featured, catalog);
  print(toList(featuredProducts));
  // [{sku: A1, title: Keyboard}, {sku: B2, title: Mouse}]
}
