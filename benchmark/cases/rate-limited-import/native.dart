import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

int inFlight = 0;
int maxInFlight = 0;

/// The rate-limited import endpoint: accepts one batch per call.
/// (Deviation from the example: the 15 ms window is Duration.zero here.)
Future<(int, double)> importBatch(List<Txn> batch) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future<void>.delayed(Duration.zero);
  final ack = (batch.length, batch.fold(0.0, (sum, t) => sum + t.amount));
  inFlight--;
  return ack;
}

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'rate-limited-import',
    impl: 'native',
    n: n,
    run: () async {
      maxInFlight = 0;
      final report = <(int, int, double, double)>[];
      var running = 0.0;
      var batchNo = 0;
      for (final batch in txns.slices(3)) {
        final (count, amount) = await importBatch(batch);
        batchNo++;
        running += amount;
        report.add((batchNo, count, amount, running));
      }
      final last = report.last;
      return '${report.length}'
          '|last=${last.$1},${last.$2},${last.$3.toStringAsFixed(2)},${last.$4.toStringAsFixed(2)}'
          '|max=$maxInFlight';
    },
  );
}
