import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

int inFlight = 0;
int maxInFlight = 0;

Future<String> fetchProfile(User u) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future<void>.delayed(Duration.zero);
  inFlight--;
  return 'user#${u.id} ${u.name} <${u.name.toLowerCase()}@example.com>';
}

Future<void> main() async {
  await bench(
    slug: 'concurrent-profile-fetch',
    impl: 'fxdart',
    n: n,
    run: () async {
      inFlight = 0;
      maxInFlight = 0;
      final report = await fx(users)
          .filter((u) => u.active)
          .sortBy((u) => u.id)
          .toAsync()
          .map(fetchProfile)
          .concurrent(3)
          .map((p) => '  $p')
          .join('\n');
      return '${report.substring(0, 40)}|len=${report.length}|'
          'max=$maxInFlight';
    },
  );
}
