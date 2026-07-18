import 'package:fxdart/fxdart.dart';

void main() {
  final product = {'title': 'widget', 'price': 10};

  // TODO: use evolve to double the 'price' and leave 'title' untouched
  final discounted = product;

  print(discounted);
}
