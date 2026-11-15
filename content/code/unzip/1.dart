import 'package:fxdart/fxdart.dart';

/// Looks up a product's stock, slowly.
Future<int> stockOf(String sku) async {
  await Future.delayed(const Duration(milliseconds: 10));
  return {'pen': 40, 'mug': 0, 'lamp': 7}[sku] ?? 0;
}

void main() async {
  final skus = ['pen', 'mug', 'lamp'];

  // attach builds (sku, stock) pairs; unzip waits for them all
  // and splits them.
  final (names, counts) = await fx(skus)
      .toAsync()
      .attach(stockOf)
      .concurrent(3)
      .unzip();
  print(names); // [pen, mug, lamp]
  print(counts); // [40, 0, 7]
}
