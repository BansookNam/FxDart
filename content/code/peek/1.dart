import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // peekAsync is built directly on mapAsync, so concurrent(n) parallelizes
  // its side effect just like it does for map.
  final logged = <int>[];
  final result = await fx([1, 2, 3])
      .toAsync()
      .peek((a) async {
        await delay(Duration(milliseconds: 150), null);
        logged.add(a);
      })
      .concurrent(3)
      .toList();

  print(result); // [1, 2, 3]
  print(logged.length); // 3
  print('took ${sw.elapsedMilliseconds}ms'); // ~150ms with concurrency
}
