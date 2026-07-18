import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // Fetch orders concurrently, then keep only the first order per customer.
  final orders = [
    {'customer': 'a', 'amount': 10},
    {'customer': 'b', 'amount': 20},
    {'customer': 'a', 'amount': 30},
  ];

  final fetched = fx(orders)
      .toAsync()
      .map((o) => delay(Duration(milliseconds: 100), o))
      .concurrent(3);

  final firstPerCustomer =
      await fxAsync(uniqByAsync((o) => o['customer'], fetched)).toArray();

  print(firstPerCustomer); // [{customer: a, amount: 10}, {customer: b, amount: 20}]
  print('took ${sw.elapsedMilliseconds}ms'); // ~100ms
}
