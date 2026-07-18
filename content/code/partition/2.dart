import 'package:fxdart/fxdart.dart';

void main() {
  final scores = [55, 82, 40, 91, 60, 38, 77];

  // TODO: partition the scores into PASS (>= 60) and FAIL (< 60).
  final (a, b) = fx(scores).partition((s) => s.isEven);

  print(a);
  print(b);
}
