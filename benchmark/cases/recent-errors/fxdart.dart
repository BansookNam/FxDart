import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final logs = makeLogs();
  await bench(
    slug: 'recent-errors',
    impl: 'fxdart',
    n: n,
    run: () {
      final recent = fx(
        logs,
      ).filter((l) => l.level == 'ERROR').uniqBy((l) => l.message).take(3);
      return recent.map((l) => '${l.time} ${l.message}').join('|');
    },
  );
}
