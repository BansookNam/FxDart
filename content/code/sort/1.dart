import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // On the async chain, .sort(f) is already a terminal that returns
  // Future<List<T>> directly (no extra .toList() needed).
  final result = await fx([5, 2, 8, 1, 9])
      .toAsync()
      .map((a) => delay(const Duration(milliseconds: 100), a))
      .sort((a, b) => a.compareTo(b));

  print(result); // [1, 2, 5, 8, 9]
}
