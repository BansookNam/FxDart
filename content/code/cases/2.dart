import 'package:fxdart/fxdart.dart';

void main() {
  final sizes = [3, 12, 40];

  // TODO: classify each size as small (<10), medium (<30), or large
  final label = cases<int, String>([
    ((n) => n < 10, (n) => 'small'),
    ((n) => n < 30, (n) => 'medium'),
  ], orElse: (n) => 'large');

  print(fx(sizes).map(label).toArray()); // [small, medium, large]
}
