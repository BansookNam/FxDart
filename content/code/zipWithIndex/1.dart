import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Async chain: .indexed() is a method — with parens.
  final result = await fx(['a', 'b', 'c'])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 50), a))
      .indexed()
      .toList();

  print(result); // [(0, a), (1, b), (2, c)]
}
