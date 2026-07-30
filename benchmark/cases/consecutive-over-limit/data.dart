// Deterministic n-reading CO2 series shared verbatim by both sides.
// ppm in [400, 1400): ~40% of readings exceed 1000, so ~6% of the sliding
// windows fire an alert (~64k alerts at the headline 1,000,000). A 3-long
// over-limit run is planted at n ~/ 2 so at least one alert exists at every
// scale — both pipelines take .first/.last of the alert list.
import '../../harness.dart';

final n = caseN(1000000);

class Reading {
  final String hour;
  final int ppm;
  const Reading(this.hour, this.ppm);
}

List<Reading> makeReadings() {
  final rng = Lcg(6);
  final readings = List.generate(n, (i) {
    final day = i ~/ 24;
    final h = (i % 24).toString().padLeft(2, '0');
    return Reading('d$day $h:00', 400 + rng.nextInt(1000));
  });
  // Planted over-limit run: guarantees alerts.first/.last exist at every n.
  for (var i = n ~/ 2; i < n ~/ 2 + 3; i++) {
    readings[i] = Reading(readings[i].hour, 1200);
  }
  return readings;
}
