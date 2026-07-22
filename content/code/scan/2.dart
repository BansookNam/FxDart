import 'package:fxdart/fxdart.dart';

void main() {
  final dailySteps = [4000, 6500, 3000, 8000];

  // TODO: use scan to produce a running total of steps, seeded at 0.
  final totals = fx(dailySteps).toList();

  print(totals);
}
