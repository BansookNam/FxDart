import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

int inFlight = 0;
int maxInFlight = 0;

Future<String> fetchProfile(int id) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future<void>.delayed(Duration.zero);
  inFlight--;
  return 'user#$id';
}

Future<void> main() async {
  await bench(
    slug: 'ordered-bounded-fetch',
    impl: 'rxdart',
    n: n,
    run: () async {
      inFlight = 0;
      maxInFlight = 0;
      // flatMap bounds in-flight work at 4 but emits in COMPLETION order —
      // tag each result with its id and sort to recover the source order.
      final tagged = await Stream.fromIterable(userIds)
          .flatMap(
            (id) => Rx.fromCallable(() => fetchProfile(id)).map((p) => (id, p)),
            maxConcurrent: 4,
          )
          .toList();

      tagged.sort((a, b) => a.$1.compareTo(b.$1));
      return '${tagged.length}|${tagged.first.$2}|${tagged.last.$2}'
          '|max=$maxInFlight';
    },
  );
}
