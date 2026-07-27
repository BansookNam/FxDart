import 'package:fxdart/fxdart.dart';

class Txn {
  final String id;
  final double amount;
  const Txn(this.id, this.amount);
}

const txns = [
  Txn('t-01', 120.00), Txn('t-02', 42.50), Txn('t-03', 9.99),
  Txn('t-04', 310.25), Txn('t-05', 75.00), Txn('t-06', 18.40),
  Txn('t-07', 220.10), Txn('t-08', 5.25), Txn('t-09', 99.99),
];

int inFlight = 0;
int maxInFlight = 0;

/// The rate-limited import endpoint: accepts one batch per call.
Future<(int, double)> importBatch(List<Txn> batch) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  final ack = await delay(const Duration(milliseconds: 15),
      (batch.length, fx(batch).sumBy((t) => t.amount).toDouble()));
  inFlight--;
  return ack;
}

Future<void> main() async {
  final report = await fx(txns)
      .chunk(3)
      .toAsync()
      .map(importBatch)
      .concurrent(1)
      .scan((acc, b) => (acc.$1 + 1, b.$1, b.$2, acc.$4 + b.$2),
          (0, 0, 0.0, 0.0))
      .drop(1) // drop the scan seed
      .toList();
  print('importing ${txns.length} txns in batches of 3, one at a time:');
  for (final (n, count, amount, running) in report) {
    print('  batch $n: $count txns, \$${amount.toStringAsFixed(2)} '
        '— running total \$${running.toStringAsFixed(2)}');
  }
  print('max batches in flight: $maxInFlight');
}
