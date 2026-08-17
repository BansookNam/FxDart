import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'no-spend-streak',
    impl: 'fxdart',
    n: n,
    run: () {
      final spendDays = txns.map((t) => int.parse(t.date.substring(8))).toSet();
      final strip = fx(
        range(1, 32),
      ).map((day) => spendDays.contains(day) ? '·' : '#').join('');
      // scan carries the running streak: reset on a spend day, else +1.
      final longest = fx(range(1, 32))
          .map((day) => spendDays.contains(day))
          .scan((streak, spent) => spent ? 0 : streak + 1, 0)
          .max();
      return '$strip|$longest';
    },
  );
}
