import 'package:fxdart/fxdart.dart';

void main() {
  // TODO: build a reusable reducer with reduceLazy that finds the max value.
  final findMax = reduceLazy<int, int>((acc, a) => acc, 0);

  print(findMax([4, 9, 2, 7]));
  print(findMax([1, 1, 1]));
}
