import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // The concurrency marker applies to iterable2, as with intersectionAsync.
  final featured = toAsync([
    {'sku': 'A1'},
  ]);
  final catalog = fx([
    {'sku': 'A1', 'title': 'Keyboard'},
    {'sku': 'B2', 'title': 'Mouse'},
  ]).toAsync().map((p) => delay(Duration(milliseconds: 100), p)).concurrent(2);

  final featuredProducts = await fxAsync(
          intersectionByAsync((p) => p['sku'], featured, catalog))
      .toArray();

  print(featuredProducts); // [{sku: A1, title: Keyboard}]
  print('took ${sw.elapsedMilliseconds}ms'); // ~100ms
}
