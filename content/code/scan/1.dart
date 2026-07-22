import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // Fetch each amount concurrently, then scan a running total. scan's own
  // accumulator runs serially (each step depends on the last), but that's
  // fine here since the slow part -- the fetch -- already ran concurrently.
  final runningTotals = await fx([10, 20, 30])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 100), a))
      .concurrent(3)
      .scan((acc, a) => acc + a, 0)
      .toList();

  print(runningTotals); // [0, 10, 30, 60]
  print('took ${sw.elapsedMilliseconds}ms'); // ~100ms
}
