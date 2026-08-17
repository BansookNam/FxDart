import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

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
  await Future<void>.delayed(Duration.zero);
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
  final txns = makeTxns();
  await bench(
    slug: 'settlement-pipeline',
    impl: 'native',
    n: n,
    run: () async {
      maxInFlight = 0;
      final byMerchant = txns
          .where((t) => t.status != 'failed')
          .groupListsBy((t) => t.merchant);
      final batches = byMerchant.entries
          .map(
            (kv) => (
              kv.key,
              kv.value.fold(0.0, (sum, t) => sum + t.signed),
              kv.value.length,
            ),
          )
          .sortedBy((m) => m.$1);
      final posted = await postAll(batches);
      final payouts = posted.where((p) => p.net >= 0).length;
      final total = posted.fold(0.0, (sum, p) => sum + p.net);
      final first = posted.first;
      return '${posted.length}|payouts=$payouts'
          '|collections=${posted.length - payouts}'
          '|settled=${total.toStringAsFixed(2)}'
          '|first=${first.merchant},${first.count},${first.net.toStringAsFixed(2)}'
          '|max=$maxInFlight';
    },
  );
}
