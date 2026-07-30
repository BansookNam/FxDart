import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final players = makePlayers();
  await bench(
    slug: 'leaderboard-ties',
    impl: 'native',
    n: n,
    run: () {
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
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
