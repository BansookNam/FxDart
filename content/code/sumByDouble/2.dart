import 'package:fxdart/fxdart.dart';

void main() {
  final orders = [
    (item: 'tea', qty: 2, unit: 1.25),
    (item: 'cake', qty: 1, unit: 3.5),
  ];

  // TODO: total the quantities with sumByInt and the cost
  // (qty * unit) with sumByDouble, so neither needs a cast.
  final int items = fx(orders).sumBy((o) => o.qty).toInt();
  final double cost = fx(orders).sumBy((o) => o.qty * o.unit).toDouble();

  print('$items items, $cost'); // should print: 3 items, 6.0
}
