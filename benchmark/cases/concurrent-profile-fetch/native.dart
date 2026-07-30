import 'package:collection/collection.dart';

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

/// A hand-rolled worker pool: [limit] workers pull from a shared cursor,
/// writing into pre-sized slots so the output keeps the input order.
Future<List<String>> fetchAll(List<User> targets, int limit) async {
  final results = List<String?>.filled(targets.length, null);
  var next = 0;
  Future<void> worker() async {
    while (next < targets.length) {
      final i = next++;
      results[i] = await fetchProfile(targets[i]);
    }
  }

  await Future.wait([for (var i = 0; i < limit; i++) worker()]);
  return results.cast<String>();
}

Future<void> main() async {
  await bench(
    slug: 'concurrent-profile-fetch',
    impl: 'native',
    n: n,
    run: () async {
      inFlight = 0;
      maxInFlight = 0;
      final targets = users.where((u) => u.active).sortedBy<num>((u) => u.id);
      final profiles = await fetchAll(targets, 3);
      final report = profiles.map((p) => '  $p').join('\n');
      return '${report.substring(0, 40)}|len=${report.length}|'
          'max=$maxInFlight';
    },
  );
}
