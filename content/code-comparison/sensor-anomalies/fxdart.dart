import 'package:fxdart/fxdart.dart';

// Two parallel lists, as a telemetry API often returns them.
const sensors = ['boiler-1', 'boiler-2', 'pump-a', 'pump-b', 'vent-3', 'vent-7'];
const readings = [71.2, 104.6, 66.0, 93.4, 38.9, 97.1]; // degrees C

const threshold = 90.0;

void main() {
  final alerts = fx(sensors)
      .zip(readings)
      .filter((r) => r.$2 > threshold)
      .map((r) => '${r.$1}: ${r.$2.toStringAsFixed(1)} °C');
  for (final line in alerts) {
    print(line);
  }
}
