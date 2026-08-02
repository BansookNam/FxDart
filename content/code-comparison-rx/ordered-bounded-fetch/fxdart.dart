import 'package:fxdart/fxdart.dart';

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
  // mapConcurrent keeps at most 4 in flight AND yields in source order.
  final profiles =
      await fx(userIds).toAsync().mapConcurrent(4, fetchProfile).toList();

  profiles.forEach(print);
  print('max in flight: $maxInFlight');
}
