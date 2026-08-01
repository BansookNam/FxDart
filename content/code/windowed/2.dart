import 'package:fxdart/fxdart.dart';

void main() {
  const limit = 100;
  final daily = [80, 120, 130, 110, 90, 140, 150, 160];

  // TODO: a streak is 3 consecutive days over the limit.
  // Slide a window of 3 over the days, then keep only the windows where
  // EVERY day is over the limit (hint: .filter + w.every).
  final streaks = fx(daily)
      .windowed(3) // ← add the filter here
      .toList();

  print(streaks);
  // Expected once solved: [[140, 150, 160]]
}
