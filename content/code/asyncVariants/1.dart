import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final input = [1, 2, 3, 4, 5, 6];

  // Data-first: every step names its *Async twin explicitly.
  final dataFirst = await toListAsync(filterAsync(
      (a) async => a > 30, mapAsync((a) => a * 10, toAsync(input))));
  print(dataFirst); // [40, 50, 60]

  // Chain form: .toAsync() flips the chain into async mode once, then every
  // method keeps its plain name — map, filter, toList — no *Async suffix.
  final chained = await fx(input)
      .toAsync()
      .map((a) => a * 10)
      .filter((a) => a > 30)
      .toList();
  print(chained); // [40, 50, 60]

  print(dataFirst.toString() == chained.toString()); // true
}
