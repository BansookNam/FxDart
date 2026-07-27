import 'package:fxdart/fxdart.dart';

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
  final added = differenceBy((Tx t) => t.id, before, after);
  final removed = differenceBy((Tx t) => t.id, after, before);
  final common = intersectionBy((Tx t) => t.id, before, after);

  final diffLines = fx(added)
      .sortBy((t) => t.id)
      .map((t) => '+ ${fmt(t)}')
      .concat(fx(removed).sortBy((t) => t.id).map((t) => '- ${fmt(t)}'));

  final net = fx(after).sumBy((t) => t.amount) -
      fx(before).sumBy((t) => t.amount);
  final sign = net < 0 ? '-' : '+';

  print(join('\n', [
    'Ledger diff (${before.length} -> ${after.length} entries)',
    ...diffLines,
    '= ${fx(common).size()} unchanged entries',
    'Net change: $sign${money(net.abs())}',
  ]));
}
