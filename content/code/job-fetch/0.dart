import 'package:fxdart/fxdart.dart';

const userIds = [1, 2, 3, 4, 5, 6];

int inFlight = 0;
int maxInFlight = 0;

Future<String> fetchProfile(int id) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future<void>.delayed(const Duration(milliseconds: 20));
  inFlight--;
  return 'user#$id';
}

Future<void> main() async {
  final profiles = await fx(userIds).mapConcurrent(2, fetchProfile).toList();
  print(profiles.join(', '));
  print('max requests in flight: $maxInFlight');
  // user#1, user#2, user#3, user#4, user#5, user#6
  // max requests in flight: 2
}
