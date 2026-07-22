import 'package:fxdart/fxdart.dart';

void main() {
  final runners = ['ana', 'boo', 'cid'];

  // TODO: pair each runner with their (0-based) finishing position
  // Hint: .indexed is the inherited getter — no parens.
  final placements = fx(runners).toList();

  print(placements);
}
