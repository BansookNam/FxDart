import 'package:fxdart/fxdart.dart';

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
    impl: 'fxdart',
    n: n,
    run: () async {
      attemptsByRow.clear();
      // Two attempts per row, three rows in flight — each in-flight row
      // retries independently, and mapRetry under concurrent yields in
      // SOURCE order by construction.
      final results = await fx(
        rows,
      ).toAsync().mapRetry(2, importRow).concurrent(3).toList();
      var attempts = 0;
      for (final a in attemptsByRow.values) {
        attempts += a;
      }
      return '${results.length}|${results.first}|${results.last}'
          '|attempts=$attempts';
    },
  );
}
