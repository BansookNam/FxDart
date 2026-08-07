import 'package:fxdart/fxdart.dart';

void main() {
  final readings = [12, 30, 28, 31, 33, 35];

  // TODO: keep only the trailing run of readings at or above 30.
  final tail = fx(readings).takeWhileRight((a) => a >= 30).toList();

  print(tail); // [31, 33, 35]
}
