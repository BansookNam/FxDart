import 'package:fxdart/fxdart.dart';

void main() {
  final steps = ['mix', 'bake'];

  // TODO: append 'cool' to the end of the steps
  final allSteps = fx(steps).toArray();

  print(allSteps);
}
