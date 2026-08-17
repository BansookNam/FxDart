import 'package:rxdart/rxdart.dart';

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
    impl: 'rxdart',
    n: n,
    run: () async {
      runs = 0;
      // Failures must become data before scan can count them — each probe
      // gets an inner stream that recovers the error as a marker value.
      final states = await Stream.fromIterable(probeIds)
          .asyncExpand(
            (id) => Rx.fromCallable(() async {
              await probe(id);
              return true;
            }).onErrorReturn(false),
          )
          .scan<({int done, int fails})>(
            (acc, ok, _) =>
                (done: acc.done + 1, fails: acc.fails + (ok ? 0 : 1)),
            (done: 0, fails: 0),
          )
          .takeWhileInclusive((s) => s.fails < 3)
          .toList();

      final last = states.last;
      return 'processed=${last.done}|failures=${last.fails}|runs=$runs';
    },
  );
}
