// Two parallel lists, as a telemetry API often returns them.
const sensors = ['boiler-1', 'boiler-2', 'pump-a', 'pump-b', 'vent-3', 'vent-7'];
const readings = [71.2, 104.6, 66.0, 93.4, 38.9, 97.1]; // degrees C

const threshold = 90.0;

void main() {
  // Core Dart has no zip — pairing parallel lists means indexing by hand.
  for (var i = 0; i < sensors.length; i++) {
    final value = readings[i];
    if (value > threshold) {
      print('${sensors[i]}: ${value.toStringAsFixed(1)} °C');
    }
  }
}
