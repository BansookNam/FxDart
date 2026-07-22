import 'package:fxdart/fxdart.dart';

void main() {
  final products = [
    {'title': 'Keyboard', 'price': 49},
    {'title': 'Mouse', 'price': 19},
    {'title': 'Monitor', 'price': 199},
  ];

  // TODO: use pluck to get a list of just the titles.
  final titles = toList(map((p) => p, products));

  print(titles);
}
