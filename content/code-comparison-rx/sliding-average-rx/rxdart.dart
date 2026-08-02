import 'package:rxdart/rxdart.dart';

// Hourly temperature readings from one sensor.
const temps = [21.0, 21.6, 22.4, 23.1, 22.8, 22.2, 21.9, 21.4];

Future<void> main() async {
  final report = await Stream.fromIterable(temps)
      // The sliding window is spelled bufferCount(3, 1): buffers of 3,
      // starting a new buffer every 1 event. It also emits the ramp-down
      // partial ([21.9, 21.4]) — filter by length to keep full windows.
      .bufferCount(3, 1)
      .where((w) => w.length == 3)
      .map((w) {
        final avg = w.reduce((a, b) => a + b) / w.length;
        final values = w.map((t) => t.toStringAsFixed(1)).join(' ');
        return '$values -> avg ${avg.toStringAsFixed(1)}';
      })
      .toList();

  report.forEach(print);
}
