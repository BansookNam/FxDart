import 'package:fxdart/fxdart.dart';

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
    impl: 'fxdart',
    n: n,
    run: () async {
      inFlight = 0;
      maxInFlight = 0;
      // mapConcurrent keeps at most 4 in flight AND yields in source order.
      final profiles = await fx(
        userIds,
      ).toAsync().mapConcurrent(4, fetchProfile).toList();

      return '${profiles.length}|${profiles.first}|${profiles.last}'
          '|max=$maxInFlight';
    },
  );
}
