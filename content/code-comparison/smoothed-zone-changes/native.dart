String zone(double t) => t < 20 ? 'cool' : (t < 25 ? 'ok' : 'hot');

List<String> zoneChanges(List<double> temps) {
  final smoothed = <double>[];
  for (var i = 0; i + 3 <= temps.length; i++) {
    var sum = 0.0;
    for (var j = i; j < i + 3; j++) {
      sum += temps[j];
    }
    smoothed.add(sum / 3);
  }
  final runStarts = <double>[];
  for (final s in smoothed) {
    if (runStarts.isEmpty || zone(s) != zone(runStarts.last)) {
      runStarts.add(s);
    }
  }
  final lines = <String>[];
  for (var i = 1; i < runStarts.length; i++) {
    final from = runStarts[i - 1];
    final to = runStarts[i];
    lines.add('${zone(from)} → ${zone(to)}'
        ' (avg ${from.toStringAsFixed(1)} → ${to.toStringAsFixed(1)})');
  }
  if (lines.isEmpty) {
    lines.add('stable — no zone changes');
  }
  return lines;
}

void main() {
  final days = {
    '2026-07-14': [18.0, 18.6, 19.2, 21.0, 23.4, 24.6, 25.8, 26.4, 25.2, 23.0, 21.8, 20.6],
    '2026-07-15': [21.4, 21.9, 22.3, 22.8, 23.1, 22.6, 22.2, 21.7, 21.3, 22.0, 22.5, 22.9],
  };
  days.forEach((day, temps) {
    print('$day (3-reading moving average):');
    for (final line in zoneChanges(temps)) {
      print('  $line');
    }
  });
}
