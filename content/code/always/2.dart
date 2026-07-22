import 'package:fxdart/fxdart.dart';

void main() {
  final scores = [55, 91, 68];

  // TODO: use `always` to replace every score with 'graded'
  final labels = fx(scores).map((s) => 'graded').toList();

  print(labels); // [graded, graded, graded]
}
