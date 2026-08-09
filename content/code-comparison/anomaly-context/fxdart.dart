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
  // Walk the INDICES, not the readings: an anomaly is rare, so pairing every
  // reading with its index would allocate a record per element to keep a few.
  final context = fx(range(0, readings.length))
      .filter((i) => readings[i].temp > limit)
      .flatMap((i) => [i - 1, i, i + 1])
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
