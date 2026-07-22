import 'package:fxdart/fxdart.dart';

void main() {
  final rawRows = [
    {'price': '9.99', 'qty': '3'},
    {'price': '4.50', 'qty': '2'},
  ];

  final parsed = fx(rawRows)
      .map((r) => evolve({
            'price': (v) => double.parse(v as String),
            'qty': (v) => int.parse(v as String),
          }, r))
      .toList();

  print(parsed); // [{price: 9.99, qty: 3}, {price: 4.5, qty: 2}]
}
