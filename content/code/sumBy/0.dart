import 'package:fxdart/fxdart.dart';

void main() {
  final cart = [
    (name: 'Bread', price: 3.50),
    (name: 'Milk', price: 2.20),
    (name: 'Cheese', price: 8.00),
  ];

  // Data-first form: map + sum in one step.
  print(sumBy((({String name, double price}) i) => i.price, cart)); // 13.7

  // Chain form — no .map((i) => i.price) stage needed:
  print(fx(cart).sumBy((i) => i.price)); // 13.7

  // Empty input sums to 0, exactly like sum:
  print(sumBy((int n) => n, <int>[])); // 0
}
