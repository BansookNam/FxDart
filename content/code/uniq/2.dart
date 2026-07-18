import 'package:fxdart/fxdart.dart';

void main() {
  final tags = ['red', 'blue', 'green', 'red', 'blue'];

  // TODO: use uniq to remove duplicate tags, preserving first-seen order.
  final result = fx(tags).toArray();

  print(result);
}
