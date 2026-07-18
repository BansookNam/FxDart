import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final allPassed = await fx([10, 20, 30])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 30), a))
      .every((a) => a >= 10);
  print(allPassed); // true

  final anyFailed = await everyAsync(
      (a) => delay(Duration(milliseconds: 30), a % 2 == 0),
      fx([2, 4, 5, 8]).toAsync());
  print(anyFailed); // false
}
