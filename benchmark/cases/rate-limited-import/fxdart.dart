import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

int inFlight = 0;
int maxInFlight = 0;

/// The rate-limited import endpoint: accepts one batch per call.
/// (Deviation from the example: the 15 ms window is Duration.zero here.)
Future<(int, double)> importBatch(List<Txn> batch) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  final ack = await delay(Duration.zero,
      (batch.length, fx(batch).sumBy((t) => t.amount).toDouble()));
  inFlight--;
  return ack;
}

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'rate-limited-import',
    impl: 'fxdart',
    n: n,
    run: () async {
      maxInFlight = 0;
      final report = await fx(txns)
          .chunk(3)
          .toAsync()
          .map(importBatch)
          .concurrent(1)
          .scan((acc, b) => (acc.$1 + 1, b.$1, b.$2, acc.$4 + b.$2),
              (0, 0, 0.0, 0.0))
          .drop(1) // drop the scan seed
          .toList();
      final last = report.last;
      return '${report.length}'
          '|last=${last.$1},${last.$2},${last.$3.toStringAsFixed(2)},${last.$4.toStringAsFixed(2)}'
          '|max=$maxInFlight';
    },
  );
}
