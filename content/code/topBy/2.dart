import 'package:fxdart/fxdart.dart';

void main() {
  final players = [
    (name: 'kim', points: 31),
    (name: 'lee', points: 48),
    (name: 'park', points: 27),
    (name: 'choi', points: 48),
    (name: 'jung', points: 12),
  ];

  // TODO: replace the sort-and-take with fxTopBy(3, ..., players).
  final podium = sortByDesc((p) => p.points, players).take(3);

  print(podium.map((p) => p.name).join(', '));
  // should print: lee, choi, kim
}
