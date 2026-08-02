import 'package:rxdart/rxdart.dart';

// This week's card feed — searched in arrival order.
const txns = [
  (id: 'T-01', amount: 42),
  (id: 'T-02', amount: 67),
  (id: 'T-03', amount: 15),
  (id: 'T-04', amount: 128),
  (id: 'T-05', amount: 80),
  (id: 'T-06', amount: 210),
  (id: 'T-07', amount: 33),
  (id: 'T-08', amount: 55),
];
const budget = 100;

Future<void> main() async {
  var examined = 0;
  // firstWhere resolves on the first match and cancels the subscription —
  // the doOnData tap counts how many events actually flowed before that.
  final hit = await Stream.fromIterable(txns)
      .doOnData((_) => examined++)
      .firstWhere((t) => t.amount > budget);

  print('First over budget: ${hit.id} (${hit.amount})');
  print('Examined $examined of ${txns.length} transactions');
}
