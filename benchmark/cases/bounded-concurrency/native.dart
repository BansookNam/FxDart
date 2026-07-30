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

Future<List<String>> fetchAll(List<int> ids, int limit) async {
  final results = List<String?>.filled(ids.length, null);
  var next = 0;
  Future<void> worker() async {
    while (next < ids.length) {
      final i = next++;
      results[i] = await fetchProfile(ids[i]);
    }
  }

  await Future.wait([for (var i = 0; i < limit; i++) worker()]);
  return results.cast<String>();
}

Future<void> main() async {
  await bench(
    slug: 'bounded-concurrency',
    impl: 'native',
    n: n,
    run: () async {
      maxInFlight = 0;
      final profiles = await fetchAll(userIds, 2);
      return '${profiles.length}|${profiles.last}|max=$maxInFlight';
    },
  );
}
