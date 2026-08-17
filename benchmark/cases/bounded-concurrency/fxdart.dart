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
    slug: 'bounded-concurrency',
    impl: 'fxdart',
    n: n,
    run: () async {
      maxInFlight = 0;
      final profiles = await fx(
        userIds,
      ).toAsync().map(fetchProfile).concurrent(2).toList();
      return '${profiles.length}|${profiles.last}|max=$maxInFlight';
    },
  );
}
