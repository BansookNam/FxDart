import 'package:fxdart/fxdart.dart';

void main() {
  final tanks = [
    (name: 'Reef', goldPerHour: 12.5, fish: 4),
    (name: 'Pond', goldPerHour: 7.25, fish: 3),
  ];

  // sumBy returns num, so a double field needs .toDouble() to be stored:
  final double viaSumBy = fx(tanks).sumBy((t) => t.goldPerHour).toDouble();

  // sumByDouble returns a double outright:
  final double perHour = fx(tanks).sumByDouble((t) => t.goldPerHour);

  // ...and sumByInt an int:
  final int fishCount = fx(tanks).sumByInt((t) => t.fish);

  print(viaSumBy); // 19.75
  print(perHour); // 19.75
  print(fishCount); // 7
}
