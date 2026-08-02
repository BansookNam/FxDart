import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

// The example's per-id delay map becomes Duration.zero at benchmark scale.
Future<String> lookup(int id) async {
  await Future<void>.delayed(Duration.zero);
  return 'user#$id';
}

Future<void> main() async {
  await bench(
    slug: 'completion-order-pool',
    impl: 'fxdart',
    n: n,
    run: () async {
      // concurrentPool runs 3 lookups at a time and yields in COMPLETION
      // order.
      final results =
          await fx(ids).toAsync().map(lookup).concurrentPool(3).toList();
      // Order-independent checksum: zero delays make the interleave a
      // scheduling detail, so sum the ids instead of sampling positions.
      var idSum = 0;
      for (final r in results) {
        idSum += int.parse(r.substring(5));
      }
      return '${results.length}|idSum=$idSum';
    },
  );
}
