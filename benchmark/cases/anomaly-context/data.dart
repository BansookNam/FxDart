// Deterministic 1,000,000-reading sensor trace shared verbatim by both sides.
// ~0.8% of readings exceed the limit; one reading (index n ~/ 2) is a forced
// unique global peak so peak selection cannot tie at any scale.
import '../../harness.dart';

final n = caseN(1000000);
const limit = 80.0;

class Reading {
  final String time;
  final double temp;
  const Reading(this.time, this.temp);
}

List<Reading> makeReadings() {
  final rng = Lcg(6);
  return List.generate(n, (i) {
    final mins = (i * 5) % 1440;
    final time =
        '${(mins ~/ 60).toString().padLeft(2, '0')}'
        ':${(mins % 60).toString().padLeft(2, '0')}';
    final double temp;
    if (i == n ~/ 2) {
      temp = 120.0; // unique global peak
    } else if (rng.nextInt(1000) < 8) {
      temp = 81.0 + rng.nextInt(150) / 10; // anomaly, 81.0-95.9
    } else {
      temp = 55.0 + rng.nextInt(220) / 10; // normal, 55.0-76.9
    }
    return Reading(time, temp);
  });
}
