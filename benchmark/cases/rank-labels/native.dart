import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final leaderboard = makeLeaderboard();
  await bench(
    slug: 'rank-labels',
    impl: 'native',
    n: n,
    run: () {
      // Dart 3's .indexed yields the same (index, element) records.
      final labels = leaderboard.indexed
          .map((e) => '${e.$1 + 1}. ${e.$2.name} (${e.$2.score} pts)')
          .toList();
      return '${labels.length}|${labels.first}|${labels.last}';
    },
  );
}
