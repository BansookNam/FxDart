import 'package:collection/collection.dart';

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
  await Future.delayed(const Duration(milliseconds: 15));
  final ack = (batch.length, batch.fold(0.0, (sum, t) => sum + t.amount));
  inFlight--;
  return ack;
}

Future<void> main() async {
  final report = <(int, int, double, double)>[];
  var running = 0.0;
  var n = 0;
  for (final batch in txns.slices(3)) {
    final (count, amount) = await importBatch(batch);
    n++;
    running += amount;
    report.add((n, count, amount, running));
  }
  print('importing ${txns.length} txns in batches of 3, one at a time:');
  for (final (n, count, amount, running) in report) {
    print('  batch $n: $count txns, \$${amount.toStringAsFixed(2)} '
        '— running total \$${running.toStringAsFixed(2)}');
  }
  print('max batches in flight: $maxInFlight');
}
