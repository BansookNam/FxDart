import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

String money(num n) => '\$${n.toStringAsFixed(2)}';
String fmt(Tx t) => '${t.id} ${t.desc} ${money(t.amount)}';

Future<void> main() async {
  final before = makeBefore();
  final after = makeAfter();
  await bench(
    slug: 'ledger-diff',
    impl: 'fxdart',
    n: n,
    run: () {
      final added = differenceBy((Tx t) => t.id, before, after);
      final removed = differenceBy((Tx t) => t.id, after, before);
      final common = intersectionBy((Tx t) => t.id, before, after);

      final diffLines = fx(added)
          .sortBy((t) => t.id)
          .map((t) => '+ ${fmt(t)}')
          .concat(fx(removed).sortBy((t) => t.id).map((t) => '- ${fmt(t)}'))
          .toList();

      final net =
          fx(after).sumBy((t) => t.amount) - fx(before).sumBy((t) => t.amount);
      final sign = net < 0 ? '-' : '+';

      return '${before.length} -> ${after.length}|${diffLines.length}|'
          '${diffLines.first}|${diffLines.last}|= ${fx(common).size()}|'
          '$sign${money(net.abs())}';
    },
  );
}
