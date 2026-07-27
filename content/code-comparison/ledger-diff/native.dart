import 'package:collection/collection.dart';

class Tx {
  final String id;
  final String desc;
  final double amount;
  const Tx(this.id, this.desc, this.amount);
}

const before = [
  Tx('t1', 'Rent July', 900.00),
  Tx('t2', 'Cafe Aroma', 12.50),
  Tx('t3', 'Metro card', 30.00),
  Tx('t4', 'Cinema', 15.00),
  Tx('t5', 'Green Grocer', 43.20),
];

const after = [
  Tx('t1', 'Rent July', 900.00),
  Tx('t2', 'Cafe Aroma', 12.50),
  Tx('t5', 'Green Grocer', 43.20),
  Tx('t6', 'Noodle Bar', 18.90),
  Tx('t7', 'Pharmacy', 22.40),
];

String money(num n) => '\$${n.toStringAsFixed(2)}';
String fmt(Tx t) => '${t.id} ${t.desc} ${money(t.amount)}';

void main() {
  final beforeIds = before.map((t) => t.id).toSet();
  final afterIds = after.map((t) => t.id).toSet();

  final added =
      after.where((t) => !beforeIds.contains(t.id)).sortedBy((t) => t.id);
  final removed =
      before.where((t) => !afterIds.contains(t.id)).sortedBy((t) => t.id);
  final commonCount = after.where((t) => beforeIds.contains(t.id)).length;

  final diffLines = [
    for (final t in added) '+ ${fmt(t)}',
    for (final t in removed) '- ${fmt(t)}',
  ];

  final net = after.fold(0.0, (s, t) => s + t.amount) -
      before.fold(0.0, (s, t) => s + t.amount);
  final sign = net < 0 ? '-' : '+';

  print([
    'Ledger diff (${before.length} -> ${after.length} entries)',
    ...diffLines,
    '= $commonCount unchanged entries',
    'Net change: $sign${money(net.abs())}',
  ].join('\n'));
}
