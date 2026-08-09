import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final logs = makeLogs();
  await bench(
    slug: 'recent-errors',
    impl: 'fxdart-fast',
    n: n,
    run: () {
      // Fast path: eager evaluation for filter → uniqBy → take
      final recent = fx(logs, strategy: FxStrategy.fast)
          .filter((l) => l.level == 'ERROR')
          .uniqBy((l) => l.message)
          .take(3);
      return recent.map((l) => '${l.time} ${l.message}').join('|');
    },
  );
}
