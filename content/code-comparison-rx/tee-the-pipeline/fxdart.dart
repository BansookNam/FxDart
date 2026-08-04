import 'package:fxdart/fxdart.dart';

int sourceRuns = 0;

/// A side-effecting source — running it twice would double [sourceRuns].
Iterable<int> readings() sync* {
  sourceRuns++;
  yield* const [12, 7, 25, 3, 18, 9];
}

void main() {
  // tee advances BOTH reductions on the same element, so one pass feeds
  // them both and nothing is ever buffered.
  final (total, peak) = tee(
      readings(),
      (seed: 0, step: (int acc, int r) => acc + r),
      (seed: 0, step: (int acc, int r) => r > acc ? r : acc));

  print('total: $total');
  print('peak: $peak');
  print('source runs: $sourceRuns');
}
