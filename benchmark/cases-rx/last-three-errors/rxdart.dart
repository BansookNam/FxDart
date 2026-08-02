import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final logLines = makeLogLines();
  await bench(
    slug: 'last-three-errors',
    impl: 'rxdart',
    n: n,
    run: () async {
      // takeLast cannot emit anything until the source is done — the last
      // three are only knowable once the done event arrives.
      final recent = await Stream.fromIterable(logLines)
          .where((l) => l.startsWith('ERROR'))
          .takeLast(3)
          .toList();
      return recent.join('|');
    },
  );
}
