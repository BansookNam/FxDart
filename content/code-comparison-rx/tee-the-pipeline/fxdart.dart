import 'package:fxdart/fxdart.dart';

int sourceRuns = 0;

/// A side-effecting source — running it twice would double [sourceRuns].
Iterable<int> readings() sync* {
  sourceRuns++;
  yield* const [12, 7, 25, 3, 18, 9];
}

void main() {
  // fork the SAME iterable object twice: both cursors share one buffered
  // pass over the source, in whatever order they happen to read.
  final shared = readings();
  final total = fx(fork(shared)).sum();
  final peak = fx(fork(shared)).max();

  print('total: $total');
  print('peak: $peak');
  print('source runs: $sourceRuns');
}
