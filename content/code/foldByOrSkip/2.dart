import 'package:fxdart/fxdart.dart';

void main() {
  final readings = [
    (sensor: 'boiler', ok: true, degrees: 71.0),
    (sensor: 'vent', ok: false, degrees: 18.0),
    (sensor: 'boiler', ok: true, degrees: 75.0),
    (sensor: 'pump', ok: true, degrees: 40.0),
    (sensor: 'vent', ok: true, degrees: 21.0),
  ];

  // TODO: the highest reading per sensor, counting only ok:true rows.
  // Hint: one callback — return the sensor when ok, null otherwise.
  // Remember the argument order: key, seed, fold, iterable.
  final hottest = foldByOrSkip(
    (r) => r.sensor, // ← almost: this folds the faulty reading in too.
    0.0,
    (double best, r) => r.degrees > best ? r.degrees : best,
    readings,
  );

  print(hottest);
  // Expected once solved:
  // {boiler: 75.0, pump: 40.0, vent: 21.0}
}
