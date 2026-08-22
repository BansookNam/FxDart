import 'package:fxdart/fxdart.dart';

void main() {
  final wrapped = fx([1, 2, 3, 4, 5])
      .map((a) => a + 10)
      .filter((a) => a % 2 == 0)
      .toList();

  // The same chain, reached from the collection itself — which
  // reads best when the source is a call:
  //   orders.where(isPaid).fx.groupBy((o) => o.customerId)
  final getter = [1, 2, 3, 4, 5].fx
      .map((a) => a + 10)
      .filter((a) => a % 2 == 0)
      .toList();

  print(wrapped); // [12, 14]
  print(getter); // [12, 14]
}
