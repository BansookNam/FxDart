import 'package:fxdart/fxdart.dart';

class Player {
  final String name;
  final int score;
  const Player(this.name, this.score);
}

const players = [
  Player('Mina', 87),
  Player('Leo', 92),
  Player('Sofia', 75),
  Player('Anton', 87),
  Player('Bea', 60),
  Player('Kai', 75),
];

void main() {
  // Sort descending, group equal scores, then number the groups:
  // every player in group i gets rank i + 1 (dense ranking).
  final byScore = fx(players).sortBy((p) => -p.score).groupBy((p) => p.score);
  final lines = fx(entries(byScore))
      .zipWithIndex()
      .flatMap((g) {
        final (i, (score, group)) = g;
        return group.map((p) => '#${i + 1} ${p.name} — $score pts');
      })
      .toList();
  print(lines.join('\n'));
}
