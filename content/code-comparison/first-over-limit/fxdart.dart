import 'package:fxdart/fxdart.dart';

class Reading {
  final String time;
  final double celsius;
  const Reading(this.time, this.celsius);
}

const readings = [
  Reading('09:00', 61.2),
  Reading('09:10', 63.8),
  Reading('09:20', 68.4),
  Reading('09:30', 71.9),
  Reading('09:40', 76.3),
  Reading('09:50', 74.8),
  Reading('10:00', 79.1),
];

const limit = 75.0;

void main() {
  // head() is lazy-friendly: nothing past the first match is examined.
  final first = fx(readings).dropWhile((r) => r.celsius <= limit).head();
  print(first == null
      ? 'No reading over ${limit.toStringAsFixed(1)} C'
      : 'First over ${limit.toStringAsFixed(1)} C: '
          '${first.time} at ${first.celsius.toStringAsFixed(1)} C');
}
