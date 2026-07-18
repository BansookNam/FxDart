import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final delays = [300, 100, 200]; // item1 is slowest, item2 is fastest

  final sw = Stopwatch()..start();
  final results = await fx([1, 2, 3])
      .toAsync()
      .map((i) => delay(Duration(milliseconds: delays[i - 1]), 'item$i'))
      .concurrentPool(3)
      .toArray();

  print(results); // [item2, item3, item1] — completion order
  print('took ${sw.elapsedMilliseconds}ms'); // ~300ms (the slowest one)
}
