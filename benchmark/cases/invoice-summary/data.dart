// Deterministic n-line-item order shared verbatim by both sides.
// Category cardinality scales with n (300 at the headline 1,000,000 —
// ~3333 lines per category) so the groupBy stays realistic at every scale.
import '../../harness.dart';

final n = caseN(1000000);
final numCategories = (n ~/ 3333).clamp(5, 300);

class Line {
  final String product;
  final String category;
  final int qty;
  final double unitPrice;
  const Line(this.product, this.category, this.qty, this.unitPrice);
}

final List<String> categories = List.generate(
  numCategories,
  (i) => 'Cat-${(i + 1).toString().padLeft(3, '0')}',
);

List<Line> makeItems() {
  final rng = Lcg(10);
  return List.generate(n, (i) {
    return Line(
      'SKU-$i',
      categories[rng.nextInt(numCategories)],
      1 + rng.nextInt(5),
      (100 + rng.nextInt(9900)) / 100,
    );
  });
}
