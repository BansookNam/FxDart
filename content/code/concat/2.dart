import 'package:fxdart/fxdart.dart';

void main() {
  final morning = ['wake', 'coffee'];
  final evening = ['dinner', 'sleep'];

  // TODO: concatenate morning and evening into one schedule
  final schedule = fx(morning).toArray();

  print(schedule);
}
