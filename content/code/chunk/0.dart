import 'package:fxdart/fxdart.dart';

void main() {
  // Last chunk may be shorter than `size`:
  print(chunk(3, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]));
  // ([1, 2, 3], [4, 5, 6], [7, 8, 9], [10])

  final result = fx([1, 2, 3, 4, 5]).chunk(2).toList();
  print(result); // [[1, 2], [3, 4], [5]]
}
