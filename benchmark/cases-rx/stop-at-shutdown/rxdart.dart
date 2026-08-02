import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final events = makeEvents();
  await bench(
    slug: 'stop-at-shutdown',
    impl: 'rxdart',
    n: n,
    run: () async {
      final kept = await Stream.fromIterable(events)
          // Inclusive stop, spelled as while-NOT-marker.
          .takeWhileInclusive((e) => e != 'SHUTDOWN')
          .map((e) => 'event: $e')
          .toList();

      return '${kept.length}|${kept.first}|${kept.last}';
    },
  );
}
