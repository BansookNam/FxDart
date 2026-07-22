import 'package:fxdart/fxdart.dart';

void main() {
  final ages = {'kim': 32, 'lee': 27, 'park': 41};

  print(toList(keys(ages))); // [kim, lee, park]

  // Chain form:
  final loud = fx(keys(ages)).map((k) => k.toUpperCase()).toList();
  print(loud); // [KIM, LEE, PARK]
}
