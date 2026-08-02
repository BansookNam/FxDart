import 'package:rxdart/rxdart.dart';

// Eight profile fetches with staggered response times.
const userIds = [1, 2, 3, 4, 5, 6, 7, 8];
const delaysMs = {1: 80, 2: 20, 3: 60, 4: 40, 5: 30, 6: 70, 7: 10, 8: 50};

int inFlight = 0;
int maxInFlight = 0;

Future<String> fetchProfile(int id) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future.delayed(Duration(milliseconds: delaysMs[id]!));
  inFlight--;
  return 'user#$id';
}

Future<void> main() async {
  // flatMap bounds in-flight work at 4 but emits in COMPLETION order —
  // tag each result with its id and sort to recover the source order.
  final tagged = await Stream.fromIterable(userIds)
      .flatMap(
          (id) => Rx.fromCallable(() => fetchProfile(id)).map((p) => (id, p)),
          maxConcurrent: 4)
      .toList();

  tagged.sort((a, b) => a.$1.compareTo(b.$1));
  for (final (_, profile) in tagged) {
    print(profile);
  }
  print('max in flight: $maxInFlight');
}
