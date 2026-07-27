// Daily noon temperatures (°C), three full weeks starting Mon 2026-07-06.
const readings = [
  20.1, 21.4, 19.8, 22.0, 23.3, 21.7, 20.5, // week 1
  24.0, 25.2, 26.1, 25.8, 24.4, 23.9, 25.6, // week 2
  22.8, 21.9, 20.7, 19.5, 18.9, 19.2, 20.3, // week 3
];

void main() {
  final lines = <String>[];
  for (var w = 0; w * 7 < readings.length; w++) {
    final week = readings.sublist(w * 7, w * 7 + 7);
    final avg = week.reduce((a, b) => a + b) / week.length;
    lines.add('Week ${w + 1}: ${avg.toStringAsFixed(1)}°C');
  }
  print(lines.join('\n'));
}
