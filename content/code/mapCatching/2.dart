import 'package:fxdart/fxdart.dart';

double readSensor(String id) =>
    id.startsWith('t') ? id.length * 1.5 : throw ArgumentError(id);

void main() {
  final sensors = ['t1', 'bad', 't22', 't3'];

  // TODO: replace the loop with
  // fx(sensors).mapCatching(readSensor, (e, st) => double.nan).toList()
  final readings = <double>[];
  for (final id in sensors) {
    try {
      readings.add(readSensor(id));
    } catch (_) {
      readings.add(double.nan);
    }
  }

  print(readings); // should print: [3.0, NaN, 4.5, 3.0]
}
