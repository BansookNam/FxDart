import 'package:fxdart/fxdart.dart';

// Daily noon temperatures (°C), three full weeks starting Mon 2026-07-06.
const readings = [
  20.1, 21.4, 19.8, 22.0, 23.3, 21.7, 20.5, // week 1
  24.0, 25.2, 26.1, 25.8, 24.4, 23.9, 25.6, // week 2
  22.8, 21.9, 20.7, 19.5, 18.9, 19.2, 20.3, // week 3
];

void main() {
  final report = fx(readings)
      .chunk(7)
      .map((week) => fx(week).averageBy((t) => t))
      .zipWithIndex()
      .map((e) => 'Week ${e.$1 + 1}: ${e.$2.toStringAsFixed(1)}°C')
      .join('\n');
  print(report);
}
