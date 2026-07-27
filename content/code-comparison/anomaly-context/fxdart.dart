import 'package:fxdart/fxdart.dart';

class Reading {
  final String time;
  final double temp;
  const Reading(this.time, this.temp);
}

const limit = 80.0;

const readings = [
  Reading('09:00', 62.1),
  Reading('09:05', 64.8),
  Reading('09:10', 91.2),
  Reading('09:15', 66.0),
  Reading('09:20', 67.4),
  Reading('09:25', 84.9),
  Reading('09:30', 88.3),
  Reading('09:35', 70.2),
  Reading('09:40', 69.5),
  Reading('09:45', 68.1),
];

void main() {
  final context = fx(readings)
      .zipWithIndex()
      .filter((p) => p.$2.temp > limit)
      .flatMap((p) => [p.$1 - 1, p.$1, p.$1 + 1])
      .filter((i) => i >= 0 && i < readings.length)
      .uniq()
      .map((i) {
    final r = readings[i];
    final mark = r.temp > limit ? '!' : ' ';
    return '$mark ${r.time}  ${r.temp.toStringAsFixed(1)} C';
  });

  final peak = fx(readings).maxBy((r) => r.temp)!;
  print(join('\n', [
    'Readings above ${limit.toStringAsFixed(1)} C, with context',
    ...context,
    'Peak: ${peak.temp.toStringAsFixed(1)} C at ${peak.time}',
  ]));
}
