import 'package:fxdart/fxdart.dart';

void main() {
  var reads = 0;
  Iterable<int> sensor() sync* {
    for (final v in [10, 20, 30]) {
      reads++;
      yield v;
    }
  }

  final readings = sensor();

  // TODO: fork `readings` for each consumer so the sensor is only read once
  final total = readings.toList();
  final doubled = readings.toList();

  print(total);
  print(doubled);
  print('reads: $reads');
}
