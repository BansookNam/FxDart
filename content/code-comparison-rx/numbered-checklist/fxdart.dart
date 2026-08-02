import 'package:fxdart/fxdart.dart';

// Setup steps for the new sensor kit, in order.
const steps = [
  'Unbox the sensor kit',
  'Charge the base station',
  'Pair the remote',
  'Mount the wall bracket',
  'Run the self-test',
  'Register the warranty',
];

void main() {
  // zipWithIndex pairs each element with its position: (index, value).
  final numbered =
      fx(steps).zipWithIndex().map((e) => '${e.$1 + 1}. ${e.$2}').toList();

  numbered.forEach(print);
}
