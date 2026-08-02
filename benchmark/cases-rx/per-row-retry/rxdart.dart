import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

final attemptsByRow = <int, int>{};

Future<String> importRow((int, String) row) async {
  final (id, name) = row;
  final attempt = attemptsByRow.update(id, (a) => a + 1, ifAbsent: () => 1);
  await Future<void>.delayed(Duration.zero);
  if (id.isEven && attempt == 1) throw StateError('endpoint reset on $name');
  return 'row $id ($name) imported on attempt $attempt';
}

Future<void> main() async {
  await bench(
    slug: 'per-row-retry',
    impl: 'rxdart',
    n: n,
    run: () async {
      attemptsByRow.clear();
      // Each row gets its own retrying inner stream, 3 subscribed at a
      // time — but flatMap emits in COMPLETION order, so every result
      // must carry its row id for the sort back to source order.
      final results = await Stream.fromIterable(rows)
          .flatMap(
              (row) => Rx.retry(() => Rx.fromCallable(() => importRow(row)), 1)
                  .map((line) => (row.$1, line)),
              maxConcurrent: 3)
          .toList();
      results.sort((a, b) => a.$1.compareTo(b.$1));
      var attempts = 0;
      for (final a in attemptsByRow.values) {
        attempts += a;
      }
      return '${results.length}|${results.first.$2}|${results.last.$2}'
          '|attempts=$attempts';
    },
  );
}
