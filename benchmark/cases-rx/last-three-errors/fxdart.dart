import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final logLines = makeLogLines();
  await bench(
    slug: 'last-three-errors',
    impl: 'fxdart',
    n: n,
    run: () {
      // takeRight keeps a 3-slot window while draining the iterable — the
      // last three are only knowable once the source is exhausted.
      final recent = fx(logLines)
          .filter((l) => l.startsWith('ERROR'))
          .takeRight(3)
          .toList();
      return recent.join('|');
    },
  );
}
