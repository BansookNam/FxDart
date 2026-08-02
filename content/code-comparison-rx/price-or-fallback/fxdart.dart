import 'package:fxdart/fxdart.dart';

/// August promo price book — looking up any other SKU throws.
const promoPrices = {'SKU-201': 11.50, 'SKU-204': 8.25, 'SKU-207': 19.90};

/// Purchase orders to quote: (order id, lines of sku + list price).
const orders = [
  (
    'PO-3391',
    [
      (sku: 'SKU-201', list: 14.00),
      (sku: 'SKU-333', list: 9.50),
      (sku: 'SKU-204', list: 9.75),
      (sku: 'SKU-207', list: 24.00),
      (sku: 'SKU-410', list: 5.20),
    ]
  ),
  ('PO-3402', <({String sku, double list})>[]),
];

Future<double> promoPrice(String sku) async {
  await Future<void>.delayed(const Duration(milliseconds: 5));
  final price = promoPrices[sku];
  if (price == null) throw StateError('no promo price for $sku');
  return price;
}

Future<void> main() async {
  for (final (id, lines) in orders) {
    print('$id:');
    final quotes = await fx(lines)
        .toAsync()
        // Recovery is plain control flow inside the callback: catch the
        // typed error right beside the call, return the fallback value.
        .map((line) async {
          try {
            final p = await promoPrice(line.sku);
            return '  ${line.sku}: ${p.toStringAsFixed(2)} (promo)';
          } on StateError {
            return '  ${line.sku}: ${line.list.toStringAsFixed(2)} (list)';
          }
        })
        .defaultIfEmpty('  (no lines to quote)')
        .toList();
    quotes.forEach(print);
  }
}
