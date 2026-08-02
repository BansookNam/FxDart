import 'package:fxdart/fxdart.dart';

// Five-day temperature forecast vs what the sensor actually measured.
const forecast = [21.0, 22.5, 23.0, 24.5, 22.0];
const actual = [20.6, 23.1, 23.0, 25.2, 21.4];

String line(double f, double a) {
  final d = a - f;
  final sign = d >= 0 ? '+' : '';
  return '${f.toStringAsFixed(1)} forecast vs ${a.toStringAsFixed(1)} '
      'actual ($sign${d.toStringAsFixed(1)})';
}

void main() {
  final days = fx(forecast)
      .zip(actual)
      .map((p) => line(p.$1, p.$2))
      .toList();

  for (var i = 0; i < days.length; i++) {
    print('day ${i + 1}: ${days[i]}');
  }
}
