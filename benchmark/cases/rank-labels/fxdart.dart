import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final leaderboard = makeLeaderboard();
  await bench(
    slug: 'rank-labels',
    impl: 'fxdart',
    n: n,
    run: () {
      final labels = fx(leaderboard)
          .zipWithIndex()
          .map((e) => '${e.$1 + 1}. ${e.$2.name} (${e.$2.score} pts)')
          .toList();
      return '${labels.length}|${labels.first}|${labels.last}';
    },
  );
}
