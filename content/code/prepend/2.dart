import 'package:fxdart/fxdart.dart';

void main() {
  final steps = ['bake', 'cool'];

  // TODO: prepend 'mix' to the front of the steps
  final allSteps = fx(steps).toList();

  print(allSteps);
}
