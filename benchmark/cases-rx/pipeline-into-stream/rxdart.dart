import 'package:rxdart/rxdart.dart';

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
    impl: 'rxdart',
    n: n,
    run: () async {
      // Streams end to end: bounded concurrent fetch, then buffer into
      // pairs.
      final batches = await Stream.fromIterable(orderIds)
          .flatMap((id) => Stream.fromFuture(fetchStatus(id)), maxConcurrent: 2)
          .bufferCount(2)
          .toList();
      // Order-independent checksum: flatMap emits in completion order, so
      // sum per-line codes rather than sampling batch contents.
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
