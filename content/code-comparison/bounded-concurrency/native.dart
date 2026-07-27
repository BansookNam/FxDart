const userIds = [1, 2, 3, 4, 5, 6];

int inFlight = 0;
int maxInFlight = 0;

Future<String> fetchProfile(int id) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future.delayed(const Duration(milliseconds: 20));
  inFlight--;
  return 'user#$id';
}

/// A hand-rolled worker pool: [limit] workers pull from a shared cursor,
/// writing into pre-sized slots so the output keeps the input order.
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
  final profiles = await fetchAll(userIds, 2);
  print(profiles.join(', '));
  print('max requests in flight: $maxInFlight');
}
