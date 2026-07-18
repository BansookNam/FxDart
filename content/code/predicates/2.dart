import 'package:fxdart/fxdart.dart';

void main() {
  final row = <Object?>['id-1', 42, null, false];

  // TODO: use isNotNull to filter out the null from `row`
  final present = row;

  print(present);
}
