import 'package:fxdart/fxdart.dart';

class Txn {
  final String id;
  final String merchant;
  final double amount;
  final String status; // captured | refund | failed
  const Txn(this.id, this.merchant, this.amount, this.status);
  double get signed => status == 'refund' ? -amount : amount;
}

const txns = [
  Txn('t1', 'Cafe Luna', 12.50, 'captured'),
  Txn('t2', 'BookNook', 34.00, 'captured'),
  Txn('t3', 'Cafe Luna', 8.25, 'captured'),
  Txn('t4', 'GadgetHub', 249.99, 'failed'),
  Txn('t5', 'BookNook', 60.00, 'refund'),
  Txn('t6', 'GadgetHub', 89.90, 'captured'),
  Txn('t7', 'Cafe Luna', 4.75, 'refund'),
  Txn('t8', 'BookNook', 19.99, 'captured'),
  Txn('t9', 'GadgetHub', 129.00, 'captured'),
  Txn('t10', 'Cafe Luna', 16.00, 'captured'),
];

class Posted {
  final String merchant;
  final double net;
  final int count;
  const Posted(this.merchant, this.net, this.count);
}

int inFlight = 0;
int maxInFlight = 0;

/// Posts one merchant's settlement to the bank gateway.
Future<Posted> post(String merchant, double net, int count) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future.delayed(const Duration(milliseconds: 20));
  inFlight--;
  return Posted(merchant, net, count);
}

Future<void> main() async {
  final byMerchant = fx(txns)
      .reject((t) => t.status == 'failed')
      .groupBy((t) => t.merchant);
  final posted = await fx(byMerchant.entries)
      .map((kv) =>
          (kv.key, fx(kv.value).sumBy((t) => t.signed).toDouble(), kv.value.length))
      .sortBy((m) => m.$1)
      .toAsync()
      .map((m) => post(m.$1, m.$2, m.$3))
      .concurrent(2)
      .toList();
  print('2026-07-27 close — ${posted.length} merchants, 2 postings at a time:');
  for (final p in posted) {
    print('  ${p.merchant}: ${p.count} txns, net \$${p.net.toStringAsFixed(2)}');
  }
  final (payouts, collections) = fx(posted).partition((p) => p.net >= 0);
  print('payouts: ${payouts.length}, collections due: ${collections.length}');
  final total = fx(posted).sumBy((p) => p.net);
  print('settled: \$${total.toStringAsFixed(2)}');
  print('max postings in flight: $maxInFlight');
}
