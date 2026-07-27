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
  final keep = <int>{};
  for (var i = 0; i < readings.length; i++) {
    if (readings[i].temp > limit) {
      for (final j in [i - 1, i, i + 1]) {
        if (j >= 0 && j < readings.length) keep.add(j);
      }
    }
  }

  final context = <String>[];
  for (final i in keep.toList()..sort()) {
    final r = readings[i];
    final mark = r.temp > limit ? '!' : ' ';
    context.add('$mark ${r.time}  ${r.temp.toStringAsFixed(1)} C');
  }

  final peak = readings.reduce((a, b) => a.temp >= b.temp ? a : b);
  print([
    'Readings above ${limit.toStringAsFixed(1)} C, with context',
    ...context,
    'Peak: ${peak.temp.toStringAsFixed(1)} C at ${peak.time}',
  ].join('\n'));
}
