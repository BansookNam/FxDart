import 'package:fxdart/fxdart.dart';

void main() {
  final orders = [12.5, 30.0, 7.25];

  // TODO: use forEach to print a receipt line for every order.
  var total = 0.0;
  fx(orders).forEach((price) {
    total += price;
    print('charged \$$price');
  });

  print('total: \$$total');
}
