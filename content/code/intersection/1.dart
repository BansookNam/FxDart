import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // The concurrency marker applies to iterable2, as with differenceAsync.
  final inStock = fxToAsync([2, 3, 4]);
  final wishlist = fx([1, 2, 4, 5])
      .toAsync()
      .map((a) => fxDelay(Duration(milliseconds: 100), a))
      .concurrent(4);

  final available = await fxAsync(fxIntersectionAsync(inStock, wishlist)).toList();

  print(available); // [2, 4]
  print('took ${sw.elapsedMilliseconds}ms'); // ~100ms
}
