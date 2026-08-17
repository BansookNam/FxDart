import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final moves = makeMoves();
  await bench(
    slug: 'running-balance-feed',
    impl: 'rxdart',
    n: n,
    run: () async {
      final balances = await Stream.fromIterable(
        moves,
      ).scan<int>((acc, move, _) => acc + move, 0).toList();
      return '${balances.length}|${balances.first}|${balances.last}';
    },
  );
}
