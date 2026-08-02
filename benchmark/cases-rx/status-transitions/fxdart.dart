import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final feed = makeFeed();
  await bench(
    slug: 'status-transitions',
    impl: 'fxdart',
    n: n,
    run: () {
      final changes = fx(feed)
          .uniqAdjacent() // drops repeats of the predecessor: one per run
          .map((s) => 'status now: $s')
          .toList();

      // The global cousin: uniq dedups across the whole feed, so each
      // status survives only once.
      final seen = fx(feed).uniq().toList();

      return '${changes.length}|${changes.first}|${changes.last}'
          '|seen=${seen.join(',')}';
    },
  );
}
