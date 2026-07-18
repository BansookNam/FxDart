import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final letters =
      fx(['a', 'b', 'c']).toAsync().map((a) => delay(Duration(milliseconds: 50), a));
  final numbers =
      fx([1, 2, 3]).toAsync().map((a) => delay(Duration(milliseconds: 50), a));

  final result =
      await toArrayAsync(zipWithAsync((a, b) => '$a$b', letters, numbers));
  print(result); // [a1, b2, c3]
}
