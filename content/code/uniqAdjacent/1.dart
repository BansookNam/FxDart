import 'package:fxdart/fxdart.dart';

void main() {
  final readings = [
    (t: '09:00', temp: 18.2),
    (t: '09:05', temp: 18.9),
    (t: '09:10', temp: 21.4),
    (t: '09:15', temp: 22.0),
    (t: '09:20', temp: 19.5),
  ];

  String zone(double temp) => temp < 20 ? 'cool' : 'warm';

  // uniqAdjacentBy keeps a reading only when its KEY changes — the first
  // reading of each zone run, timestamps intact:
  final changes = fx(readings)
      .uniqAdjacentBy((r) => zone(r.temp))
      .map((r) => '${r.t}: entered ${zone(r.temp)} (${r.temp}°)')
      .toList();

  changes.forEach(print);
  // 09:00: entered cool (18.2°)
  // 09:10: entered warm (21.4°)
  // 09:20: entered cool (19.5°)
}
