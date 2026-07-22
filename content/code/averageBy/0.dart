import 'package:fxdart/fxdart.dart';

void main() {
  final runs = [
    (day: 'Mon', km: 5.0),
    (day: 'Wed', km: 8.0),
    (day: 'Fri', km: 5.0),
  ];

  // Data-first form: map + average in one step.
  print(averageBy((({String day, double km}) r) => r.km, runs)); // 6.0

  // Chain form — no .map((r) => r.km) stage needed:
  print(fx(runs).averageBy((r) => r.km)); // 6.0

  // Empty input averages to NaN (0/0), exactly like average:
  print(averageBy((int n) => n, <int>[]).isNaN); // true
}
