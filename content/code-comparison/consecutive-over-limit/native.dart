class Reading {
  final String hour;
  final int ppm;
  const Reading(this.hour, this.ppm);
}

// Hourly CO2 readings for the meeting room, 2026-07-21.
const readings = [
  Reading('09:00', 640),
  Reading('10:00', 820),
  Reading('11:00', 1015),
  Reading('12:00', 1120),
  Reading('13:00', 1080),
  Reading('14:00', 940),
  Reading('15:00', 1030),
  Reading('16:00', 1105),
  Reading('17:00', 1010),
  Reading('18:00', 760),
];

void main() {
  final alerts = <String>[];
  for (var i = 0; i + 2 < readings.length; i++) {
    final a = readings[i];
    final b = readings[i + 1];
    final c = readings[i + 2];
    if (a.ppm > 1000 && b.ppm > 1000 && c.ppm > 1000) {
      alerts.add('${a.hour}–${c.hour}');
    }
  }
  print('Ventilation alerts (3h over 1000 ppm):');
  print(alerts.join('\n'));
}
