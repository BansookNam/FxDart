import 'package:fxdart/fxdart.dart';

void main() {
  final scores = [88, 45, 92, 67, 30, 99, 71];

  // TODO: average only the PASSING scores (>= 60).
  final passingAvg = fx(scores).average();

  print(passingAvg);
}
