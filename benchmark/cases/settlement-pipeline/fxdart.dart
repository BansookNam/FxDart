import 'package:fxdart/fxdart.dart';

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

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'settlement-pipeline',
    impl: 'fxdart',
    n: n,
    run: () async {
      maxInFlight = 0;
      final byMerchant = fx(txns)
          .reject((t) => t.status == 'failed')
          .groupBy((t) => t.merchant);
      final posted = await fx(byMerchant.entries)
          .map((kv) => (
                kv.key,
                fx(kv.value).sumBy((t) => t.signed).toDouble(),
                kv.value.length
              ))
          .sortBy((m) => m.$1)
          .toAsync()
          .map((m) => post(m.$1, m.$2, m.$3))
          .concurrent(2)
          .toList();
      final (payouts, collections) = fx(posted).partition((p) => p.net >= 0);
      final total = fx(posted).sumBy((p) => p.net);
      final first = posted.first;
      return '${posted.length}|payouts=${payouts.length}'
          '|collections=${collections.length}'
          '|settled=${total.toStringAsFixed(2)}'
          '|first=${first.merchant},${first.count},${first.net.toStringAsFixed(2)}'
          '|max=$maxInFlight';
    },
  );
}
