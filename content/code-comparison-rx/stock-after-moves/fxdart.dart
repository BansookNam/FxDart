import 'package:fxdart/fxdart.dart';

// Warehouse moves for SKU-1042 in August 2026: +receipts, -shipments.
const start = 20;
const moves = [40, -25, -50, 30, -20, -10, 45];

void main() {
  fx(moves)
      // scan emits the seed first, so the opening level is line one.
      .scan((acc, m) => (m < 0 ? '$m' : '+$m', acc.$2 + m), ('start', start))
      .map((e) =>
          e.$2 < 0 ? '${e.$1}: ${e.$2} (backorder)' : '${e.$1}: ${e.$2}')
      .toList()
      .forEach(print);
}
