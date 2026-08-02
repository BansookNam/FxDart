import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final moves = makeMoves();
  await bench(
    slug: 'running-balance-feed',
    impl: 'fxdart',
    n: n,
    run: () {
      // scan1 folds without a separate seed — each partial sum IS the
      // balance, matching Rx's one-value-per-event pace.
      final balances = scan1((acc, move) => acc + move, moves).toList();
      return '${balances.length}|${balances.first}|${balances.last}';
    },
  );
}
