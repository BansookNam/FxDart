import 'package:fxdart/fxdart.dart';

void main() {
  final unavailable = [
    {'sku': 'A1'},
  ];
  final products = [
    {'sku': 'A1', 'title': 'Keyboard'},
    {'sku': 'B2', 'title': 'Mouse'},
  ];

  // TODO: use differenceBy (keyed on 'sku') to find products that are
  // still available.
  final available = toList(products);

  print(available);
}
