import 'package:fxdart/fxdart.dart';

void main() {
  final points = [(1.0, 2.0), (3.0, 5.0), (4.0, 1.5)];

  // TODO: these two maps walk the pairs twice. Replace them with
  // one call: final (xs, ys) = fxUnzip(points);
  final xs = points.map((p) => p.$1).toList();
  final ys = points.map((p) => p.$2).toList();

  print('x: $xs, y: $ys');
  // should print: x: [1.0, 3.0, 4.0], y: [2.0, 5.0, 1.5]
}
