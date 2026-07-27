import 'package:collection/collection.dart';

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

/// Worker pool over the merchant batches: 2 workers, ordered slots.
Future<List<Posted>> postAll(List<(String, double, int)> batches) async {
  final results = List<Posted?>.filled(batches.length, null);
  var next = 0;
  Future<void> worker() async {
    while (next < batches.length) {
      final i = next++;
      final (merchant, net, count) = batches[i];
      results[i] = await post(merchant, net, count);
    }
  }

  await Future.wait([worker(), worker()]);
  return results.cast<Posted>();
}

Future<void> main() async {
  final byMerchant = txns
      .where((t) => t.status != 'failed')
      .groupListsBy((t) => t.merchant);
  final batches = byMerchant.entries
      .map((kv) => (
            kv.key,
            kv.value.fold(0.0, (sum, t) => sum + t.signed),
            kv.value.length
          ))
      .sortedBy((m) => m.$1);
  final posted = await postAll(batches);
  print('2026-07-27 close — ${posted.length} merchants, 2 postings at a time:');
  for (final p in posted) {
    print('  ${p.merchant}: ${p.count} txns, net \$${p.net.toStringAsFixed(2)}');
  }
  final payouts = posted.where((p) => p.net >= 0).length;
  print('payouts: $payouts, collections due: ${posted.length - payouts}');
  final total = posted.fold(0.0, (sum, p) => sum + p.net);
  print('settled: \$${total.toStringAsFixed(2)}');
  print('max postings in flight: $maxInFlight');
}
