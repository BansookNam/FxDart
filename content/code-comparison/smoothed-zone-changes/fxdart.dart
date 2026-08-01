import 'package:fxdart/fxdart.dart';

String zone(double t) => t < 20 ? 'cool' : (t < 25 ? 'ok' : 'hot');

List<String> zoneChanges(List<double> temps) => fx(temps)
    .windowed(3)
    .map((w) => fx(w).average())
    .uniqAdjacentBy(zone)
    .pairwise()
    .map((p) => '${zone(p.$1)} → ${zone(p.$2)}'
        ' (avg ${p.$1.toStringAsFixed(1)} → ${p.$2.toStringAsFixed(1)})')
    .ifEmpty(() => ['stable — no zone changes'])
    .toList();

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
