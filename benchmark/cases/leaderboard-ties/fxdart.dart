import 'package:fxdart/fxdart.dart';

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
    impl: 'fxdart',
    n: n,
    run: () {
      // Sort descending, group equal scores, then number the groups:
      // every player in group i gets rank i + 1 (dense ranking).
      final byScore = fx(
        players,
      ).sortBy((p) => -p.score).groupBy((p) => p.score);
      final lines = fx(entries(byScore)).zipWithIndex().flatMap((g) {
        final (i, (score, group)) = g;
        return group.map((p) => '#${i + 1} ${p.name} — $score pts');
      }).toList();
      return '${lines.length}|${tieSafe(lines.first)}|${tieSafe(lines.last)}';
    },
  );
}
