import 'package:fxdart/fxdart.dart';

void main() {
  final orders = [
    (id: 1, total: 40, refunded: false),
    (id: 2, total: 15, refunded: false),
    (id: 3, total: 90, refunded: false),
  ];

  // "No order was refunded" — said as a universal, not !some:
  print(fxNone((o) => o.refunded, orders)); // true
  print(fx(orders).none((o) => o.total > 50)); // false (order 3)

  // An empty input has no counter-example, so none is true:
  print(fxNone((int n) => n < 0, <int>[])); // true

  // It stops at the first match — the rest is never tested:
  var tested = 0;
  final clean = fxNone((int n) {
    tested++;
    return n < 0;
  }, [4, -1, 7, -3, 9]);
  print('$clean after $tested tests'); // false after 2 tests
}
