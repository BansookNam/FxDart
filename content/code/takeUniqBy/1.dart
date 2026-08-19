import 'package:fxdart/fxdart.dart';

void main() {
  final orders = [
    (id: 1, city: 'Seoul', status: 'paid'),
    (id: 2, city: 'Busan', status: 'cancelled'),
    (id: 3, city: 'Seoul', status: 'paid'),
    (id: 4, city: 'Daegu', status: 'paid'),
    (id: 5, city: 'Incheon', status: 'paid'),
  ];

  // "The first two cities we actually shipped to." The null key drops the
  // cancelled order; the Seoul repeat is dropped as a duplicate key.
  print(takeUniqBy(2, (o) => o.status == 'paid' ? o.city : null, orders));
  // [(city: Seoul, id: 1, status: paid), (city: Daegu, id: 4, status: paid)]

  // count is a ceiling, not a promise — it returns what it found.
  print(takeUniqBy(99, (o) => o.status == 'paid' ? o.city : null, orders).length);
  // 3

  // Every key null means nothing survives.
  print(takeUniqBy(3, (o) => null, orders));
  // []

  // It stops the moment the count is met: the fifth order is never inspected.
  var looked = 0;
  takeUniqBy(2, (o) {
    looked++;
    return o.status == 'paid' ? o.city : null;
  }, orders);
  print('inspected $looked of ${orders.length}');
  // inspected 4 of 5
}
