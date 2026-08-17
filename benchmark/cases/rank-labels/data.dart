// Deterministic 1,000,000-player leaderboard shared verbatim by both sides.
// Already sorted by score, highest first (scores strictly decrease).
import '../../harness.dart';

final n = caseN(1000000);

class Player {
  final String name;
  final int score;
  const Player(this.name, this.score);
}

const _names = ['Hana', 'Dan', 'Ava', 'Finn', 'Cara', 'Ben', 'Gus', 'Elle'];

List<Player> makeLeaderboard() {
  final rng = Lcg(9);
  // Start at 10n (10,000,000 at the headline n): each step subtracts 1..9,
  // so scores are strictly decreasing AND stay positive at every BENCH_N.
  var score = n * 10;
  return List.generate(n, (i) {
    score -= 1 + rng.nextInt(9); // strictly decreasing
    return Player('${_names[rng.nextInt(_names.length)]}-$i', score);
  });
}
