import 'package:fxdart/fxdart.dart';

void main() {
  final temps = [21.0, 22.5, 25.0, 24.0, 23.5, 26.0, 27.5];

  // A window of 3 consecutive readings, sliding by 1 — lazily:
  final smoothed = fx(temps)
      .windowed(3)
      .map((w) => (fx(w).sum() / w.length).toStringAsFixed(1))
      .toList();
  print(smoothed); // [22.8, 23.8, 24.2, 24.5, 25.7]

  // was: for (var i = 0; i + 3 <= temps.length; i++) { temps.sublist(i, i + 3) ... }
  // — index arithmetic and bounds, every time.
}
