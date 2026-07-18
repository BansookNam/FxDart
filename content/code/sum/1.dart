import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // sumAsync / .toAsync().sum() pulls each delayed value then totals them.
  final total = await fx([1, 2, 3, 4])
      .toAsync()
      .map((a) => delay(const Duration(milliseconds: 100), a * a))
      .sum();

  print(total); // 30 (1 + 4 + 9 + 16)
}
