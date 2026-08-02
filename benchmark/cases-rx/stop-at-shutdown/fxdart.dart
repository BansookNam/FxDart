import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final events = makeEvents();
  await bench(
    slug: 'stop-at-shutdown',
    impl: 'fxdart',
    n: n,
    run: () {
      final kept = fx(events)
          // Inclusive stop, spelled as until-marker.
          .takeUntilInclusive((e) => e == 'SHUTDOWN')
          .map((e) => 'event: $e')
          .toList();

      return '${kept.length}|${kept.first}|${kept.last}';
    },
  );
}
