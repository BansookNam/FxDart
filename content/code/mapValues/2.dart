import 'package:fxdart/fxdart.dart';

void main() {
  final scores = {'kim': 82, 'lee': 91, 'park': 77};

  // TODO: turn every score into a letter grade, keeping the names.
  final grades =
      mapValues((s) => s >= 90 ? 'A' : (s >= 80 ? 'B' : 'C'), scores);

  print(grades); // {kim: B, lee: A, park: C}
}
