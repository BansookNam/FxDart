import 'package:fxdart/fxdart.dart';

void main() async {
  final orders = ['a:2', 'b:5', 'a:3', 'c:1', 'b:4'];

  // foldByAsync / .toAsync().foldBy(...) awaits the key selector and the
  // combining step for each element, folding in source order.
  final byCustomer = await fx(orders).toAsync().foldBy(
        (o) => delay(const Duration(milliseconds: 50), o.split(':')[0]),
        0,
        (total, o) => total + int.parse(o.split(':')[1]),
      );

  print(byCustomer); // {a: 5, b: 9, c: 1}
}
