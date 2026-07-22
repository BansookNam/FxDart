import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // The concurrency marker applies to iterable2 (the source of the
  // results) -- iterable1 (the exclusion set) is drained up front.
  final owned = toAsync([1, 2, 3]);
  final wishlist = fx([2, 3, 4, 5])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 100), a))
      .concurrent(4);

  final newItems = await fxAsync(differenceAsync(owned, wishlist)).toList();

  print(newItems); // [4, 5]
  print('took ${sw.elapsedMilliseconds}ms'); // ~100ms
}
