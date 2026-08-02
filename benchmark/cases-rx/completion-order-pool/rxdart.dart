import 'package:rxdart/rxdart.dart';

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
    impl: 'rxdart',
    n: n,
    run: () async {
      // flatMap runs 3 lookups at a time and emits each result the moment
      // it completes — completion order is its native behavior.
      final results = await Stream.fromIterable(ids)
          .flatMap((id) => Rx.fromCallable(() => lookup(id)), maxConcurrent: 3)
          .toList();
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
