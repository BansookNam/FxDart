import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final (ok, failed) = await fx([1, 2, 3, 4, 5, 6])
      .toAsync()
      .map((a) => delay(const Duration(milliseconds: 100), a))
      .partition((a) => a % 3 == 0);

  print(ok); // [3, 6]
  print(failed); // [1, 2, 4, 5]
}
