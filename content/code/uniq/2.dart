import 'package:fxdart/fxdart.dart';

void main() {
  final tags = ['red', 'blue', 'green', 'red', 'blue'];

  // TODO: use distinct to remove duplicate tags, preserving first-seen order.
  final result = fx(tags).toList();

  print(result);
}
