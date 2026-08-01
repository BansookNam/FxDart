import 'package:fxdart/fxdart.dart';

/// A price service that only knows some SKUs.
Future<double?> lookupPrice(String sku) async {
  await Future.delayed(const Duration(milliseconds: 10));
  return {'a': 9.99, 'c': 12.00}[sku];
}

void main() async {
  final items = [
    (sku: 'a', listPrice: 11.00),
    (sku: 'b', listPrice: 5.00),
    (sku: 'c', listPrice: 14.00),
  ];

  // attach keeps the item beside its (maybe missing) price; three lookups
  // run at a time because attachAsync is built on the parallel-safe map.
  final priced = await fx(items)
      .toAsync()
      .attach((it) => lookupPrice(it.sku))
      .concurrent(3)
      .map((r) => (
            sku: r.$1.sku,
            price: r.$2 ?? r.$1.listPrice, // fallback — the input is right there
            fallback: r.$2 == null,
          ))
      .toList();

  for (final p in priced) {
    print('${p.sku}: ${p.price}${p.fallback ? ' (list price)' : ''}');
  }
  // a: 9.99 / b: 5.0 (list price) / c: 12.0
}
