import 'package:fxdart/fxdart.dart';

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

Future<void> main() async {
  final profiles = await fx(userIds)
      .toAsync()
      .map(fetchProfile)
      .concurrent(2)
      .toList();
  print(profiles.join(', '));
  print('max requests in flight: $maxInFlight');
}
