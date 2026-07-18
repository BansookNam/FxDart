import 'package:fxdart/fxdart.dart';

void main() {
  final prices = [10, 25, 40];

  // TODO: use peek to print 'checking price: $p' for each price, without
  // changing the values, then sum them with fold.
  final total = fx(prices).fold(0, (acc, p) => acc + p);

  print('total: $total');
}
