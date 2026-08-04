import 'package:fxdart/fxdart.dart';

void main() {
  var reads = 0;
  Iterable<int> sensor() sync* {
    for (final v in [12, 7, 25, 3, 18, 9]) {
      reads++;
      yield v;
    }
  }

  // Both reductions advance on the SAME element, so the sensor is read once
  // and nothing is buffered along the way:
  final (total, peak) = tee2(
      sensor(),
      (seed: 0, step: (int acc, int r) => acc + r),
      (seed: 0, step: (int acc, int r) => r > acc ? r : acc));

  print('total: $total'); // 74
  print('peak: $peak'); // 25
  print('reads: $reads'); // 6 — not 12
}
