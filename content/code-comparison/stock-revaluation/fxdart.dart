import 'package:fxdart/fxdart.dart';

class Stock {
  final String sku;
  final int qty;
  final double bookPrice;
  const Stock(this.sku, this.qty, this.bookPrice);
}

const stock = [
  Stock('KB-01', 12, 49.00),
  Stock('MS-77', 30, 19.50),
  Stock('HD-15', 8, 74.25),
  Stock('CB-02', 55, 4.80),
  Stock('MN-24', 6, 189.00),
  Stock('DK-31', 3, 320.00),
  Stock('WC-09', 21, 12.40),
];

int inFlight = 0;
int maxInFlight = 0;

/// The price service knows most SKUs — not all.
Future<double?> livePrice(String sku) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future.delayed(const Duration(milliseconds: 15));
  inFlight--;
  const prices = {
    'KB-01': 45.00, 'MS-77': 21.00, 'HD-15': 69.90,
    'CB-02': 5.10, 'MN-24': 175.00,
  };
  return prices[sku];
}

Future<void> main() async {
  final repriced = await fx(stock)
      .toAsync()
      .attach((s) => livePrice(s.sku))
      .concurrent(3)
      .map((r) => (qty: r.$1.qty, price: r.$2 ?? r.$1.bookPrice, fb: r.$2 == null))
      .toList();

  final total = fx(repriced).sumBy((r) => r.qty * r.price);
  final fallbacks = fx(repriced).countWhere((r) => r.fb);

  print('stock value: \$${total.toStringAsFixed(2)}');
  print('fallback prices used: $fallbacks');
  print('max lookups in flight: $maxInFlight');
}
