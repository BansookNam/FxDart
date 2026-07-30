import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final players = makePlayers();
  await bench(
    slug: 'leaderboard-ties',
    impl: 'fxdart',
    n: n,
    run: () {
      // Sort descending, group equal scores, then number the groups:
      // every player in group i gets rank i + 1 (dense ranking).
      final byScore =
          fx(players).sortBy((p) => -p.score).groupBy((p) => p.score);
      final lines = fx(entries(byScore))
          .zipWithIndex()
          .flatMap((g) {
            final (i, (score, group)) = g;
            return group.map((p) => '#${i + 1} ${p.name} — $score pts');
          })
          .toList();
      return '${lines.length}|${lines.first}|${lines.last}';
    },
  );
}
