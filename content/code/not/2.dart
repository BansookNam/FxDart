import 'package:fxdart/fxdart.dart';

void main() {
  final done = [true, false, false, true];

  // TODO: use `not` to build the "still pending" flags
  final pending = fx(done).map(not).toArray();

  print(pending); // [false, true, true, false]
}
