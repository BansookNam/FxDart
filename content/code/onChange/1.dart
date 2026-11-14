import 'package:fxdart/fxdart.dart';

void main() {
  // equals: decide what counts as "changed" — here, a 10% bucket.
  final progress = fxOnChange<double>(
    (p) => print('bar at ${(p * 100).round()}%'),
    equals: (a, b) => (a * 10).floor() == (b * 10).floor(),
  );
  for (final p in [0.0, 0.03, 0.08, 0.12, 0.19, 0.31]) {
    progress(p);
  }
  // bar at 0%, bar at 12%, bar at 31%

  // reset() forgets the last value, so the next call runs again.
  final log = print.fxOnChange();
  log('a');
  log('a');
  log.reset();
  log('a'); // printed twice in total
}
