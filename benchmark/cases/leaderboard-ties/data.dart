// Deterministic n-player roster shared verbatim by both sides.
// The score range scales with n so ties stay ~2000-way per rank (the point
// of the example: dense ranking over tied groups) — 500 distinct scores at
// the headline 1,000,000, clamped to 5 at small n so groups stay ~20+ deep.
// Deep tie groups also keep the checksum tie-safe: first/last land inside
// large groups that both sides order identically (same comparator outcome on
// the same input list).
import '../../harness.dart';

final n = caseN(1000000);
final scoreRange = (n ~/ 2000).clamp(5, 500);

class Player {
  final String name;
  final int score;
  const Player(this.name, this.score);
}

List<Player> makePlayers() {
  final rng = Lcg(9);
  return List.generate(n, (i) => Player('p$i', rng.nextInt(scoreRange)));
}
