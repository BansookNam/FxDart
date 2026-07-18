import 'package:fxdart/fxdart.dart';

void main() {
  final scores = {'kim': 88, 'lee': 42, 'park': 95};

  // TODO: use values() to compute the average score.
  final avg = fx(values(scores)).average();

  print(avg); // 75.0
}
