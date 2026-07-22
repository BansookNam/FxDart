import 'package:fxdart/fxdart.dart';

void main() {
  final ages = {'kim': 32, 'lee': 27, 'park': 41};

  print(toList(values(ages))); // [32, 27, 41]

  // Chain form + the Fx<num> numeric terminals:
  final oldest = fx(values(ages)).max();
  print(oldest); // 41
}
