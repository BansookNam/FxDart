import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final expenses = [
    (item: 'rent', amount: 1200),
    (item: 'coffee', amount: 4),
    (item: 'laptop', amount: 1800),
    (item: 'train', amount: 90),
    (item: 'gym', amount: 45),
  ];

  // On the sync chain topBy is a step, so the chain keeps going:
  final top = fx(expenses)
      .topBy(2, (e) => e.amount)
      .map((e) => e.item)
      .toList();
  print(top); // [laptop, rent]

  // Any Comparable key works — here the cheapest by name:
  print(fx(expenses).bottomBy(1, (e) => e.item).toList());
  // [(amount: 4, item: coffee)]

  // The async chain ends there: it returns Future<List<T>>.
  final smallest = await fxAsync(fxToAsync(expenses))
      .bottomBy(2, (e) => e.amount);
  print(smallest.map((e) => e.item).toList()); // [coffee, gym]
}
