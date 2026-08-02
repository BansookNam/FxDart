// Deterministic n-order batch shared verbatim by both sides.
// Each order holds two or three line items, as in the example.
import '../../harness.dart';

final n = caseN(1000000);

class Order {
  const Order(this.id, this.skus);
  final String id;
  final List<String> skus;
}

const _skuNames = [
  'tea', 'mug', 'pen', 'ink', 'pad', //
  'jar', 'lid', 'cup', 'box', 'tag',
];

List<Order> makeOrders() {
  final rng = Lcg(9);
  return List.generate(n, (i) {
    // Two or three line items — drawn from the high bits (see Lcg caution).
    final lineCount = rng.nextDouble() < 0.5 ? 2 : 3;
    final skus = List.generate(
      lineCount,
      (_) => '${_skuNames[rng.nextInt(_skuNames.length)]}'
          '-${(1 + rng.nextInt(99)).toString().padLeft(2, '0')}',
    );
    return Order('A-${101 + i}', skus);
  });
}
