import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Each item takes a different amount of time — the 2nd item (100ms)
  // finishes before the 1st (300ms) — but concurrent(3) still hands back
  // results in *source* order, not completion order.
  final delays = [300, 100, 200];

  final sw = Stopwatch()..start();
  final result = await fx([1, 2, 3])
      .toAsync()
      .map((i) => delay(Duration(milliseconds: delays[i - 1]), 'item$i'))
      .concurrent(3)
      .toArray();

  print(result); // [item1, item2, item3] — source order, not completion order
  print('took ${sw.elapsedMilliseconds}ms'); // ~300ms (the slowest one)
}
