import 'package:fxdart/fxdart.dart';

void main() {
  final numbers = [42, 7, 19, 3, 88, 25];

  // TODO: sort the numbers in DESCENDING order.
  final sorted = sort<int>((a, b) => a.compareTo(b), numbers);

  print(sorted);
}
