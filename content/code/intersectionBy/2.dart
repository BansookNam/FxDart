import 'package:fxdart/fxdart.dart';

void main() {
  final onSale = [
    {'sku': 'B2'},
  ];
  final products = [
    {'sku': 'A1', 'title': 'Keyboard'},
    {'sku': 'B2', 'title': 'Mouse'},
  ];

  // TODO: use intersectionBy (keyed on 'sku') to find products that are
  // on sale.
  final saleProducts = toArray(products);

  print(saleProducts);
}
