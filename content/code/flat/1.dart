import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // Each fetch (concurrent) resolves to a small nested list; flat()
  // flattens the already-resolved, purely synchronous nesting.
  final result = await fx([1, 2, 3])
      .toAsync()
      .map((id) => delay(Duration(milliseconds: 100), [id, [id * 10]]))
      .concurrent(3)
      .flat()
      .toArray();

  print(result); // [1, [10], 2, [20], 3, [30]] -- dynamic, see Lecture
  print('took ${sw.elapsedMilliseconds}ms'); // ~100ms
}
