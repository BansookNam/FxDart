import 'package:fxdart/fxdart.dart';

// One boot cycle of a temperature probe — it reads low until it warms up.
const readings = [12.1, 15.8, 18.6, 21.4, 20.9, 18.7, 22.3, 23.0];
const threshold = 20.0;

void main() {
  // dropWhile drops only the LEADING low readings — once one reading
  // clears the threshold, later dips (18.7) are real data and stay.
  final live = fx(readings)
      .dropWhile((r) => r < threshold)
      .map((r) => 'Live: ${r.toStringAsFixed(1)} °C')
      .toList();

  live.forEach(print);
  print('Kept ${live.length} of ${readings.length} readings');
}
