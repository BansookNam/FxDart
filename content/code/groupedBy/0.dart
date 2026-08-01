import 'package:fxdart/fxdart.dart';

void main() {
  final spending = [
    (cat: 'food', amount: 20),
    (cat: 'rent', amount: 900),
    (cat: 'food', amount: 30),
    (cat: 'fun', amount: 15),
    (cat: 'food', amount: 12),
  ];

  // groupBy would stop the chain at a Map. groupedBy keeps going:
  final ranked = fx(spending)
      .groupedBy((e) => e.cat) // Fx<({String key, List items})>
      .map((g) => (g.key, fx(g.items).sumBy((e) => e.amount)))
      .sortByDesc((c) => c.$2)
      .toList();

  print(ranked); // [(rent, 900), (food, 62), (fun, 15)]

  // Groups come out in first-seen key order, matching groupBy's map:
  for (final g in fx(spending).groupedBy((e) => e.cat)) {
    print('${g.key}: ${g.items.length} entries');
  }
  // food: 3 entries / rent: 1 entries / fun: 1 entries
}
