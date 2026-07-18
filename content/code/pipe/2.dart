import 'package:fxdart/fxdart.dart';

void main() {
  // TODO: pipe [10, 15, 20, 25] through a step that keeps values > 12, then
  // a step that sums them, using top-level `filter` and `sum`.
  final total = pipe([10, 15, 20, 25], [
    (Iterable<int> a) => filter((n) => n > 12, a),
    sum,
  ]);

  print(total); // 60
}
