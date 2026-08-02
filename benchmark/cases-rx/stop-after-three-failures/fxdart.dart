import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

int runs = 0;

// One health probe — throws when the endpoint is down.
Future<void> probe(int id) async {
  runs++;
  await Future<void>.delayed(Duration.zero);
  if (isFailing(id)) throw StateError('probe $id failed');
}

Future<void> main() async {
  await bench(
    slug: 'stop-after-three-failures',
    impl: 'fxdart',
    n: n,
    run: () async {
      runs = 0;
      final states = await fx(probeIds)
          .toAsync()
          .map((id) async {
            try {
              await probe(id);
              return true;
            } catch (_) {
              return false;
            }
          })
          .scan<({int done, int fails})>(
              (acc, ok) =>
                  (done: acc.done + 1, fails: acc.fails + (ok ? 0 : 1)),
              (done: 0, fails: 0))
          .takeUntilInclusive((s) => s.fails == 3)
          .toList();

      final last = states.last;
      return 'processed=${last.done}|failures=${last.fails}|runs=$runs';
    },
  );
}
