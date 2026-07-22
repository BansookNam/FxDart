import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Async chain: .count() is a method — with parens — and still has to pull
  // every element to count them.
  final n = await fx(['a', 'bb', 'ccc', 'd'])
      .toAsync()
      .filter((s) => delay(const Duration(milliseconds: 100), s.length > 1))
      .count();

  print(n); // 2
}
