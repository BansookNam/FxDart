import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final feed = makeFeed();
  await bench(
    slug: 'status-transitions',
    impl: 'rxdart',
    n: n,
    run: () async {
      final changes = await Stream.fromIterable(feed)
          .distinct() // plain Stream.distinct is adjacent-only: one per run
          .map((s) => 'status now: $s')
          .toList();

      // The global cousin: rxdart's distinctUnique dedups across the whole
      // stream, so each status survives only once.
      final seen = await Stream.fromIterable(feed).distinctUnique().toList();

      return '${changes.length}|${changes.first}|${changes.last}'
          '|seen=${seen.join(',')}';
    },
  );
}
