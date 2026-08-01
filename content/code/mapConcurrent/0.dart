import 'package:fxdart/fxdart.dart';

int inFlight = 0;
int maxInFlight = 0;

Future<String> fetchProfile(int id) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  // Later ids finish FIRST — yet the results still come out in order.
  await Future.delayed(Duration(milliseconds: 40 - id * 10));
  inFlight--;
  return 'user#$id';
}

void main() async {
  final profiles =
      await fx([1, 2, 3, 4, 5, 6]).mapConcurrent(3, fetchProfile).toList();

  print(profiles); // [user#1, user#2, ..., user#6] — source order
  print('max in flight: $maxInFlight'); // 3 — the limit was honored
}
