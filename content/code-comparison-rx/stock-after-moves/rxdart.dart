import 'package:rxdart/rxdart.dart';

// Warehouse moves for SKU-1042 in August 2026: +receipts, -shipments.
const start = 20;
const moves = [40, -25, -50, 30, -20, -10, 45];

Future<void> main() async {
  final lines = await Stream.fromIterable(moves)
      .scan<(String, int)>(
          (acc, m, _) => (m < 0 ? '$m' : '+$m', acc.$2 + m), ('start', start))
      // scan's first emission is already the first fold — replay the
      // opening level with startWith.
      .startWith(('start', start))
      .map((e) =>
          e.$2 < 0 ? '${e.$1}: ${e.$2} (backorder)' : '${e.$1}: ${e.$2}')
      .toList();

  lines.forEach(print);
}
