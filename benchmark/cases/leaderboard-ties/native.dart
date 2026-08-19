import '../../harness.dart';
import 'data.dart';

/// The rank and score of a line are decided by the pipeline; the *name* at a
/// given position inside a 2000-deep tie group is decided by the sort's tie
/// order, and the two sides need not share one — fxdart's int-key `sortBy` is
/// stable, while `List.sort` is free to shuffle equal keys. Strip the name so
/// the checksum pins what both programs actually compute.
String tieSafe(String line) =>
    line.substring(0, line.indexOf(' ')) + line.substring(line.indexOf(' — '));

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
      return '${lines.length}|${tieSafe(lines.first)}|${tieSafe(lines.last)}';
    },
  );
}
