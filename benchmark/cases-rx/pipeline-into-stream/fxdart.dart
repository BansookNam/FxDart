import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

// The example's per-order delay map becomes Duration.zero at benchmark
// scale.
Future<String> fetchStatus(String id) async {
  await Future<void>.delayed(Duration.zero);
  return '$id ${statuses[id]}';
}

Future<void> main() async {
  await bench(
    slug: 'pipeline-into-stream',
    impl: 'fxdart',
    n: n,
    run: () async {
      // The pipeline fetches 2 at a time in order, pairs the results with
      // chunk(2) — fxdart's bufferCount — and toStream() hands the batches
      // to any stream consumer.
      final stream =
          fx(orderIds).toAsync().mapConcurrent(2, fetchStatus).chunk(2).toStream();
      final batches = <List<String>>[];
      await for (final b in stream) {
        batches.add(b);
      }
      // Order-independent checksum, matching the rx side: sum per-line
      // codes rather than sampling batch contents.
      var items = 0;
      var code = 0;
      for (final batch in batches) {
        items += batch.length;
        for (final line in batch) {
          code = (code + lineCode(line)) & 0x3fffffff;
        }
      }
      return 'batches=${batches.length}|items=$items|'
          'last=${batches.last.length}|code=$code';
    },
  );
}
