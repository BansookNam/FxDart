import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // Fetch (the slow part) concurrently first, THEN flatten. flatMap itself
  // pulls its upstream serially, so put the concurrency in the async step
  // that produces each list, not inside flatMap's own callback.
  final userIds = [1, 2, 3];
  final orderIds = await fx(userIds)
      .toAsync()
      .map((id) => delay(Duration(milliseconds: 150), [id * 100, id * 100 + 1]))
      .concurrent(3)
      .flatMap((list) => list)
      .toArray();

  print(orderIds); // [100, 101, 200, 201, 300, 301]
  print('took ${sw.elapsedMilliseconds}ms'); // ~150ms, not ~450ms
}
