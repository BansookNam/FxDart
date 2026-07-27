class Player {
  final String name;
  final int score;
  const Player(this.name, this.score);
}

// Already sorted by score, highest first.
const leaderboard = [
  Player('Hana', 982),
  Player('Dan', 951),
  Player('Ava', 917),
  Player('Finn', 862),
  Player('Cara', 840),
  Player('Ben', 799),
];

void main() {
  // Dart 3's .indexed yields the same (index, element) records.
  final labels = leaderboard.indexed
      .map((e) => '${e.$1 + 1}. ${e.$2.name} (${e.$2.score} pts)')
      .toList();
  print(labels.join('\n'));
}
