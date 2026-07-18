import 'package:fxdart/fxdart.dart';

void main() {
  final prices = [10, -5, 20, -1];

  // TODO: use `when` to double only the positive prices
  final adjusted =
      fx(prices).map((p) => when((x) => x > 0, (x) => x * 2, p)).toArray();

  print(adjusted); // [20, -5, 40, -1]
}
