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
  // Worker pool: shared cursor, pre-sized slots so order survives.
  final repriced =
      List<({int qty, double price, bool fb})?>.filled(stock.length, null);
  var cursor = 0;
  Future<void> worker() async {
    while (cursor < stock.length) {
      final i = cursor++;
      final s = stock[i];
      final live = await livePrice(s.sku);
      repriced[i] = (qty: s.qty, price: live ?? s.bookPrice, fb: live == null);
    }
  }

  await Future.wait([worker(), worker(), worker()]);

  var total = 0.0;
  for (final r in repriced) {
    total += r!.qty * r.price;
  }
  final fallbacks = repriced.where((r) => r!.fb).length;

  print('stock value: \$${total.toStringAsFixed(2)}');
  print('fallback prices used: $fallbacks');
  print('max lookups in flight: $maxInFlight');
}
