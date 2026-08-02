import 'package:fxdart/fxdart.dart';

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

void main() {
  var examined = 0;
  // find stops pulling at the first match — the predicate runs once per
  // pulled element, so counting inside it shows how far the pull went.
  final hit = fx(txns).find((t) {
    examined++;
    return t.amount > budget;
  });

  print('First over budget: ${hit!.id} (${hit.amount})');
  print('Examined $examined of ${txns.length} transactions');
}
