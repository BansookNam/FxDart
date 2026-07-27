class Item {
  final String sku;
  final int qty;
  final double listPrice; // catalog fallback
  const Item(this.sku, this.qty, this.listPrice);
}

const items = [
  Item('SKU-100', 2, 9.99), Item('SKU-205', 1, 24.50),
  Item('SKU-317', 3, 4.25), Item('SKU-408', 1, 129.00),
  Item('SKU-512', 4, 2.80), Item('SKU-620', 2, 15.75),
];

int inFlight = 0;
int maxInFlight = 0;

/// The live pricing service; some SKUs are missing from it (null).
Future<double?> lookupPrice(String sku) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future.delayed(const Duration(milliseconds: 15));
  inFlight--;
  const live = {
    'SKU-100': 8.49, 'SKU-317': 3.99, 'SKU-408': 119.00, 'SKU-620': 14.20,
  };
  return live[sku];
}

/// Worker pool: [limit] workers share a cursor, results keep input order.
Future<List<(Item, double, bool)>> priceAll(List<Item> all, int limit) async {
  final results = List<(Item, double, bool)?>.filled(all.length, null);
  var next = 0;
  Future<void> worker() async {
    while (next < all.length) {
      final i = next++;
      final live = await lookupPrice(all[i].sku);
      results[i] = (all[i], live ?? all[i].listPrice, live == null);
    }
  }

  await Future.wait([for (var i = 0; i < limit; i++) worker()]);
  return results.cast<(Item, double, bool)>();
}

Future<void> main() async {
  final priced = await priceAll(items, 3);
  print('priced ${priced.length} items, 3 lookups at a time:');
  for (final (it, price, fellBack) in priced) {
    print('  ${it.sku} x${it.qty} @ \$${price.toStringAsFixed(2)}'
        '${fellBack ? ' (catalog fallback)' : ''}');
  }
  print('fallbacks used: ${priced.where((r) => r.$3).length}');
  final total = priced.fold(0.0, (sum, r) => sum + r.$2 * r.$1.qty);
  print('order total: \$${total.toStringAsFixed(2)}');
  print('max lookups in flight: $maxInFlight');
}
