import 'package:rxdart/rxdart.dart';

int sourceRuns = 0;

/// A side-effecting source — running it twice would double [sourceRuns].
Stream<int> readings() async* {
  sourceRuns++;
  yield* Stream.fromIterable(const [12, 7, 25, 3, 18, 9]);
}

Future<void> main() async {
  // Make the stream connectable: attach BOTH readers first, then connect,
  // so one subscription to the source feeds two reductions.
  final shared = readings().publish();
  final total = shared.fold<int>(0, (acc, r) => acc + r);
  final peak = shared.reduce((a, b) => a > b ? a : b);
  shared.connect();

  print('total: ${await total}');
  print('peak: ${await peak}');
  print('source runs: $sourceRuns');
}
