import 'package:rxdart/rxdart.dart';

class Order {
  const Order(this.id, this.skus);
  final String id;
  final List<String> skus;
}

// Yesterday's orders — each holds two or three line items.
const orders = [
  Order('A-101', ['tea-01', 'mug-07']),
  Order('A-102', ['pen-11', 'ink-02', 'pad-05']),
  Order('A-103', ['mug-07', 'lid-04']),
  Order('A-104', ['tea-01', 'jar-03', 'lid-04']),
];

Future<void> main() async {
  // expand (core Stream API) flattens each order into its line records —
  // rxdart's flatMapIterable is for line lists that arrive as streams.
  final lines = await Stream.fromIterable(orders)
      .expand((o) => o.skus.map((sku) => (order: o.id, sku: sku)))
      .map((l) => '${l.order}/${l.sku}')
      .toList();

  lines.forEach(print);
  print('${lines.length} lines from ${orders.length} orders');
}
