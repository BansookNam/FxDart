import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final delays = [250, 50, 150]; // item2 is fastest, item1 is slowest

  // TODO: this pool size of 1 makes items run one at a time (in launch
  // order). Change it to 3 so all three race at once, and watch the
  // printed order switch to completion order.
  final poolSize = 1;

  final it = fx([1, 2, 3])
      .toAsync()
      .map((i) => delay(Duration(milliseconds: delays[i - 1]), 'item$i'))
      .concurrentPool(poolSize)
      .iterator;

  final sw = Stopwatch()..start();
  final results = await Future.wait([it.next(), it.next(), it.next()]);
  print(results.map((r) => r.value).toList()); // [item1, item2, item3]
  print('poolSize=$poolSize took ${sw.elapsedMilliseconds}ms'); // ~450ms
}
