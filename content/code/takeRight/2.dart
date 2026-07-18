import 'package:fxdart/fxdart.dart';

void main() {
  final scores = [55, 61, 70, 82, 90, 95];

  // TODO: keep only the last 3 scores
  final recent = fx(scores).toArray();

  print(recent);
}
