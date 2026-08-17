import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final txns = makeTxns();
  await bench(
    slug: 'no-spend-streak',
    impl: 'native',
    n: n,
    run: () {
      final spendDays = txns.map((t) => int.parse(t.date.substring(8))).toSet();
      final strip = StringBuffer();
      var streak = 0;
      var longest = 0;
      for (var day = 1; day <= 31; day++) {
        final spent = spendDays.contains(day);
        strip.write(spent ? '·' : '#');
        streak = spent ? 0 : streak + 1;
        if (streak > longest) longest = streak;
      }
      return '$strip|$longest';
    },
  );
}
