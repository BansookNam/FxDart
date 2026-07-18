import 'package:fxdart/fxdart.dart';

void main() {
  final runners = ['ana', 'boo', 'cid'];

  // TODO: pair each runner with their (0-based) finishing position
  final placements = fx(runners).toArray();

  print(placements);
}
