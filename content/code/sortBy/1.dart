import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Async chain: .sortBy(f) is a terminal returning Future<List<T>> directly.
  final ranked = await fx(['banana', 'fig', 'kiwi', 'apple'])
      .toAsync()
      .map((s) => delay(const Duration(milliseconds: 100), s))
      .sortBy((s) => s.length);

  print(ranked); // [fig, kiwi, apple, banana]
}
