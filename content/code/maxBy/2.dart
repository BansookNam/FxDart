import 'package:fxdart/fxdart.dart';

void main() {
  final expenses = [
    (title: 'Coffee', amount: 4.50),
    (title: 'Rent', amount: 1200.0),
    (title: 'Groceries', amount: 82.30),
  ];

  // TODO: find the biggest expense WITHOUT sorting — one maxBy call.
  final biggest = fx(expenses).head();

  print(biggest?.title); // should print: Rent
}
