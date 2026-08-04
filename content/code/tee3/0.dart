import 'package:fxdart/fxdart.dart';

void main() {
  var reads = 0;
  Iterable<int> sensor() sync* {
    for (final v in [12, 7, 25, 3, 18, 9]) {
      reads++;
      yield v;
    }
  }

  // Three folds, still one pass — sum, peak, and how many readings there were:
  final (total, peak, count) = tee3(
      sensor(),
      (seed: 0, step: (int a, int r) => a + r),
      (seed: 0, step: (int a, int r) => r > a ? r : a),
      (seed: 0, step: (int a, int _) => a + 1));

  print('total: $total'); // 74
  print('peak: $peak'); // 25
  print('count: $count'); // 6
  print('reads: $reads'); // 6 — one pass, three answers
}
