import 'package:fxdart/fxdart.dart';

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
  // Sliding window of 3: the list zipped with itself shifted by 1 and 2.
  final alerts = fx(readings)
      .zip3(drop(1, readings), drop(2, readings))
      .filter((t) => t.$1.ppm > 1000 && t.$2.ppm > 1000 && t.$3.ppm > 1000)
      .map((t) => '${t.$1.hour}–${t.$3.hour}')
      .join('\n');
  print('Ventilation alerts (3h over 1000 ppm):');
  print(alerts);
}
