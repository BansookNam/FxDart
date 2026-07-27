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
  final sorted = [...players]..sort((a, b) => b.score.compareTo(a.score));
  final lines = <String>[];
  var rank = 0;
  int? prevScore;
  for (final p in sorted) {
    if (p.score != prevScore) {
      rank++; // dense ranking: next distinct score takes the next rank
      prevScore = p.score;
    }
    lines.add('#$rank ${p.name} — ${p.score} pts');
  }
  print(lines.join('\n'));
}
