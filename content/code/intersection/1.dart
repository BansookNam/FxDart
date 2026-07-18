import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // The concurrency marker applies to iterable2, as with differenceAsync.
  final inStock = toAsync([2, 3, 4]);
  final wishlist = fx([1, 2, 4, 5])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 100), a))
      .concurrent(4);

  final available = await fxAsync(intersectionAsync(inStock, wishlist)).toArray();

  print(available); // [2, 4]
  print('took ${sw.elapsedMilliseconds}ms'); // ~100ms
}
