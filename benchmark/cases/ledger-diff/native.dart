import 'package:collection/collection.dart';

import '../../harness.dart';
import 'data.dart';

String money(num n) => '\$${n.toStringAsFixed(2)}';
String fmt(Tx t) => '${t.id} ${t.desc} ${money(t.amount)}';

Future<void> main() async {
  final before = makeBefore();
  final after = makeAfter();
  await bench(
    slug: 'ledger-diff',
    impl: 'native',
    n: n,
    run: () {
      final beforeIds = before.map((t) => t.id).toSet();
      final afterIds = after.map((t) => t.id).toSet();

      final added = after
          .where((t) => !beforeIds.contains(t.id))
          .sortedBy((t) => t.id);
      final removed = before
          .where((t) => !afterIds.contains(t.id))
          .sortedBy((t) => t.id);
      final commonCount = after.where((t) => beforeIds.contains(t.id)).length;

      final diffLines = [
        for (final t in added) '+ ${fmt(t)}',
        for (final t in removed) '- ${fmt(t)}',
      ];

      final net =
          after.fold(0.0, (s, t) => s + t.amount) -
          before.fold(0.0, (s, t) => s + t.amount);
      final sign = net < 0 ? '-' : '+';

      return '${before.length} -> ${after.length}|${diffLines.length}|'
          '${diffLines.first}|${diffLines.last}|= $commonCount|'
          '$sign${money(net.abs())}';
    },
  );
}
