import 'package:fxdart/fxdart.dart';

// Hourly temperature readings from one sensor.
const temps = [21.0, 21.6, 22.4, 23.1, 22.8, 22.2, 21.9, 21.4];

void main() {
  final report = fx(temps)
      .windowed(3)
      .map((w) {
        final values = w.map((t) => t.toStringAsFixed(1)).join(' ');
        return '$values -> avg ${average(w).toStringAsFixed(1)}';
      })
      .toList();

  report.forEach(print);
}
