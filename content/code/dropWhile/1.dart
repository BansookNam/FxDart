import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final result = await fx([1, 2, 3, 8, 4])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 50), a))
      .skipWhile((a) => a < 5) // FxTS alias: .dropWhile((a) => a < 5)
      .toList();

  print(result); // [8, 4]
}
